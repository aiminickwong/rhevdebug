$(document).ready(function() {

	//initialize with all divs under #tabs hidden
	$('.left div').hide();
	$('.right div').hide();

	//enable the first content div and tab so they are showing
	$('.left div:first').show();
	$('.left ul li:first').addClass('active');

	$('.right div:first').show();
	$('.right ul li:first').addClass('active');

	//loop for reacting to tab clicks
	$('.left ul li a').click(function(){
		$('.left ul li').removeClass('active');
		$(this).parent().addClass('active');
		var currentTab = $(this).attr('href');
		$('.left div').hide();
		$(currentTab).show();
		return false;
	});

	$('.right ul li a').click(function(){
		$('.right ul li').removeClass('active');
		$(this).parent().addClass('active');
		var currentTab = $(this).attr('href');
		$('.right div').hide();
		$(currentTab).show();
		return false;
	});



});