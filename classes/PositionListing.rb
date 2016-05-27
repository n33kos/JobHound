class PositionListing
	attr_accessor :url, :title, :summary, :desc, :employer, :location, :source, :date_posted
	@url = ""
	@title = ""
	@summary = ""
	@desc = ""
	@employer = ""
	@location = ""
	@source = ""
	@date_posted = DateTime.now
end