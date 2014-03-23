(function(){

	var mainMenu = $('#mainMenu'),
		wWidth = $(window).width(),
		wHeight = $(window).height();


	//Function to have the necessary height
	//for 5 squared buttons
	mainMenu.css({
		'height' : wWidth / 5,
		'top' : wHeight -  wWidth / 5
	});


})();