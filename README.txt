My GIMP script(s)

Android menu actions:
   Image->Android->Standard 9-patch
      This will simply resize the canvas 1 pixel in all directions and add a
      '9patch' layer of transparent color so that you can draw a 9 patch in
      the second most painful way ever (by hand, once-only, better than
      draw9patch)

   Image->Android->Prepare as 9-patch
      Prepare an image (add the appropriate layers) to have an elastic region
      and a content region.  The layers are set to 33% transparency; simply
      draw/fill a box in the appropriate place over the image to denote the
      region which should be demarked as either content or elastic.

   Image->Android->Render 9-patch layer
      Resizes the image (+1 all) and creates a 9patch layer with the
      appropriate pixels masked off based on the non-alpha regions of the
      content and elastic regions created by the 'Prepare as 9-patch' option
      above.

   Image->Android->Save all resolutions
      Saves three images into the resources directory specified at running
      time -- or some other way through batch mode, but I haven't tried that
      yet.  Based on the images 'resolution' information (see Scale Image) it
      will resize the image for all of ldpi, mdpi, and hdpi before saving them
      into the subdirectories (under the input folder) "drawable-ldpi",
      "drawable-mdpi", and "drawable-hdpi".

      This is nearly the culmination of what I was hoping, in some wild
      dreams, to do... and in curiously short time. Now I just want to make
      this script deal also with images that are not 9-patch images.
