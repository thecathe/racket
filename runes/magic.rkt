#lang racket

(require redex)

; L
(define-language L
  ; expression
  (e ::= (e e)
         (need x)
         (amb e ...)
         (have? x e e)
         (fix e)
         a
     )
  ; class
  (c ::= (process)
         (enzyme)
     )
  ; actions
  (a ::= (consume) ; take from environment
         (produce) ; give to environment
         (map f)   ; (consume) to (produce)
         (store)   ; put in context
         (read)    ; get from context
         (emit)    ; signal to environment
         (observe) ; signal from environment
         (solve)   ; no-more-expansion
         (compute) ; handle the evaluation of terms
         (reduce)
         (spawn)
         (yield)
     )
  ; functions
  (f ::= (x t)
     )
  ; variable names
  (x y ::= variable-not-otherwise-mentioned)
  ; environmental resource
  ;(r ::= 
   ;  )
  )

(define-extended-language L+Γ L
  [Γ ∅ (x : t Γ)])