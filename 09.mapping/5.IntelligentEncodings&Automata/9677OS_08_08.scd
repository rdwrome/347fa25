( // 1-dimension cellular automata
Server.default.waitForBoot({
	var synth; // a synth used later
	var ruleSet = [60,90,102,150].choose.asBinaryDigits; // randomly choose a rule and convert to an Array of binary digits
	var cells = Array.fill(512,{[0,1].choose([0.95,0.05])}); // a random seed of mainly 0s and just a few 1s at random places
	var generateAccordingToRule = { arg a,b,c; // simply map each neighborhood state to each digit of our rule, respectively
		case
		{(a == 0) && (b == 0) && (c == 0)} {ruleSet[0]}
		{(a == 0) && (b == 0) && (c == 1)} {ruleSet[1]}
		{(a == 0) && (b == 1) && (c == 0)} {ruleSet[2]}
		{(a == 0) && (b == 1) && (c == 1)} {ruleSet[3]}
		{(a == 1) && (b == 0) && (c == 0)} {ruleSet[4]}
		{(a == 1) && (b == 0) && (c == 1)} {ruleSet[5]}
		{(a == 1) && (b == 1) && (c == 0)} {ruleSet[6]}
		{(a == 1) && (b == 1) && (c == 1)} {ruleSet[7]};
	};
	var window = Window("1-dimension cellular automata", 512@200).front
	.onClose_({synth.free;}); // our parent window
	var userView = UserView(window, 512@200).background_(Color.magenta)
	.animate_(true).clearOnRefresh_(false).frameRate_(40).drawFunc_({ // setup UserView and callback func
		var counter = userView.frame % 200;
		synth.set(\array, cells); // modulate synth
		512.do{ arg i;
			// first draw each cell
			if (cells[i].asBoolean) {
				Pen.fillColor_(Color.yellow);
				Pen.addRect(Rect(i,counter,1,1));
				Pen.fill;
			};
			// then calculate next generation
			cells[i] = generateAccordingToRule.value(cells.foldAt(i-1),cells[i],cells.foldAt(i+1));
		};
		// when we have reaches the botom start from scratch with a new random rule and random seed
		if (counter == 0) {
			userView.clearDrawing; // clear previous contents
			ruleSet = [60,90,102,150].choose.asBinaryDigits; // randomly choose a rule and convert to an Array of binary digits

			cells = Array.fill(512,{0}); // an array of empty cells
			rrand(1,50).do{ // add a random number of 1s at random places to achieve a random seed
				cells[512.rand] = 1;
			};
		};
	});
	fork {  // sound
		SynthDef(\caSynth, { // synthDef
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
		synth = Synth(\caSynth); // start synth
	};
});
)

/*Automata
Automata is the plural of automaton which in Greek stands for any kind of non-biological self-operating being. When a program, or elements of it, operate on their own, either following finite behavior instructions by means of stochastic or probabilistic algorithms or relying on some sort of artificial intelligence, we can speak of an automaton. Automata in their various implementations are fundamental parts of any generative art project, that is, art created partly or exclusively relying on some sort of autonomous, non-human controlled system. As far as mapping and visualization is concerned, whenever decisions and behaviors are performed intrinsically by our program, we can speak of a generative process that, by definition, involves some kind of automaton. Herein we will pinpoint our discussion on the infamous cellular automata, while on the next chapter we will discuss other kinds of automata as well.
Cellular Automata
A cellular automaton comprises of a n-dimensional grid of cells each of which has a certain neighborhood and may alternate between a finite number of states with respect to some set of rules, usually considering the state of neighboring cells. On each generation, a cellular automaton will permute according to how each individual cell changes state, therefore generating new patterns and structures dynamically. The initial pattern (which is also referred to as the seed) is of great importance and typically decisive of how the automaton will evolve over time. In the following example we implement an elementary one-dimensional Wolfram’s cellular automaton. Herein our grid is merely a line of cells of 1-pixel width, each of which has a neighborhood of three (that is itself, the pixel on its right and that on its left) and may alternate between two possible states represented by two possible colors. Each subsequent generation will be placed beneath the first one, which is placed on top, and will have its cells configured with respect to the previous one.
In detail, the state of each cell will be a function of the individual states of the cell that constituted the former’s neighborhood in the previous generation. A rule in this context is a configuration of the possible outcomes of each possible combination. The possible states of a neighborhood of 3 wherein each cell alternates between 2 possible states, in binary notation would be:  000, 001, 010, 011, 100, 101, 111, wherein 0 represents one of the two colors and 1 the other. We can then describe a rule as another binary number which holds the results for every of these configurations. For example the rule 01011010 would mean that a cell having a neighborhood of 000, in the next generation will have a state of 0, a cell having a generation of 001 will have a state of 1, and so on. The following diagram describes the rule graphically (here black represents 0 and white 1).
By the way, the number 01011010 corresponds to the decimal number 90 (which is arguably easier to remember). In SuperCollider we can invoke asBinaryDigits on some decimal number to get an instance of Array containing the individual bits of its binary equivalent. Therefore it does make sense to use decimals to describe rules. Configurations of 8 bits may represent a maximum of 256 (including 0) different numbers. However, out of these possible rules only a few will produce interesting results. Consider the following example wherein we use a 512 sized grid and we both visualize/sonify the results of a cellular automaton. Sonification is done in the spectral domain, using pvcalc to generate a spectrum with energy in those bins that correspond to a colored cell. Note that an instance of Control is used to allow instances of Array as arguments to our Synth; the initial value of the each parameter should be an instance of Array similar in size as that later passed as arguments; in our case we will use instances of Array comprised of two 256-sized arrays, one for the magnitudes and one for the phases. Visualization is implementing using Pen to add one-pixel sized rectangles when a cell’s value is 1, else the background color is revealed. */