//adapted from: https://en.wikibooks.org/wiki/Designing_Sound_in_SuperCollider
//a plug for pd
// BOOT

(
/*

RM octaver

inSignal is RingModulated by a sinusoidal tone with half frequency.
The resulting spectrum is given by all the components of inSignal with
half freqs.
This means that the new spectrum is a one 8ve below version of the input signal's one,
with only odd partials.
As a consequence, if inSignal is added again, even partials are
recovered.

See:
Miller Puckette, The Theory and Technique of Electronic Music, p. 126
http://crca.ucsd.edu/~msp/techniques/latest/book.pdf
http://crca.ucsd.edu/~msp/techniques/latest/book-html/node77.html#sect5.ringmod

andreavalle

*/

s = Server.local.waitForBoot({
	SynthDef.new(\RmOctaver, { var in, out = 0, freq, hasFreq ;
		in = SoundIn.ar(0) ;
		# freq, hasFreq = Pitch.kr(in) ;
		Out.ar(out, SinOsc.ar(freq: freq*0.5)*in+in);
	}).add ;
})
)


Synth.new(\RmOctaver) ;


// recirculating schroeder reverb with Ndef and DELAYC
b = Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/windchimes.wav");

(
Ndef(\verb, {
	var input, output, delrd, sig, deltimes;

	// Choose which sort of input you want by (un)commenting these lines:
	//input = Pan2.ar(PlayBuf.ar(1, b, loop: 1), -0.5); // buffer playback, panned halfway left
	//input = SoundIn.ar([0,1]); // TAKE CARE of feedback - use headphones
	input = Dust2.ar([0.1, 0.01]); // Occasional clicks

	// Read our 4-channel delayed signals back from the feedback loop
	delrd = LocalIn.ar(4);

	// This will be our eventual output, which will also be recirculated
	output = input + delrd[[0,1]];

	// Cross-fertilise the four delay lines with each other:
	sig = [output[0]+output[1], output[0]-output[1], delrd[2]+delrd[3], delrd[2]-delrd[3]];
	sig = [sig[0]+sig[2], sig[1]+sig[3], sig[0]-sig[2], sig[1]-sig[3]];
	// Attenutate the delayed signals so they decay:
	sig = sig * [0.4, 0.37, 0.333, 0.3];

	// Here we give delay times in milliseconds, convert to seconds,
	// then compensate with ControlDur for the one-block delay
	// which is always introduced when using the LocalIn/Out fdbk loop
	deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;

	// Apply the delays and send the signals into the feedback loop
	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));

	// Now let's hear it:
	output

}).play
)

Ndef(\verb).free;

//throwback dial tone and DICTIONARIES
(
Ndef(\dialtone, {
	// Note: the array here specifies two frequencies, so we get two separate channels.
	// We sum the two channels so they combine into one signal - otherwise we
	// would hear one note on left, one note on right.
	Pan2.ar(SinOsc.ar([350, 440], 0, 0.2).sum)
}).play
)

Ndef(\dialtone).free;

// Dual Tone MultiFrequency phone
(
// This data structure (like a "hashtable" or "associative array" in other languages)
// maps from a phone key to a pair of frequencies in Hz.
// We can push these frequencies to a synth.
~tbl = IdentityDictionary[
	$1 -> [[697, 1209]],
	$2 -> [[770, 1209]],
	$3 -> [[852, 1209]],
	$4 -> [[697, 1336]],
	$5 -> [[770, 1336]],
	$6 -> [[852, 1336]],
	$7 -> [[697, 1477]],
	$8 -> [[770, 1477]],
	$9 -> [[852, 1477]],
	$* -> [[697, 1633]],
	$0 -> [[770, 1633]],
	$# -> [[852, 1633]],
	$A -> [[941, 1209]],
	$B -> [[941, 1336]],
	$C -> [[941, 1477]],
	$D -> [[941, 1633]]
];

// Here we define a SynthDef which plays a single "number" at a time.
// Note that our strategy here is a bit different from the PD code in the book:
//   there, a single pair of sine-wave oscillators was re-used for each number,
//   whereas here, we create (and later free) an individual synth for each number.
SynthDef(\dtmf, {|freq=#[770, 1633], out=0, amp=0.2, gate=1|
	var son, env;
	son = SinOsc.ar(freq, 0, amp).sum;
	env = EnvGen.ar(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(son * env * amp));
}).add;
)

