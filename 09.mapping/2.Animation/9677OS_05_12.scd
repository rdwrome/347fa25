( // a kinematic snake factory
~snakeFactory = { arg numberOfSegments = 50, length = 20,  width = 40, colorFunc = {arg i; Color(1,0,i)};

	// the body
	var body =  Array.fill(numberOfSegments, {arg i;
		(position: 0@(i * 2), radius: (2 * (50 - i) / 2)); // an event
	});

	var snake = ( // the snake
		position: 0@0, // the current position of the sname
		theta: 0.1, // used to calculate the angles
		draw: { arg self;
			self.theta_(self.theta + 0.0005); // increment theta

			body[0].position_(self.position); // the position of the head
			body[1].position_(Point(body[0].position.x + sin( pi + self.theta), body[0].position.y + cos( pi + self.theta).neg)); // the next to the head segment is caclulated as a function of theta

			// calculate the position and color of each segment with respect to the adjacent ones
			(numberOfSegments-4).do{ arg i; // iterate over the rest segments (-4 because we access i+2,i+1 and i herein)
				var newPosition, hypotenuse, points;
				var index = i + 2;
				var color = colorFunc.(index/numberOfSegments); // calculate color
				newPosition = body[index].position - body[index-2].position; // calculate the new position as a function of a previous segment's position

				hypotenuse = newPosition.x.hypot(newPosition.y); // calculate the hypotenuse between x and y of this new position
				body[index].position_( body[index-1].position + ((newPosition * length) / hypotenuse)); // set the positioning of this snake

				points = [ // array with the positions of 2 consecutive segments
					body[index-1].position,
					body[index].position
				];

				// draw segment
				Pen.strokeColor_(color);
				Pen.width_(width*(numberOfSegments-index)/numberOfSegments);
				Pen.line(points[0],points[1]);
				Pen.stroke();
			};
		},
		refresh: { arg self, newPosition;
			self.position_(newPosition); // update position
		}
	);

	snake;
};
)
