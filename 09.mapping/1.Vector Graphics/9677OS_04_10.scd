( // A canonical particle system
var window = Window("A canonical particle system",640@480).background_(Color.new255(100, 149, 237)).front;
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_04_06.scd").loadPaths; // first load the windmill factory
window.drawFunc_({
	forBy(0,window.bounds.width-50,50,{ // iterate over width minus 50 (to leave a margin) by steps of 50
		arg ix;
		forBy(0,window.bounds.height-50,50,{ // for each iteration over width, iterate over height minus 50 (to leave a margin) by steps of 50
			arg iy;
			var x,y,windmill; // coordinates and our windmill
			x = 45 + ix;  // incrementally (by 50) calculate x, add offset it by 45 so that the first element is not right on the edge
			y = 45 + iy;  // incrementally (by 50) calculate y, add offset it by 45 so that the first element is not right on the edge
			Pen.push; // push new matrix
			Pen.rotate(2pi.rand,x,y); // randomly rotate each windmill around its own axis
			// generate windmills so that each row has more wings than the previous and so that colors are a function of position
			windmill = ~windmillFactory.(x@y,20,(5,7..27).wrapAt(ix/50),
				[Color(sin(ix/50).abs,sin(iy/50).abs,1),
				Color.black]);
			windmill.draw(); // draw windmill
			Pen.pop; // pop matrix
		});
	});
});
)
