// adapted from: https://doc.sccode.org/Tutorials/A-Practical-Guide/PG_01_Introduction.html

/*

BUSSES, NODES, & STREAMS

Busses
Generally your analog definition works: how we route audio to new places, but they're actually a little more complicated than that.

When we boot the audio server and see the I/O we see something like:
"MacBook Pro Speakers" Output Device
   Streams: 1
      0  channels 2

This means that there is a STEREO bus called "0" on the server RECEIVING 1 STREAM which is sending stereo out to our hardware output device.

So, what's a Stream?

SC puts abstract objects (meaning we don't necessarily explicitly declare them) on busses on the server that wait to receive messages. Nodes are the most common of these types of objects. Messages travel to Nodes and other abstract objects on Streams. There are two types of Nodes, Synths and Groups. Killing a Node is actually what you're doing when you use command|. to silence.

There is a special type of Stream called an Event Stream which basically allows the Stream to continue to deliver messages but Nodes can start and stop doing the things ON the messages.

PBind is the most common UGen that uses this Stream/Event Stream feature.
*/


(
Pbind(
  \midinote, Pseq([60, 62, 64, 65, 67, 69, 71, 72]),
  \dur, 1
).play
)
s.plotTree; // watch it with .plotTree


// Twinkle Twinkle Little Star
(
Pbind(
  \midinote, Pseq([60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,67, 67, 65, 65, 64, 64, 62,67, 67, 65, 65, 64, 64, 62,60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2]),
).play
)
)

// Twinkle Twinkle Little Star with more algorthmic efficiency
(
Pbind(
  \midinote, Pseq([60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,67, 67, 65, 65, 64, 64, 62,67, 67, 65, 65, 64, 64, 62,60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60]),
	\dur, (Pseq([1, 1, 1, 1, 1, 1, 2], 6)*0.6)
).play
)

// and even more
(
var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

Pbind(
  \midinote, Pseq(a ++ b ++ b ++ a),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)

// and more
(
var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

Pbind(
  \midinote, Pseq(a) ++ Pseq(b, 2) ++ Pseq(a),
	\dur, (Pseq([1, 1, 1, 1, 1, 1, 2], 6)*0.03),
).play
)

// and more

Scale.directory

(
var a = Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]);
var b = Pseq([4, 4, 3, 3, 2, 2, 1]);

Pbind(
  \scale, Scale.prometheus, // lc
  \root, 6, // lc
  \octave, 5,
  \degree, a ++ b ++ b ++ a,
	\dur, (Pseq([1, 1, 1, 1, 1, 1, 2], 6))*0.5,
).play
)

// C for infinity
(
Pbind(
  \midinote, [60,64,67],
  \dur, 4).play
)

// C - G for infinity
(
Pbind(
  \midinote, Pseq([[60,64,67], [67,71,74]], inf),
  \dur, 4).play
)

// all together

(
var c = [0, 2, 4];  // C E G
var f = [0, 3, 5];  // C F A
var g7 = [-1, 1, 3, 4]; // B D F G

var progA = Pseq([c, f, c, f, c, g7, c]);
var progB = Pseq([c, f, c, g7, c, f, c, g7]);

var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 6, 65, 65, 64, 64, 62];

var prog = Pbind(
	\octave, 5,
	\degree, progA ++ progB ++ progB,
	\dur, Pseq([4, Pseq([2], 14), 4, Pseq([2], 6)])));

var melody = Pbind(
	\midinote, (Pseq(a) ++ Pseq(b, 2) ++ Pseq(a)) + 12,
	\dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
);

Ppar([melody, prog]).play
)


// default pbind synth vs synthdef

