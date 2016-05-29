jQuery(document).ready(function($){
	
	//-------------------Scrape Button------------------
	$('.scrapeForm').on('submit',function (e) {
		$listings = $('.listings');
		$button = $('.scrapeButton');
		e.preventDefault();
		$listings.html("<div class='uil-ripple-css' style='transform:scale(0.6);'><div></div><div></div></div></div>");
		$button.html("Scraping Listings <i class=\"fa fa-ellipsis-h margin-left-5\"></i>");
		$.ajax({
		  url: '/jobs/scrape',
		  dataType: 'json',
		  contentType: 'application/json',
		  type: 'POST',
		  data : $('.scrapeForm').serialize(),
		  accepts: "application/json",
		  success: function(json) {
		  	$listings.hide().html("");
		  	$button.html("Scrape Listings <i class=\"fa fa-database margin-left-5\"></i> ("+json.length+")");
			$.each( json, function( key, value ) {
				
				listing_classes = value.status
				if (value.dismissed_bit != 1){
					dismissed_icon = "fa-minus-square"
					dismissed_value = "0"
				}else{
					dismissed_icon = "fa-plus-square";
					dismissed_value = "1"
					listing_classes += " dismissed"
				}

				if(value.viewed_bit == 1){
					listing_classes += " viewed"
				}

				$listings.append(
					'<div class="listing '+listing_classes+'">'
					+'<h4><a href="'+value.url+'" class="listing-title" target="_blank">'+value.title+'</a></h4>'
					+'<select class="status-dropdown" data-url="<%= listing.url %>">'
					+'<option>Select Status</option>'
					+'<option value="interested" '+(value.status == "interested" ? "selected=\"selected\"" : "")+'>Interested</option>'
					+'<option value="applied" '+(value.status == "applied" ? "selected=\"selected\"" : "")+'>Applied</option>'
					+'<option value="followup" '+(value.status == "followup" ? "selected=\"selected\"" : "")+'>Followed Up</option>'
					+'<option value="interviewed" '+(value.status == "interviewed" ? "selected=\"selected\"" : "")+'>Interviewed</option>'
					+'</select>'
					+'<a href="#" class="dismiss fa '+dismissed_icon+' font-20 no-underline" data-url="'+value.url+'" data-value="'+dismissed_value+'"></a>'
					+'<span class="date-posted">'+(value.date_posted || "Unavailable" )+'</span>'
					+'<div style="font-size:12px;color:green;">'+value.employer+' - '+value.location+'</div>'
					+'<div class="description">'+value.summary+'</div>'
					+'<span class="source"><a href="'+value.source+'" target="_blank" class="break-word">'+value.source+'</a></span>'
					+'</div>'
				);
			});
			$listings.fadeIn();
		  }
		});
	});

	//---------------------------Sort Dropdown---------------------------------
	$(document).on({
		click: function () {
			location = $(this).data("url-append");
		}
	}, '.sort-menu li');


	//---------------------------Status Dropdown---------------------------------
	$(document).on({
		change: function () {
			that = this
			data_url = $(this).data("url");
			data_value = $(this).val();
			$.ajax({
				url: '/listings/setstatus',
				type: 'POST',
				data: {url: data_url, set_value: data_value},
				accepts: "application/json",
				success: function(json) {
					if (json == 1){
						$(that).parents('.listing').addClass(data_value);
					}else{
						$(that).parents('.listing').addClass(data_value);
					}
				}
			});
		}
	}, '.status-dropdown');

	//---------------------------dismissed Button---------------------------------
	$(document).on({
		click: function (e) {
			e.preventDefault();
			that = this
			data_url = $(this).data("url");
			data_value = $(this).data("value");
			$.ajax({
				url: '/listings/dismissed',
				type: 'POST',
				data: {url: data_url, set_value: data_value},
				accepts: "application/json",
				success: function(json) {
					if (json == 1){
						$(that).data('value', 0).removeClass("fa-minus-square").addClass("fa-plus-square").parents('.listing').addClass("dismissed");
					}else{
						$(that).data('value', 1).removeClass("fa-plus-square").addClass("fa-minus-square").parents('.listing').removeClass("dismissed");
					}
				}
			});
		}
	}, '.dismiss');

	//---------------------------Viewed Toggle---------------------------------
	$(document).on({
		click: function () {
			that = this
			data_url = $(this).attr("href");
			$.ajax({
				url: '/listings/viewed',
				type: 'POST',
				data: {url: data_url, set_value: 1},
				accepts: "application/json",
				success: function(json) {
					if (json == 1){
						$(that).parents('.listing').addClass("viewed");
					}else{
						$(that).parents('.listing').removeClass("viewed");
					}
				}
			});
		}
	}, '.listing-title');
	
});