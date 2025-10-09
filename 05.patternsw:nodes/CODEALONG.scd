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

SC puts abstract objects (meaning we don't necessarily explicitly declare them) on busses on the server that wait to receive messages. Nodes are the most common of these types of objects. Messages travel to Nodes and other abstract objects on Streams.

There is a special type of Stream called an Event Stream which basically allows the Stream to continue to deliver messages but Nodes can start and stop doing the things ON the messages.

PBind is the most common UGen that uses this Stream/Event Stream feature.

[example below from PBind help file]
*/

So let's start off by writing a very simple scale:

```
(
Pbind(
  \midinote, Pseq([60, 62, 64, 65, 67, 69, 71, 72]),
  \dur, 1
).play
)
```

Now type ctrl-enter (Windows and Linux) or Cmd-Enter (Mac).

[Put a picture of ctrl-enter and cmd-enter]


In the post window in the bottom right you should also see the following, while in the background
you will hear a simple C major scale.

[TODO Screenshot]

Whenever you successfully evaluate a piece of code in SuperCollider, this window will give you a
little bit of feedback about what just happened. Don't worry yet about what that means.

#Didn't Hear Anything?

If you see something different then there was probably something wrong with what you just typed in.
Check it again, paying careful attention to placement of brackets and commas. In particular
SuperCollider requires brackets to be balanced. If all else fails, try copy and pasting the code
from the book. If that doesn't fix it there may a deeper problem. Contact the mailing list, forum
or Slack channel [links to follow].

If you see the following, then you need to start the SuperCollider sound server:

[TODO Screenshot]

Finally, if you still don't hear anything then make sure that the volume is turned up sufficiently.
I make this mistake more often than I'd like.

# Explaining What Just Happened

So we're going to take the piece of code that you just ran [terminology - this is sometimes also
called 'evaluating'] and examine each piece of it so that you understand what happened. If you're a
confident coder then you can probably skim this part.

[Image with brackets colored]

So the code we just ran is surround by brackets. Whenever we surround code by brackets in the
SuperCollider IDE this is our way of telling the IDE that we want it to run all the code between
the brackets. Note that whenever you have an open parenthesis - you must have a matching closing
parenthesis. So what happens if we remove one of those parentheses:

[Screenshots]

We get the mysterious ```parse error in interpreted text```, but also see that a little further
down we see ```unmatched ')' in interpreted text line 1 char 1```.xw So SuperCollider is telling us
that it didn't understand the code ('parse error'), where it thinks the problem starts ('line 1'
where the open paranthesis is) and what the problem is ('unmatched )' - that is we don't have a
closing parenthesis to match the opening one). If you put the parenthesis back and run the code
again you should now hear the scale played back.

Now place the cursor (the blinking horizontal line that marks where new text will appear) after the
final parenthesis. See how the entire block is colored yellow. Now remove the final parenthesis.
The yellow highlight disappears. This is another way that you can tell if a code block can be run,
and if you have missing parentheses.

[IMAGE of BLOCK]

Restore the code block to it's initial state (hint: you can use undo to do this: `ctrl-z` or
`cmd-z`). When you reevaluate it it should play normally. Now let's look deeper. First of all what
is ```\dur```? This is short for duration, and tells SuperCollider that the code following the
comma (```1```) should be used for the duration in beats of the next note.

```\midinote``` is used to tell SuperCollider that the code that follows the comma: ```Pseq([60,
62, 64, 65, 67, 69, 71, 72])``` will generate 'midi notes'. MIDI notes are an industry standard
where particular numbers (these are defined as part of the MIDI standard [wikipedia link]) are
treated as musical notes. For example middle C is 60, D#/Cb is 61, D is 62, etc.

[Image of the Midi notes].

At this point hopefully you have guessed that ```Pseq``` is being used to define our scale:
+ **60** - C4
+ **62** - D4
+ **64** - E4
+ **65** - F4
+ **67** - G4
+ **69** - A4
+ **71** - B4
+ **72** - C5

So this little bit of code has generated the following sequence of notes:
+ C4 for a duration of 1 beat
+ D4 for a duration of 1 beat
+ D4 for a duration of 1 beat
+ D4 for a duration of 1 beat
+ E4 for a duration of 1 beat
+ F4 for a duration of 1 beat
+ G4 for a duration of 1 beat
+ A4 for a duration of 1 beat
+ B4 for a duration of 1 beat
+ C5 for a duration of 1 beat