(
SynthDef(\cfstring1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

e = Pbind(
    \degree, Pseq((-12..24), inf),
    \dur, 0.2,
    \instrument, \cfstring1
).play; // returns an EventStream
)

( // an interactive session
e.stop
e.play
e.reset
e.mute; // keeps playing, but replaces notes with rests
e.unmute;
)

// WHAT IS YOUR CODE ANALYSIS PROJECT?

/*Simple Pattern UGens to go with PBind from https://doc.sccode.org/Browse.html#Streams-Patterns-Events
  - **Pseq**
  - Goes through sequence */

(
p = Pbind(
    \degree, Pseq(#[0, 0, 4, 4, 5, 5, 4], 3),
    \dur, Pseq(#[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1], 3)
).play;
)
p.stop;
p.play;
/*
  - **Pseries**
  - Arithmetic
  - **Pgeom**
  - Geometry*/

(
p = Pbind(
    \degree, Pseries(-7, 1, 15),
    \dur, Pgeom(0.5, 0.89140193218427, 15)
).play;
)

/*
  - **Prand**
- "Randomly" chooses from array */

(
p = Pbind(
    \degree, Prand([0, 1, 2, 4, 5], inf),
    \dur, 0.25
).play;
)
/*
  - **Pxrand**
  - "Randomly" chooses but never twice in a row*/

(
p = Pbind(
    \degree, Pxrand([0, 1, 2, 4, 5], inf),
    \dur, 0.25
).play;
)
/*
  - **Pshuf**
  - Shuffles the list in random order but then uses the same random order*/

(
p = Pbind(
    \degree, Pshuf([0, 1, 2, 4, 5], inf),
    \dur, 0.25
).play;
)
/*
  - **Pwrand**
  - Chooses "randomly" according to weighted probabilities*/

(
p = Pbind(
	\degree, Pwrand([0, 1, 2, 3, 4, 5, 6, 7], [4, 2, 2, 2, 2, 2, 4].normalizeSum, inf),
    \dur, 0.25
).play;
)

/* Probability
Pwhite(lo, hi, length)
Produces length random numbers with equal distribution ('white' refers to white noise).
Pexprand(lo, hi, length)
Same, but the random numbers have an exponential distribution, favoring lower numbers. This is good for frequencies, and also durations (because you need more notes with a shorter duration to balance the weight of longer notes).
Pbrown(lo, hi, step, length)
Brownian motion. Each value adds a random step to the previous value, where the step has an equal distribution between -step and +step.
Pgbrown(lo, hi, step, length)
Brownian motion on a geometric scale. Each value multiplies a random step factor to the previous value.
Pbeta(lo, hi, prob1, prob2, length)
Beta distribution, where prob1 = α (alpha) and prob2 = β (beta).
Pcauchy(mean, spread, length)
Cauchy distribution.
Pgauss(mean, dev, length)
Gaussian (normal) distribution.
Phprand(lo, hi, length)
Returns the greater of two equal-distribution random numbers.
Plprand(lo, hi, length)
Returns the lesser of two equal-distribution random numbers.
Pmeanrand(lo, hi, length)
Returns the average of two equal-distribution random numbers, i.e., (x + y) / 2.
Ppoisson(mean, length)
Poisson distribution.
Pprob(distribution, lo, hi, length, tableSize)
Given an array of relative probabilities across the desired range (a histogram) representing an arbitrary distribution, generates random numbers corresponding to that distribution.
*/
(
(
a = (
    pattern: Pbind(\note, Pgeom(1, 1.1, { 20.rand }), \dur, 0.05),
    embedInStream: { |event, inevent| event[\pattern].embedInStream(inevent) }
);
b = (note: [3, 5]);
c = (freq: 402, dur: 0.3);
Prand([a, b, c], inf).play;
)
)

// change the events while playing
c[\freq] = [900, 1002, 1102];
c[\freq] = [200, 101, 1102];


// NDef by redFrik;

(
s.waitForBoot{

	SynthDef(\p, {|out= 0, freq= 400, amp= 0.1, gate= 1, detune= 0|
		var env= EnvGen.ar(Env.perc(Rand(0.001, 0.01), LinRand(0.2, 0.4), amp, Rand(-9, -1)), doneAction:2);
		var snd= Mix(SinOsc.ar(freq+[0, detune*0.1], env*2pi));
		Out.ar(out, Pan2.ar(snd*env, Rand(-1, 1)));
	}).add;
	Ndef(\p, Pspawn(Pbind(\method,\par,\delta,1/8,\pattern,{Pbind(\instrument, \p, \dur,a=Pseq((1..9).sputter),\sustain,1/8/a,\degree,a,\detune,a)})));
	Ndef(\p).play(vol:0.5);

	Ndef(\t, {
		var mod= Saw.ar([3, 4], Saw.ar(1, 32, 128), Duty.ar(1, 0, flop(Dseq([0, 8, 1, 5])*[1, 4, 8])));
		var snd= SinOsc.ar(Saw.ar(2, 64, 99), mod)/9;
		CombN.ar(snd, 1/4, 1/4.125, SinOsc.kr(0.005, 1.5pi).range(0, 6));
	});
	Ndef(\t).play(vol:0.5);

	Routine.run({
		var cnt= 1;
		loop{
			var syn;
			cnt= cnt%8+1;
			syn= {
				var del= DelayN.ar(InFeedback.ar(0, 2)+(InFeedback.ar(100, 2)), 1, 1);
				SinOsc.ar(cnt*99+[0, 2], del[1..0])/4;
			}.play(outbus: 64);
			{syn.release(16)}.defer(9-cnt);
			wait(9-cnt);
		};
	});
	Ndef(\c, {InFeedback.ar(64, 2)}).play(vol:0.5);

	Ndef(\r, {
		var lfos= LFNoise1.ar(0.5!2);
		var snd= Crackle.ar(lfos.range(1.8, 1.98));
		Formlet.ar(snd, TExpRand.ar(200, 2000, lfos).lag(2), lfos.range(5e-4, 1e-3), 0.0012);
	});
	Ndef(\r).play(vol:0.25);

	Routine.run({
		loop{
			var syn= {
				var snd= Pluck.ar(Crackle.ar([1.9, 1.8]), Mix(Impulse.ar({5.linrand+1}!2, -0.125)), 0.05, 0.05.linrand);
				BPF.ar(snd, 2000.rand+100, 0.25.rrand(1.75));
			}.play(s, 62, 18);
			{syn.release(69)}.defer(18);
			wait(18);
		};
	});
	Ndef(\m, {InFeedback.ar(62, 2)*SinOsc.kr(0.006).range(0.25, 1)}).play(vol:0.5);

	NdefMixer(s);
	s.meter;
};
)
