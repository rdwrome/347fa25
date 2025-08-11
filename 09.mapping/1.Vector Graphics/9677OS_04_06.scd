( // windmill factory
~windmillFactory = { arg position = 0@0, radius = 100, 
    numberOfWings = 5, colors = [Color.red, Color.green]; 
	
	// calculate step (angular difference between concecutive points)
	var step = if (numberOfWings.odd) { 
		(2pi / numberOfWings) * (numberOfWings/2).floor; 
	} {
		(2pi / numberOfWings) * ((numberOfWings/2)-1); 
	};
	
	// calculate points' coordinates and store in an array
	var points = Array.fill(numberOfWings, { // we only need one point per wing as they are connected with each other diametrically
		arg i; 
		var x, y;
		x = position.x + (radius * cos((step * i)));
		y = position.y + (radius * sin((step * i)));
		x@y; // return the anchor point point
	});
	
	var windmill = ( // event as an object prototype
		position: position,  // sprite's position
		points: points,  // the anchor points (to be updated if needed)
		refresh: { arg self, newPosition;
			self.position = newPosition;  // set new position
			// re-calculate points according to newPosition
			self.points = Array.fill(numberOfWings, { 
				arg i; 
				var x, y;
				x = newPosition.x + (radius * cos((step * i)));
				y = newPosition.y + (radius * sin((step * i)));
				x@y; // return the anchor point point
			});
		},
		draw: { arg self;
			Pen.moveTo(self.points[0]); // move to the first point
			(numberOfWings).do{  // iterate over the array of anchor points
				arg i; 
				var pointA, pointB, pointC; 
				// get three consecutive points
				pointA = self.points[i];  
				pointB = self.points.wrapAt(i+1); 
				pointC = self.points.wrapAt(i+2); 
				Pen.curveTo(pointB,pointC,pointA); // define Bezier segment
			};	
			
			// fill with radial gradient 
			Pen.fillRadialGradient(self.position, self.position,0,
				radius*1.5,colors[0], colors[1]); 
		}
	);
	windmill;  // return windmill 
};
)
