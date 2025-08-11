( // another fractal example
var window, fractal; 
    (PathName(Document.current.path).pathOnly ++ "9677OS_04_12.scd").loadPaths; // first load the windmill factory
window = Window("a fractal !", 640@640).background_(Color.black).front;
fractal = ~fractalFactory.(6, 6,window.bounds.center,100,0.5);
window.drawFunc_({
	fractal.draw({Color.rand});
});
)
