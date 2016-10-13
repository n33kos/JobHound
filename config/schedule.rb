#whenever gem
# 1.minute 1.day 1.week 1.month 1.year
# run "$whenever --update-crontab" in base jobhound directory after saving modifications
every 6.hours do 
	command "ruby /home/pi/dev/JobHound/jobhound.rb -scrape"
end