[Image of a simple ascending scale here]

Similarly the following piece of code will generate a descending C Major scale, where each note has a duration of 2 beats:

```
(
Pbind(
  \midinote, Pseq([72, 71, 69, 67, 65, 64, 62, 60]),
  \dur, 2
).play
)
```

[Image of a simple descending scale here]

If we want to vary the number of beats, then we use a Pseq for the ```\dur``` key:

```
(
Pbind(
  \midinote, Pseq([60, 62, 64, 65, 67, 69, 71, 72]),
  \dur, Pseq([8, 4, 2, 1, 1/2, 1/4, 1/8, 1/16])
).play
)
```

[Image of what this is here]

Note that when we want to create eighth notes, or sixteenth notes we write it as a fraction (e.g.
1\8 for one eighth of a beat). We could also write these durations as decimal places if we liked -
```0.5``` and ```1/2``` are interchangable.

So what happens with the following code:

```
(
Pbind(
  \midinote, Pseq([60, 62, 64, 65, 67, 69, 71, 72]),
  \dur, Pseq([1, 2, 2])
).play
)
```

It plays C4 for 1 beat, D4 for 2 beats, E4 for 2 beats and then stops. So Pbind will keep playing
until one of the sequences runs out of notes to play. If we provided it with infinitely long
```\midinote``` and ```\dur``` sequences then it would play for ever. One way that we can provide
such an infinite sequence is by providing a single value. The following will play for as long as
you let it (remember ```Ctrl/Cmd-period``` will stop the audio server):

```
(
Pbind(
  \midinote, 60,
  \dur, 1
).play
)
```

So single values result in an infinite repeating sequence.

So now we have enough to create a simple tune:

[Twinkle Twinkle little star score]


```
// Twinkle Twinkle Little Star
(
Pbind(
  \midinote, Pseq([60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,67, 67, 65, 65, 64, 64, 62,67, 67, 65, 65, 64, 64, 62,60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2]),
).play
)
)
```

And hopefully after pasting this into your IDE, you should hear Twinkle Twinkle little star played
at the very sedate pace of 60bpm. If you're thinking this is pretty verbose and annoying way to
enter music, then let's fix that.

First of all note in the score above that the rhythm is a repeating motif of 6 quarter notes,
followed by a half note. So now we can change the above to:

```
// Twinkle Twinkle Little Star
(
Pbind(
  \midinote, Pseq([60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,67, 67, 65, 65, 64, 64, 62,67, 67, 65, 65, 64, 64, 62,60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6)
).play
)
```

So by passing in a second value to Pseq (separated from the array by a ```,```) we were able to
tell SuperCollider to play this sequence 6 times in a row. We can't repeat the `dur` trick, but
fortunately we have options available to us:

