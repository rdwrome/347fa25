( // extended fractal factory
~fractalFactory = { arg numLevels, numBranches, position, radius, changeFactor;

	var fractalFunc = thisFunction;   // assign thisFunction to a variable
	var points, children, fractal; // declare variables

	// calculate ending points for our segments
	points = Array.fill(numBranches, {arg i;
		var x, y;
		x = position.x + (radius * numLevels * cos(((2pi/numBranches) * i)));
		y = position.y + (radius * numLevels * sin(((2pi/numBranches) * i)));
		x@y;
	});

	// generate children
	if (numLevels > 0) { // if there are more levels to go
		var childrenPoints, childrenRadius;
		// calculate the children points for each for the branches
		childrenPoints = Array.fill(numBranches, {arg i;
			var x,y;
			x = (points[i].x + position.x) / 2;
			y = (points[i].y + position.y) / 2;
			x@y
		});

		// calculate the children radiuses
		childrenRadius = radius * changeFactor;

		// for each level generate all branches and add them to fChildren array
		numBranches.do{ arg i;
			children = children.add(fractalFunc.(numLevels-1, numBranches, childrenPoints[i], childrenRadius, changeFactor));
		};

	} { // if there are more levels to go set children to nil
		children = nil;
	};

	// create fractal object
	fractal = (
		children: children,   // an array with the children (all of them fractal objects, too or nil if in the last level)
		branches: numBranches,   // how many branches
		counter: 0, // counter for animation
		animatePoints: Array.newClear(numBranches), // intermediate points for animation
		animate: { arg self, speed = 0.01, colors = [Color.red, Color.green];
			self.branches.do{arg i;
				if (self.counter < 1) { // if not done
					self.counter_(self.counter + speed); // update counter

					// calculate line-segments to draw with respect to counter
					self.animatePoints[i] =
					Point(
						position.x + ((points[i].x - position.x)
							* self.counter),
						position.y + ((points[i].y - position.y)
							* self.counter),
					);

					// draw segment
					Pen.strokeColor_(colors[0].blend(colors[1],self.counter)); 	// progressively blend colors wiht respect to counter
					Pen.line(position,self.animatePoints[i]);
					Pen.stroke;

				} { // if done

					// draw the completed fractal
					Pen.strokeColor_(colors[0].blend(colors[1],self.counter));
					Pen.line(position,self.animatePoints[i]);
					Pen.stroke;

					self.counter_(0); // reset counter to start from scratch
				};
			};
			// animate children
			if (self.children.notNil) { // if there are children
				// draw all of their branches
				self.children.do{arg item;
					item.animate(speed,colors);
				};
			};
		},
		draw: {arg self, colorFunc; // drawing function,
			// draw self
			self.branches.do{arg i;
				Pen.strokeColor_(colorFunc.()); // set a color for each branch
				Pen.line(position,points[i]); // create lines
				Pen.stroke; // stroke lines
			};
			// draw children
			if (self.children.notNil) { // if there are children
				// draw all of their branches
				self.children.do{arg item;
					item.draw(colorFunc);
				};
			};
		}
	);

	fractal; // explicitely return fractal
};
)
