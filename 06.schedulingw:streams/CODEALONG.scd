/*
Routines & Tasks:
  - Pattern-less passing of messages to streams
  - Need to sync things with clocks?
    - SystemClock: Most reliable
    - TempoClock: Best for beats
  - Need to start and stop full iterations with clocks?
    - **Routine**
  - Need to start, stop, and pause iterations without clocks?
    - **Task**
https://doc.sccode.org/Tutorials/Getting-Started/15-Sequencing-with-Routines-and-Tasks.html
WAIT == YIELD
*/
(
SynthDef(\bleep,{ arg out=0, note=60, amp=0.5, pan=0.0;
	var freq, env;
	freq = note.midicps;
	env = EnvGen.ar(
					Env([0,1,1,0],[0.01, 0.1, 0.2]),
					levelScale:amp,
					doneAction:2
				);
	Out.ar(out,
		Pan2.ar(Blip.ar(freq) * env, pan)
	)
}).add;
)
/// SystemClock
(

SystemClock.sched(0.0,//start at 0.0 sec from now, i.e. immediately

	{//a function which states what you wish to schedule

		Synth(\bleep);

		1		//repeat every second

	}

))
/// TempoClock
(
var t;
t = TempoClock(2); // 120 bpm = 2 beats per second
t.schedAbs(0, { arg ... args;
				args.postln;
				Synth(\bleep);// make a bleep
				1.0	// reschedule every beat
}))
/// Simple Routine
(
r = Routine({
		1.wait;
		Synth(\bleep);
		5.wait;
		Synth(\bleep);
	});
)
///
r.play;

/// Simple Task

(SynthDef(\singrain, { |freq = 440, amp = 0.2, sustain = 1, out|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.1, sustain), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;);


(
t = Task({
    loop {
        [60, 62, 64, 65, 67, 69, 71, 72].do({ |midi|
            Synth(\singrain, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
            1.wait;
        });
    }
}).play;
)

// probably stops in the middle of the scale
t.stop;

t.play;    // should pick up with the next note

t.stop;

/***Forks**
    - Routine shortcut. Wraps routine into .play and allows you to pass a clock into it.
    - Because SC is totally OOP, have to use an object method to iterate
    - **.do** is the most common*/

(3.do({ "threescrambledeggs".scramble.postln; }))

(
{8.do{arg i; Synth(\bleep,
	[\note,rrand(48,84) ,\amp, rrand(0.25,0.75)]); 2.wait} }.fork(TempoClock(5))
)

// APP CLOCK for guis

(
var w, r;
w = Window.new("trem", Rect(512, 256, 360, 130));
w.front;
r = Routine({ arg appClockTime;
    ["AppClock has been playing for secs:",appClockTime].postln;
    60.do({ arg i;
        0.05.yield;
        w.bounds = w.bounds.moveBy(10.rand2, 10.rand2);
        w.alpha = cos(i*0.1pi)*0.5+0.5;
    });
    1.yield;
    w.close;
});
AppClock.play(r);
)
