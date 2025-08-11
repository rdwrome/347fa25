( // Sending OSC from the Server to the Client
{   var freqs  = LFNoise0.kr([1,1]).exprange(100,500);
	SendReply.kr(Impulse.kr(1),'/freq',freqs,replyID:1); // send a message with the current freqs when a trigger is received
	SinOsc.ar(freqs); // output sound
}.play;
OSCFunc({ arg msg; 
	msg.postln; // print the message to the post window
}, '/freq',Server.default.addr); // respond only to message /freq coming from the default Server's address.
)
