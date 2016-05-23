require 'sinatra'
require 'launchy'

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
  erb :jobs, :locals => {:listings => $listings}
end

post '/jobs/scrape', :provides => :json do
	load "./posag_lite.rb";
	while (!$listings.kind_of?(Array))
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

get '/shutdown' do
	Thread.new { sleep 1; Process.kill 'INT', Process.pid }
	halt 200
end

#--------Launch JobHound-----------------
Launchy.open("http://localhost:4567")