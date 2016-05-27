require 'sqlite3'

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