// adapted from https://github.com/schollz/workshops and https://en.wikibooks.org/wiki/Designing_Sound_in_SuperCollider

/*
Preludes

*busses*
- your analog meaning of busses mostly make sense here
- bus methods are kind of confusing in sc sometimes because there are sometimes private busses that work more like effects sends and aren't explicitly declared.
- a good explanation of this can be found here:
https://doc.sccode.org/Tutorials/Getting-Started/11-Busses.html
but I'll explain more in the 03.patterns week.

*digital audio 101*
- transducers
- A/D, D/A
- sample rates
- bit resolution/bit depth
- amplitude
- nyquist

*rachel reminders*
- You do need to boot the Audio Server with **Command|B**
- You see your I/O in the Post window after booting the Audio Server
- [You might need to change them/select them with this code](https://doc.sccode.org/Reference/AudioDeviceSelection.html)
- If you I/O audio rates don't match, the server won't boot and you'll need to make sure they match in your Audio MIDI setup
- Evaluate a line with **Shift|Return**
- Evaluate a block with **Command|Return**
- Kill what is on the server with **Command|.**
- ***Beware Zombie servers***
- Everything's in mono by default
- "Syntax Sugar": many ways to write out the same thing
- Help! with **Command|D**

*/


(
x={
	arg freq=166; /* PIRATE vs PIPE NOTATION a la rachelle */
	// | freq=220 |
	SinOsc.ar(freq:freq);
}.play; // .play will play it
)

// now you can run each of these lines to change it!
x.set(\freq,220);

x.set(\freq,49.midicps); // .midicps converts midi note to frequency (cycles per second)

x.free; // we can stop the synth running this line

/*
Interludes

*Stopping sounds with sophistication*
.free - kills bus assigned to variable on the server (ideal)
<<Command|.>> - kills all busses on the server (panic)
Server>Kill All Servers > KILLS ALL SERVERS (apocalypse)

*UGens*
- Modular building blocks of synthesis systems
- Think of them like modules in your synthesizer
  - They make a waveform, a filter, etc.
- In SC they're actually written in C/C++ and are a plugin to the SC Server, but most come standard with download
  - Most UGen classes have Audio Rate **.ar** and Control Rate **.kr** signal methods internal to the language.
- LOOK UP THE arguments OF UGens with <<Command|D>>
- AR = sends 44.1k values per second; KR = sends 7,350 values per second (1/6th as many as ar. Just saves CPU this way!...like difference between VCO and LFO modules in a modular synth).
- Let's get out of mono with Pan2:*/
{Pan2.ar(SinOsc.ar(440))}.play;
{Pan2.ar(SinOsc.ar(440), SinOsc.kr(4), SinOsc.ar(440))}.play // demo of .ar vs kr

s.scope; // time domain

// Additive synthesis

(
x = {

	var freq = MouseX.kr(100, 1000, 1) / SampleRate.ir;
	var distance = 3.00;
	var index = MouseY.kr(0.42, 0.99);
	var theta, beta, num, denom, son;

	// Two phasors which will ramp from zero to 2pi as fancy oscillators
	theta = Phasor.ar(0, freq, 0, 2pi);
	beta  = Phasor.ar(0, freq * distance, 0, 2pi);

	num = sin(theta) - (index * sin(theta - beta));
	denom = 1 + index.squared - (2 * index * cos(beta));

	son = num / denom;

	Out.ar(0, Pan2.ar(son * 0.3)); // main mix or 'master' bus, first argument is just the index/location/proper name of the the bus itself

}.freqscope; // frequency domain
)

// Frequency Modulation Synthesis
(
SynthDef(\fmSynth, { |carrierFreq=440, carrierLvl=0.5, modulatorRatio=5, modulatorIndex=1.5, outputAmp=0.2, sig|

	// the simple FM core
	sig = LFSaw.ar(carrierFreq, 1, 0.5, 0.5) * carrierLvl;
	sig = sig + SinOsc.ar(carrierFreq * modulatorRatio) * modulatorIndex;
	sig = cos( sig * 2pi) * outputAmp * 0.06;
	Out.ar(0, sig);
}).add;
)

// At first start the synth:
g = Synth(\fmSynth);

// Play with the parameters:
g.set(\carrierFreq, 880);
g.set(\carrierFreq, 50);
g.set(\carrierFreq, 100, \modulatorRatio, 5, \modulatorIndex, 0.5);
g.set(\carrierFreq, 40, \modulatorRatio, 7, \modulatorIndex, 1.5);
g.set(\carrierFreq, 955, \carrierLvl, 0.4, \modulatorRatio, 3, \modulatorIndex, 4);
// ... etc.

// To stop:
g.free;
/*
rachel's recommended UGens for output, read help files for all!
Pan2
Out
Mix
Splay
Pan4
PanAz
*/