// Check that it works:
x = Synth(\dtmf) // create
x.set(\gate, 0)  // free

(
// This pattern generates a random "phone number" and dials it
Pbind(
	\instrument, \dtmf,
	\dur, Pwhite(0.2, 0.5, inf),
	\sustain, 0.15,
	\amp, 0.3,
	\freq, Prand(~tbl.asArray, 13)
).play;
)

(
// You could even dial a specific number:
Pbind(
	\instrument, \dtmf,
	\dur, Pwhite(0.2, 0.5, inf),
	\sustain, 0.15,
	\amp, 0.3,
	\freq, Pseq("3363551993".collectAs({|digit| ~tbl[digit] }, Array))
).play;
)

// MAKE IT YOUR OWN

// uk ambulance alarm
(
Ndef(\alarm, {
	var tone1 = SinOsc.ar(600);
	var tone2 = SinOsc.ar(800);
	// We switch between the tones using LFPulse, but soften the crossfade with the low-pass:
	var control = LPF.kr(LFPulse.kr(2), 70);
	var out = SelectX.ar(control, [tone1, tone2]);
	Pan2.ar(out * 0.1)
}).play
)

// us police siren with FREEVERB
(
SynthDef(\siren, { |rate=0.1|
	var freq = LFPulse.kr(rate, 0.99, 0.4).lagud(0.4 / rate, 0.6 / rate) * 800 + 300;
	var son  = LFPulse.ar(freq, 0.99, 0.2).lagud(0.4 / freq, 0.6 / freq) * 2 - 1;

	// This filtering is a simple approximation of the plastic horn acoustics:
	son = BPF.ar(son.clip2(0.2), 1500, 1/4) * 4;

	// delay and reverb, to simulate the environment in which we hear the siren
	son = son + DelayC.ar(son, 0.1, 0.1, 0.3);
	son = son + FreeVerb.ar(son);

	Out.ar(0, Pan2.ar(son * 0.4));
}).add;
)

x = Synth(\siren);

x.set(\rate, 3);
x.set(\rate, 0.1);

// alarm with STEPPER
(
Ndef(\alarm, {
	var tone1 = SinOsc.ar(723);
	var tone2 = SinOsc.ar(932);
	var tone3 = SinOsc.ar(1012);
	// Stepper is perfect for stepping through the options:
	var control = LPF.kr(Stepper.kr(Impulse.kr(2), 0, 0, 2), 70);
	var out = SelectX.ar(control, [tone1, tone2, tone3]);
	Pan2.ar(out * 0.1)
}).play
)

// alarm with mousex mapped to duty mapped to Duty/Dseq
(
Ndef(\alarm, {
	var freq, out, operations;
	freq = Duty.kr(0.05, 0, Dseq([723, 932, 1012], inf));
	freq = LPF.kr(freq, 70);
	out = SinOsc.ar(freq);
	operations = [out, (out * pi).sin, (out * pi).cos, ((out+0.25) * pi).cos];
	out = Select.ar(MouseX.kr(0,4).poll, operations);
	Pan2.ar(out * 0.1)
}).play
)

// metallic resonance with KLANK and its cousins
(
{
	var son;
	son = Klank.ar(`[
		[521, 732, 934],  // freqs
		[0.7, 0.45, 0.25],// amps
		[0.8, 0.8, 0.8]   // ring times
		],
	Impulse.ar(1));
	Pan2.ar(son * 0.2)
}.play
)

// phonebell with GROUP
(
SynthDef(\phonebell, { |gate=1, freq=465, strength=1, decay=3, amp=1|
	var trigs, striker, son;
	trigs = Impulse.ar(14) * gate;
	striker = WhiteNoise.ar(EnvGen.ar(Env.perc(0.0000001, 0.01), trigs));
	son = Klank.ar(`[
		// frequency ratios
		[0.501, 1, 0.7,   2.002, 3, 9.6,   2.49, 11, 2.571,  3.05, 6.242, 12.49, 13, 16, 24],
		// amps
		[0.002,0.02,0.001, 0.008,0.02,0.004, 0.02,0.04,0.02, 0.005,0.05,0.05, 0.02, 0.03, 0.04],
		// ring times - "stutter" duplicates each entry threefold
		[1.2, 0.9, 0.25, 0.14, 0.07].stutter(3)
		]
	, striker, freq, 0, decay);
	Out.ar(0, Pan2.ar(son * amp));
}).add
)

