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
				
				interested_append = "";
				interested_value = "1"
				if (value.interested_bit != 1){
					interested_append = "-o"
					interested_value = "0"
				}

				dismissed_append = "";
				dismissed_value = "1"
				if (value.dismissed_bit != 1){
					dismissed_append = "-o"
					dismissed_value = "0"
				}

				$listings.append(
					'<div class="listing">'
					+'<h4><a href="'+value.url+'" class="listing-title" target="_blank">'+value.title+'</a>'
					+'<a href="#" class="dismiss fa fa-times-circle'+dismissed_append+' font-20 no-underline" data-url="'+value.url+'" data-value="'+dismissed_value+'"></a></h4>'
					+'<a href="#" class="interested fa fa-star'+interested_append+' font-20 no-underline" data-url="'+value.url+'" data-value="'+interested_value+'"></a></h4>'
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

	//---------------------------interested Button---------------------------------
	$(document).on({
		click: function (e) {
			e.preventDefault();
			that = this
			data_url = $(this).data("url");
			data_value = $(this).data("value");
			$.ajax({
				url: '/listings/interested',
				type: 'POST',
				data: {url: data_url, set_value: data_value},
				accepts: "application/json",
				success: function(json) {
					console.log(json)
					if (json == 1){
						$(that).data('value', 0).removeClass("fa-star-o").addClass("fa-star");
					}else{
						$(that).data('value', 1).removeClass("fa-star").addClass("fa-star-o");
					}
				}
			});
		}
	}, '.interested');

	//---------------------------interested Button---------------------------------
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
					console.log(json)
					if (json == 1){
						$(that).data('value', 0).removeClass("fa-times-circle-o").addClass("fa-times-circle").parents('.listing').addClass("dismissed");
					}else{
						$(that).data('value', 1).removeClass("fa-times-circle").addClass("fa-times-circle-o").parents('.listing').removeClass("dismissed");
					}
				}
			});
		}
	}, '.dismiss');

	//---------------------------Viewed Toggle---------------------------------
	/*
	$(document).on({
		click: function (e) {
			e.preventDefault();
			that = this
			data_url = $(this).attr("href");
			data_value = 1;
			$.ajax({
				url: '/listings/viewed',
				type: 'POST',
				data: {url: data_url, set_value: data_value},
				accepts: "application/json",
				success: function(json) {
					console.log(json)
					if (json == 1){
						$(that).data('value', 0).removeClass("fa-star-o").addClass("fa-star");
					}else{
						$(that).data('value', 1).removeClass("fa-star").addClass("fa-star-o");
					}
				}
			});
		}
	}, '.listing-title');
	*/
});