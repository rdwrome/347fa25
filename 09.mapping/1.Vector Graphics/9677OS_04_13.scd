( // a fractal example
var window, fractal; // declare variables
    (PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_04_12.scd").loadPaths; // first load the windmill factory
window = Window("a fractal !", 640@640).background_(Color.black).front;
fractal = ~fractalFactory.(6, 4,window.bounds.center,60,0.6);
window.drawFunc_({
	fractal.draw({Color.rand});
});
)
