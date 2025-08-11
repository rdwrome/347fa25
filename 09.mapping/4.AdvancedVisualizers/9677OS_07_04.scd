( // rotating windmills
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "/9677OS_07_windmill_factory.scd").loadPaths; // first load the windmill factory

Server.default.waitForBoot({ // boot server
	var window, userView, windmills; // GUI elements
	var synths, buses; // an array of synths and an array of buses
	
	fork{  // sound related
		buses = Array.fill(5,{Bus.control(Server.default)}); // allocate the buses
		Server.default.sync; // sync with server
		SynthDef(\windmillVisualizerSynth, { arg freqOut, rate;
			var signal, modulator, analysis;
			modulator = LFNoise2.ar(rate).range(100,1000);
			signal = Saw.ar(modulator) * 0.2; 
			analysis = Tartini.kr(signal); // analyze signal
			signal = signal!2; // mix signal and make stereo
			Out.kr(freqOut, analysis[0]); // output to a control bus
			Out.ar(0,signal); 
		}).add; // add synthDef
		Server.default.sync; // sync with server
		synths = Array.fill(5,{arg i; 
			Synth(\windmillVisualizerSynth,[
				\freqOut, buses[i], \rate, rrand(0.5,1.0);
			]);
		}); // start 5 synths 
	};
	
	// GUI related
	windmills = [ // an array with 5 windmills
		~windmillFactory.(125@80,80,8,[Color.red,Color.black]),
		~windmillFactory.(325@80,80,8,[Color.red,Color.black]),
		~windmillFactory.(225@225,80,8,[Color.red,Color.black]),  
		~windmillFactory.(125@370,80,8,[Color.red,Color.black]),
		~windmillFactory.(325@370,80,8,[Color.red,Color.black]),
	];
	window = Window("Rotating windmills", 450@450).front;
	window.onClose_({ // clean up
		synths.do{arg i; i.free;};
		buses.do{arg i; i.free};
	});

	// animation
	userView = UserView(window, 450@450).background_(Color.white).animate_(true).clearOnRefresh_(false).frameRate_(60).drawFunc_({ 
		Pen.fillColor_(Color(1,1,1,0.5)); // a transparent white
		Pen.addRect(Rect(0,0,450,450));   // create a semi-transparent rectangle to cover previous contents (for trailing effects)
		Pen.fill; // draw rectangle
		windmills.do{arg item, index; // for each windmill
			// calculate speed from frequency
			var speed = buses[index].getSynchronous.explin(100,1000,20,10); // encode frequency to speed factor
			Pen.push;
			Pen.rotate((userView.frame/speed).cos, item.position.x,item.position.y);  // divide frame count with speed factor 
			item.draw();
			Pen.pop;
		}
	});
});
)
