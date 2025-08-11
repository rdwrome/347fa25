( // kinematics example
var window, userView, snake;
// first load the snake factory
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_05_12.scd").loadPaths;
snake = ~snakeFactory.(50,20,40);
window = Window("Kinematic snake", 640@640).front.acceptsMouseOver_(true); // to enable mouse actions
userView = UserView(window, 640@640).background_(Color.black).animate_(true).frameRate_(60).drawFunc_({
	snake.draw;
});
userView.mouseOverAction_({arg m,x,y;
	snake.refresh(x@y);
});
)
