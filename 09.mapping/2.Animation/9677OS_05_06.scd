( // animating particles
var particleEngine = { arg width, height, distance, counter;
	(width/distance).floor.do{arg ix;
		(height/distance).floor.do{arg iy;
			var x,y; // positioning
			var color, radius, xoffset, yoffset;

			// try this section and then comment it out and try the second
			color = Color(sin(counter).abs,cos(counter).abs,sin(counter/4).abs); // modulate color
			radius = sin(counter / 2).abs * 20; // modulate radius
			xoffset = sin(counter) * 10; // move left and right
			yoffset = sin(counter/2) * 10; // move up and down

			// uncomment the following once you have tried the former
			/*color = Color(sin(ix).abs,cos(ix).abs,sin(iy+ix).abs); // modulate color
			radius = sin((ix+1) * (iy+1) * (counter/10)).abs * 30; // modulate radius
			xoffset = 0;
			yoffset = 0;*/

			x = (distance/2) + (ix * distance) + xoffset;
			y = (distance/2) + (iy * distance) + yoffset;
			Pen.fillColor_(color);
			Pen.push;
			Pen.rotate(2pi.rand,x,y);
			Pen.addArc(x@y,radius,0,2pi);
			Pen.fill;
			Pen.pop;
		};
	};
};

var window = Window("animating particles", 640@640).front;
var userView = UserView(window, 640@640).background_(Color.black).animate_(true).frameRate_(60).drawFunc_({
	var counter = userView.frame / 30; // counter
	particleEngine.value(640,640,70,counter); // width, height, distance between articles’ centers and counter
});
)