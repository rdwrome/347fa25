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

// objects and messages
// We can assign objects to variables, and then send messages to those objects with the syntax `object.message.` messages will be received (and sent) based on an object's methods

~breakfast = { "eggs".scramble };
~breakfast.value;

// use a tilda to assign objects to variables on the server
~rachel={"SuperCollider loves Massimo".postln};
~rachel.value; // .value is another

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
	| urname = "rachel" | // arguments must be defined first within the function
	var x; // then variables must be defined next
	x="bleeePPP BLLLooooopS"; // variables can be assigned later
	(urname++", do you want to make "++x+"?").postln;
};
);
~banana.value;
~banana.("rome");

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
 s.scope; // time domain!!!
 s.freqscope; // frequency domain!!!

/* UGens
- Modular building blocks of SuperCollider Systems for synthesis; sound design; algorithmic composition
- In SC they're actually written in C/C++ and are a plugin to the SC Audio Server, but most come standard with download
- Most UGen classes have Audio Rate **.ar** and Control Rate **.kr** signal methods internal to the language
- AR = sends 44.1k values per second; KR = sends 7,350 values per second (1/6th as many as ar. Just saves CPU this way!...like difference between VCO and LFO modules in an analog modular synthesizer).
- LOOK UP THE arguments OF UGens with <<Command|D>> ALL THE TIME
- SinOsc is the "hello, world" of computer music.
- Look at Mul and Add methods of SinOsc in its help file
https://doc.sccode.org/Guides/Tour_of_UGens.html
- your early SC use will be weaving parameters of UGens together; using OOP to swap related methods
*/

(
~orange={
	//arg pitch=166; /* PIRATE vs PIPE NOTATION a la rachelle */
	| pitch=220 |
	SinOsc.ar(pitch);
}.play; // .play will play it
)
~orange.set(\pitch,550);
~orange.set(\pitch,54.midicps); // .midicps converts midi note to frequency (cycles per second)
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
~kiwi.set(\pan, 1)
~kiwi.free;

//Why the pop sound? because the phase is interrupted. We don't have envelopes yet!

/*
UGens you should know for output, read help files for all!
Pan2 // Rachel Recommends for Stereo Field
Out // For sending signals directly to the bus that goes to your hardware Output Device ("master")
Mix // Great for simple submixing, adding a bunch of channels together
Splay // Great for complex submixing, spreading a bunch of channels across the Stereo Field
PanAz // Multi-channel panning gold!
*/

// sclang my_file.scd


`myFunction.value` can be shortened to `myFunction.()`, but not `myFunction()`.

Function arguments are denoted using this funky pipe-delimited section:

```supercollider
var myFunction = { |foo, bar, baz = 5|
    foo + bar + baz;
};
myFunction.(3, 4);
// -> 12
```

There is an older way of writing this: `{ arg foo, bar, baz = 5; ... }`, but
it's going out of fashion.

Like in JavaScript, functions not strict about variable arguments. Unspecified
arguments with no explicit default value are set to `nil`. If too many
arguments are provided, they are simply ignored.

## Conditionals

Boolean operators in sclang are a little different from other languages.

```supercollider
(0 == 1).not  // -> false

// Equivalent:
true.and(false)
true and: false

// The second is known as "key binary operator" syntax, and can be used in the
// special case where only one argument is passed to the method.

// 'and' and 'or' require their second argument to be wrapped in a function
// for short circuiting to occur:
doThisThing.() or: { doThatThing.() }
```

In keeping with sclang's minimal syntax, control structures are just method
calls involving functions.

```supercollider
(
if(2 + 2 == 4, {
    "Nice!".postln;
}, {
    "What?".postln;
});
)

// Shortcut syntax that may be used because all arguments are functions.

(
if(2 + 2 == 4) {
    "Nice!".postln;
} {
    "What?".postln;
};
)

// 'if' produces a return value from the function/block that was run, so it
// actually doubles as a ternary operator.
if(2 + 2 == 4, { "Nice" }, { "What" }).postln;

// 'case' is a quick way to write a bunch of nested 'if's. The first condition
// that's true is evaluated.
case
    { x < 0 } { "It's negative".postln; }
    { x > 1000 } { "It's nonnegative, but too big".postln; }
    { x % 2 == 0 } { "It's an even number".postln; };

// 'switch' is very similar to ordinary switch statements. Like 'if' and
// 'case', it passes along the return value of the function that was actually
// evaluated.
switch(thing,
    \option1, { "Option 1" },
    \option2, { "Option 2" }
).postln;

// You can wrap the values in functions — saves a few commas.
switch(thing)
    { \option1 } { "Option 1".postln }
    { \option2 } { "Option 2".postln };
```

sclang is strict about only Booleans being placed in `if`, `not`, `and`, and
`or`. If you try something like `if(0, ...)`, you will receive an error that
says "Non Boolean in test."

`if`, `switch`, and `case` are *not* keywords. They are methods.

## Arrays

Creation, getting, and setting are the usual. Zero-indexed.