// Here we start the phone bells constantly ringing. We put them in a group for convenience
~bellgroup = Group.new(s);
~bell1 = Synth(\phonebell, [\freq, 650], ~bellgroup);
~bell2 = Synth(\phonebell, [\freq, 653], ~bellgroup);


// OK, shush for now
~bellgroup.set(\gate, 0);

// Now let's turn them on and off in a telephone-like pattern.
// This could be done using a synth, but let's use a (client-side) pattern:
p = Pbind(\type, \set, \id, ~bellgroup.nodeID, \args, [\gate], \gate, Pseq([1,0], inf), \dur, 2).play
p.stop;

// bouncing ball (like maths makenoise module)
(
Ndef(\bouncer, {

var bounceperiod, bouncetrigs, amp, fm, mainosc;

bounceperiod = Line.kr(0.3, 0, 3, doneAction: 2);

bouncetrigs = Impulse.kr(bounceperiod.reciprocal.min(30));

amp = EnvGen.ar(Env.perc(0.001, 0.0), bouncetrigs);
amp = Amplitude.ar(amp, 0, bounceperiod) * Line.kr(1, 0.05, 3);

fm =
	SinOsc.ar(120).range(0, Line.ar(1, 0, 3))
		+
	(amp * Line.ar(1, 0, 3).cubed * 130 + 80)
;

mainosc = SinOsc.ar(fm, pi/2);

amp * mainosc;
}).play
)

// hit a can
(
x = { |t_trig=0|
	// This line just creates a sharp little spike whenever we want:
	var strike = EnvGen.ar(Env.perc(0.0001, 0.001, 0.1), t_trig);
	// here's the resonances:
	var son = Ringz.ar(strike, [359, 426, 1748, 3150], 0.2).sum;
	// some distortion livens up the spectrum a little:
	son = HPF.ar(son.clip2(0.6), 300);
	son * 0.2
}.play;
)
x.set(\t_trig, 1); // Run this line to hit the can!

// can fall and roll
(
~regularroll = { |rate = 1|
	// In the original code, Andy uses a master phase control,
	// wrapping and re-scaling it before differentiating, to produce
	// a repeating but disorderly set of impulses.
	// Here we do it differently - we use Impulse.kr to generate the
	// impulses directly.
	// We evaluate this function multiple times using .dup so that
	// we get a whole set of impulses with random phase positions.
	{
		Impulse.kr(rate, 1.0.rand, 1.0.bilinrand)
	}.dup(10).sum
};
~regularroll.plot(2);
);
(
// This signal contribution to rolling signature based on Mathias Rath's idea - see 'The Sounding Object'
// (ajf2009) with K2A and Ringz
//
~irregularground = { |rate=10|
	var trigs = Dust.kr(rate);
	EnvGen.ar(

		Env([0,0,-1,1.5,-1,1,0], [0.1, 0.1, 0.001, 0.001, 0.1, 0.1], 'sine'),
		trigs
	) * 0.1
};
~irregularground.plot(4)
);
(
x = {
	var rate, strike, son;
	// rate of motion starts fast and tails off
	rate = XLine.kr(4, 0.001, 8, doneAction: 2);
	// This rate affects both the regular rolling, and the irregular ground contacts.
	strike =
		~irregularground.(rate*2) * 0.04
			+
		K2A.ar(~regularroll.(rate) * 0.1)
			;
	// Force the strikes to die off in intensity:
	strike = strike * XLine.ar(1, 0.0001, 8);
	// And here are the tin-can resonances as in fig 31.3:
	son = Ringz.ar(strike, [359, 426, 1748, 3150], 0.2).sum;
	son = HPF.ar(son.clip2(0.6), 300);
	son * 0.2
}.play;
)

