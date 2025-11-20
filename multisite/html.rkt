#lang racket

(provide site-head)

(define (site-head site-name)
  (define (default-css)
    '(link ((rel "stylesheet")
            (href "/style.css")
            (type "text/css"))))
  `(head (title ,site-name)
         ,(default-css)))