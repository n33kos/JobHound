require 'sinatra'

get '/' do
  erb :home
end

get '/config' do
  erb :config
end

post '/config' do
	configFile = params[:config].gsub(/\n/,"")
	File.open("config", "w") {|file| file.print configFile }
	erb :config
end

get '/jobs' do
  $listings = get_all_listings "./sql/jobhound.sqlite", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
	  sleep(1)
	end
  erb :jobs, :locals => {:listings => $listings}
end

post '/jobs/scrape', :provides => :json do
	sources = generate_sources
	$listings = aggregate_listings sources
	save_listings "./sql/jobhound.sqlite", $listings
	$listings = get_all_listings "./sql/jobhound.sqlite", params[:orderby], params[:direction]

	while (!$listings.kind_of?(Array) and $listings != false)
	  sleep(1)
	end

	data = []
	$listings.each do |listing|
		if listing.date_posted.kind_of?(DateTime)
			date = DateTime.parse(listing.date_posted.to_s).strftime("%D")
		else
			date = "Unavailable"
		end

		data.push({
			"url" => listing.url,
			"title" => listing.title,
			"summary" => listing.summary,
			"employer" => listing.employer,
			"location" => listing.location,
			"source" => listing.source,
			"date_posted" => date,
			"viewed_bit" => listing.viewed_bit,
			"interested_bit" => listing.interested_bit,
			"dismissed_bit" => listing.dismissed_bit,
			"applied_bit" => listing.applied_bit,
			"followup_bit" => listing.followup_bit,
			"interviewed_bit" => listing.interviewed_bit
		})
	end
	halt 200, data.to_json
end

get '/interested' do
	$listings = get_status_listings "./sql/jobhound.sqlite", "interested_bit", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :interested, :locals => {:listings => $listings}
end

get '/dismissed' do
	$listings = get_status_listings "./sql/jobhound.sqlite", "dismissed_bit", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :dismissed, :locals => {:listings => $listings}
end

post '/listings/viewed', :provides => :json do
	puts params[:url]
	puts params[:set_value]
	status = save_status "./sql/jobhound.sqlite", params[:url], "viewed_bit", params[:set_value]
	halt 200, status.to_json
end

post '/listings/interested', :provides => :json do
	puts params[:url]
	puts params[:set_value]
	status = save_status "./sql/jobhound.sqlite", params[:url], "interested_bit", params[:set_value]
	halt 200, status.to_json
end

post '/listings/dismissed', :provides => :json do
	puts params[:url]
	puts params[:set_value]
	status = save_status "./sql/jobhound.sqlite", params[:url], "dismissed_bit", params[:set_value]
	halt 200, status.to_json
end

get '/shutdown' do
	Thread.new { sleep 1; Process.kill 'INT', Process.pid }
	halt 200
end