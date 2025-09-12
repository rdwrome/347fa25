// SYNTAX

// this is a single-line comment!

/*this is a...
multi-line comment
REMINDERS FROM last week's README.md
- What you downloaded was actually three things:
  - scide, sclang/interpreter (client), scsynth (server)
- [Client vs Server](https://doc.sccode.org/Guides/ClientVsServer.html)
- OSC messages between Client and Server
- IDE: Text Editor, Post window, Help browser
- Client (Interpreter/Language) boots when you open IDE
- You do need to ACTIVELY boot scsynth/audio server with **Command|B** (or with drop-down or with s.boot)
- You see your I/O in the Post window after booting the Audio Server
- [You might need to change them/select them with this code](https://doc.sccode.org/Reference/AudioDeviceSelection.html)
- If you I/O audio rates don't match, the server won't boot and you'll need to make sure they match in your Audio MIDI setup
- Evaluate a line with **Shift|Return**
- Evaluate a block with **Command|Return**
- Kill the busses going to the server with **Command|.**
- You can run server(s) from anything/anywhere
- ***Beware Zombie servers***
- Everything's in mono by default
- "Syntax Sugar": many ways to write out the same thing
- Help! with **Command|D**
*/

"hello, world".postln;// make sure to always have a ";" after statements

// objects and messages
// We can assign objects to variables, and then send messages to those objects with the syntax `object.message` messages will be received (and sent) based on an object's methods

~breakfast = { "eggs".scramble };
~breakfast.value;

// use a tilda to assign objects to global variables on the server
~massimo={"SuperCollider loves Massimo".postln};
~massimo.value; // .value is another

//parentheses are everything and there is no PEMDAS
(
"I love SuperCollider".postln;
"SuperCollider loves me".postln;
)

(100+2/2).postln; // what does this equal?
(100+(2/2)).postln; // force order of operations using parentheses

// FUNCTIONS

// local variables need to be declared but not by their type (which is good AND bad...)
// local variables are hella local:
a = 1;
(
var a;
a = 3;
);
a;

// a template function definition with both an argument and a local variable
(
~banana={ // CURLY BRACKETS WRAP FUNCTIONS
	| urname | // arguments must be defined first within the function
	var x; // then variables must be defined next
	x="bleeePPP BLLLooooopS"; // variables can be assigned later
	(urname++", do you want to make "++x++"?").postln;
};
);
~banana.("rooommmmee");

// arguments can be passed into functions when the function has already been passed to the server
/* can be called two ways:
arg ;//old-school "pirate" notation
| | //"pipe notation"
*/


/* VERY IMPORTANT DISTINCTION: function arguments you can change on the fly, function variables can be assigned later but you have to reup the synth to the server. Again, in other words: function arguments can be passed to directly to server, but function variables have to be passed from the client to the server with the whole function.

// server methods
- 's' stands for server! Don't assign things to it
- useful **s.** commands*/
 s.makeWindow;
 s.meter;
 s.record;
 s.stopRecording;
 s.scope; // time domain
 s.freqscope; // frequency domain
 s.addr // the address of the server (IP address and Port)
 s.name // the localhost server is the default server (see Main.scd file)
 s.serverRunning // is it running?
 s.avgCPU // how much CPU is it using right now?

/* UGens
- Modular building blocks of SuperCollider Systems for synthesis; sound design; algorithmic composition
- In SC they're actually written in C/C++ and are a plugin to the SC Audio Server, but most come standard with download
- Most UGen classes have Audio Rate **.ar** and Control Rate **.kr** signal methods internal to the language
- AR = sends 44.1k values per second; KR = sends 7,350 values per second (1/6th as many as ar. Just saves CPU this way!...like difference between VCO and LFO modules in a modular synth).
- LOOK UP THE arguments OF UGens with <<Command|D>> ALL THE TIME
- SinOsc is the "hello, world" of computer music.
- Look at Mul and Add methods of SinOsc in its help file*/

(
~orange={
	//arg pitch=166; /* PIRATE vs PIPE NOTATION a la rachelle */
	| pitch=220 |
	SinOsc.ar(pitch);
}.play; // .play will play it
)
~orange.set(\pitch,455);
~orange.set(\pitch,51.midicps); // .midicps converts midi note to frequency (cycles per second)
~orange.free; // we can stop the play functions with this line

/*Stopping sounds with sophistication*
.free - kills bus assigned to variable on the server (ideal)
<<Command|.>> - kills all busses on the server (panic)
Server>Kill All Servers > KILLS ALL SERVERS (apocalypse)

Let's get out of mono with Pan2:*/
(
~kiwi={
	| pitch=220, pan=1 | // N.B. only arguments in this function, no local variables
	Pan2.ar(SinOsc.ar(pitch), SinOsc.kr(pan)); // .kr vs .ar!
}.play; // .play will play it
)
~kiwi.set(\pitch,440)
~kiwi.set(\pan, 4)
~kiwi.free;

//Why the pop sound? because the phase is interrupted

/*
UGens you should know for output, read help files for all!
Pan2 // Rachel Recommends for Stereo Field
Out // For sending signals directly to the bus that goes to your Output (we'll talk more about busses soon)
Mix // Great for simple submixing, adding a bunch of channels together
Splay // Great for complex submixing, spreading a bunch of channels across the Stereo Field
PanAz // Multi-channel panning gold!
*/
