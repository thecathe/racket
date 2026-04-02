#lang racket

(provide site-head
         render-as-itemized-list)

; site-head
(define (site-head site-name)
  (define (default-css)
    '(link ((rel "stylesheet")
            (href "/style.css")
            (type "text/css"))))
  `(head (title ,site-name)
         ,(default-css)))


; render-as-itemized-list
(define (render-as-itemized-list items)
  (define (render-as-item an-item)
    `(li ,an-item))
  `(ul ,@(map render-as-item items)))


