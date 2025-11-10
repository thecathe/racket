#lang racket

(require racketui)

(define (acronym a-los)
  (cond [(empty? a-los) ""]
        [(cons? a-los)
          (if (char-upper-case? (string-ref (first a-los) 0))
              (string-append (substring (first a-los) 0 1)
                             (acronym (rest a-los)))
              (acronym (rest a-los)))]))

(web-launch
 "Acronym Builder"
 (function
  "Enter some words to build an acronym."
  (acronym ["Words" (listof+ ["Word" string+])]
           -> ["The acronym" string])))