```
(
var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

Pbind(
  \midinote, Pseq(a ++ b ++ b ++ a),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

So what was that? The first two lines create two new `variables` called `a` and `b` respectively
and assign arrays to those labels. [Definition of an array to go here]. Then in Pseq we concatenate
those variables using `++` to create one large array:

```
(
var a = [1,2,3];
var b = [4,5,6];

a.postln;
b.postln;
a ++ b;
)
```

[TODO Previous chapter - explain parentheses]

In the post window you should see:

```
[ 1, 2, 3 ]
[ 4, 5, 6 ]
-> [ 1, 2, 3, 4, 5, 6 ]
```

```a ++ b``` creates a new array which combines `a` and `b`. So above we create a new sequence of
note values that consisted of `a` followed by `b` twice followed by `a` again. There is another way
to achieve this, and when working with ```Pbind``` this is generally preferred. We can use
```Pseq``` to chain several sequences together. So the above would be rewritten:

```
(
var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

Pbind(
  \midinote, Pseq([Pseq(a), Pseq(b, 2), Pseq(a)]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

Or if you prefer, you can use ```++``` to combine the patterns:

```
(
var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

Pbind(
  \midinote, Pseq(a) ++ Pseq(b, 2) ++ Pseq(a),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

The last two pieces of code are interchangable - the way you write this comes down to personal
preference (I personally prefer the latter). SuperCollider will convert the second piece of code
into the the former for you.

Okay, so this is definitely better, but you probably don't know all the midinote numbers. Can we do
better? Yes we can:

```
(
var a = Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]);
var b = Pseq([4, 4, 3, 3, 2, 2, 1]);

Pbind(
  \scale, Scale.major,
  \root, 0,
  \octave, 5,
  \degree, a ++ b ++ b ++ a,
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

So this time the numbers in our array correspond to notes in the C scale in the middle octave on
the piano (the octave that begins with middle C, or C4), with `0` for `C4`, `1`, for `D` all the
way to `8` for `C5`. So let's explain the new keys in this `Pbind`:

+ **scale** - this Pbind uses the major scale. SuperCollider has pretty much any scale you can
  imagine. If you don't set this value then the default value is Scale.major.
+ **root** - The key for this scale. 0 is C, 1 is C#, etc. The default is `0`.
+ **octave** - The default octave. 5 is confusing used for the octave that starts with `C4`. If you
  don't set the octave key, then `5` is the default.
+ **degree** - The degree of the current scale, where 0 is the root note of the scale in the
  current octave. In the above example if wanted to play `C3` then we would use the value `-8`
  while C4 would be `8`. We can also play sharps and flats. C# would be 0.1 - while Db is 0.9. C##
  (also known as D) would be 0.2.

So transposition is pretty easy. By key to G:

```
(
var a = Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]);
var b = Pseq([4, 4, 3, 3, 2, 2, 1]);

Pbind(
  \scale, Scale.major,
  \root, 7,
  \octave, 5,
  \degree, a ++ b ++ b ++ a,
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

So in the example above `0` means the value G4, as we're starting 7 intervals (or 7 notes in the
chromatic scale) above C4. The bass point that we're using is up the keyboard from middle C.

or to A minor (note that we went down to the A3 before C4):


```
(
var a = Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]);
var b = Pseq([4, 4, 3, 3, 2, 2, 1]);

Pbind(
  \scale, Scale.minor,
  \root, -3,
  \octave, 4,
  \degree, a ++ b ++ b ++ a,
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

We can even transpose it to a different mode, such as F Lydian, by using ```mtranspose```:
```
(
var a = Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]);
var b = Pseq([4, 4, 3, 3, 2, 2, 1]);

Pbind(
  \scale, Scale.major,
  \root, 0,
  \octave, 5,
  \degree, a ++ b ++ b ++ a,
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

Note that in the above example the scale and root are very important. As `F Lydian` is built upon
the 4th degree of the C major scale, then we need to pass in a major scale and a root of `0` so
that we're using the C major scale. C lydian built upon `C4` would require a root of `F` and the
octave value of `4` and would look like this:

```
(
var a = Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]);
var b = Pseq([4, 4, 3, 3, 2, 2, 1]);

Pbind(
  \scale, Scale.major,
  \root, 5,
  \octave, 4,
  \degree, a ++ b ++ b ++ a,
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
).play
)
```

# Volume and Articulation

So far we've seen how to write a simple melody, but the results have been a little robotic. So in
this section we're going to look at ways we can vary the amplitude (also known as velocity) and
articulation of notes.

## Stacatto to Legato

While ```\dur``` controls the length of the note event, we can control the articulation of each note
with ```legato```:

```
(
// stacatto
Pbind(
  \degree, Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 2),
  \legato, 0.1
).play
)
```

```
(
// legato
Pbind(
  \degree, Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 2),
  \legato, 1
).play
)
```

and obviously we can vary the legato if we so desire:

```
(
Pbind(
  \degree, Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 2),
  \legato, Pseq([0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.9], 2)
).play
)
```

## Volume

We can vary the amplitude directly with the ```\amp``` key. Amplitude is a value between 0 (silence)
and 1 (maximum volume).

```
(

Pbind(
  \degree, Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 2),
  \amp, 0.5
).play
)
```

We can also vary it from note to note quite easily:

```
(
Pbind(
  \degree, Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 2),
  \amp, Pseq([0.8, 0.5, 0.6, 0.4], inf)
).play
)
```

This probably looks quite familiar except for one thing. What is this ```inf``` value. This is
SuperCollider's way of defining infinity, and when used in a pattern in this way it tells
SuperCollider to repeat this pattern for ever. This is useful when you have a pattern that repeats
for the entirety of a piece, and you don't want to work out how many times it should repeat.

This works, if you remember, because Pbind stops creating new note events when one of it's patterns
ends.

```\amp``` isn't the only key that defines the amplitude. ```Pbind``` also supports the ```\db```
key. This value allows you to define the value in decibels.

[Explanation of decibels go here.]

```
(
Pbind(
  \degree, Pseq([0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
  \dur, Pseq([1, 1, 1, 1, 1, 1, 2], 2),
  \db, Pseq([-2, -4, -3, -6], inf)
).play
)
```

# Chords

So far all we've played has been melodies. But music would pretty uninteresting without harmony.
Fortunately creating chords and chord progressions in SuperCollider is pretty straightforward.

## A C Chord

So let's play one chord every bar:

```
// C - G progression for infinity
(
Pbind(
  \midinote, [60,64,67],
  \dur, 4).play
)
```

Contrast this with a pattern that plays a single note:
```
// C - G progression for infinity
(
Pbind(
  \midinote, 60,
  \dur, 4).play
)
```

The only difference between them is we now have three notes in an array. If you remember, an array
is a data structure that contains multiple data items in a sequential 'list'. Creates an event for
each value in the array and plays them simultaneously. In this case it results in a chord being
played.

## Simple Chord Progression

If we want to create a chord progression, we can just use Pseq and play back multiple arrays, rather
than single values:

```
// C - G progression for infinity
(
Pbind(
  \midinote, Pseq([[60,64,67], [67,71,74]], inf),
  \dur, 4).play
)
```

Note that the first parameter of ```Pseq``` is an array of arrays: ```[[60, 64, 65], [67,71,74]]```
rather than a single array like we have seen before.

Of course, just as before, we can specify the chord using ```\degree```:

```
// C - G progression for infinity
(
Pbind(
  \root, 0,
  \degree, Pseq([[0,2,4], [4, 6, 8]], inf),
  \dur, 4).play
)
```

and we could even cycle through a cycle of 5ths:

```
(
Pbind(
  \root, Pseq([0, -7, -2, 3]),
  \degree, [4, 6, 8],
  \dur, 4).play
)
```

## Harmonizing a Melody

So now let's look at how we can harmonize an existing melody by returning to old standby - Twinkle
Twinkle Little Star.

So first of all let's create our chord progression:

```
(
var c = [0, 2, 4];  // C E G
var f = [0, 3, 5];  // C F A
var g7 = [-1, 1, 3, 4]; // B D F G

var progA = Pseq([c, f, c, f, c, g7, c]);
var progB = Pseq([c, f, c, g7, c, f, c, g7]);

var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

var prog = Pbind(
  \octave, 5,
  \degree, progA ++ progB ++ progB,
  \dur, Pseq([4, Pseq([2], 14), 4, Pseq([2], 6)]));
```

So hopefully this all looks fairly similar to how we created melodies in a previous chapter. All
that's changed here is that now we are playing a chord, rather than a single note. Now let's add
the melody:

```
(
var c = [0, 2, 4];  // C E G
var f = [0, 3, 5];  // C F A
var g7 = [-1, 1, 3, 4]; // B D F G

var progA = Pseq([c, f, c, f, c, g7, c]);
var progB = Pseq([c, f, c, g7, c, f, c, g7]);

var a = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60];
var b = [67, 67, 65, 65, 64, 64, 62];

var prog = Pbind(
	\octave, 5,
	\degree, progA ++ progB ++ progB,
	\dur, Pseq([4, Pseq([2], 14), 4, Pseq([2], 6)]));

var melody = Pbind(
	\midinote, (Pseq(a) ++ Pseq(b, 2) ++ Pseq(a)) + 12,
	\dur, Pseq([1, 1, 1, 1, 1, 1, 2], 6),
);

Ppar([melody, prog]).play
)
```

So here you can see we have a new pattern type: ```Ppar```. Ppar allows us to play two independent
patterns simultaneously - allowing us to construct more complex musical arrangements. As we'll see
in future chapters - pattern constructs such as this allow us to flexibly and quickly build up
complex musical arrangements quite easily.


// DEFAULT PBIND SYNTH vs instrument synth!!!

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
    \degree, Pseq((0..12), inf),
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

// dictionaries https://doc.sccode.org/Classes/Dictionary.html
a = (note: 2);
b = (note: [3, 5]);
Pseq([a, b]).play;

(
a = (
    pattern: Pbind(\note, Pgeom(1, 1.1, { 20.rand }), \dur, 0.05),
    embedInStream: { |event, inevent| event[\pattern].embedInStream(inevent) }
);
b = (note: [3, 5]);
c = (freq: 402, dur: 0.3);
Prand([a, b, c], inf).play;
)

// change the events while playing
c[\freq] = [900, 1002, 1102];
c[\freq] = [200, 101, 1102];


// NDef;

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
