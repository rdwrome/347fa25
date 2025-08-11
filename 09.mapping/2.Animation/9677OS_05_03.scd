( // rotating windmill trailing effect
var window, userView, windmill;
(PathName(thisProcess.nowExecutingPath).pathOnly  ++ "9677OS_05_windmill_factory.scd").loadPaths; // first load the windmill factory
windmill = ~windmillFactory.(225@225,150); // a new windmill
window = Window("Trailing Effect", 450@450).front;
userView = UserView(window,450@450).background_(Color.white).animate_(true).frameRate_(60).clearOnRefresh_(false); // do not clear previous contents
userView.drawFunc_({
	var speed = 100;
	Pen.fillColor_(Color(1,1,1,0.4));  // a transparent white
	Pen.addRect(Rect(0,0,450,450));   // create a semi-transparent rectangle to dampen previous contents
	Pen.fill; // draw rectangle
	Pen.push;
	Pen.rotate( tan(userView.frame / speed) * 2pi, 225, 225); // rotating windmill
	windmill.draw();  // draw windmill
	Pen.pop;
});
)
