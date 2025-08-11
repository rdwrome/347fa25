( // testing our FancySpectrogram
Server.default.waitForBoot({ fork { // boot server and start a routine
	var spectrogram;
		{spectrogram = MyFancySpectrogram.new(0)}.defer; // a new spectrogram
		1.wait; // wait a bit before starting scoping;
		{spectrogram.start}.defer; // start scoping
		// an audio signal to test
		{   Resonz.ar(ClipNoise.ar,15000,0.01,mul:SinOsc.kr(0.2).range(0,1))  
			+ Saw.ar(LFTri.kr(0.1).range(200,5060),mul:0.2) 
			+ ( Klang.ar(`[[800, 803, 8011],[0.3, 0.7, 0.4],[0, 0, pi]]) *
				SinOsc.kr(0.5).range(0,2) );
		}.play;
	};
});
)