//fire
(
~firegen = {
	var trigs, durscale, resfreq;
	var noise, hissing, crackles, lapping;
	// A common noise source
	noise = WhiteNoise.ar;
	// Hissing
	hissing = HPF.ar(noise, 1000) * LFNoise2.kr(1).squared.squared;
	// Crackle
	trigs = Dust.kr(3);
	durscale = TRand.kr(1, 1.5, trigs); // vary duration between default 20ms and 30ms
	resfreq = TExpRand.kr(100, 1000, trigs); // different resonant frequency for each one
	crackles = noise * EnvGen.ar(Env.perc(0, 0.02, curve: 0), trigs, timeScale: durscale);
	crackles = crackles + BPF.ar(crackles, resfreq, 20);
	// Flame
	lapping = LeakDC.ar(LeakDC.ar(BPF.ar(noise, 30, 0.2) * 50).clip2(0.9)) * 0.5;
	// Combine them:
	([crackles, hissing, lapping] * [0.1, 0.3, 0.6]).sum * 3
};
~firegen.play
)

//bubbles with pbind
(
SynthDef(\bubblebub, {	|out=0, t_trig=0, attack=0.01, decay=0.08, pitchcurvelen=0.1, freq=1000, doneAction=0, amp=0.1|
	var pitch, son;
	amp   = amp * EnvGen.ar(Env.perc(attack, decay).delay(0.003), t_trig, doneAction: doneAction);
	pitch = freq * EnvGen.ar(Env.new([0,0,1],[0,1]).exprange(1, 2.718), t_trig, timeScale: pitchcurvelen);
	son = SinOsc.ar(pitch);
	// high-pass to remove any lowpitched artifacts, scale amplitude
	son = HPF.ar(son, 500) * amp * 10;
	Out.ar(out, Pan2.ar(son));
}).add
);
(
p = Pbind(
	\instrument, \bubblebub,
	\sizefactor, Pwhite(0.0,1,inf),
	\dur, Pgauss(0.3, 0.2),
	\freq,  Pkey(\sizefactor).linexp(0, 1, 1000, 3000),
	\amp ,  Pkey(\sizefactor).linlin(0, 1, 0.15, 0.04),
	\decay, Pkey(\sizefactor).linlin(0, 1, 0.05, 0.08),
	\doneAction, 2
).play
)
p.stop

///MAKE IT YOUR OWN

//running water
(
x = {
	var trigs, freq;
	6.collect{
		trigs = Dust.kr(170);
		freq =
			// Generally choose from a varied base freq
			TExpRand.kr(800, 2000, trigs)
			// Wobbly variation
			+ LFNoise2.kr(20, mul: 300)
			// General tendency for upward rise
			+ EnvGen.kr(Env.perc(1).range(0,17), trigs)
			;
		SinOsc.ar(freq, 0, 0.3)
	}.mean
}.play;
)
x.free;

