( // simple decision-making encoder
Server.default.waitForBoot({
	var data = Array.fill(100,{rrand(0,1.0)}); // our dataset
	var mappingFunc = { arg datum; // the mapping function
		if (datum<=0.5) { // if input is less than 0.5
			datum.linlin(0,0.5,200,400); // map linearly in the low register
		} {  // else map linearly to the high register
			datum.linlin(0.5,1.0,2000,4000);
		};
	};
	fork{loop{ // sonify dataset
		var freq;
		freq = mappingFunc.(data.choose);
		{SinOsc.ar(freq) * Line.ar(1,0,0.4,doneAction:2)}.play;
		0.5.wait;
	}};
})
)
/*Advanced Mappings
In Chapter 6: Data Acquisition and Mapping, we demonstrated how we can essentially map any consecutive range to any other with respect to distribution curves. In this section we will extend our arsenal of encoding techniques and introduce ourselves with how to implement complex and intelligent encodings.
Complex and intelligent encodings
There are situations wherein what we need is some kind of intelligence that will take the necessary decisions and select the appropriate process from a broader range of candidate ones in order to encode our data properly. To realize such mappings we need some kind of mechanism that ensures the right decisions are taken, and of course we need to define alternative behaviors. A simplistic way to implement decision-making algorithms would be using test mechanisms and control flow structures, such as if or case. For the following simplistic example, assume, that we want to sonify floating point numerical values in the range of 0-1 so that they control oscillators that are either in a low (200-400) or in a high (2000-4000) frequency register. That is to say that our destination range is not continuous.
Consider this possible solution:
( // simple decision-making encoder
Server.default.waitForBoot({
	var data = Array.fill(100,{rrand(0,1.0)}); // our dataset
	var mappingFunc = { arg datum; // the mapping function
		if (datum<=0.5) { // if input is less than 0.5
			datum.linlin(0,0.5,200,400); // map linearly in the low register
		} {  // else map linearly to the high register
			datum.linlin(0.5,1.0,2000,4000);
		};
	};
	fork{loop{ // sonify dataset
		var freq;
		freq = mappingFunc.(data.choose);
		{SinOsc.ar(freq) * Line.ar(1,0,0.4,doneAction:2)}.play;
		0.5.wait;
	}};
})
)
This is a very simplistic case of course, albeit it exemplifies how an algorithm can make decisions and is therefore a very primitive kind of artificial.intelligence.*/