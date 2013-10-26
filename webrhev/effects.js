function initTabs() {

	console.log("WOOOO HOOO I'VE BEEN CALLED");
	//initialize with all divs under #tabs hidden
	$('.left div').hide();
	$('.right div').hide();
	console.log("Hid the divs on either side");

	//enable the first content div and tab so they are showing
	$('.left div:first').show();
	$('.left ul li:first').addClass('active');
	console.log("Revealed the first left div, added active class to tab");

	$('.right div:first').show(function() {
			drawChart();
	});
	
	$('.right ul li:first').addClass('active');
	console.log("Revealed the first right dev, added active class to tab");

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



}