//electrical hum with sparks
(
{
var noise, phasor, chirpPulse, randGate, chirpAmp, clip, snap, trig, formant, comb;

phasor = LFSaw.ar([-99.8, 100.2], 1, 0.5, 0.5);

noise = WhiteNoise.ar!2;
noise[0] = OnePole.ar(noise[0], exp(-2pi * (0.1 * SampleDur.ir)));
noise[0] = OnePole.ar(noise[0], exp(-2pi * (0.1 * SampleDur.ir)));
noise[0] = noise[0].max(0) * 700 + 3;


// fig 39.4: Chirp pulse
chirpPulse = phasor[0].scope * noise[0];
chirpPulse = chirpPulse.min(1) - (chirpPulse.max(1) - 1 * 1e+09).min(1);
chirpPulse.scope;
chirpPulse = ((chirpPulse + 0.1)**2 * 12 * 2pi).cos * chirpPulse;
chirpPulse.scope;
chirpPulse = (chirpPulse - OnePole.ar(chirpPulse, exp(-2pi * (300 * SampleDur.ir))));


// fig 39.5: Random Gate
randGate = WhiteNoise.ar;
randGate = OnePole.ar(randGate, exp(-2pi * (3 * SampleDur.ir)));
randGate = OnePole.ar(randGate, exp(-2pi * (3 * SampleDur.ir)));
randGate = Clip.ar(noise.max(2) - 0.0008 * 1e+09, 0, 1);
randGate = OnePole.ar(randGate, exp(-2pi * (30 * SampleDur.ir)));
randGate = chirpPulse * randGate;


noise[1] = LPF.ar(LPF.ar(WhiteNoise.ar,2),2);
noise[1] = noise[1] * noise[1] * 500;


clip = Clip.ar((phasor.sum - 1) * noise[1], -0.9, 0.1);


chirpAmp = OnePole.ar(clip, exp(-2pi * (15 * SampleDur.ir)));
chirpAmp = OnePole.ar(chirpAmp, exp(-2pi * (15 * SampleDur.ir)));
chirpAmp = Clip.ar((chirpAmp * 500).max(0.1) - 0.1 * 1e+09, 0, 1);
chirpAmp = OnePole.ar(chirpAmp, exp(-2pi * (30 * SampleDur.ir)));


chirpPulse = chirpPulse * chirpAmp * 0.6;
trig = (Amplitude.kr(clip)>0.03);


// fig 39.7: Spark snap
snap = 0!2;
snap[0] = EnvGen.ar(Env.new([0,1,0], [0, 0.5]), trig);
snap[0] = snap[0] * snap[0] * snap[0] * WhiteNoise.ar * 0.5;
snap[1] = EnvGen.ar(Env.new([0,1,0], [0, 10/1000]), trig);
snap[1] = SinOsc.ar(snap[1] * 7000 + 20);
snap = snap.sum * 0.05;


// fig 39.6: Spark formant
formant = BPF.ar(snap, 1.8 * [4600, 7200, 480, 720], [5,5,7,8].reciprocal);
formant = formant[0..1].sum * 2 + formant[2] * 1.2 + formant[3] * 2.5;
formant = BPF.ar(formant, 2500, 0.5.reciprocal);


// fig 39.2 Comb unit
comb = DelayC.ar(InFeedback.ar(10), delaytime: (noise[1] + 20)/1000);
OffsetOut.ar(10, (chirpPulse + clip + snap + OnePole.ar(comb * 0.2, exp(-2pi * (3000 * SampleDur.ir)))));

comb!2;

}.play;
)

//cricket with WRAP
(
a = {
	var modulator, mod1, mod2, mod3;

	// repeat time is 0.7s: equates to 1.43 Hz.
	modulator = LFSaw.ar(1.43, 1, 0.5, 0.5);
	mod2 = (modulator * 40.6 * 2pi).cos.squared;
	mod3 = modulator * 3147;
	mod3 = (mod3 * 2pi).cos + ((mod3 * 2 * 2pi).cos * 0.3);
	mod1 = ((Wrap.ar(modulator.min(0.1714) * 5.84) - 0.5).squared * (-4) + 1) * (mod2 * mod3);
	mod1 = (mod1 * 0.1)!2;
}.play;
)

// To stop:
a.free;

//cicada
(
c = {
	var sig, trig, seq, freq, mul, vals;

	trig = Impulse.kr(0.2);
	vals = [
		[0.5, 128],
		[8,6],
		[30,3]
	];
	freq = TChoose.kr(trig, vals);


	sig = WhiteNoise.ar;
	// The one pole filters in pure data and SC differ, so I changed the coefficents
	// a little. Also the  multiplication by 5 is not in the book, but helps to
	// approach the audible result of Farnells patch.
	sig = (sig - OnePole.ar(sig, exp(-2pi * (8000 * SampleDur.ir))));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (8000 * SampleDur.ir))));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = sig * 5;


	sig = BPF.ar(sig, [7500, 5500], 40.reciprocal).sum * SinOsc.ar(500);
	sig = sig * (1 / (SinOsc.ar( freq[0], 0, freq[1] ).squared + 1));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (4000 * SampleDur.ir)))) * 4.dup;
}.play;
)

