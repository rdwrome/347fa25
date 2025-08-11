( // custom path with gradient
var window = Window("Pen Example", 450@450).front.drawFunc_({
	Pen.moveTo(78@122);    
	Pen.curveTo(284@395,280@57,78@122); 
	Pen.curveTo(280@57,80@332,284@395); 
	Pen.curveTo(80@332,405@225,280@57); 
	Pen.curveTo(405@225,78@122,80@332); 
	Pen.curveTo(78@122,284@395,405@225); 
    Pen.fillRadialGradient(225@225, 225@225, 0,250,Color.red, Color.green);
});
)