```supercollider
(
var myArray = [1, 3, 4, 4, 3];
myArray[0] = myArray[3];
myArray[1] = "hey";
"Array size is %".format(myArray.size).postln;
myArray;
)
// Array size is 5
// -> [ 4, hey, 4, 4, 3 ]

// NOTE: getting and setting indices are actually syntactic sugar for the ".at"
// and ".put" methods.
```

Retrieving an out-of-bounds index returns `nil`. Setting an out-of-bounds index produces an error.

Here are a few useful ways to create arrays:

```supercollider
(0..4)    // -> [ 0, 1, 2, 3, 4 ], inclusive of both endpoints
(1,3..10) // -> [ 1, 3, 5, 7, 9 ]
4.dup(8)  // -> [ 4, 4, 4, 4, 4, 4, 4, 4 ]
{ |i| i ** 2 }.dup(8)   // -> [ 0, 1, 4, 9, 16, 25, 36, 49 ]
```

sclang supports multichannel expansion. Binary and unary operators, when
applied to arrays, are broadcast to the array's elements:

```supercolliders
[1, 2, 3, 4] + 4   // -> [ 5, 6, 7, 8 ]
[3, 4, 5] * [1, 6, 8]  // -> [ 3, 24, 40 ]
```

This sounds small, but it becomes unbelievably convenient when working with
multichannel sound design.

Appending to arrays is done using the `.add` method. However, for efficiency
**`.add` may or may not be in place**. To avoid unexpected behavior, always
assign the return value of `.add` back to the slot for the original array:

```supercollider
(
var myArray = [1, 2, 3];
myArray = myArray.add(4);
)
// -> [1, 2, 3, 4]
```

Slices are denoted with `..` and are inclusive of both indices:

```supercollider
(
var myArray = [1, 5, 2, 0, 4, 4];
myArray[2..4]
)
// -> [ 2, 0, 4 ]
```

The following tools are also useful — I am certain you can figure out how they work from their names
and very brief examples, and if not, you can consult the documentation:

```supercollider
["con", "cat"] ++ ["en", "a", "tion"]
newArray = array.copy
array.indexOf(thing)
array.includes(thing)
["heads", "tails"].choose
array.scramble
```

## Iteration

sclang has a rich variety of methods for iterating and filtering arrays. Here is a very terse
summary of them.

```supercollider
// Prints numbers 0 through 7 inclusive.
8.do { |i| "i".postln; };

// Remember, 8.do { ... } is just shorthand for 8.do({ ... }).

// Do something for each element. index is optional.
array.do { |elem| ... };
array.do { |elem, index| ... };

// Do something for each element and make a new array from the return values.
// Often called "map" in other environments
var newArray = array.collect { |elem| ... };

// Filter the array and keep only elements for which the given function returns
// true. The function should only return Booleans.
var newArray = array.select { |elem| elem % 2 == 0 };

// Return true iff the function returns true for any/every element.
// The function should only return Booleans.
[1, 2, 3].any { |elem| elem % 2 == 0 }
[1, 2, 3].every { |elem| elem % 2 == 0 }
```

These methods don't lazy evaluate on arrays, so chaining them isn't efficient like in functional
programming environments. SC does have native coroutines via the `Routine` class.

Array methods get the job done most of the time, but `while` loops are also sometimes necessary:

```
var x = 3;
while { x < 10 } {
    x.postln;
    x = x + 1;
};

// More idiomatic: (3..9).do { |x| x.postln }
```

Loops can be broken out of using the `block` method, which is exceedingly rare but occasionally
the best option:

```
block { |break|
    5.do { |i|
        if(i > 3) {
            break.value("hey"); // "hey" is the return value of block { ... }
        };
    };
};
```

## Strings and symbols

```supercollider
"Strings are delimited with double quotes."
"Strings can be
multiline."
"Escape characters: \t \f \v \n \r \\"
```

sclang will tolerate non-ASCII bytes in strings, but they are just bytes, and Unicode isn't really
understood. The SCIDE displays UTF-8, so if you're careful, non-ASCII characters will come out
unscathed. Sorry about that.

Strings are effectively immutable arrays of `Char` objects. `Char` objects have a literal syntax:
`$a`.

Symbols are similar to strings, but are efficient when reused, and not so efficient for textual
operations. A symbol is therefore ideal for identifiers that are only meaningful within your
program, while a string is intended for actual text input, manipulation, and output.

```supercollider
'Symbols are delimited by single quotes'

// But if the symbol is a valid identifier, there's a much simpler syntax:
\validIdentifier2000
```

Here are some useful things to do with strings and symbols — any ambiguities can be cleared up by
consulting the docs:

```supercollider
// Querying:
"string".size

// Conversion:
"string".asSymbol
\symbol.asString
3.asString
"3".asInteger
"3".asFloat

// Modification:
"concaten" ++ "ation"
"with" + "space" + "in" + "between"
"path/" +/+ "/joining"
"You can format %.".format("strings")
```


"hello, world".postln;// make sure to always have a ";" after statements

