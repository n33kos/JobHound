relative_path = File.expand_path(File.join(File.dirname(__FILE__)))
if ARGV[0] == "-scrape"
	#----------------Gems----------------
	require 'nokogiri'
	require 'sqlite3'
	require 'chronic'
	require 'whenever'

	#-------------Modules----------------
	require 'json'
	require 'open-uri'
	require 'openssl'
	require 'yaml'

	#------------Classes---------------
	require relative_path+'/classes/ScrapeSource.rb'
	require relative_path+'/classes/PositionListing.rb'

	#------------Models---------------
	require relative_path+"/models/listings.rb";
	require relative_path+"/models/listings_status.rb";

	#------------Functions----------------
	require relative_path+'/models/scrapers.rb'

	sources = generate_sources
	$listings = aggregate_listings sources
	save_listings relative_path+"/sql/jobhound.sqlite", $listings
	remove_duplicate_entries relative_path+"/sql/jobhound.sqlite"
else
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
	require relative_path+'/classes/ScrapeSource.rb'
	require relative_path+'/classes/PositionListing.rb'

	#------------Models---------------
	require relative_path+"/models/listings.rb";
	require relative_path+"/models/listings_status.rb";

	#-------------Routes-----------------
	require relative_path+'/models/routes.rb'

	#------------Functions----------------
	require relative_path+'/models/scrapers.rb'
end
