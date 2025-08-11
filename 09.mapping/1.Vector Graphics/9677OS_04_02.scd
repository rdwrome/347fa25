( // loading and displaying images
var image = Image.new("/Users/rrome/Desktop/pug.png"); // load image
Window.new.front.drawFunc_({
    image.drawAtPoint(0@0,image.bounds); // display image
})
)