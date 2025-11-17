#lang racket

(require web-server/servlet
         web-server/formlets
         ;  web-server/safety-limits
         web-server/dispatch
         db)

(provide/contract (start (request? . -> . response?)))

(require "model.rkt")

; start
(define (start request)
  (blog-dispatch request))

; blog-dispatch
(define-values (blog-dispatch request)
  (dispatch-rules 
  [("") (render-initial-blog-page request)]
  [else (render-initial-blog-page request)]
  ))

; (define (initialized-blog)
;   (initialize-blog!
;    (build-path (current-directory) "the-blog.db")))

(define (render-initial-blog-page request) 
  (render-blog-page (initialize-blog!
   (build-path (current-directory) "the-blog.db")) request))

; back-to-homepage
; (define (back-to-homepage a-blog view-blog-page-handler embed/url)
;   `(a ((id "back-to-homepage")
;        (class "nav-btn heading lift")
;        (href ,(embed/url view-blog-page-handler)))
;       "Back"))

; render-blog-page
(define (render-blog-page a-blog request)
  ; view-blog-page-handler
  ; when defining a handler, it must point to something that has a response-generator
  (define (view-blog-page-handler request)
    (render-blog-page a-blog request))
  ; response-generator
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (head (title "My Blog")
             (link ((rel "stylesheet")
                    (href "/style.css")
                    (type "text/css"))))
       (body
        ; heading
        (h1 ((class "heading")) "Under Construction")
        ; nav-bar
        (div ((id "nav-bar") (class "container"))
             (a ((id "nav-homepage-btn")
                 (class "nav-btn heading lift")
                 (href ,(embed/url view-blog-page-handler)))
                "Blog"))
        ; main-content
        ,(render-posts a-blog embed/url)
        (form ([action ,(embed/url insert-post-handler)])
              ,@(formlet-display new-post-formlet)
              (input ([type "submit"])))))))

  ; insert-post-handler
  (define (insert-post-handler request)
    (define-values (title body)
      (formlet-process new-post-formlet request))
    (blog-insert-post! a-blog title body)
    (render-blog-page a-blog (redirect/get)))

  (send/suspend/dispatch response-generator))

; new-post-formlet : formlet (values string? string?)
; A formlet for requesting a title and body of a post
(define new-post-formlet
  (formlet
   (#%# ,((to-string
           (required
            (text-input
             #:attributes '([id "new-post-title"] [class "form-text form-title"]))))
          . => . title)
        ,((to-string
           (required
            (text-input
             #:attributes '([id "new-post-body"] [class "form-text form-body"]))))
          . => . body))
   (values title body)))

; (define new-post-formlet
;   (formlet
;    (#%# ,{input-string . => . title}
;         ,{input-string . => . body})
;    (values title body)))

; render-post-detail-page
(define (render-post-detail-page a-blog a-post request)
  ; view-blog-page-handler
  (define (view-blog-page-handler request)
    (render-blog-page a-blog request))
  ; response-generator
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (head (title "Post Details")
             (link ((rel "stylesheet")
                    (href "/style.css")
                    (type "text/css"))))
       (body
        ; heading
        (h1 ((class "heading")) "View Post")
        ; nav-bar
        (div ((id "nav-bar") (class "banner-container"))
             (a ((id "nav-homepage-btn")
                 (class "nav-btn heading lift")
                 (href ,(embed/url view-blog-page-handler)))
                "Blog"))
        ; main-content
        (h2 "Post details")
        (h3 ,(post-title a-post))
        (p ,(post-body a-post))
        ,(render-comments (post-comments a-post))
        (form ([action
                ,(embed/url insert-comment-handler)])
              ,@(formlet-display new-comment-formlet)
              (input ([type "submit"])))))))

  ; parse-comment
  (define (parse-comment bindings)
    (extract-binding/single 'comment bindings))

  ; insert-comment-handler
  (define (insert-comment-handler request)
    (render-comment-confirmation-page
     a-blog
     (formlet-process new-comment-formlet request)
     a-post
     request))


  (send/suspend/dispatch response-generator))


(define new-comment-formlet
  (formlet
   (#%# ,((to-string
           (required
            (text-input
             #:attributes '([id "new-comment"] [class "form-text form-body"]))))
          . => . comment))
   (values comment)))

; render-comment-confirmation-page
(define (render-comment-confirmation-page a-blog a-comment a-post request)
  ; view-blog-page-handler
  (define (view-blog-page-handler request)
    (render-blog-page a-blog request))
  ; response-generator
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (head (title "Confirmation")
             (link ((rel "stylesheet")
                    (href "/style.css")
                    (type "text/css"))))
       (body
        ; heading
        (h1 ((class "heading")) "Comment Confirmation")
        ; nav-bar
        (div ((id "nav-bar") (class "banner-container"))
             (a ((id "nav-homepage-btn")
                 (class "nav-btn heading lift")
                 (href ,(embed/url view-blog-page-handler)))
                "Blog"))
        ; main content
        (h3 "Add a Comment")
        (div ((class ""))
             "The comment: "
             (div ((id "") (class "")) (p ,a-comment))
             "will be added to "
             (div ((id "") (class "")) ,(post-title a-post)))

        (div ((id "") (class ""))
             (p (a ((href ,(embed/url confirm-handler))) "Confirm.")))
        (div ((id "") (class ""))
             (p (a ((href ,(embed/url cancel-handler))) "Cancel")))))))

  #;
  (define (view-comment-confirmation-page-handler request)
    (render-comment-confirmation-page (redirect/get)))

  (define (confirm-handler request)
    (post-insert-comment! a-blog a-post a-comment)
    (render-post-detail-page a-blog a-post (redirect/get)))

  (define (cancel-handler request)
    (render-post-detail-page a-blog a-post request))

  (send/suspend/dispatch response-generator))

; render-post
(define (render-post a-blog a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-blog a-post request))
  `(div ((id ,(post-id->string a-post)) (class "post lift wobble"))
        (a ((class "post-link") (href ,(embed/url view-post-handler)))
           (div ((class "post-title heading")) (h4 ,(post-title a-post)))
           (div ((class "post-body-wrap"))
                (div ((class "post-body")) (p ,(post-body a-post))))
           (div ((class "post-comments-wrap"))
                (div ((class "post-comments-num"))
                     (p ,(number->string (length (post-comments a-post)))
                        " comment(s)"))))))

