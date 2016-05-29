require 'sqlite3'

def save_status database_file, listing_url, status
	db = SQLite3::Database.open database_file
	if !status.nil?
		query = "UPDATE listings SET status=\""+status.to_s+"\" WHERE url = \""+listing_url.to_s+"\" "
		puts query
		db.execute(query)
	end
	db.close
	return status
end

def save_bit database_file, listing_url, status_column, status
	db = SQLite3::Database.open database_file
	if !status_column.nil?
		query = "UPDATE listings SET "+status_column.to_s+"=\""+status.to_s+"\" WHERE url = \""+listing_url.to_s+"\" "
		puts query
		db.execute(query)
	end
	db.close
	return status
end