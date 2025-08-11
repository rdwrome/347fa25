// adapted from https://github.com/schollz/workshops

/*SynthDefs
- a class which pre-compiles multiple unit generators together on the server
- greaaat for reuse!
*/

//////// a ////////
// lets define a synth to use multiple times
// using a "SynthDef"

(
SynthDef("coolsynth",{ // add SynthDef here, with a name
	arg freq=220, amp=0.1;
	var snd;
	snd=SinOsc.ar(freq:[freq,freq*2,freq*4],mul:[amp,amp/2,amp/8]);
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add; // use "add" instead of play
)

// now you can create multiple instances of them!
(
x = Synth("coolsynth",[\freq,60.midicps]);
y = Synth("coolsynth",[\freq,62.midicps]);
z = Synth("coolsynth",[\freq,65.midicps]);
)

// and each can be set later!
(
x.set(\freq,58.midicps);
y.set(\freq,62.midicps);
z.set(\freq,67.midicps);
)

(
x.set(\freq,60.midicps);
y.set(\freq,62.midicps);
z.set(\freq,65.midicps);
)

// set them all free!
(
x.free;
y.free;
z.free;
)


//////// b ////////
// you can treat UGens like numbers because of OOP!
// let's add them together and make a new oscillator
// famous oscillator UGens to play with:
// SinOsc, LFSaw, Tri
(
SynthDef("coolsynth",{
	arg freq=110, amp=0.5;
	var snd;
	// you can directly Mix
	snd=Mix.ar(
		SinOsc.ar(freq:[freq,freq*5,freq*8],mul:[amp,amp/2,amp/4])
	);
	// lets add some harmonic from a saw wave
	snd=snd+(0.1*Mix.ar(
		Saw.ar(freq:[freq,freq*2,freq*3,freq*4],mul:[amp,amp/1,amp/3,amp/3]))
	);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add;
)
x = Synth("coolsynth");
x.free;

/* interlude on arrays vs lists
  - Array: fixed size collection (most common)
  - List: variable size collection
  - What are tuning systems but arrays and lists?*/
m = Scale.minor.degrees; // Scale class returns the degrees of the minor scale

Tuning.directory // which scales

//////// c ////////
// use Array.fill(<num>,{arg i; <code>})
// to easily create an additive synth

(
SynthDef("coolsynth",{
	arg freq=110, amp=0.5;
	var snd;
	// you can directly Mix
	snd=Mix.ar(
		Array.fill(2,{arg i; SinOsc.ar(freq:freq*(2**i),mul:amp/(2**i))})
	);
	// lets add some harmonic from a saw wave
	snd=snd+(0.1*Mix.ar(
		Array.fill(4,{arg i; Saw.ar(freq:freq*(i+1),mul:amp/(i+1))}))
	);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add;
)
x = Synth("coolsynth");
x.free;
// your turn!
// take the synth in c and try changing things, including:
// - try changing the oscillators (try VarSaw, SinOsc, Pulse, LFTri, Saw, ..)
// - try changing the frequency
// - try changing the number of oscillators (instead of 3, do 1, 2, ..)


//////// d ////////
// filtering
// LPF, RLPF, HPF, RHPF, BPF
// MoogLadder, MoogVCF, MoogFF
(
SynthDef("filtersynth",{
	arg freq=220;
	var snd;
	var lpf, res;
	snd = Saw.ar([freq,freq+2]); // create a saw wave
	snd = snd * (-6.dbamp); // decrease volume by 6 dB

	lpf = Clip.kr(MouseX.kr(20,20000,1),20,20000); // add mouse modulation to lpf
	res = Clip.kr(MouseY.kr(1,0.02),0.1,1); // add mouse modulation to resonance
	snd = RLPF.ar(snd,lpf,res); // resonant low-pass filter
	Out.ar(0,snd); // output the send
}).add;
)
y = Synth("filtersynth");
y.free;

//////// e ////////
// combining modulation + filter
(
SynthDef("filtersynth", {
	arg freq = 110;
	var snd;
	var lpf, res;
	snd = Saw.ar([freq,freq-1]); // create a saw wave

	snd = snd * -12.dbamp; // reduce volume by 12 dB

	lpf = LFNoise2.kr(1).range(freq,4000);
	res = LFNoise2.kr(1).range(0.5,1);
	snd = RLPF.ar(snd,lpf, res); // resonant low-pass filter

	Out.ar(0,snd); // output the send
}).add;
)
y = Synth("filtersynth");
y.free;


//////// g ////////
///midisynth
(
SynthDef("midisynth",
{
	arg note=32;
	var detune=0.1;
	var snd;
	var lpf, res;
	snd = {
		var freq = (note+LFNoise0.kr(1).range(detune.neg,detune)).midicps; // add detuning to note and then convert to midi
		var snd_ = Pulse.ar(freq,LFNoise2.kr(3).range(0.2,0.8)); // create a pulse wave with pwm
		snd_ = snd_ * -6.dbamp; // reduce volume by 12 dB
		lpf = LFNoise2.kr(1).exprange(100,Rand(1000,5000));
		res = LFNoise2.kr(1).range(0.1,1);
		snd_ = RLPF.ar(snd_,lpf, res); // resonant low-pass filter
		snd_ // return sound
	}!8;

	snd = Splay.ar(snd); // make a stereo field out of all the channels

	Out.ar(0,snd); // output the send
}).add
)
z = Synth("midisynth");
z.free;