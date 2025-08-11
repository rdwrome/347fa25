( // transparency and custom color example
var window = Window("Pen Example", 450@450).front;
window.background_(Color.white); // set background color
window.drawFunc_({
	Pen.width_(10);      // set stroke width as 10 pixels
	Pen.strokeColor_(Color.cyan);  // set cyan as stroke color
	Pen.fillColor_(Color.fromHexString("FF0000FF")); // set red as fill color
	Pen.addRect(Rect(30,30,300,300)); // add a rectangle
	Pen.draw(4);  // draw rectangle
	Pen.strokeColor_(Color.rand);  // set a random color as stroke
	Pen.fillColor_(Color.new255(0,255,0,50)); // set a transparent green as fill color
	Pen.addRect(Rect(220,220,200,200)); // draw another rectangle
	Pen.draw(4);  // draw
});
)
