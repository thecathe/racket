#lang racket

(define-values
  (struct:thing make-thing thing? thing-ref thing-set!)
  (make-struct-type 'thing #f 2 1 'uninitialized))
(define a-thing (make-thing 'x 'y))


(struct thingOLD
  (alias 
   names 
   description))

;(define-values struct:thingOLD (make-struct-type 'thingOLD))


;#lang typed/racket


; need to make a monad containing the "set of names",
; from which all things draw their names from
  
; define custom description type that can contain symbols within the text and create symbolic links between them.
; is this already how scribble works? this may want to be a kind of programmatic wrapper for that?

; define method of renaming other pre-existing aliases

; (define-type names (Setof String))

;(struct thingOLD
;  ([alias : Symbol]
;   [names : names]
;   [description : (Listof String)]))

;(define-values
;  (struct:thing make-thing thing? thing-ref thing-set!)
;  (make-struct-type 'thing #f 2 1 'uninitialized))
;(define a-thing (make-thing 'x 'y))

(define-values (struct:a make-a a? a-ref a-set!)
  (make-struct-type 'a #f 2 1 'uninitialized))
(define an-a (make-a 'x 'y))

;(define-type Thing (-> thing))
;(define-type Collection (Setof Thing))

;(define-type Location : Thing)
;(define-type 


;(provide location species)