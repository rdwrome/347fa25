//140 Characters DUE/PLAYED IN CLASS

//ANALYSIS IS COMING!

// Vera Molnar: Hommage à Duerer (1948-92)

(
w = Window.new("Vera Molnar: Hommage a Duerer (1948-92)", Rect(20, 20, 720, 720), false).front;
w.view.background_(Color.white);
x = Array.fill2D(4, 4, _ @ _).flat.scramble * 20;
w.drawFunc = {
	Pen.strokeColor = Color.black;
	Pen.translate(10, 10);
	9.do {
		9.do {
			Pen.moveTo(x.first);
			x.do { |point, i|
				Pen.lineTo(point);
			};
			x = x.scramble;
			Pen.translate(80, 0);
			Pen.stroke;
		};
	Pen.translate(80 * -9, 80);
	};
};
w.refresh;
)

/*
adapted from:
https://doc.sccode.org/Guides/GUI-Introduction.html
*/

// GOOEY (take a look at all the UGens

w = Window.new("rachel doesn't remeber cartesian stuff", Rect(400,400,255,100));
b = Button.new(w,Rect(10,0,80,30)).states_([["yes"],["no"]]);
l = Slider.new(w,Rect(95,0,150,30));
c = CompositeView.new(w,Rect(20,35,100,60));
StaticText.new(c,Rect(0,0,80,30)).string_("Hello");
StaticText.new(c,Rect(20,30,80,30)).string_("World!");
b.action = { c.visible = b.value.asBoolean.not };
l.action = { c.bounds = Rect( l.value * 150 + 20, 35, 100, 100 ) };
w.front;

// colorful GOOEY

(
w = Window("GUI Introduction").background_(Color.rand).front;
b = Button(w, Rect(10,10,100,30)).states_([
    ["a",Color.rand,Color.rand],
    ["b",Color.rand,Color.rand],
    ["c",Color.rand,Color.rand]
]);
l = ListView.new(w, Rect(10,50,200,100))
    .items_(["One","Two","Three"])
    .colors_([Color.rand,Color.rand,Color.rand])
    .hiliteColor_(Color.blue)
    .selectedStringColor_(Color.white);
r = Slider(w, Rect(10, 160, 200, 20))
    .knobColor_(Color.rand)
    .background_(Color.rand);
)

// fo(u)nt of GOOEY

Font.availableFonts;

(
w = Window.new("GUI Introduction",Rect(200,200,200,70)).front;
a = [Font.defaultMonoFace, Font.defaultSansFace, Font.defaultSerifFace];
b = Button.new(w,Rect(10,10,180,50))
    .states_([["Monospace"],["Sans serif"],["Serif"]])
    .font_(a[0])
    .action_({|b| b.font = a[b.value]});
)

/*
adapted from Eli Fieldsteel week 12:
https://uofi.app.box.com/s/b2hapggp6taaeac2uppqpommau3rhypv/file/1067298603558
*/

//Oh, so you wanted sound? with a slider

(
Window.closeAll;
x = {
	var sig;
	sig = SinOsc.ar(\freq.kr(300).lag(1), mul:0.1!2);
}.play;

w = Window.new(bounds: Rect(1000, 100, 100, 400)).front;
w.alwaysOnTop_(true);
w.onClose_({ x.free; });
~view = Slider.new();
~view.action_({
	arg v;
	x.set(
		\freq,
		v.value.linexp(0, 1, 200, 1000).postln);
});
w.layout_(HLayout(~view));
)

