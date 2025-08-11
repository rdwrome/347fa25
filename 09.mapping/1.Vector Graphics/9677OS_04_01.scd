( // primitive shapes with Pen
var window = Window("Pen Example", 450@450).front; // a window
window.drawFunc_({  // all the drawing has to be done in this function
	Pen.line(0@0,100@100);               // a line between 2 points
	Pen.line(350@100,450@0);             // a line between 2 points
	Pen.addArc(200@150,20,0,pi);         // half a circle (an arc with angle of pi radians)
	Pen.addArc(250@200,40,pi,pi/2);      // 1/4th of a circle 
	Pen.addRect(Rect(50,100,350,300));   // a rectangle
	Pen.addOval(Rect(100,220,250,80));   // an ellipse
	Pen.addWedge(350@350,40,1.5pi,pi/2); // a pi/2 radians wedge 
	Pen.addAnnularWedge(345@355,15,40,0,1.5pi); // and an annular wedge
	Pen.stroke;   // draw only the outlines
});
)
