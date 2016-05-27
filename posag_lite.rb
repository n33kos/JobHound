require 'Nokogiri'
require 'open-uri'
require 'openssl'
require 'yaml'
require 'sqlite3'
require 'chronic'

#---------------Classes--------------
class ScrapeSource
	attr_accessor :base_url, :search_url, :listing_url_regex, :date_posted_regex, :entry_css_path, :url_css_path, :title_css_path, :summary_css_path, :desc_css_path, :employer_css_path, :location_css_path, :date_posted_css_path
	@base_url = ""
	@search_url = ""
	@listing_url_regex = []
	@date_posted_regex = []
	@entry_css_path = ""
	@url_css_path = ""
	@title_css_path = ""
	@summary_css_path = ""
	@desc_css_path = ""
	@employer_css_path = ""
	@location_css_path = ""
	@date_posted_css_path = ""
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
	@date_posted = DateTime.now
end

#------------Functions----------------
def define_sources
	sources = []
	yaml_sources = YAML.load_file("config")
	yaml_sources.each do |source|
		new_source = ScrapeSource.new
		new_source.base_url = source[1][:base_url].to_s
		new_source.search_url = source[1][:search_url].to_s
		new_source.listing_url_regex = source[1][:listing_url_regex]
		new_source.date_posted_regex = source[1][:date_posted_regex]
		new_source.entry_css_path = source[1][:entry_css_path].to_s
		new_source.url_css_path = source[1][:url_css_path].to_s
		new_source.title_css_path = source[1][:title_css_path].to_s
		new_source.summary_css_path = source[1][:summary_css_path].to_s
		new_source.desc_css_path = source[1][:desc_css_path].to_s
		new_source.employer_css_path = source[1][:employer_css_path].to_s
		new_source.location_css_path = source[1][:location_css_path].to_s
		new_source.date_posted_css_path = source[1][:date_posted_css_path].to_s
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
				source.listing_url_regex.each {|replacement| prep_url.gsub!(/#{replacement[1][:pattern]}/, replacement[1][:replace])}

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
					date_rough = extract.css(source.date_posted_css_path)[0].content
					if !source.date_posted_regex.nil?
						source.date_posted_regex.each {|replacement| date_rough.gsub!(/#{replacement[1][:pattern]}/, replacement[1][:replace])}
					end
					date_parsed = Chronic.parse(date_rough, :context => :past)
					listing.date_posted = date_parsed
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
		db = SQLite3::Database.open database_file

		listings.each do |listing|
			db.execute("INSERT OR REPLACE INTO listings (url, title, summary, desc, employer, location, source, date_posted, viewed_bit, favorite_bit, dismissed_bit, applied_bit, followup_bit, interviewed_bit)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [listing.url, listing.title, listing.summary, listing.desc, listing.employer, listing.location, listing.source, listing.date_posted.to_s])
		end
	else
		db = SQLite3::Database.new database_file
		rows = db.execute <<-SQL
		  create table listings (
			url varchar(255) PRIMARY KEY,
			title varchar(255),
			summary varchar(255),
			desc varchar(255),
			employer varchar(255),
			location varchar(255),
			source varchar(255),
			date_posted DATETIME,
			viewed_bit int(255),
			favorite_bit int(255),
			dismissed_bit int(255),
			applied_bit int(255),
			followup_bit int(255),
			interviewed_bit int(255)
		  );
		SQL

		listings.each do |listing|
			db.execute("INSERT OR REPLACE INTO listings (url, title, summary, desc, employer, location, source, date_posted, viewed_bit, favorite_bit, dismissed_bit, applied_bit, followup_bit, interviewed_bit) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [listing.url, listing.title, listing.summary, listing.desc, listing.employer, listing.location, listing.source, listing.date_posted.to_s])
		end

	end
	db.close
end

def save_status database_file, listing_url, status_column, status
	db = SQLite3::Database.open database_file
	if !status_column.nil?
		query = "UPDATE listings SET "+status_column+"=\""+status+"\" WHERE url = \""+listing_url+"\" "
		puts query
		db.execute(query)
	end
	db.close
	return status
end

def get_all_listings database_file, orderby, direction
	if File.file?(database_file)
		query = "select * from listings"
		if !orderby.nil?
			query += " order by "+orderby
		end
		if !direction.nil?
			query += " "+direction 
		end

		db = SQLite3::Database.open database_file
		listings = []
		db.execute( query ) do |row|
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
		db.close

		return listings
	else
		puts "Database "+database_file+" not found."
		return false
	end
end

def get_favorite_listings database_file, orderby, direction
	if File.file?(database_file)
		query = "select * from listings where favorite_bit = 1"
		if !orderby.nil?
			query += " order by "+orderby
		end
		if !direction.nil?
			query += " "+direction 
		end

		db = SQLite3::Database.open database_file
		listings = []
		db.execute( query ) do |row|
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
		db.close

		return listings
	else
		puts "Database "+database_file+" not found."
		return false
	end
end