// with a button (from the Button help file)
(
s.waitForBoot({
    var w, p, snd, b;

    w = Window.new;

    b = Button(w, Rect(20, 20, 80, 26))
            .states_([["start a sound", Color.black, Color.green], ["stop", Color.black, Color.red]])
            .action_({});

    v = VLayoutView(w, Rect(140, 20, 200, 300)); //Group the following views
    StaticText(v, Rect(20, 20, 180, 60))
        .string_("The button does nothing at first, so try dragging a function to the button");

    DragSource(v, Rect(20, 20, 80, 26))
        .object_(
            {|b| (b.value == 1).if{ snd = { SinOsc.ar(440,0,0.6) }.play} { snd.free }; } //a button action function
            )
        .string_("a play sine function").align_(\center).background_(Color.rand);

    DragSource(v, Rect(20, 20, 80, 26))
        .object_(
            {|b| (b.value == 1).if{ snd = { Saw.ar(440,0.4) }.play} { snd.free }; } //a button action function
            )
        .string_("a play saw function").align_(\center).background_(Color.rand);

    DragSource(v, Rect(20, 20, 80, 26))
        .object_(
            {|b| (b.value == 1).if{ snd = { WhiteNoise.ar(0.4) }.play } { snd.free }; } //a button action function
            )
        .string_("a play noise function").align_(\center).background_(Color.rand);

    p = CmdPeriod.add({ b.value_(0) }); // set button to 0 on hitting Cmd-period
    w.onClose_{ snd.free; CmdPeriod.removeAll };//clean up when window is closed
    w.front;
})
)

// GUIs used to be OPERATING SYSTEM SPECIFIC and that was terrible, they're on Qt now
// GUIS don't play well with OSC, MIDI or CLOCKS

// MIDI
/*
SIMPLE MIDI IN:
https://doc.sccode.org/Guides/UsingMIDI.html
*/

(
var notes, on, off;
​
MIDIClient.init;
MIDIIn.connectAll;
​
notes = Array.newClear(128);    // array has one slot per possible MIDI note
​
on = MIDIFunc.noteOn({ |veloc, num, chan, src|
    notes[num] = Synth(\default, [\freq, num.midicps,
        \amp, veloc * 0.00315]);
});
​
off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    notes[num].release;
});
​
q = { on.free; off.free; };
)
​
// when done:
q.free;

