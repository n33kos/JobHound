require 'sqlite3'

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