( // trailing effects using geometrical transormations
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_04_06.scd").loadPaths; // first load the windmill factory
Window("Trailing Effects Example",640@480).background_(Color.white).front.drawFunc_({
	// trailing effects with rotation
	Pen.push;  // push a new matrix
	5.do{ arg i;
		var windmill = ~windmillFactory.value(150@200,130,11); // create 5 instances of an 11-winged windmill
		Pen.rotate(i * 0.1,150,200); // incrementally rotate each instance around its own axis
		Pen.alpha_(1-(i*0.1));  // decrementally set transparency
		windmill.draw();        // draw the windmills
	};
	Pen.pop; // pop matrix to revert to original graphics state

	// trailing effects with translation
	Pen.push;  // push a new matrix
	10.do{ arg i;
		var windmill = ~windmillFactory.(420@120,130,7); // create 10 instances of a 7-winged windmill
		Pen.translate(10,10);  // cummulatively translate each instance 10 pixels upwards and downwards
		Pen.alpha_(1-(i*0.1)); // decrementally set transparency
		windmill.draw();  // draw the windmills
	};
	Pen.pop;  // pop matrix to revert to original graphics state

	// trailing effects with scaling
	Pen.push;      // push a new matrix
	3.do{ arg i;
		var windmill = ~windmillFactory.(80@400,60,7);  // create 3 instances of a 7-winged windmill
		Pen.scale(1.7,1);   // cummulatively scale each instance's horizontal dimension
		Pen.alpha_(1-(i*0.1)); // decrementally set transparency
		windmill.draw(); // draw the windmills
	};
	Pen.pop;  // pop matrix to revert to original graphics state
});
)