// Car Engine controlled by MIDI IN CC from Designing Sound by Andy Farrell
(
e = SynthDef(\engine, {

	| // arguments range: 0.0 - 1.0
	mixCylinders   = 0.8,
	mixParabolic   = 0.9,
	engineSpeed    = 0,
	parabolaDelay  = 0.15,
	warpDelay      = 0.4,
	waveguideWarp  = 0.67,
	wguideFeedback = 0.35,
	wguideLength1  = 0.2,
	wguideLength2  = 0.3,
	wguideWidth1   = 0.5,
	wguideWidth2   = 0.7
	|

	// To be able to send arrays as arguments you have to declare them as variables and
	// use NamedControl.kr. Take also a look at the MIDI example at the bottom how to address them.
	var transDelay = NamedControl.kr(\transDelay, [0.2, 0.3, 0.45]);
	var overtonePhase = NamedControl.kr(\overtonePhase, [0.25, 0.35, 0.5]);
	var overtoneFreq = NamedControl.kr(\overtoneFreq, [0.3, 0.47, 0.38]);
	var overtoneAmp = NamedControl.kr(\overtoneAmp, [0.1, 0.2, 0.2]);

	var noise, bufferA, bufferB, bufferTd, fourstroke, phasor, td, parabola, fm1, preFM1,
	fm2, preFM2, overtone, overtoneDrive, e1b, e2a, e2b, e1a, spacewarp, engine;

	engineSpeed = MouseX.kr(0,1);


	bufferA = LocalBuf(44100, 1);
	bufferB = LocalBuf(44100, 1);
	bufferTd = LocalBuf(44100, 1);


	noise = WhiteNoise.ar;
	noise = OnePole.ar(noise, exp(-2pi * (20 * SampleDur.ir)));
	noise = OnePole.ar(noise, exp(-2pi * (20 * SampleDur.ir)));
	noise = (DelTapWr.ar([bufferA, bufferB], [noise * 0.5, noise * 30]));

	phasor = LFSaw.ar(
		OnePole.ar(K2A.ar(engineSpeed) * 30, exp(-2pi * (0.8 * SampleDur.ir))),
		1, 0.5, 0.5);
	td = DelTapWr.ar(bufferTd, phasor);

	fourstroke = DelTapRd.ar(bufferA, noise[0], [5, 10, 15, 20]/1000, 4);
	fourstroke = phasor + fourstroke - [0.75, 0.5, 0.25, 0];
	fourstroke = (fourstroke * 2pi).cos;
	fourstroke = fourstroke * (DelTapRd.ar(bufferB, noise[1], [5, 10, 15, 20]/1000, 4) + ((1 - engineSpeed) * 15 + 7));
	fourstroke = 1 / ((fourstroke * fourstroke) + 1);
	fourstroke = fourstroke.sum * mixCylinders;
	fourstroke = fourstroke - OnePole.ar(fourstroke, exp(-2pi * (4 * SampleDur.ir)));


	parabola = DelTapRd.ar(bufferTd, td, (parabolaDelay * 100)/1000, 1) - 0.5;
	parabola = parabola * parabola * (-4) + 1 * 3 * mixParabolic;


	preFM1 = DelTapRd.ar(bufferTd, td, (warpDelay * 100)/1000, 1);
	preFM1 = (preFM1 * 2pi).cos;
	preFM2 = K2A.ar(engineSpeed * waveguideWarp);
	preFM2 = OnePole.ar(preFM2, exp(-2pi * (0.2 * SampleDur.ir)));
	fm1 = (1 - preFM1) * preFM2 + 0.5;
	fm2 = (preFM2 * preFM1) + 0.5;


	overtoneDrive  = overtoneDrive!3;
	overtone = overtone!3;

	3.do{|i|

		overtoneDrive[i] = DelTapRd.ar(bufferTd, td, (transDelay[i]*100)/1000) * (0.5**(i+1)*32);
		overtoneDrive[i] = Wrap.ar(overtoneDrive[i]);

		overtone[i] = overtoneDrive[i].max(overtonePhase[i]) - overtonePhase[i];
		overtone[i] = overtone[i] * (1 - overtonePhase[i]).reciprocal;
		overtone[i] = overtone[i] * ((overtoneFreq[i] * 12) * overtonePhase[i]);
		overtone[i] = Wrap.ar(overtone[i]) - 0.5;
		overtone[i] = (overtone[i] * overtone[i]) * (-4) + 1 * 0.5;
		overtone[i] = (overtone[i] * (1 - overtoneDrive[i])) * (overtoneAmp[i] * 12);
	};


	# e1b, e2b, e2a, e1a = DelayC.ar(
		in: InFeedback.ar(bus:(10..13)),
		maxdelaytime: 1,
		delaytime: ((([wguideLength1,wguideWidth1,wguideLength2,wguideWidth2] * 40)
			* [fm1,fm1,fm2,fm1])/1000)
	);

	OffsetOut.ar(11, e1b + overtone[1]);

	e2b = e2b + overtone[2];
	OffsetOut.ar(13, e2b);

	e2a = e2a + overtone[0];
	OffsetOut.ar(10, e2a);

	OffsetOut.ar(12, e1a * wguideFeedback + (parabola - OnePole.ar(parabola, exp(-2pi * (30 * SampleDur.ir)))));

	spacewarp = e1b + e2b + e2a + e1a;
	spacewarp = spacewarp - OnePole.ar(spacewarp, exp(-2pi * (200 * SampleDur.ir)));
	spacewarp = spacewarp - OnePole.ar(spacewarp, exp(-2pi * (200 * SampleDur.ir)));

	engine = (spacewarp + fourstroke)!2 * 0.5;

	Out.ar(0, engine);

}).play;
);
MIDIIn.connectAll;
(
	var transFreq = Array.newClear(3);

	MIDIFunc.cc({ |val, num|
		switch( num,
		1,	{e.set(\wguideFeedback, (val/128).range(0,1).postln)},
		2,	{e.set(\mixParabolic, (val/128).range(0,1).postln)},
		3,	{e.setn(\overtoneFreq, transFreq.put(0, (val/128).range(0,1)).postln)},
		4,	{e.setn(\overtoneFreq, transFreq.put(1, (val/128).range(0,1)).postln)},
		5,	{e.setn(\overtoneFreq, transFreq.put(2, (val/128).range(0,1)).postln)},
		6,	{e.set(\parabolicDelay, (val/128).range(0,1).postln)},
		7,	{e.set(\warpDelay, (val/128).range(0,1).postln)},
		8,	{e.set(\waveguideWarp, (val/128).range(0,1).postln)},
		)
	});

)

// Wanna send MIDI Out? THIS IIS MAC SPECIFIC!
//Initialize your IAC Driver in AUDIO MIDI SETUP/MIDI STUDIO

MIDIOut.newByName("IAC Driver", "Bus 1");

