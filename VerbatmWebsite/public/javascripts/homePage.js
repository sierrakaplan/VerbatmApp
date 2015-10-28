var images = [];
images[0] = "../images/bannerimage3.jpg";
images[1] = "../images/bannerimage5.jpg";
images[2] = "../images/bannerimage4.jpg";
images[3] = "../images/bannerimage8.jpg";
images[4] = "../images/bannerimage1.jpg";
images[5] = "../images/bannerimage6.jpg";
images[6] = "../images/bannerimage7.jpg";
// images[7] = "../images/bannerimage2.jpg";
// images[8] = "../images/bannerimage9.jpg";
// images[9] = "../images/bannerimage10.jpg";


var showBeta = true;

function addBackgroundPictures() {
	var animationDelay = 0;
	for(var i=0; i < images.length; i++) {
		var listItem = document.createElement("LI");
		var listImage = document.createElement("SPAN");
		listItem.appendChild(listImage);
		document.getElementById('banner_images').appendChild(listItem);
		// listItem.className = listItem.className + 'banner_media';
		listImage.id = 'banner_image' + i;
		var imageId = '#banner_image' + i;
		$(imageId).css('background-image', 'url(' + images[i] + ')');
		$(imageId).css('animation-delay', animationDelay + 's');
		animationDelay+=6;
	}
}

function resize() {
	var width = $(window).width();
	var height = $(window).height();
	if (height > width) {
		$('.banner_media').css('width', 'auto');
		$('.banner_media').css('height', height);
		// video.height = height;
		
		$('.banner_media').css('left', '0').css('top', 'auto');
		console.log("height > width");
	} else {
		// video.width = width;
		$('.banner_media').css('height', 'auto');
		$('.banner_media').css('width', width);
		$('.banner_media').css('top', '0').css('left', 'auto');
		console.log("width > height");
	}
}

function hideMenuWhileScrolling() {

	$('#beta_test_container').removeClass('beta_not_scrolling');
	$('#beta_test_container').addClass('beta_scrolling');

	if (jQuery.browser.mobile) { 
		$('#header').removeClass('menu_not_scrolling_mobile');
		$('#header').addClass('menu_scrolling_mobile');
	} else {
		$('#header').removeClass('menu_not_scrolling_desktop');
		$('#header').addClass('menu_scrolling_desktop');
	}
	

	clearTimeout($.data(this, 'scrollTimer'));
    $.data(this, 'scrollTimer', setTimeout(function() {
        if (jQuery.browser.mobile) { 
			$('#header').removeClass('menu_scrolling_mobile');
			$('#header').addClass('menu_not_scrolling_mobile');
		} else {
			$('#header').removeClass('menu_scrolling_desktop');
			$('#header').addClass('menu_not_scrolling_desktop');
		}
		$('#beta_test_container').removeClass('beta_scrolling');
		$('#beta_test_container').addClass('beta_not_scrolling');
        console.log("Haven't scrolled in 250ms!");
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
		console.log("mobile");
		$('#header').addClass('menu_not_scrolling_mobile');
		$('#header').addClass('header_mobile');
	} else {
		console.log("desktop");
		$('#header').addClass('menu_not_scrolling_desktop');
		$('#header').addClass('header_desktop');
	}
	// startBackgroundImageTimer();
	addBackgroundPictures();
	resize();
	
	$(window).resize(function () {
		if (!jQuery.browser.mobile) {
			resize();
		}
	});

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
		$('.menu_item').addClass('inactive_item');
		$(this).removeClass('inactive_item');
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
			console.log(res);
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