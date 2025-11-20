#lang racket

(require web-server/servlet
         web-server/formlets
         web-server/dispatch
         db
         "model.rkt"
         "db.rkt"
         "html.rkt")

(provide/contract (start (request? . -> . response?)))

; start
(define (start request)
  (main-dispatch
;   (initialize-db! (build-path (current-directory) "data.sqlite"))
   request))

  
; TODO: move to main.rkt
(define-values (main-dispatch request)
  (dispatch-rules
   [("db") (render-db-site '(initialize-db! (build-path (current-directory) "data.sqlite")) request)]
   [else (render-db-site '(initialize-db! (build-path (current-directory) "data.sqlite")) request)]
   ))

; render-db-site
(define (render-db-site db req)
  ; view-db-page-handler 
  (define (view-db-page-handler req)
    (render-db-site db req))
  ; view-fresh-db-page-handler 
  (define (view-fresh-db-page-handler req)
    (main-dispatch (url->request "http://localhost:8080/db")))
  ; response-generator
  (define (response-generator embed/url)
    (response/xexpr
     `(html ,(site-head (site->string site/db))
            (body (h1 ((class "heading"))
                      ,(string-join `("test" ,(site->string site/db)) ": "))
                  (div ((id "nav-bar") (class "container"))
                       (a ((id "nav-homepage-btn")
                           (class "nav-btn heading lift")
                           #;
                           (href ,(embed/url
                                   (main-dispatch
                                    (url->request "http://localhost:8080/db"))))
                           (href ,(embed/url view-db-page-handler))
                           ;(href ,(embed/url view-fresh-db-page-handler))
                           )
                          "DB"))))))
  (send/suspend/dispatch response-generator))


; start
(require web-server/servlet-env)
(serve/servlet start
               #:launch-browser? #f
               #:quit? #t
               #:listen-ip #f
               #:port 8080
               #:servlet-path "/db"
               #:servlets-root (build-path "res")
               #:server-root-path "./"
               #:extra-files-paths (list (build-path "res")))