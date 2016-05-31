require 'sqlite3'

def save_listings database_file, listings
	if File.file?(database_file)
		db = SQLite3::Database.open database_file

		listings.each do |listing|
			result = db.execute("select url from listings where url = \""+listing.url+"\"")
			if result.length == 0
				db.execute("INSERT INTO listings (url, title, summary, desc, employer, location, source, date_posted)
	            VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
	            [listing.url, listing.title, listing.summary, listing.desc, listing.employer, listing.location, listing.source, listing.date_posted.to_s])
			end
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
			dismissed_bit int(255),
			status varchar (255)
		  );
		SQL

		listings.each do |listing|
			db.execute("INSERT INTO listings (url, title, summary, desc, employer, location, source, date_posted)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
            [listing.url, listing.title, listing.summary, listing.desc, listing.employer, listing.location, listing.source, listing.date_posted.to_s])
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
			if !row[7].empty?
				listing.date_posted = DateTime.parse(row[7].to_s)
			end
			listing.viewed_bit = row[8]
			listing.dismissed_bit = row[9]
			listing.status = row[10]
			listings.push(listing)
		end
		db.close

		return listings
	else
		puts "Database "+database_file+" not found."
		return false
	end
end

def get_listings_by_status database_file, status_column, orderby, direction
	if File.file?(database_file)
		query = "select * from listings where status = \""+status_column+"\""
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
			if !row[7].empty?
				listing.date_posted = DateTime.parse(row[7].to_s)
			end
			listing.viewed_bit = row[8]
			listing.dismissed_bit = row[9]
			listing.status = row[10]
			listings.push(listing)
		end
		db.close

		return listings
	else
		puts "Database "+database_file+" not found."
		return false
	end
end


def get_listings_by_bit database_file, status_column, orderby, direction
	if File.file?(database_file)
		query = "select * from listings where "+status_column+" = 1"
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
			if !row[7].empty?
				listing.date_posted = DateTime.parse(row[7].to_s)
			end
			listing.viewed_bit = row[8]
			listing.dismissed_bit = row[9]
			listing.status = row[10]
			listings.push(listing)
		end
		db.close

		return listings
	else
		puts "Database "+database_file+" not found."
		return false
	end
end