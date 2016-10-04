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
			"dismissed_bit" => listing.dismissed_bit,
			"status" => listing.status
		})
	end

	puts "----------Removing Duplicate Entries-----------"
	remove_duplicate_entries "./sql/jobhound.sqlite"

	halt 200, data.to_json
end

get '/interested' do
	$listings = get_listings_by_status "./sql/jobhound.sqlite", "interested", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :interested, :locals => {:listings => $listings}
end

get '/applied' do
	$listings = get_listings_by_status "./sql/jobhound.sqlite", "applied", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :applied, :locals => {:listings => $listings}
end

get '/followup' do
	$listings = get_listings_by_status "./sql/jobhound.sqlite", "followup", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :followup, :locals => {:listings => $listings}
end

get '/interviewed' do
	$listings = get_listings_by_status "./sql/jobhound.sqlite", "interviewed", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :interviewed, :locals => {:listings => $listings}
end

get '/dismissed' do
	$listings = get_listings_by_bit "./sql/jobhound.sqlite", "dismissed_bit", params[:orderby], params[:direction]
	while (!$listings.kind_of?(Array) and $listings != false)
		sleep(1)
	end
	erb :dismissed, :locals => {:listings => $listings}
end

post '/listings/setstatus', :provides => :json do
	status = save_status "./sql/jobhound.sqlite", params[:url], params[:set_value]
	halt 200, status.to_json
end

post '/listings/dismissed', :provides => :json do
	status = save_bit "./sql/jobhound.sqlite", params[:url], "dismissed_bit", params[:set_value]
	halt 200, status.to_json
end

post '/listings/viewed', :provides => :json do
	status = save_bit "./sql/jobhound.sqlite", params[:url], "viewed_bit", params[:set_value]
	halt 200, status.to_json
end

get '/shutdown' do
	Thread.new { sleep 1; Process.kill 'INT', Process.pid }
	halt 200
end