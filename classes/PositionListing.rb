class PositionListing
	attr_accessor :url, :title, :summary, :desc, :employer, :location, :source, :date_posted, :viewed_bit, :dismissed_bit, :status
	@url = ""
	@title = ""
	@summary = ""
	@desc = ""
	@employer = ""
	@location = ""
	@source = ""
	@date_posted = DateTime.now
	@viewed_bit = ""
	@dismissed_bit = ""
	@status = ""
end