// To stop:
c.free;


//housefly
(
SynthDef(\houseflyWing, { |out=0|
	var sig, downstroke, upstroke, wingFreq, wingRes;

	// this is already a preparation for fig 50.14 and is not described
	// in the pure data patch on fig 50.13
	wingFreq = In.ar(10,2);
	wingRes = In.ar(20,2);

	// Also, it is prepared for some other input from a different source,
	// to not only control the patch with the mouse movement.
	// See also the following URL for more information about the next lines:
	// http://supercollider.sourceforge.net/wiki/index.php/Boolean_logic_in_the_server
	wingFreq = Select.ar(wingFreq > 0, [K2A.ar(MouseX.kr(0, 300)), wingFreq]);
	wingRes = Select.ar(wingRes > 0, [K2A.ar(MouseY.kr(3,5)), wingRes]);

	sig = LFSaw.ar(wingFreq, 1, 0.5, 0.5);
	sig = ((sig * 0.2).min(sig * (-1) + 1)).min(sig.min(sig * (-1) + 1));
	sig = (sig * 6 - 0.5) * 2;

	downstroke = (wingRes) * sig.min(0);
	downstroke = (Wrap.ar(downstroke) * 2pi).cos * sig.min(0) * 0.5 + sig.min(0);
	upstroke = sig.max(0).cubed * 2;

	sig = downstroke + upstroke;
	sig = (sig - OnePole.ar(sig, exp(-2pi * (700 * SampleDur.ir)))).dup * 0.05;
	Out.ar(out, sig);
}).add;
x = Synth(\houseflyWing);
);

(
(
SynthDef(\buzzingHousefly, {
	var beatingFreq, resonanceMod;

	beatingFreq = OnePole.ar(WhiteNoise.ar, exp(-2pi * (4 * SampleDur.ir)));
	beatingFreq = OnePole.ar(beatingFreq, exp(-2pi * (4 * SampleDur.ir)));
	beatingFreq = beatingFreq * 700 + 220;

	resonanceMod = OnePole.ar(WhiteNoise.ar, exp(-2pi * (5 * SampleDur.ir)));
	resonanceMod = OnePole.ar(resonanceMod, exp(-2pi * (5 * SampleDur.ir)));

	Out.ar(10, [beatingFreq, (resonanceMod * 3) + beatingFreq]);
	Out.ar(20, (resonanceMod * 40 + 5)!2 );
}).add);
y = Synth(\buzzingHousefly);
)

//red alert
(
SynthDef(\red, {

	var env, redAlert, dfbe, aIn, bIn, cIn, aOut, bOut, cOut;

	# aIn, bIn, cIn = LocalIn.ar(7).clumps([5,1,1]);

	env = [EnvGen.ar(Env.new([0,1,1,0], [0.9, 0.3, 0.0])), EnvGen.ar(Env.new([0,1,1,0], [0.01, 0.88, 0.01]))];
	env[0] = LFSaw.ar(env[0].sqrt * 487 + 360, 1, 0.5, 0.5);
	env[0] = (env[0] - 0.5) + ((env[0] * 2 * 2pi).cos * 0.3);
	redAlert = (env[0] - OnePole.ar(env[0], exp(-2pi * (1 * SampleDur.ir)))) * env[1];
	redAlert = redAlert + (cIn * 0.006) * 0.2;


	// fig 58.6: Delay feedback element
	dfbe = 0!6;
	redAlert = redAlert + (aIn * 0.7);
	5.do{|i| dfbe[i] = DelayN.ar(redAlert[i], 0.1, [0.015, 0.022, 0.035, 0.024, 0.011][i])};
	aOut = dfbe[0..4];

	redAlert = redAlert[0..4].sum;
	redAlert = (redAlert - OnePole.ar(redAlert, exp(-2pi * (12 * SampleDur.ir))));

	dfbe[5] = redAlert + (bIn * 0.7);
	dfbe[5] = DelayN.ar(dfbe[5], 0.1, 0.061);
	# bOut, cOut = dfbe[5]!2;
	LocalOut.ar(aOut ++ bOut ++ cOut);

	redAlert = Clip.ar(redAlert * 4, -1, 1);
	redAlert = BPF.ar(redAlert, [740, 1400, 1500, 1600], (12!4).reciprocal) ++ (redAlert * 0.5);
	Out.ar(0, (redAlert.sum * 0.2)!2);

}).add;
)


