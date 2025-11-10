#lang web-server/insta
; start: request -> response
(define (start request)
  (phase-1 request)
  ;(show-counter 0 request)
  )
 
; phase-1: request -> response
(define (phase-1 request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (body (h1 "Phase 1")
             (a ((href ,(embed/url phase-2)))
                "click me!")))))
  (send/suspend/dispatch response-generator))
 
; phase-2: request -> response
(define (phase-2 request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (body (h1 "Phase 2")
             (a ((href ,(embed/url phase-1)))
                "click me!")))))
  (send/suspend/dispatch response-generator))

; show-counter: number request -> doesn't return
; Displays a number that's hyperlinked: when the link is pressed,
; returns a new page with the incremented number.
(define (show-counter n request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Counting example"))
            (body
             (a ((href ,(embed/url next-number-handler)))
                ,(number->string n))))))
 
  (define (next-number-handler request)
    (show-counter (+ n 1) request))
  (send/suspend/dispatch response-generator))