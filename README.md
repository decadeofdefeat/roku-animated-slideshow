Roku Animated Slideshow
=======================

I couldn't find a decent slide show application written for Roku so I wrote one myself.

This application assumes you are using 1280x720 jpgs. I didn't update it yet to make graphics scale to the screen if they are not the same dimensions of the screen.

The slide show uses a Robert Penner easing equation to ease the images in and out as they transition.

Currently the slide show pulls a JSON feed from a website. You could modify it to load an XML file, local images or images stored on a USB.

Note:
The slide show application loads all of the images right away into the tmp:// directory of the app. This way it doesn't have to load each image from the list every time it's called. So far in my testing this hasn't caused the app to crash. However, there may be a limit to how many images you could load into this application before the memory would reach capacity. If you need a lot of images, it may be better to load the images as they are called from the move_handler function instead of loading the tmp:// graphics from the array.

Roadmap of updates/fixes I'd like to accomplish
===============================================

1. Allow images to be pulled from a USB stick
2. Add the ability for background music in a never-ending loop
3. Add the ability to use any size images that scale to screen
4. Add more transition options
5. Test with a lot of images (100+) to see if the app crashes
6. Add control of slides with remote (PowerPoint style)
7. Add ability of 1080p resolution for Roku 3
8. Figure out why m.JSON_ARRAY.photos.count() doesn't work?