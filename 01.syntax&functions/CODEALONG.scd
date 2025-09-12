// GETTING STARTED WITH SYNTAX

// this is a single-line comment!

/*this is a...
multi-line comment
REMINDERS FROM last week's README.md
- What you downloaded was actually three things:
  - sclang (client), scserver (server), scide
- [Client vs Server](https://doc.sccode.org/Guides/ClientVsServer.html)
- IDE: Text Editor, Post window, Help browser
- Client (Interpreter/Language) boots when you open IDE
- You can run server(s) from anything/anywhere
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

"I love SuperCollider".postln;// .postln is function object in sclang. make sure to always have a ";" after code

(
"I love SuperCollider".postln;
"SuperCollider loves me".postln;
)//parentheses are everything

// disorder of operations!
// there is no order of operations in SuperCollider!
// beware beware beware beware
(100+2/2).postln; // what does this equal?
(100+(2/2)).postln; // force order of operations using parentheses

// assigning objects to variables
a={"I love SuperCollider".postln};
~rachel={"SuperCollider loves me".postln;};
a.value;
~rachel.value;

// arguments and variables of functions

// arguments can be passed into functions when the function is called on the server
/* can be called two ways:
arg ;//old-school "pirate" notation
| | //"pipe notation"
*/
//variables of a function are containers of a value
// you need to declare them but not their type (which is good AND bad...)
// local variables are hella local:
a = 1;
(
var a;
a = 3;
);
a;
// a postln function with both an argument and variable:
(
a={
	| urname | // arguments must be defined first
	var something; // then variables must be defined next
	something="SuperCollider"; // variables can be assigned later
	(urname++", do you love "++something++"?").postln;
};
);
a.("Rachel");

/* VERY IMPORTANT DISTINCTION: function arguments you can change on the fly, function variables can be assigned later but you have to reup the synth to the server. Again, in other words: function arguments can be passed to directly to server, but function variables have to be passed from the client to the server.

// objects and messages
// We can assign objects to variables, and then send messages to those objects with the syntax `object.message`

f = { "eggs".scramble };
f.value;

//Each message executes a particular method
//Different objects share methods with the same name, but because they're different objects, they execute the same message differently a la polymorphism (you down with OOP?) Makes for nice theme and variations form!

// server goodies!
- the audio engine!
- 's' stands for server! Don't assign things to it
- useful **s.** commands*/
 s.makeWindow;
 s.meter;
 s.record;
 s.stopRecording;
 s.scope;
 s.freqscope;
 s.addr // the address of the server (IP address and Port)
 s.name // the localhost server is the default server (see Main.scd file)
 s.serverRunning // is it running?
 s.avgCPU // how much CPU is it using right now?

*UGens*
- Modular building blocks of synthesis systems
- Think of them like modules in your synthesizer
  - They make a waveform, a filter, etc.
- In SC they're actually written in C/C++ and are a plugin to the SC Server, but most come standard with download
  - Most UGen classes have Audio Rate **.ar** and Control Rate **.kr** signal methods internal to the language.
- LOOK UP THE arguments OF UGens with <<Command|D>>
- AR = sends 44.1k values per second; KR = sends 7,350 values per second (1/6th as many as ar. Just saves CPU this way!...like difference between VCO and LFO modules in a modular synth).



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
*Stopping sounds with sophistication*
.free - kills bus assigned to variable on the server (ideal)
<<Command|.>> - kills all busses on the server (panic)
Server>Kill All Servers > KILLS ALL SERVERS (apocalypse)


MUL and ADD in SinOSc UGen


Let's get out of mono with Pan2:*/
{Pan2.ar(SinOsc.ar(440))}.play;
{Pan2.ar(SinOsc.ar(440), SinOsc.kr(4), SinOsc.ar(440))}.play // demo of .ar vs kr

s.scope; // time domain

/*
rachel's recommended UGens for output, read help files for all!
Pan2
Out
Mix
Splay
Pan4
PanAz
*/