; render-posts
(define (render-posts a-blog embed/url)
  (define (render-post/embed/url a-post)
    (render-post a-blog a-post embed/url))
  `(div ((id "posts") (class "container"))
        ,@(map render-post/embed/url (blog-posts a-blog))))

; parse-comment
(define (parse-comment bindings)
  (extract-binding/single 'comment bindings))

; form-new-comment
#;
(define (form-new-comment embed/url insert-comment-handler)
  `(form ((action ,(embed/url insert-comment-handler)))
         (input ((name "comment")))
         (input ((type "submit")))))

; form-new-post
#;
(define (form-new-post embed/url insert-post-handler)
  `(form ((action ,(embed/url insert-post-handler)))
         (input ((name "title")))
         (input ((name "body")))
         (input ((type "submit")))))



(define (render-as-itemized-list items)
  `(ul ,@(map render-as-item items)))


(define (render-as-item an-item)
  `(li ,an-item))


; render-comment
(define (render-comment a-comment)
  `(div ((class "post-comment"))
        (p ,a-comment)))

; render-comments
(define (render-comments comments)
  `(div ((class "post-comments"))
        ,@(map render-comment comments)))


; can-parse-post?
(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)
       (exists-binding? 'comments bindings)))



(require web-server/servlet-env)
(serve/servlet start
               #:launch-browser? #f
               #:quit? #t
               #:listen-ip #f
               #:port 8080
               #:servlet-path "/blog"
               #:servlets-root (build-path "res")
               #:server-root-path "./"
               #:extra-files-paths (list (build-path "res"))
               ;  #:safety-limits (make-safety-limits )
               )