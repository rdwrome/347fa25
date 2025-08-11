( // fractal animation
var window, userView, fractal;
// first load the fractal factory
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_05_07.scd").loadPaths;
window = Window("fractal animation", 640@640).front;
fractal = ~fractalFactory.value(5, 7, window.bounds.center, 60,0.5); // create a fractal
userView = UserView(window, 640@640).background_(Color.black).animate_(true).frameRate_(30).drawFunc_({
	fractal.animate(0.001,[Color.red,Color.green]); // animate it
});
)
