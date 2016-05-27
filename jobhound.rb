require "./posag_lite.rb";
require 'sinatra'
require 'launchy'
require 'json'

#-------------Routes-----------------
get '/' do
  erb :home
end

get '/config' do
  erb :config
end

post '/config' do
	configFile = params[:config]
	File.open("config", "w") {|file| file.print configFile }
	erb :config
end

get '/jobs' do
  $listings = get_all_listings "jobhound.sqlite", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
	  sleep(1)
	end
  erb :jobs, :locals => {:listings => $listings}
end

post '/jobs/scrape', :provides => :json do
	sources = define_sources
	$listings = aggregate_listings sources
	save_listings "jobhound.sqlite", $listings
	$listings = get_all_listings "jobhound.sqlite", params[:orderby], params[:direction]

	while (!$listings.kind_of?(Array) and $listings != false)
	  sleep(1)
	end

	data = []
	$listings.each do |listing|
		data.push({
			"url" => listing.url,
			"title" => listing.title,
			"summary" => listing.summary,
			"employer" => listing.employer,
			"location" => listing.location,
			"source" => listing.source,
			"date_posted" => listing.date_posted
		})
	end
	halt 200, data.to_json
end

get '/favorites' do
	$listings = get_favorite_listings "jobhound.sqlite", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :favorites, :locals => {:listings => $listings}
end

post '/favorites/save', :provides => :json do
	puts params[:url]
	puts params[:set_value]
	status = save_status "jobhound.sqlite", params[:url], "favorite_bit", params[:set_value]
	halt 200, status.to_json
end

get '/shutdown' do
	Thread.new { sleep 1; Process.kill 'INT', Process.pid }
	halt 200
end

#--------Launch JobHound-----------------
Launchy.open("http://localhost:4567")