#lang web-server/insta

;; NOTE
;; embed/url generates URLs
;; -> embed/url f
;; -> f request
;; -> request-bindings request

(require "model.rkt")

(define Post1 (post "Title1" "Body1" (list)))
(define Post3 (post "Title3" "Body3" (list "some comment1" "com2")))


; start
(define (start request)
  (render-blog-page request))

; parse-comment
(define (parse-comment bindings)
  (post (extract-binding/single 'comment bindings)))

; can-parse-post?
(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)
       (exists-binding? 'comments bindings)))

; form-new-comment
(define (form-new-comment embed/url insert-comment-handler)
  `(form ((action ,(embed/url insert-comment-handler)))
         (input ((name "comment")))
         (input ((type "submit")))))

; form-new-[pst
(define (form-new-post embed/url insert-post-handler)
  `(form ((action ,(embed/url insert-post-handler)))
         (input ((name "title")))
         (input ((name "body")))
         (input ((type "submit")))))

; render-blog-page
(define (render-blog-page request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (style "html,div,h1,h2,h3,h4,p{background-color:rgba(50, 168, 82, 0.329);transition:background-color 0.1s;}div:hover{background-color:rgba(77, 138, 104, 0.34)}")
       (head (title "My Blog"))
       (body
        (h1 "Under Construction")
        ,(render-posts embed/url)
        ,(form-new-post embed/url insert-post-handler)))))

  ; parse-post
  (define (parse-post bindings)
    (post (extract-binding/single 'title bindings)
          (extract-binding/single 'body bindings)
          empty))

  (define (insert-post-handler request)
    (blog-insert-post!
     BLOG (parse-post (request-bindings request)))
    (render-blog-page request))

  (send/suspend/dispatch response-generator))

; render-post-detail-page
(define (render-post-detail-page a-post request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (head (title "Post Details"))
       (body
        (a ((href ,(embed/url view-blog-page-handler)))
           "Back")
        (h1 "Post details")
        (h2 ,(post-title a-post))
        (p ,(post-body a-post))
        ,(render-as-itemized-list (post-comments a-post))
        ,(form-new-comment embed/url insert-comment-handler)))))

  (define (parse-comment bindings)
    (extract-binding/single 'comment bindings))

  (define (insert-comment-handler a-request)
    (render-comment-confirmation-page
     (parse-comment (request-bindings a-request))
     a-post
     a-request))

  ; when defining a handler, it must point to something that has a response-generator
  (define (view-blog-page-handler request)
    (render-blog-page request))

  (send/suspend/dispatch response-generator))

; render-comment-confirmation-page
(define (render-comment-confirmation-page a-comment a-post request)
  (define (view-comment-confirmation-page-handler request)
    (render-comment-confirmation-page request))

  (define (response-generator embed/url)
    (response/xexpr
     `(html
       (head (title "Confirmation"))
       (body
        (h1 "Add a Comment")
        "The comment: " (div (p ,a-comment))
        "will be added to " (div ,(post-title a-post))

        (p (a ((href ,(embed/url confirm-handler))) "Confirm."))
        (p (a ((href ,(embed/url cancel-handler))) "Cancel"))))))

  (define (confirm-handler a-request)
    (post-insert-comment! a-post a-comment)
    (render-post-detail-page a-post a-request))

  (define (cancel-handler a-request)
    (render-post-detail-page a-post a-request))

  (send/suspend/dispatch response-generator))

; render-post
(define (render-post a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-post request))

  `(div ((class "post"))
        (a ((href ,(embed/url view-post-handler)))
           ,(post-title a-post))
        (div ((class "post-head")) (p ,(post-title a-post)))
        (div ((class "post-body")) (p ,(post-body a-post)))
        ,(render-comments (post-comments a-post))))

; render-posts
(define (render-posts embed/url)
  (define (render-post/embed/url a-post)
    (render-post a-post embed/url))
  `(div ((class "posts"))
        ,@(map render-post/embed/url (blog-posts BLOG))))


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

