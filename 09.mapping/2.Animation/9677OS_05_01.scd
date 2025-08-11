( // A decending circle
var window = Window("a decending circle", 400@400).front; // create the window
var userView = UserView(window, 450@450) // create the UserView
.background_(Color.white)  // set background color
.animate_(true)  // start animation !
.frameRate_(60)  // set frameRate to 60 frames per second
.drawFunc_({   // callback drawing function
	var x,y, counter;
    counter = userView.frame; // count the number of frames
	x = 100; // no change in the horizontal axis
	y = counter % (userView.bounds.height+200); // calculate y as the modulo of the passed frames
	Pen.fillColor_(Color.cyan);  // set color to yellow
	Pen.addOval(Rect(x,y-200,200,200));  // create a circle
	Pen.fillStroke;  // draw circle
});
)