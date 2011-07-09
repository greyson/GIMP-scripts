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
