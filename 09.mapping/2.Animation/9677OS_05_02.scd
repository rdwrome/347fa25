( // rotating windmills
var window, userView, windmills; // decalaring variables
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_05_windmill_factory.scd").loadPaths; // first load the windmill factory
windmills = [ // an array with three windmills
	~windmillFactory.(100@100,80),
	~windmillFactory.(300@100,80),
	~windmillFactory.(500@100,80)
];
window = Window("animation and mouse interaction", 600@200).front;
userView = UserView(window, 600@200).background_(Color.white).animate_(true).frameRate_(60).drawFunc_({ // setup UserView and callback func
	var speed = 100;  // change this to make rotation faster or slower
	Pen.push;
	// uniform motion
	Pen.rotate( userView.frame/speed, 100, 100);  // simply use frame count
	windmills[0].draw();
	Pen.pop;
	Pen.push;
	// accelerated motion: back and forth
	Pen.rotate( sin(userView.frame / speed) * 2pi, 300,100); // use the sinusoid of frame count
	windmills[1].draw();
	Pen.pop;
	Pen.push;
	// even more accelerated !
	Pen.rotate( tan(userView.frame / speed) * 2pi, 500,100); // use the tangent of frame count
	windmills[2].draw();
	Pen.pop;
});
)