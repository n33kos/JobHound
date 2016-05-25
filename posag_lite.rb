require 'Nokogiri'
require 'open-uri'
require 'openssl'
require 'yaml'
require 'sqlite3'

#---------------Classes--------------
class ScrapeSource
	attr_accessor :base_url, :search_url, :entry_css_path, :url_css_path, :title_css_path, :summary_css_path, :desc_css_path, :employer_css_path, :location_css_path, :date_posted_css_path, :ignore_after_regex
	@base_url = ""
	@search_url = ""
	@entry_css_path = ""
	@url_css_path = ""
	@title_css_path = ""
	@summary_css_path = ""
	@desc_css_path = ""
	@employer_css_path = ""
	@location_css_path = ""
	@date_posted_css_path = ""
	@ignore_after_regex = ""
end

class PositionListing
	attr_accessor :url, :title, :summary, :desc, :employer, :location, :source, :date_posted
	@url = ""
	@title = ""
	@summary = ""
	@desc = ""
	@employer = ""
	@location = ""
	@source = ""
	@date_posted = ""
end

#------------Functions----------------
def define_sources
	sources = []
	yaml_sources = YAML.load_file("config")
	yaml_sources.each do |source|
		new_source = ScrapeSource.new
		new_source.base_url = source[1][:base_url].to_s
		new_source.search_url = source[1][:search_url].to_s
		new_source.entry_css_path = source[1][:entry_css_path].to_s
		new_source.url_css_path = source[1][:url_css_path].to_s
		new_source.title_css_path = source[1][:title_css_path].to_s
		new_source.summary_css_path = source[1][:summary_css_path].to_s
		new_source.desc_css_path = source[1][:desc_css_path].to_s
		new_source.employer_css_path = source[1][:employer_css_path].to_s
		new_source.location_css_path = source[1][:location_css_path].to_s
		new_source.date_posted_css_path = source[1][:date_posted_css_path].to_s
		new_source.ignore_after_regex = source[1][:ignore_after_regex].to_s
		sources.push(new_source)
	end
	return sources
end

#initialize constant for ssl connections
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE 
def aggregate_listings sources
	listings = []
	sources.each do |source|
		#Parse Page
		page = Nokogiri::HTML(open(source.search_url))
		puts "\n-------------Reading Listings From "+source.base_url+"--------------"
		#for each identified entry
		page.css(source.entry_css_path).each do |extract|
			#init new PositionListing object
			listing = PositionListing.new
			begin
				#Process and add URL to listing object
				prep_url = extract.css(source.url_css_path)[0]['href'].to_s
				prep_url = prep_url.sub /#{source.ignore_after_regex}/, ''

				if prep_url.include? "//"
					url = prep_url
				else
					if prep_url.include? source.base_url
						url = prep_url
					else
						url = source.base_url+prep_url
					end
				end
				listing.url = url

				#Search for other data points and add them to listing object
				if !source.search_url.empty?
					listing.source = source.search_url
				end
				if !source.title_css_path.empty?
					listing.title = extract.css(source.title_css_path)[0].content
				end
				if !source.summary_css_path.empty?
					listing.summary = extract.css(source.summary_css_path)[0].content
				end
				if !source.employer_css_path.empty?
					listing.employer = extract.css(source.employer_css_path)[0].content
				end
				if !source.location_css_path.empty?
					listing.location = extract.css(source.location_css_path)[0].content
				end
				if !source.date_posted_css_path.empty?
					listing.date_posted = extract.css(source.date_posted_css_path)[0].content
				end

				#Add listing to listings array
				if url.include? source.base_url
					listings.push(listing)
				end
				print "."
				#sleep 1
			rescue
				print "x"
			end
		end
	end
	puts "\nAggregated "+listings.length.to_s+" Listings."
	return listings
end

def save_listings database_file, listings
	if File.file?(database_file)
		listing_db = SQLite3::Database.open database_file

		listings.each do |listing|
			listing_db.execute("REPLACE INTO listings (url, title, summary, desc, employer, location, source, date_posted) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [listing.url, listing.title, listing.summary, listing.desc, listing.employer, listing.location, listing.source, listing.date_posted])
		end

	else
		listing_db = SQLite3::Database.new database_file
		rows = listing_db.execute <<-SQL
		  create table listings (
			url varchar(255) PRIMARY KEY,
			title varchar(255),
			summary varchar(255),
			desc varchar(255),
			employer varchar(255),
			location varchar(255),
			source varchar(255),
			date_posted varchar(255)
		  );
		SQL

		listings.each do |listing|
			listing_db.execute("REPLACE INTO listings (url, title, summary, desc, employer, location, source, date_posted) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [listing.url, listing.title, listing.summary, listing.desc, listing.employer, listing.location, listing.source, listing.date_posted])
		end

	end
	listing_db.close
end

def get_all_listings database_file
	if File.file?(database_file)
		listing_db = SQLite3::Database.open database_file

		listings = []
		listing_db.execute( "select * from listings" ) do |row|
			listing = PositionListing.new
			listing.url = row[0]
			listing.title = row[1]
			listing.summary = row[2]
			listing.desc = row[3]
			listing.employer = row[4]
			listing.location = row[5]
			listing.source = row[6]
			listing.date_posted = row[7]
			listings.push(listing)
		end
		listing_db.close

		return listings
	else
		puts "Database "+database_file+" not found."
		return false
	end
end