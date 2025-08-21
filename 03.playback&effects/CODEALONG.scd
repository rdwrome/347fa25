// adapted from https://github.com/schollz/workshops

/*SynthDefs
- a class which pre-compiles multiple unit generators together on the server
- greaaat for reuse!
*/

//////// a ////////
// lets define a synth to use multiple times
// using a "SynthDef"

(
SynthDef("coolsynth",{ // add SynthDef here, with a name
	arg freq=220, amp=0.1;
	var snd;
	snd=SinOsc.ar(freq:[freq,freq*2,freq*4],mul:[amp,amp/2,amp/8]);
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add; // use "add" instead of play
)

// now you can create multiple instances of them!
(
x = Synth("coolsynth",[\freq,60.midicps]);
y = Synth("coolsynth",[\freq,62.midicps]);
z = Synth("coolsynth",[\freq,65.midicps]);
)

// and each can be set later!
(
x.set(\freq,58.midicps);
y.set(\freq,62.midicps);
z.set(\freq,67.midicps);
)

(
x.set(\freq,60.midicps);
y.set(\freq,62.midicps);
z.set(\freq,65.midicps);
)

// set them all free!
(
x.free;
y.free;
z.free;
)


//////// b ////////
// you can treat UGens like numbers because of OOP!
// let's add them together and make a new oscillator
// famous oscillator UGens to play with:
// SinOsc, LFSaw, Tri
(
SynthDef("coolsynth",{
	arg freq=110, amp=0.5;
	var snd;
	// you can directly Mix
	snd=Mix.ar(
		SinOsc.ar(freq:[freq,freq*5,freq*8],mul:[amp,amp/2,amp/4])
	);
	// lets add some harmonic from a saw wave
	snd=snd+(0.1*Mix.ar(
		Saw.ar(freq:[freq,freq*2,freq*3,freq*4],mul:[amp,amp/1,amp/3,amp/3]))
	);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add;
)
x = Synth("coolsynth");
x.free;

/* interlude on arrays vs lists
  - Array: fixed size collection (most common)
  - List: variable size collection
  - What are tuning systems but arrays and lists?*/
m = Scale.minor.degrees; // Scale class returns the degrees of the minor scale

Tuning.directory // which scales

//////// c ////////
// use Array.fill(<num>,{arg i; <code>})
// to easily create an additive synth

(
SynthDef("coolsynth",{
	arg freq=110, amp=0.5;
	var snd;
	// you can directly Mix
	snd=Mix.ar(
		Array.fill(2,{arg i; SinOsc.ar(freq:freq*(2**i),mul:amp/(2**i))})
	);
	// lets add some harmonic from a saw wave
	snd=snd+(0.1*Mix.ar(
		Array.fill(4,{arg i; Saw.ar(freq:freq*(i+1),mul:amp/(i+1))}))
	);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add;
)
x = Synth("coolsynth");
x.free;
// your turn!
// take the synth in c and try changing things, including:
// - try changing the oscillators (try VarSaw, SinOsc, Pulse, LFTri, Saw, ..)
// - try changing the frequency
// - try changing the number of oscillators (instead of 3, do 1, 2, ..)


//////// d ////////
// filtering
// LPF, RLPF, HPF, RHPF, BPF
// MoogLadder, MoogVCF, MoogFF
(
SynthDef("filtersynth",{
	arg freq=220;
	var snd;
	var lpf, res;
	snd = Saw.ar([freq,freq+2]); // create a saw wave
	snd = snd * (-6.dbamp); // decrease volume by 6 dB

	lpf = Clip.kr(MouseX.kr(20,20000,1),20,20000); // add mouse modulation to lpf
	res = Clip.kr(MouseY.kr(1,0.02),0.1,1); // add mouse modulation to resonance
	snd = RLPF.ar(snd,lpf,res); // resonant low-pass filter
	Out.ar(0,snd); // output the send
}).add;
)
y = Synth("filtersynth");
y.free;

//////// e ////////
// combining modulation + filter
(
SynthDef("filtersynth", {
	arg freq = 110;
	var snd;
	var lpf, res;
	snd = Saw.ar([freq,freq-1]); // create a saw wave

	snd = snd * -12.dbamp; // reduce volume by 12 dB

	lpf = LFNoise2.kr(1).range(freq,4000);
	res = LFNoise2.kr(1).range(0.5,1);
	snd = RLPF.ar(snd,lpf, res); // resonant low-pass filter

	Out.ar(0,snd); // output the send
}).add;
)
y = Synth("filtersynth");
y.free;


//////// g ////////
///midisynth
(
SynthDef("midisynth",
{
	arg note=32;
	var detune=0.1;
	var snd;
	var lpf, res;
	snd = {
		var freq = (note+LFNoise0.kr(1).range(detune.neg,detune)).midicps; // add detuning to note and then convert to midi
		var snd_ = Pulse.ar(freq,LFNoise2.kr(3).range(0.2,0.8)); // create a pulse wave with pwm
		snd_ = snd_ * -6.dbamp; // reduce volume by 12 dB
		lpf = LFNoise2.kr(1).exprange(100,Rand(1000,5000));
		res = LFNoise2.kr(1).range(0.1,1);
		snd_ = RLPF.ar(snd_,lpf, res); // resonant low-pass filter
		snd_ // return sound
	}!8;

	snd = Splay.ar(snd); // make a stereo field out of all the channels

	Out.ar(0,snd); // output the send
}).add
)
z = Synth("midisynth");
z.free;

// adapted from https://github.com/schollz/workshops

// don't forget to BOOT!

//////// a ////////
// to play samples we first need to load a sample into a "buffer" using a file or recording

// ~someBuffer=Buffer.read(s,<filename>) will read the file into the buffer ~someBuffer
// on server "s"
~kalimba=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

// play the buffer
~kalimba.play;
// plot the buffer
~kalimba.plot;


//////// b ////////
// lets play the buffer using the PlayBuf "UGen"

(
{
	var snd; // define a variable to hold our sound
	snd=PlayBuf.ar( // PlayBuf will play a sound in a buffer
		numChannels:2, // we are dealing with stereo samples, so 2 channels
		bufnum:~kalimba, // the buffer
		rate: -0.2,
		loop:1,
	);
	Out.ar(0,snd); // send to Out UGen to channel 0 (default speakers)
}.play; // .play will play the sound immediately!
)


//////// c ////////
// lets record into a buffer
// define a new buffer that is 3 seconds long
~me=Buffer.alloc(s,s.sampleRate*3,2);
// then define a function to record into that buffer
(
{
	RecordBuf.ar(SoundIn.ar([0])!2, ~me, loop:0, doneAction:2)
}.play; // .play will play this synth that records from the input audio
)
// lets see if it worked!
~me.play;
~me.plot;
// TRY! try recording and plotting/playing your recording



//////// d ////////
// lets define how our sample will playback
// first we will define what is called a "SynthDef", a synth definition
// SynthDef(<name>,<function>).add
(
SynthDef("musicboxa", {
	// buffers have an index, and the buffer index will be supplied later using

	|bufnum = 0|
	var snd;

	snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop: 1,                     // loop forever
		rate:BufRateScale.kr(bufnum) // BufRateScale will calculate the
	);                               // difference between the server sampling and the audio file

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)


//////// e  ////////
// now let's play our defined synth using the "Synth" function
// we can then create a synth that plays a sound!
~syn=Synth("musicboxa",[\bufnum,~kalimba]);
~syn.free; // will stop playing

//////// f ////////
// now lets create a synthdef with some modulation
(
SynthDef("musicboxb", {

	arg bufnum = 0;

	var snd;
	var rate;

	rate = BufRateScale.kr(bufnum)*MouseX.kr(0.9,1.1); // use the mouse to modulate the rate

	snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop: 1,
		rate: rate,
	);

	snd = Pan2.ar(snd,LFNoise2.kr(1)); // use "LFNoise2" to modulate panning randomly

	snd[0] = snd[0] * LFPar.ar(5).range(0,1); // use "LFPar" to modulate the amplitude
	snd[1] = snd[1] * LFPar.ar(5.1).range(0,1); // use "LFPar" to modulate the amplitude slightly differently

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)

~box=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/musicbox.wav");

x=Synth("musicboxb", [\bufnum, ~box]); // will start playing

// TRY! try putting the modulation you created into this synthdef and playing


//////// g ////////
// lets modify our synth with some EFFECTS!
// there are many effects
// filters: RLPF, LPF, HPF, BPF
// delays: CombC, DelayC
// distortion: .tanh, .softclip, .distort
(
SynthDef("musicboxc", {
	// buffers have an index, and the buffer index will be supplied later using
	// an argument, "arg":
	arg bufnum = 0;
	// after arguments, we will declare variables that we will use with "var":
	var snd;

	snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop: 1,                     // loop forever
		rate:BufRateScale.kr(bufnum) // BufRateScale will calculate the
	);                               // difference between the server sampling

	snd = Pan2.ar(snd,BrownNoise.kr(1)); // pans randomly left and right

	snd = RLPF.ar(snd, MouseX.kr(10,20000,1),0.5); // effects controlled by mouse!

	snd = CombC.ar(snd,0.5,MouseY.kr(0.05,0.5)); // add delay

	snd = (snd * SinOsc.kr(0.1).range(1,10)).tanh * 0.1; // add distortion

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)

x=Synth("musicboxc", [\bufnum, ~box]); // will start playing

// TRY! change up the effects, the filters, the distortion, the modulation

s.record(numChannels:2);
s.stopRecording;

////////////////
// __   __  _______  _______
// |  | |  ||  _    ||       |
// |  | |  || |_|   ||    ___|
// |  |_|  ||       ||   |___
// |       ||  _   | |    ___|
// |       || |_|   ||   |___
// |_______||_______||_______|
//
// ube is a little tool made to play with all these ideas:
// it is a "macrogranulator" that modulates all sorts of things of buffers
// and does recording/playback with the buffers
//
// before running this you must first save `Ube.sc` to the extensions directory.
// open `Ube.sc` in SuperCollider.
// now save it by doing `File -> Save As Extension...` and type `Ube.sc`.
// THEN GO TO LANGUAGE>RECOMPILE CLASS LIBRARY! Then reboot!

// to run this code, but a cursor anywhere in the code block (a code block is enclosed in parentheses)
// and hit <Ctrl>+Enter

// if you run into trouble, restart everything <Ctrl>+<Shift>+L and then <Ctrl>+Enter
(
s.waitForBoot({
	var pairs;

	// define the "looper"
	SynthDef("looper",{
		// main arguments
		arg buf,tape,player,baseRate=1.0,amp=1.0,timescale=0.2;
		// variables to store UGens later
		var volume;
		var switch=0,snd,snd1,snd2,pos,pos1,pos2,posStart,posEnd,index;
		// store the number of frames and the duraiton
		var frames=BufFrames.kr(buf);
		var duration=BufDur.kr(buf);

		// LFO for the start point
		var lfoStart=SinOsc.kr(timescale/Rand(30,60),Rand(hi:2*pi)).range(1024,frames-10240);

		// LFO for the window lenth
		var lfoWindow=SinOsc.kr(timescale/Rand(60,120),Rand(hi:2*pi)).range(4096,frames/2);

		// LFO for the rate (right now its not an LFO)
		var lfoRate=baseRate;

		// LFO for switching between forward and reverse
		var lfoForward=Demand.kr(Impulse.kr(timescale/Rand(5,15)),0,Drand([0,1],inf));

		// LFO for the volume
		var lfoAmp=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(0.05,0.5);

		// LFO for the panning
		var lfoPan=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(-1,1);

		// calculate the final rate
		var rate=Lag.kr(lfoRate*(2*lfoForward-1),1)*BufRateScale.kr(buf);

		// modulate the start/stop
		posStart = lfoStart;
		posEnd = Clip.kr(posStart + lfoWindow,0,frames-1024);

		// LocalIn collects the a trigger whenever the playhead leaves the window
		switch=ToggleFF.kr(LocalIn.kr(1));

		// playhead 1 has a play position and buffer reader
		pos1=Phasor.ar(trig:1-switch,rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
		snd1=BufRd.ar(2,buf,pos1,1.0,4);

		// playhead 2 has a play position and buffer reader
		pos2=Phasor.ar(trig:switch,  rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
		snd2=BufRd.ar(2,buf,pos2,1.0,4);

		// current position changes according to the swtich
		pos=Select.ar(switch,[pos1,pos2]);

		// send out a trigger anytime the position is outside the window
		LocalOut.kr(
			Changed.kr(Stepper.kr(Impulse.kr(20),max:1000000000,
				step:(pos>posEnd)+(pos<posStart)
			))
		);

		// crossfade bewteen the two sounds over 50 milliseconds
		snd=SelectX.ar(Lag.kr(switch,0.05),[snd1,snd2]);

		// apply the volume lfo
		volume = amp*lfoAmp*EnvGen.ar(Env.new([0,1],[Rand(1,10)],4));

		// send data to the GUI
		SendReply.kr(Impulse.kr(25),"/position",[tape,player,posStart/frames,posEnd/frames,pos/frames,volume,(lfoPan+1)/2]);

		// do the panning
		snd=Balance2.ar(snd[0],snd[1],lfoPan);

		snd = CombC.ar(snd,0.5,Rand(0.05,0.5),2); // random delay

		// final output
		Out.ar(0,snd*volume/5);
	}).send(s);

	// basic players
	SynthDef("recorder",{
		arg buf,recLevel=1.0,preLevel=0.0;
		RecordBuf.ar(SoundIn.ar([0,1]),buf,0.0,recLevel,preLevel,loop:0,doneAction:2);
	}).send(s);

	// effects
	SynthDef("effects",{
		arg amp=1.0;

		// collect the sound coming from the bus "0" on 2 channels (stereo)
		var snd=In.ar(0,2);

		// add some delay
		snd = CombC.ar(snd,0.5,delaytime:0.25,decaytime:1.1);

		// add some reverb
		snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.5),[
			snd,
			FreeVerb2.ar(snd[0],snd[1],50)
			//Fverb.ar(snd[0],snd[1],50,decay:LFNoise2.kr(1/3).range(70,90))
		]);

		// replace the output with the effected output
		ReplaceOut.ar(0,snd*Lag.kr(amp));
	}).send(s);

	// load the ube class
	u=Ube.new(Server.default);

	Routine {
		// either load a file into the tape
		u.loadTape(tape:1,filename:thisProcess.nowExecutingPath.dirname++"/whale.wav");
		// OR record another tape and play it
		// u.recordTape(tape:1,seconds:3,recLevel:2); 3.5.wait;

		0.5.wait; // give time for buffer to load
		// create players to play the tape
		u.playTape(tape:1,player:0,rate:1,db:0,timescale:1);
		u.playTape(tape:1,player:1,rate:0.5,db:3,timescale:1.0);
		u.playTape(tape:1,player:2,rate:0.25,db:6,timescale:1.0);
		u.playTape(tape:1,player:3,rate:0.125,db:9,timescale:1.0);
		u.playTape(tape:1,player:4,rate:2,db:-6,timescale:1.0);
		u.playTape(tape:1,player:5,rate:4,db:-12,timescale:1.0);
		// show gui
		u.gui;

	}.play;



});
)

// TRY IT! load your own sounds, record your own sounds
// change the modulation, change the effects

