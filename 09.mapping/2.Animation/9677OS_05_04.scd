( // gui interaction
var window, userView, windmill, speed = 100;
var x =0, y = 0; // windmill's new positioning

(PathName(thisProcess.nowExecutingPath).pathOnly  ++ "9677OS_05_windmill_factory.scd").loadPaths; // first load the windmill factory

windmill = ~windmillFactory.(225@225,150); // create a new windmill

window = Window("Gui interaction", 450@535).front; // parent window
window.addFlowLayout; // add flowLayout
userView = UserView(window, 440@440).background_(Color.white).animate_(true).frameRate_(60).clearOnRefresh_(false).drawFunc_({
	// add trailing effect
	Pen.fillColor_(Color(1,1,1,0.4));  // a transparent white
	Pen.addRect(Rect(0,0,450,450));   // create a semi-transparent rectangle
	Pen.fill; // draw rectangle to dampen previous contents
	Pen.push;
	Pen.rotate( tan(userView.frame / speed) * 2pi, x, y); // rotate windmill
	windmill.refresh(x@y); // change windmill's positioning according to x and y
	windmill.draw();
	Pen.pop;
});

// create the sliders to control positioning
EZSlider.new(window,430@40,"x",ControlSpec(0,440),{arg slider; x = slider.value});
EZSlider.new(window,430@40,"y",ControlSpec(0,440),{arg slider; y = slider.value});
)
