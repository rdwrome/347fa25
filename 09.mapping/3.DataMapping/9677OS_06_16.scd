( // feature extraction
{   var sound = SinOsc.ar(240,mul:0.5) 
	+ Resonz.ar(ClipNoise.ar,2000,0.6,mul:SinOsc.kr(0.05).range(0,0.5))
	+ Saw.ar(2000,mul:SinOsc.kr(0.1).range(0,0.3));
	var fft = FFT(LocalBuf(2048),sound);  // a complex signal 
	SpecCentroid.kr(fft).poll(label:\Centroid);
	SpecFlatness.kr(fft).poll(label:\Flatness);
	SpecPcile.kr(fft,0.8).poll(label:\Percentile);
	FFTCrest.kr(fft,1800,2200).poll(label:\Crest); 
	SensoryDissonance.kr(fft).poll(label:\Dissonance);
	Out.ar(0,sound!2);
}.play;
)