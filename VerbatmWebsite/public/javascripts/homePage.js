
var showBeta = true;

function hideMenuWhileScrolling() {

	$('#beta_test_container').removeClass('beta_not_scrolling');
	$('#beta_test_container').addClass('beta_scrolling');

	if (jQuery.browser.mobile) { 
		$('#menu_container').removeClass('menu_not_scrolling_mobile');
		$('#menu_container').addClass('menu_scrolling_mobile');
	} else {
		$('#menu_container').removeClass('menu_not_scrolling_desktop');
		$('#menu_container').addClass('menu_scrolling_desktop');
	}
	

	clearTimeout($.data(this, 'scrollTimer'));
    $.data(this, 'scrollTimer', setTimeout(function() {
        if (jQuery.browser.mobile) { 
			$('#menu_container').removeClass('menu_scrolling_mobile');
			$('#menu_container').addClass('menu_not_scrolling_mobile');
		} else {
			$('#menu_container').removeClass('menu_scrolling_desktop');
			$('#menu_container').addClass('menu_not_scrolling_desktop');
		}
		$('#beta_test_container').removeClass('beta_scrolling');
		$('#beta_test_container').addClass('beta_not_scrolling');
    }, 500));
}

function readMoreAboutUs(readMore) {
	if(readMore) {
		$('#read_more').hide();
		$('#about_us_container').show();
		$('#read_less').show();
	} else {
		$('#read_less').hide();
		$('#about_us_container').hide();
		$('#read_more').show();
	}
}

$(document).ready(function() {

	if (jQuery.browser.mobile) { 
		$('#menu_container').addClass('menu_not_scrolling_mobile');
		$('#menu_container').addClass('header_mobile');
	} else {
		$('#menu_container').addClass('menu_not_scrolling_desktop');
		$('#menu_container').addClass('header_desktop');
	}

	$('#beta_nav').on('click', function(event) {
		$('#beta_test_container').hide();
	});

	$('.menu_item').on('click', function(event) {
		$('#beta_test_container').show();
	});

	$(window).scroll(function(event) {
		hideMenuWhileScrolling();
		$('.team_member_description').hide();
		// readMoreAboutUs(false);
	});

	$('.section_link').on('click', function(event) {
		event.preventDefault();
		var target = this.hash;
		var $target = $(target);
		$target.animatescroll({scrollSpeed:1500});
		$('.menu_item').removeClass('active_item');
		$(this).addClass('active_item');
	});

	$('#about_us_container').hide();
	$('#read_less').hide();

	$('#read_more').click(function() {
		readMoreAboutUs(true);
	});

	$('#read_less').click(function() {
		readMoreAboutUs(false);
	});

	//hide the team description
  	$(".team_member_description").hide();
  	var shownDescription;
  	//toggle the componenet with class msg_body
  	$(".team_member_picture").click(function() {
  		if (shownDescription) shownDescription.hide();
   		description = $(this).parent('div').find($('.team_member_description'));
   		if (description.is(shownDescription)) {
   			shownDescription = null;
   		} else {
   			shownDescription = description;
   			shownDescription.show();
   		}
  	});

	$('#submit_beta_email_request').on('click', function() {
		$.post('/email?email=' + $("#input_email")[0].value, function(res) {
			// window.confirm(res);
		});
		$('#thankyou_section').animatescroll({scrollSpeed:1500});
		$("#input_email").val('');
	});

	$("#input_email").keypress(function(e) {
		var keycode = (e.keyCode ? e.keyCode : e.which);
        if (keycode == '13') { //enter key
			e.preventDefault();
			$('#submit_beta_email_request').click();
		}
	});
});