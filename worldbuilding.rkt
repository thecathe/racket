#lang typed/racket

(require "worldbuilding/structs.rkt")


(define locations
  (list
   (location 'Arb (set "Arbhor'tahn" "Forest of the Vale") (list ""))
   ))

(define Species
  (list
   (species 'Korread
            (set "Korread")
            (list "Goat geodude oread people."
                  "Doc Martin earnest."))
   (species 'Scorcher
            (set "Scorcher")
            (list "Satyr Mjork fusion"))))