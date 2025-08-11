( // kinematic pattern visualizer
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "/9677OS_07_snake_factory.scd").loadPaths; // first load the windmill factory
Server.default.waitForBoot({fork{ // boot server and start a routine
	var snake; // the kinematic snake
	var tempo; // a tempo clock
	var data; // pattern data to use for snake's movement
	var window, userView; // the window and the userView
	var sound; // a Pmono 
	
	SynthDef(\mySound, { arg freqA,freqB;  
		var signal = SinOsc.ar([freqA*0.9,freqA*1.1]);
		signal = signal + BrownNoise.ar(0.3);
		signal = signal * SinOsc.ar(freqB).range(0,1);
		signal = LPF.ar(signal,400);
		Out.ar(0,signal*0.5);
	}).add; // add SynthDef
	Server.default.sync; // and sync to server

	tempo = TempoClock.new(10); // new TempoClock
	
	snake = ~snakeFactory.(50,20,40,{arg i; Color(0.3,1-i,0.8)}); // create a new snake

	// a Pmono event player mapping random walk streams to frequencies
	sound = Pmono(\mySound, 
		\freqA, Pwalk((100..800),Pbrown(-5,5,1,inf).trunc,1,200.rand),
		\freqB, Pwalk((100..800),Pbrown(-5,5,1,inf).trunc,1,200.rand)
	).collect({ arg event; 
		data = event; // assign currently playing event to data
	}).play(tempo,quant:Quant(quant: 1, timingOffset: 0.1));
	
	0.5.wait; // wait half a second before creating the GUI so that the event has been assigned to data in time

	{ // defer
		window = Window("Kinematic Pattern Visualizer",640@480,false).front;
		window.onClose_({
			sound.stop;
			sound.free;
		});
		
		userView = UserView(window,640@480).background_(Color.black).frameRate_(30).clearOnRefresh_(false).animate_(true).drawFunc_({
			var newPosition; // snake's new position
			
			// adding trails
			Pen.fillColor_(Color(0,0,0,0.4));
			Pen.addRect(Rect(0,0,640,480));
			Pen.fill;
			
			// calculate new position
			newPosition = Point(
				data.freqA.explin(100,800,1,640),
				data.freqB.explin(100,800,1,480)				
			);
			
			snake.refresh(newPosition); // update snake's position
			snake.draw();  // draw snake
		});
	}.defer;
}});
)
