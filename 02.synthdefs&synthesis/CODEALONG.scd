/*SynthDef
- a class which pre-compiles multiple unit generators together on the server
- greaaat for reuse!
*/

(
SynthDef("kiwi", { // name it
	| pitch=220, pan=0 |
	Out.ar(0, (Pan2.ar(SinOsc.ar(pitch), pan))); // send it to hardware Output Device
}).add; // use "add" to the audio server instead of play
)

x = Synth("kiwi",[\pitch,60.midicps, \pan, -1]);

x.set(\pitch,30.midicps, \pan, 0);

x.free;

// Amplitude Modulation Synthesis
// like tremolo ('trembling')
// generator vs modifier

(
SynthDef("amkiwi", {
	| genfreq=220, pan=0, modfreq=110 |
	Out.ar(0, (Pan2.ar(SinOsc.ar(genfreq), pan, SinOsc.ar(modfreq))));
}).add;
)

x = Synth("amkiwi")
x.set(\genfreq, 330, \modfreq, 56);
x.free;

// Frequency Modulation Synthesis
// like vibrato
// generator vs modifier here

(
SynthDef("fmkiwi", {
	| genfreq=220, pan=0, modfreq=110, sig |
	sig = SinOsc.ar(genfreq*(SinOsc.ar(modfreq)));
	Out.ar(0, (Pan2.ar(sig)));
}).add;
)

x = Synth("fmkiwi")
x.set(\genfreq, 330, \modfreq, 56);
x.free;

// Frequency Modulation Synthesis with depth/index as argument

(
SynthDef("fmwdepthkiwi", {
	| genfreq=220, pan=0, modfreq=110, modamp=1, sig |
	sig = SinOsc.ar(genfreq*(SinOsc.ar(modfreq, 0, modamp)));
	Out.ar(0, (Pan2.ar(sig)));
}).add;
)

x = Synth("fmwdepthkiwi")
x.set(\genfreq, 330, \modfreq, 56, \modamp, 1.7);
x.free;


// Subtractive Synthesis

(
SynthDef('simplesubsynth', {
	var sig;
	// Filtered saw, cutoff/reciprocal of Q controlled by mouse
	sig = RLPF.ar(
		Saw.ar(200),
		MouseX.kr(100, 5000, 1),
		MouseY.kr(0.05, 0.9, 1)
	);

	// Pan to stereo and output
	Out.ar(0, Pan2.ar(sig));
}).add;
)
x = Synth('rdRLPF');


/*Envelopes
  - Envelopes wrap around a sound to start and stop a generating sound
  - Attack, Decay, Sustain, and Release most common type across electronic music
  - SC can do un-sustaining envelopes (timed) and sustaining (untimed)
    - un-sustaining: we have to know how it is going to end when it starts
    - sustaining: we don't know how it is going to end when it starts
    - Gates control sustaining envelopes (they can open and close)
  - **EnvGen** is the UGen to make envelopes (Envelope Generator!)*/

//Shapes:
//unsustaining
Env.linen(1, 2, 3, 0.6).test.plot;
Env.triangle(1, 1).test.plot;
Env.sine(1, 1).test.plot;
Env.perc(0.05, 1, 1, -4).test.plot;
//sustaining
Env.asr(0.2, 0.5, 1, 1).test.plot;
Env.adsr(0.2, 0.2, 0.5, 1, 1, 1).test.plot;
Env.cutoff(1, 1).test(2).plot;
Env.new([0, 0.5, 0.3, 1, 0], [2, 3, 1, 4],curve: [-5, 0, -5]).test.plot; //DIY shape (first array is levels, second array is times)

// Done Actions:

0 - Do nothing when the envelope has ended.
1 - Pause the synth running, it is still resident.
2 - Remove the synth and deallocate it.
3 - Remove and deallocate both this synth and the preceding node.
4 - Remove and deallocate both this synth and the following node.
5 - Same as 3. If the preceding node is a group then free all members of the group.
6 - Same as 4. If the following node is a group then free all members of the group.
7 - Same as 3. If the synth is part of a group, free all preceding nodes in the group.
8 - Same as 4. If the synth is part of a group, free all following nodes in the group.
9 - Same as 2, but pause the preceding node.
10 - Same as 2, but pause the following node.
11 - Same as 2, but if the preceding node is a group then free its synths.
12 - Same as 2, but if the following node is a group then free its synths.
13 - Frees the synth and all preceding and following nodes.


(
SynthDef('subwithunsustain', {
	var sig, env;
	sig = RLPF.ar(
		Saw.ar(200),
	);
	env = Env.triangle(1, 1);
	Out.ar(0, Pan2.ar(sig*EnvGen.kr(env, doneAction:2)));
}).add;
)
x = Synth('subwithunsustain');


(
SynthDef(\subwithsustain, { |gate=1|
    var sig, env;
    sig = RLPF.ar(
        Saw.ar(200, 0.3),
    );
    env = Env.adsr(0.01, 0.2, 0.7, 0.5);
    sig = sig * EnvGen.kr(env, gate, doneAction:2);
    Out.ar(0, Pan2.ar(sig));
}).add;
)

// play it
x = Synth(\subwithsustain);

// release it
x.set(\gate, 0);



/* arrays vs lists
  - Array: fixed size collection (most common)
  - List: variable size collection */

// Additive Synthesis with Array.fill(<num>,{arg i; <code>}) and Mix.ar

(
SynthDef('simpleaddsynth', { |freq=110, amp=0.5|
    var sig;
    sig = Mix.ar(
        Array.fill(3, { |i| SinOsc.ar(freq * (i+1))})
    ) * amp;
	Out.ar(0, Pan2.ar(sig));
}).add;
)

s.freqscope
// play it
x = Synth('simpleaddsynth');

// stop it
x.free;

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

// wave tables are the heart of computer music!
// wave table based on Fieldsteel p.94
(
~wt = Signal.sineFill(400, [1], [0]).asWavetable;
b = Buffer.loadCollection(s, ~wt);
)

{Osc.ar(b, 30) * 0.2 ! 2}.play;