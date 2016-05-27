class ScrapeSource
	attr_accessor :base_url, :search_url, :listing_url_regex, :date_posted_regex, :entry_css_path, :url_css_path, :title_css_path, :summary_css_path, :desc_css_path, :employer_css_path, :location_css_path, :date_posted_css_path
	@base_url = ""
	@search_url = ""
	@listing_url_regex = []
	@date_posted_regex = []
	@entry_css_path = ""
	@url_css_path = ""
	@title_css_path = ""
	@summary_css_path = ""
	@desc_css_path = ""
	@employer_css_path = ""
	@location_css_path = ""
	@date_posted_css_path = ""
end