( // draw windmills
var windmillA, windmillB, windmillC, windmillD;
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_04_06.scd").loadPaths; // first load the windmill factory
windmillA=~windmillFactory.(150@150,150,15, [Color.red,Color.magenta]);
windmillB=~windmillFactory.(100@500,80,23); 
windmillC=~windmillFactory.(500@100,100,5,[Color.magenta,Color.black]);
windmillD=~windmillFactory.(400@420,200,9,[Color.black,Color.blue]);
Window.new("Windmills",640@640).background_(Color.white).front.drawFunc_({
	windmillA.draw();
	windmillB.draw();
	windmillC.draw();
	windmillD.draw();
});
)