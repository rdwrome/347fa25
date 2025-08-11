( // track loudness
{   var sound, loudness;
	sound = SinOsc.ar(LFNoise2.ar(1).range(100,10000),
		mul:LFNoise0.ar(1).range(0,1)); // source
	loudness = FFT(LocalBuf(1024),sound); // sampling rates of 44.1/48K
	// loudness = FFT(LocalBuf(1024),sound); // sampling rates of 88.2/96K
	loudness = Loudness.kr(loudness).poll(label:\loudness);
	Out.ar(0, sound);
}.play;
)
