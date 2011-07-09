(define (android-nine-patch theImage theLayer)
  (let* ( (new-layer 0) )
    (gimp-undo-push-group-start theImage)
    (gimp-image-resize theImage 
                       (+ (car (gimp-image-width theImage)) 2)
                       (+ (car (gimp-image-height theImage)) 2) 1 1)
    (set! new-layer (car (gimp-layer-new theImage 
                                         (car (gimp-image-width theImage))
                                         (car (gimp-image-height theImage))
                                         RGBA-IMAGE "9patch" 100 0)))
    (gimp-drawable-set-tattoo new-layer 990)
    (gimp-image-add-layer theImage new-layer 0)
    (gimp-undo-push-group-end theImage)
    )
  )

(script-fu-register
  "android-nine-patch"              ; func name
  "Standard 9-patch"                ; menu label
  "Prepares an image for \
   android 9-patch annotation"      ; description
  "Greyson Fischer"                 ; author
  "copyright 2011, Greyson Fischer" ; copyright notice
  "July 8, 2011"                    ; date created
  "RGBA"                            ; image type that the script works on
  SF-IMAGE  "Image" 0               ; - current image
  SF-DRAWABLE "Drawable" 0          ; - current layer
  )
(script-fu-menu-register "android-nine-patch" "<Image>/Image/Android")

; This next part is going to be two-part, and it's going to (hopefully)
; be the most elegant solution to the 9-patch problem.

(define (android-prep-nine-patch theImage)
  (let*
    ((width (car (gimp-image-width theImage)))
     (height (car (gimp-image-height theImage)))
     (new-layer 0))
    (gimp-undo-push-group-start theImage)
    ; Add the elastic layer
    (set! new-layer (car (gimp-layer-new theImage width height
                                         RGBA-IMAGE "9-elastic" 33 0)))
    (gimp-drawable-set-tattoo new-layer 991)
    (gimp-image-add-layer theImage new-layer -1)

    ; Add the content containment layer
    (set! new-layer (car (gimp-layer-new theImage width height
                                         RGBA-IMAGE "9-content" 33 0)))
    (gimp-drawable-set-tattoo new-layer 992)
    (gimp-image-add-layer theImage new-layer -1)

    (gimp-undo-push-group-end theImage)
   ))

(script-fu-register
  "android-prep-nine-patch"         ; func name
  "Prepare as 9-patch"              ; menu label
  "Prepares an image for \
   region-based
   android 9-patch annotation"      ; description
  "Greyson Fischer"                 ; author
  "copyright 2011, Greyson Fischer" ; copyright notice
  "July 9, 2011"                    ; date created
  "RGBA"                            ; image type that the script works on
  SF-IMAGE  "Image" 0               ; - current image
  )
(script-fu-menu-register "android-prep-nine-patch" "<Image>/Image/Android")

(define (android-render-nine-patch theImage)
  (let*
    ((imageWidth (+ 2 (car (gimp-image-width theImage))))
     (imageHeight (+ 2 (car (gimp-image-height theImage))))
     (selection 0)
     (new-layer 0)
     (line-points (cons-array 4 'double))
     (elasticLayer (car (gimp-image-get-layer-by-tattoo theImage 991)))
     (contentLayer (car (gimp-image-get-layer-by-tattoo theImage 992))) )
    (gimp-undo-push-group-start theImage)
    (gimp-context-push)
    (gimp-image-resize theImage imageWidth imageHeight 1 1)

    ; Get the drawing layer and set up our brush
    (set! new-layer (car (gimp-layer-new theImage imageWidth imageHeight
                                         RGBA-IMAGE "9patch" 100 0)))
    (gimp-drawable-set-tattoo new-layer 990)
    (gimp-image-add-layer theImage new-layer -1)
    (gimp-brushes-set-brush "Circle (01)")
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-opacity 100)

    ; Grab the dimensions of the elastic layer
    (gimp-selection-layer-alpha elasticLayer)
    (set! selection (cdr (gimp-selection-bounds theImage)))
    (gimp-selection-clear theImage)

    (aset line-points 0 0)
    (aset line-points 1 (cadr selection))
    (aset line-points 2 0)
    (aset line-points 3 (- (cadddr selection) 1))
    (gimp-pencil new-layer 4 line-points)

    (aset line-points 0 (car selection))
    (aset line-points 1 0)
    (aset line-points 2 (- (caddr selection) 1))
    (aset line-points 3 0)
    (gimp-pencil new-layer 4 line-points)

    ; Grab the dimensions of the content layer
    (gimp-selection-layer-alpha contentLayer)
    (set! selection (cdr (gimp-selection-bounds theImage)))
    (gimp-selection-clear theImage)

    (aset line-points 0 (- imageWidth 1))
    (aset line-points 1 (cadr selection))
    (aset line-points 2 (- imageWidth 1))
    (aset line-points 3 (- (cadddr selection) 1))
    (gimp-pencil new-layer 4 line-points)

    (aset line-points 0 (car selection))
    (aset line-points 1 (- imageHeight 1))
    (aset line-points 2 (- (caddr selection) 1))
    (aset line-points 3 (- imageHeight 1))
    (gimp-pencil new-layer 4 line-points)

    (gimp-context-pop)
    (gimp-undo-push-group-end theImage)
  ))

(script-fu-register
  "android-render-nine-patch"         ; func name
  "Render 9-patch layer"              ; menu label
  "Renders the 9-patch layer based on\
   android 9-patch elastic and content annotation layers"      ; description
  "Greyson Fischer"                 ; author
  "copyright 2011, Greyson Fischer" ; copyright notice
  "July 9, 2011"                    ; date created
  "RGBA"                            ; image type that the script works on
  SF-IMAGE  "Image" 0               ; - current image
  )
(script-fu-menu-register "android-render-nine-patch" "<Image>/Image/Android")

