( // Using Control UGen
Server.default.waitForBoot({fork{
	var synth;
	
	SynthDef(\controlExample, { //define SynthDef
		var frequencies = Control.names([\freqs]).kr([100,200,300,400]);
		var sound = Mix.new(SinOsc.ar(frequencies)*0.1);
		Out.ar(0,sound!2);
	}).add;
	Server.default.sync; // sync with Server
	
	synth = Synth(\controlExample); // start synth
	
	fork{ loop { // modulate freqs with a loop
		var newFreqs = Array.fill(4,{arg i; rrand(100,1000)}); // array has to be of the same size as the original
		synth.set(\freqs, newFreqs);
		1.wait;
	}};
}});
)
