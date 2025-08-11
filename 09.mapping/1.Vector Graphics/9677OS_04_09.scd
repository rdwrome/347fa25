( // An a-canonical particle system
var window = Window("An a-canonical particle system",640@480).background_(Color.black).front;

(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_04_06.scd").loadPaths; // first load the windmill factory

window.drawFunc_({ 500.do{      // iterate 500 times
    var x,y, radius, windmill;
    x = window.bounds.width.rand;  // a random x (but within bounds)
    y = window.bounds.height.rand; // a random y (but within bounds)
    radius = rrand(10,50);         // a random radius
    Pen.push;                      // push a new matrix
    Pen.alpha_(1.0.rand);    // set a random level of transparency
    Pen.rotate(2pi.rand,x,y);  // randomly rotate each particle around its own axis
    windmill = ~windmillFactory.value(x@y,radius,(5,7..25).choose, [Color.rand,Color.rand]); // generate a windmill object centered at x@y with a random ratio, a random even number of wings, and random colorings
    windmill.draw(); // draw windmills
    Pen.pop;   // destroy matrix and revert to default state
}});
)
