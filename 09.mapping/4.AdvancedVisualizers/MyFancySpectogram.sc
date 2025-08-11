MyFancySpectrogram { 
	// instance variables
	var mWindow, mUserView;  // our main views
	var mBuffer;   // the buffer for the FFT analysis
	var mSynth;    // the synth that performs the analysis
	var mInput;    // the input bus
	var mColumns;  // an array of Images to hold the collumn of the spectrogram

	*new { arg inBus = 0;
		^super.new.init(inBus); // redirect to init
	}

	init { arg inBus; 
		mInput = inBus;  // copy inBus to instance variable
		mColumns = Array.fill(640,{arg i; Image.newEmpty(1,512)}); // an array of empty Images having dimension 1@512 
		Server.default.waitForBoot({fork{ // boot server and start a Routine
			mBuffer = Buffer.alloc(Server.default,1024); // alloc buffer
			Server.default.sync; // sync to the server

			this.addSynthDef.value; // call this instance's addSynthDef method
			{ this.makeGui.value; }.defer;  // call this instance's makeGUI method
		}});
	}

	addSynthDef { // this methods adds the SynthDef to the graph
		SynthDef(\myFancySpectrogramSynth, {
			arg in, buf;
			FFT(buf,In.ar(Mix.new(in))); // just analyze audio and fill the buffer with spectral data
		}).add;
		Server.default.sync; // sync to the server
	}

	makeGui{ // this method sets up the various GUI elements
		mWindow = Window("MyFancySpectrogram !", 640@512,false).front; 
		mWindow.onClose_({ 
			mColumns.do{arg image; image.free};
			mSynth.free;
			mBuffer.free;
		});
		mUserView = UserView(mWindow,640@512).background_(Color.white)
		.frameRate_(30).animate_(false).drawFunc_({ 
			this.updateColumns.value; // call this instance's updateColumns' method
			// draw columns once next to each other starting from the left
			mColumns.do{ arg image,index; 
				image.drawAtPoint(Point(index,0),image.bounds); 
			};
		});
	}

	updateColumns { // this methods reads/processes spectral data and updates columns accordingly
		// read spectral data from the FFT buffer
		mBuffer.getn(0, 1024,{ arg buf; 
			var magnitudes, complex, data; 
			{ // defer
				magnitudes = buf.clump(2).flop; // re-arrange spectral data so that we have a pair of magnitudes/phases
				complex = ((((Complex(
					Signal.newFrom( magnitudes[0] ),
					Signal.newFrom( magnitudes[1] )
				).magnitude.reverse)).log10)*80).clip(0, 255); // process spectral data accordingly so that we end up with an array of values represent the intensity of the 512 bins as numbers in the 0-255 range

				// convert bin intensity to pixels
				data = complex.floor.collect({arg item; 
					var pixel, color;
					color = Color.grey( (255 - item) / 255 ); // first invert bin intensity so that full intensity is black, rather than white
					Image.colorToPixel( color ); // convert color to pixel (setPixels cannot handle colors directly)
				});
				
				data = data.as(Int32Array); // make an Int32Array out of our bins (this is what setPixels expects)
				mColumns = mColumns.rotate(-1); // rotate mColumns so that the first element is now the last and all the rest are moved to the left
				mColumns[639].setPixels(data,Rect(0,0,1,512)); // fill the last column with newly acquired data
			}.defer;
		});
	}

	start {  // create a analysis synth and start animation
		if (Server.default.serverRunning) {
			mSynth = Synth.tail(Server.default, \myFancySpectrogramSynth,
				[\buf, mBuffer, \in, mInput]);
			mUserView.animate_(true);
		} {
			"Please wait for Server to boot and try again !";
		}
	}

	stop { // free synth and pause animation
		mUserView.animate_(false);
		mSynth.free;
	}
}
