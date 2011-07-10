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

; Get the last element (as in, remove path from listified filename)
(define (last-element lis)
  (cond ((null? (cdr lis)) (car lis))
        (else (last-element (cdr lis))) ))

(define (morph-filename orig-name new-extension)
  (let* ((buffer (vector "" "" "")))
    (if (re-match "^(.*)[.]([^.]+)$" orig-name buffer)
      (string-append (substring orig-name 0 (car (vector-ref buffer 2))) new-extension)) ))

(define (filename-extension filename new-extension)
  (morph-filename (last-element (strbreakup filename "/")) new-extension) )

(define (android-save-scaled-9patch theImage theDrawable theDirectory scale-factor)
  (let*
    ((new-xcf-file (car (gimp-temp-name "xcf")))
     (result-png-file (string-append theDirectory "/"
                                     (filename-extension (car (gimp-image-get-filename theImage)) "9.png")))
     (width (car (gimp-image-width theImage)))
     (height (car (gimp-image-height theImage)))
     (new-image 0)
     (result-layer 0) )
    (gimp-xcf-save 0 theImage theDrawable new-xcf-file new-xcf-file)
    (set! new-image (car (gimp-xcf-load 0 new-xcf-file new-xcf-file)))
    (gimp-image-scale-full new-image
                           (* scale-factor width)
                           (* scale-factor height)
                           INTERPOLATION-CUBIC)
    (android-render-nine-patch new-image)
    (set! result-layer (car (gimp-image-merge-visible-layers new-image EXPAND-AS-NECESSARY)))
    (file-png-save2 1
                    new-image
                    result-layer
                    result-png-file
                    result-png-file
                    0 9 0 0 0 0 0 0 0 )
    (gimp-image-delete new-image)
  ))


(define (android-save-all-resolutions theImage theDrawable theDirectory)
  (let*
    ( (resolution (car (gimp-image-get-resolution theImage))) )
    (android-save-scaled-9patch theImage theDrawable
                                (string-append theDirectory "/drawable-ldpi")
                                (/ 120 resolution))
    (android-save-scaled-9patch theImage theDrawable
                                (string-append theDirectory "/drawable-mdpi")
                                (/ 160 resolution))
    (android-save-scaled-9patch theImage theDrawable
                                (string-append theDirectory "/drawable-hdpi")
                                (/ 240 resolution))
  ))

(script-fu-register
  "android-save-all-resolutions"         ; func name
  "Save all resolutions"              ; menu label
  "Saves all images (as 9-patch) into the\
   'drawable-*' directories scaled and 9patched\
   according to the current image's resolution"
  "Greyson Fischer"                 ; author
  "copyright 2011, Greyson Fischer" ; copyright notice
  "July 9, 2011"                    ; date created
  "RGBA"                            ; image type that the script works on
  SF-IMAGE  "Image" 0               ; - current image
  SF-DRAWABLE "Drawable" 0          ; - current layer
  SF-DIRNAME "Resources Directory" "/tmp/res" ; directory into which to place drawable-*
  )
(script-fu-menu-register "android-save-all-resolutions" "<Image>/Image/Android")
