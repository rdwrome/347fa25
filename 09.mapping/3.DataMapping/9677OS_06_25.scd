( // sending data retrieved from Patterns
Server.default.waitForBoot({fork{ 
	var data; // we will store the currently playing event here
	SynthDef(\mySound, { arg freqA,freqB;  
		var signal;
		signal = SinOsc.ar([freqA,freqB]);
		Out.ar(0,signal*0.5);
	}).add; 	// add synthDef
	Server.default.sync; // and sync with Server

	Pmono(\mySound,  // a Pmono 
		\freqA, Pbrown(100,500,100,inf),
		\freqB, Pbrown(100,500,100,inf)
	).collect({ arg event; 
		data = event; // here we pass the current even to data
	}).play;

	1.wait; // wait a second so that data is given some value

	fork{loop{ // do something with the data
		[data.freqA, data.freqB].postln; 
		1.wait;
	}}
}});
) 
