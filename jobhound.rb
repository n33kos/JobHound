#----------------Gems----------------
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

#-------------Modules----------------
require 'json'
require 'open-uri'
require 'openssl'
require 'yaml'

#------------Classes---------------
require './classes/ScrapeSource.rb'
require './classes/PositionListing.rb'

#------------Models---------------
require "./models/listings.rb";
require "./models/listings_status.rb";

#-------------Routes-----------------
require './models/routes.rb'

#------------Functions----------------
def generate_sources
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

#--------Launch JobHound-----------------
Launchy.open("http://localhost:4567")