// ALL HANDS!! BATTLESTATIONS!
e = Synth(\red);

//babbling R2D2
(
w = {	|period=0|
	var change, rate, sig, carrierFreq, cfRamp, carrierLvl, clRamp,
	modulatorRatio, mrRamp, modulatorIndex, miRamp, outputAmplitude, oaRamp;

	period = period * 600 + 100;

	// Calculation of a recursive working metronome (Impulse.kr) that generates its
	// changing frequency out of its own impulses.
	change = Impulse.kr(LocalIn.kr(1,10));
	rate = CoinGate.kr(1/3, change);
	rate = (TChoose.kr(rate, period/((0..1) + 1))/1000).reciprocal;
	LocalOut.kr(rate);

	# carrierFreq, cfRamp = TIRand.kr(0, [1000, 1], change);
	carrierFreq = Ramp.kr( carrierFreq / 1000, (cfRamp * period) / 1000 ) * 0.6;

	# carrierLvl, clRamp = TIRand.kr(0, [9000, 1], CoinGate.kr(1/3, change));
	carrierLvl = Ramp.kr( carrierLvl, (clRamp * period) / 1000) + 100;

	# modulatorRatio, mrRamp = TIRand.kr([800,1], CoinGate.kr(1/4, change));
	modulatorRatio = Ramp.kr(modulatorRatio, (mrRamp * period) / 1000) + 20;

	# modulatorIndex, miRamp = TIRand.kr(0, [100, 1], CoinGate.kr(1/4, change));
	modulatorIndex = Ramp.kr(modulatorIndex / 200, (miRamp * period) / 1000) + 0.2;

	# outputAmplitude, oaRamp = TIRand.kr(0!2, 1!2, CoinGate.kr(1/2, change));
	outputAmplitude = Ramp.kr(outputAmplitude, (oaRamp * period + 3) / 1000);

	// jointed FM Synthesizer
	sig = LFSaw.ar(carrierFreq, 1, 0.5, 0.5) * carrierLvl;
	sig = sig + SinOsc.ar(carrierFreq * modulatorRatio) * modulatorIndex;
	sig = cos(sig * 2pi) * outputAmplitude;

	// One pole filters:
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (100 * SampleDur.ir))));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (100 * SampleDur.ir))));
	sig = sig!2 * 0.06;
}.play;
)

// period controls the talk-speed. range: 0-1. 0 matches to fast, 1 to slow:
w.set(\period, 1);
w.set(\period, 0);
w.set(\period, 0.5);
w.set(\period, 0.7);
w.set(\period, 0.3);

// To stop:
w.free;

// shepard tones
// alberto de campo
(
var ampTable, freqTable, b1, b2;

ampTable = Signal.hanningWindow(1024).squared;
freqTable = Signal.newClear(1024).waveFill({ arg i; 0.5 ** i * 20000 }, 0, 10);

b1 = Buffer.loadCollection(s, freqTable);
b2 = Buffer.loadCollection(s, ampTable);

{
	var freqs, amps, phasor, ratescale, rate, phases;
	ratescale = 1024 / 44100 / 10;
	rate = 0.1;	// once per 10 sec
	phasor = Phasor.ar(0, rate * ratescale, 0, 1024);
	phases = (0..9) * 0.1 * 1024 + phasor;

	freqs = BufRd.ar(1, b1.bufnum, phases);
	amps = BufRd.ar(1, b2.bufnum, phases);

	Mix.ar(SinOsc.ar(freqs) * amps) * 0.1;
}.play;

)