m = MIDIOut(0);

a = Pbind(\degree, Prand([1, 2, 3, [0, 5]], inf), \bend, Pwhite(0, 76, inf));

// chain a midi event into the pattern and play it (see Pchain)

(a <> (type: \midi, midiout: m)).play;

// Wanna sync clock with Ableton Link? use
LinkClock
// more info from James Harkins here: https://www.youtube.com/watch?v=rdc-uPfkSCQ

/*
<3 Rachel <3 Libraries <3
Building out SC Lang to our Liking!
Quarks: https://doc.sccode.org/Guides/UsingQuarks.html
(SuperDirt is a Quark)
They are HARD to install on M1s
*/


// adapted from https://github.com/schollz/workshops
// before running this you must first save `Sun.sc` to the extensions directory.
// open `Sun.sc` in SuperCollider.
// now save it by doing `File -> Save As Extension...` and type `Sun.sc`.
//THEN go to Language>Reboot Interpreter!!!//

(
s.waitForBoot({
	var scale;

	SynthDef("padVoice",{
		// ARGUMENTS (leave this as is)
		arg note=60,amp=0.5,out=0,attack=1,decay=1;
		var snd = Silent.ar(2); // initialize the sound to silence
		var freq = note.midicps; // midi note converts to frequency using .midicps
		var env = EnvGen.ar(Env.perc(attack,decay,amp,[4,4]),doneAction:2); // envelope
		var pan = LFNoise2.kr(1/Rand(3,6)).range(-0.5,0.5); // random modulation for panning
		var detune = LFNoise2.kr(1/Rand(1,5)).range(-0.1,0.1); // random modulation for detuning or anything



		//////////////////////////////////////////////////
		// ----- START ADDING YOUR OWN SYNTH HERE ----- //
		//////////////////////////////////////////////////

		// note contains the midi note
		// freq contains the frequency

		// simple sine wave
		snd = SinOsc.ar(freq);

		// filtered detuned saw wave
		// with opening filter
		// snd = Saw.ar([note-detune,note+detune].midicps);
		// snd = MoogFF.ar(snd,
		// 	LinExp.kr(0.01+EnvGen.kr(Env.perc(attack,decay)),0.01,1.01,freq,ExpRand(freq*2,20000)));

		// simple filtered saw wave
		// snd = Saw.ar(freq);
		// snd = LPF.ar(snd, freq*8);

		// sine with phase modulation feedack
		// feedback is randomly modulated
		// snd = SinOscFB.ar(freq, LFNoise2.kr(1/3).range(0,1));

		// a switch can randomly switch between
		// snd = SelectX.ar(LFNoise2.kr(1).range(0,1),[
		// 	LFTri.ar(freq),
		// 	SinOsc.ar(freq),
		// ]);


		//////////////////////////////////////////////////
		// ------ DONE ADDING YOUR OWN SYNTH HERE ----- //
		//////////////////////////////////////////////////



		// panning
		snd=snd!2;
		snd = Balance2.ar(snd[0],snd[1],pan);

		// send data to the GUI
		SendReply.kr(Impulse.kr(25),"/sunposition",[\sector.kr(0),note,env,pan,detune.abs]);

		// final output
		Out.ar(out,snd*env/12);
	}).send(s);

	// effects
	SynthDef("padOutput",{
		arg amp=1.0;

		// collect the sound coming from the bus "0" on 2 channels (stereo)
		var snd=In.ar(0,2);

		// replace the output with the effected output /*RACHEL EDITS*/
		ReplaceOut.ar(0,snd*Lag.kr(amp));
	}).send(s);


	// CHANGE THIS!
	// set the scale
	scale = Scale.major;
	// scale = Scale.minor;
	// scale = Scale.dorian;
	// ... see more at ScaleLP

	// set the four

	// the Sun plays random notes from the scale
	b=Sun.new(s,
		argSynName:"padVoice",
		argSynOutput:"padOutput",
		argScale:scale,
		argTimes:[10,7,5,2], // <--- CHANGE THIS! these numbers correspond to the durations for the south, east, west, and north sectors
		argNums:[1,2,3,1] // <--- CHANGE THIS! these numbers correspond to the number of voices for the south, east, west, and north sectors
	);
	b.gui;
})
)