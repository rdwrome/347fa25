( // onset detection example
Server.default.waitForBoot({
	{   // a complex signal 
		var sound, sequence, fft, analysis;
		sequence = Demand.kr(Impulse.kr(2),0,Dseq([[250,300],[420,650],[100,150],[1000,2300]],inf));
		sound = Saw.ar(sequence,mul:0.2)+Resonz.ar(ClipNoise.ar(),sequence,0.3,1);
		sound = sound * EnvGen.ar(Env([0,1,0],[0,0.5]),Impulse.kr(2));
		Coyote.kr(sound).poll(label:\Coyote);
		Slope.ar(sound).poll(label:\Slope); 
		fft = FFT(LocalBuf(512),Mix.new(sound));
		analysis = PV_HainsworthFoote.ar(fft,0.5,0.5,threshold:1);
		K2A.ar(1).poll(K2A.ar(analysis),label:\HainsworthFoote); 
		analysis = PV_JensenAndersen.ar(fft,threshold:0.2);
		K2A.ar(1).poll(K2A.ar(analysis),label:\JensenAndersen); 
		analysis = Onsets.kr(fft,threshold:1);
		K2A.ar(1).poll(K2A.ar(analysis),label:\Onsets);
		Out.ar(0,sound);b
	}.play;
})
)
