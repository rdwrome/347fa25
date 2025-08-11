// adapted from https://github.com/schollz/workshops


//////// 1 ////////
// this is a comment! it is valid code but doesn't do anything

/*this is a...
multi-line comment
REMINDERS FROM this week's README.md
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


//////// 2 ////////
"I love SuperCollider".postln;// <- make sure to always have a ";" after code

//////// 3 ////////
(
"I love SuperCollider".postln;
"SuperCollider loves me".postln;
)//parentheses are everything

//////// 4 ////////
// disorder of operations!
// there is no order of operations in SuperCollider!
// beware beware beware beware

(
(100+2/2).postln; // what does this equal?
(100+(2/2)).postln; // force order of operations using parentheses
)


//////// 5 ////////
// LET'S assign objects to variables in the server!
// you can assign variables using letters a-z or with ~variableName
// execute each step, incrementally

// step 1:

(
a={"I love SuperCollider".postln};

~rachel={"SuperCollider loves me".postln;};
)

// step 2a: run the first

a.value; // .value evaluates the function stored in "a"

// step 2b: run the second

~someVariable.value;

// .postln, .value (evaluate) are messages to function objects included in sclang

//////// 6 ////////
// functions can have arguments and variables!
// arguments and variables are similar, except that arguments can be passed into functions when the function is called on the server.
// step 1: create a function that contains arguments and variables
(
a={
	arg name; // arguments must be defined first
	var something; // then variables must be defined next
	something="SuperCollider"; // variables can be assigned later
	(name++", do you like "++something++"?").postln;
};
)

// step 2: execute the function
a.value("hello");

/*interlude on function variables
- they're containers of a value
- you need to declare them but not their type (which is good and bad...)
- local variables work like this*/
a = 1;
(
var a;
a = 3;
);
a
/*interlude on arguments
- declared one of two ways: */
arg ;//old school like above
| | //"pipe notation"
// a good example of this soon

/*IMPORTANT DISTINCTION: function arguments you can change on the fly, function variables can be assigned later but you have to reup the synth to the server. OTHER WORDS: function arguments can be passed to directly to server, but function variables have to be passed from the client to the server.

interlude on objects and messages.
- We can assign objects to variables, then send messages to those objects with the syntax `object.message`*/
f = { "eggs".scramble };
f.value;
/*
- .value means evaluate the function `f`
- Each message executes a particular method
- Different objects share methods with the same name, but because they're different objects, they execute the same message differently a la polymorphism (you down with OOP?) Makes for nice theme and variations form!

interlude on the server
- The audio engine!
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

//////// 7 ////////
// let's get into the music now!
// we need to boot the server to start music making:
// goto Server -> Boot Server


//////// 8 ////////
// lets make a function that generates a Sine wave
// SuperCollider generates things with a "UGen"
// the UGen for Sine waves is called "SinOsc"

(
{
	SinOsc.ar(freq:220);
}.plot(10/220); // .plot(x) will plot it for x seconds
)


//////// 9 ////////
// finally lets make a sound!
// just add .play to our function
// instead of .plot
(
{
	SinOsc.ar(freq:220);
}.play; // .play will play it
)


/*interlude
let's use
s.scope;
and see how mono it is
remember that everything is mono by default, which is annoying now but
will facilitate fun later
*/