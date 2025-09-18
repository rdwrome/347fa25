// PITCH AMPLITUDE TIMBRE definitions for us doing synthesis
// time domain vs frequency domain

/*SynthDef
- a class which pre-compiles multiple unit generators together on the server
- greaaat for reuse!
*/

(
SynthDef("kiwi", {
	| pitch=220, pan=0 |
	Out.ar(0, (Pan2.ar(SinOsc.ar(pitch), pan)));
}).add; // use "add" to the audio server instead of play
)

x = Synth("kiwi",[\pitch,60.midicps]);
y = Synth("kiwi",[\pitch,62.midicps]);
z = Synth("kiwi",[\pitch,65.midicps]);

s.meter;
// and each can be set later!
x.set(\pitch,58.midicps);|
y.set(\pitch,62.midicps);
z.set(\pitch,67.midicps);


// set them free!

x.free;
y.free;
z.free;


/* interlude on arrays vs lists
  - Array: fixed size collection (most common)
  - List: variable size collection
  - What are tuning systems but arrays and lists?*/
m = Scale.minor.degrees; // Scale class returns the degrees of the minor scale

Tuning.directory // which scales

// Additive Synthesis with Array.fill(<num>,{arg i; <code>}) and Mix.ar

(
SynthDef("addsynthdemo",{
	| freq=110, amp=0.5 |
	var sig;
	sig=Mix.ar(
		Array.fill(2,{arg i; SinOsc.ar(freq:freq*(2**i),mul:amp/(2**i))})
	);
	Out.ar(0,sig);
}).add;
)
x = Synth("addsynthdemo");
x.free;
// your turn!
// take the synth in c and try changing things, including:
// - try changing the oscillators (try VarSaw, SinOsc, Pulse, LFTri, Saw, ..)
// - try changing the frequency
// - try changing the number of oscillators (instead of 3, do 1, 2, ..)

// Additive Synthesis with Dynklank from the helpfile

(
SynthDef('helprd-dynKlang', { |
    freqs=#[220, 440, 880, 1760],
    amps=#[0.35, 0.23, 0.12, 0.05],
    phases=#[1, 1.5, 2, 2.5]|

	Out.ar(0, Pan2.ar(DynKlang.ar(`[freqs, amps, phases])))
}).add
)

x = Synth('helprd-dynKlang');

x.setn(\freqs, Array.rand(4, 500, 2000));
x.setn(\amps, Array.rand(4, 0.01, 0.25));


// Subtractive Synthesis

(
SynthDef('rdRLPF', {
	var saw, ctl, sine, mix;

	// Sawtooth oscillator at audio rate
	saw = Saw.ar(200, 0.2);

	// Filtered saw, cutoff/resonance controlled by mouse
	ctl = RLPF.ar(
		saw,
		MouseX.kr(100, 5000, 1),   // cutoff frequency (wider range, audio-relevant)
		MouseY.kr(0.05, 0.9, 1)    // resonance
	);

	// Sine oscillator, frequency modulated by ctl
	sine = SinOsc.ar(ctl * 2 + 400, 0, 0.1);

	// Mix both signals together
	mix = ctl * 0.3 + sine;

	// Pan to stereo and output
	Out.ar(0, Pan2.ar(mix * 0.5));
}).add;
)

x = Synth('rdRLPF');

// Amplitude Modulation Synthesis

(
~kiwi={
	| pitch=220|
	Pan2.ar(SinOsc.ar(pitch), 0, SinOsc.ar(pitch*2)); // .kr vs .ar, again!
}.play; // .play will play it
)
~kiwi.set(\pitch,440)
~kiwi.set(\pan, 4)
~kiwi.free;

// Frequency Modulation Synthesis
(
SynthDef(\fmSynth, { |carrierFreq=440, carrierLvl=0.5, modulatorRatio=5, modulatorIndex=1.5, outputAmp=0.2, sig|

	// the simple FM core
	sig = LFSaw.ar(carrierFreq, 1, 0.5, 0.5) * carrierLvl;
	sig = sig + SinOsc.ar(carrierFreq * modulatorRatio) * modulatorIndex;
	sig = cos( sig * 2pi) * outputAmp * 0.06;
	Out.ar(0, Pan2.ar(sig));
}).add;
)

// At first start the synth:
g = Synth(\fmSynth);

// Play with the arguments:
g.set(\carrierFreq, 880);
g.set(\carrierFreq, 50);
g.set(\carrierFreq, 100, \modulatorRatio, 5, \modulatorIndex, 0.5);
g.set(\carrierFreq, 40, \modulatorRatio, 7, \modulatorIndex, 1.5);
g.set(\carrierFreq, 955, \carrierLvl, 0.4, \modulatorRatio, 3, \modulatorIndex, 4);
// ... etc.

// To stop:
g.free;


// wave table based on Fieldsteel p.94
(
~wt = Signal.sineFill(4, [1], [0]).asWavetable;
b = Buffer.loadCollection(s, ~wt);
)

{Osc.ar(b, 440) * 0.2 ! 2}.play;

///// filters
// LPF, RLPF, HPF, RHPF, BPF
// MoogLadder, MoogVCF, MoogFF
(
SynthDef("filtersynth",{
	| freq=220 |
	var sig, lpf, res;
	sig = Saw.ar([freq,freq+2]); // create a saw wave
	sig = sig * (-6.dbamp); // decrease volume by 6 dB

	lpf = Clip.kr(MouseX.kr(20,20000,1),20,20000); // add mouse modulation to lpf
	res = Clip.kr(MouseY.kr(1,0.02),0.1,1); // add mouse modulation to resonance
	sig = RLPF.ar(sig,lpf,res); // resonant low-pass filter
	Out.ar(0,Pan2.ar(sig)); // output the send
}).add;
)
y = Synth("filtersynth");
y.free;

// combining modulation + filter
(
SynthDef("modfiltersynth", {
	|freq = 110|
	var sig, lpf, res;
	sig = Saw.ar([freq,freq-1]); // create a saw wave

	sig = sig * -12.dbamp; // reduce volume by 12 dB

	lpf = LFNoise2.kr(1).range(freq,4000);
	res = LFNoise2.kr(1).range(0.5,1);
	sig = RLPF.ar(sig,lpf, res); // resonant low-pass filter

	Out.ar(0,Pan2.ar(sig)); // output the send
}).add;
)
y = Synth("modfiltersynth");
y.free;