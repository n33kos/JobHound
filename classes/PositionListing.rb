class PositionListing
	attr_accessor :url, :title, :summary, :desc, :employer, :location, :source, :date_posted, :viewed_bit, :interested_bit, :dismissed_bit, :applied_bit, :followup_bit, :interviewed_bit
	@url = ""
	@title = ""
	@summary = ""
	@desc = ""
	@employer = ""
	@location = ""
	@source = ""
	@date_posted = DateTime.now
	@viewed_bit = ""
	@interested_bit = ""
	@dismissed_bit = ""
	@applied_bit = ""
	@followup_bit = ""
	@interviewed_bit = ""
end