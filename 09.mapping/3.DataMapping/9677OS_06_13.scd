(// tracking amplitude
{   var sound = SinOsc.ar(mul:LFNoise2.kr(1).range(0,1)); // source
	RunningSum.rms(sound,100).poll(label:'rms'); // rms
	Amplitude.kr(sound).poll(label:'peak'); // peak
	Peak.kr(sound, Impulse.kr(1)).poll(label:'peak_trig'); // peak when triggered
	PeakFollower.kr(sound).poll(label:'peak_dec'); // peak with decay
	RunningMin.kr(sound).poll(label:'min'); // minimum
	RunningMax.kr(sound).poll(label:'max'); // maximum
	Out.ar(0,sound); // write to output
}.play;
)