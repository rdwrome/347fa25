( // A game of life implentation
Server.default.waitForBoot({
	var synth; // synth to be used later

	var cells = Array.fill(32,{Array.fill(16,{[1,0].wchoose([0.3,0.7])})}); // an 32x16 grid

	var updateCell = {arg xIndex,yIndex; // function to count neighbours and update cells' state
		var neighbours = 0 ; // initial number of neighbours
		var state = cells[xIndex][yIndex]; // set current state
		var newState = state; // new state
		// first count neighbours
		[-1,0,1].do{arg i;
			[-1,0,1].do{arg j;
				neighbours = neighbours +
				cells.foldAt(xIndex+i).foldAt(yIndex+j);
			}
		};

		if (state.asBoolean) {neighbours = neighbours - 1}; // if state is not 0, subtract cell's own state
		case  // calculate new state
		{state.asBoolean && (neighbours < 2)} {newState = 0} // it dies from loneliness.
		{state.asBoolean && (neighbours > 3)} {newState = 0} // it dies from overpopulation.
		{state.asBoolean.not && (neighbours == 3)} {newState = 1}; // birth
		// update
		cells[xIndex][yIndex] = newState;
	};

	var window = Window("Game of life", 640@320).front.onClose_({synth.free});
	var userView = UserView(window, 640@320).background_(Color.magenta).animate_(true).frameRate_(40).drawFunc_({ // setup UserView and callback func
		var speed = userView.frame % 4;
		synth.set(\array, cells.flatten); // sonify
		cells.do{arg xItem, xIndex;  // for each cell
			xItem.do{arg yItem, yIndex;
				if (yItem!=0) { // draw current state
					Pen.fillColor_(Color.new255(214,176,49));
					Pen.addRect(Rect(xIndex*20,yIndex*20,20,20));
					Pen.fill;
				};
				if (speed==0) {updateCell.(xIndex,yIndex);}; // calculate and draw new state
			};
		};
	});

	fork {
		SynthDef(\gameOfLife, {
			var signal, array, magnitudes, phases;
			array = Control.names([\array]).kr(Array.fill(512,{0})).clump(2).flop; // Control is used to allow an array to be passed as an argument
			magnitudes = array[0]; // read argument magnitudes
			phases = array[1]; // read argument phases
			signal = Silent.ar(); // a silent signal since we will replace it
			signal = FFT(LocalBuf(512),signal); // FFT
			signal = signal.pvcalc(512,{
				[magnitudes,phases]; // manually set magnitudes and phases
			});
			signal = IFFT(signal); // inverse FFT
			Out.ar(0,signal!2);
		}).add; // add SynthDef
		Server.default.sync; // sync with Server
		synth = Synth(\gameOfLife); // start synth
	};
});
)

/*Cellular automata are known since the 40s, primarily due to Stanisław Ulam and John von Neumann who first discovered and systematically studied them at the Los Alamos National Laboratory in New Mexico. It wasn’t but until the 70s, however, that cellular automata were popularized and exceeded narrow academic circles, primarily due to the infamous Conway’s game of life, which we will soon discuss in more detail. A seminal work in the subject is Stephen Wolfram’s 1,280-page book entitled A New Kind of Science. Wolfram argues that cellular automata are relevant to the study of biology, chemistry, physics and several other branches of science. The entire book is freely available online at http://www.wolframscience.com/nksonline/toc.html
Game of life
The infamous game of life is a two-dimensional cellular automaton originally devised by the British mathematician John Horton Conway. Herein we have a two-dimensional grid, two-state cells (alive or dead in this context) and a 9-cell neighborhood (the cell in question and all its neighboring ones up, down, left, right and diagonally). There are four rules:
1.	Loneliness: any living cell with fewer than two living neighbors dies.
2.	Stasis: any living cell with two or three living neighbors lives on to the next generation.
3.	Over-population: any living cell with more than three live neighbors dies.
4.	Birth: any dead cell with exactly three living neighbors becomes a living cell.
What is particularly intriguing with the game of life is that there are certain patterns which will constantly oscillate between the same states, certain others which will remain static, certain others which appear as if moving. To implement a basic game of life we will follow a similar approach as before, this time however using a two-dimensional array of cells*/