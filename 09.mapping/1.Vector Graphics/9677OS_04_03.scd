( // generating a custom path
var window = Window("Pen Example", 450@450).front; 
window.drawFunc_({
	Pen.moveTo(78@122);                 // goto point 70@122
	Pen.curveTo(284@395,280@57,78@122); // make a Bezier curve from 78@122 to 284@395 (which is now the new current position). 280@57 and 78@122 are curvature points
	Pen.curveTo(280@57,80@332,284@395); // make another Bezier curve
	Pen.curveTo(80@332,405@225,280@57); // make another Bezier curve
	Pen.curveTo(405@225,78@122,80@332); // make another Bezier curve
	Pen.curveTo(78@122,284@395,405@225); // make another Bezier curve
	Pen.draw(4);  // fill according to the even-odd rule
});
)
