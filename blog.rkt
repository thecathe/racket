#lang web-server/insta
(define (render-as-itemized-list items)
  `(ul ,@(map render-as-item items)))
(define (render-as-item an-item)
  `(li ,an-item))


(struct blog (posts) #:mutable)
(struct post (title body comments) #:mutable)


(define Post1 (post "Title1" "Body1" empty))
(define Post3 (post "Title3" "Body3" empty))

(define BLOG
  (blog (list Post1 (post "S1" "C1" empty) Post3)))

(define (blog-insert-post! a-blog a-post)
  (set-blog-posts! a-blog
                   (cons a-post (blog-posts a-blog))))

; start
(define (start request)
  (render-blog-page request))

; request-bindings
;(define (request-bindings request)

; parse-post
(define (parse-post bindings)
  (post (extract-binding/single 'title bindings)
        (extract-binding/single 'body bindings)))

; can-parse-post?
(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))

; render-blog-page
(define (render-blog-page request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html 
       (style "html,div,h1,h2,h3,h4,p{background-color:rgba(50, 168, 82, 0.329);transition:background-color 0.1s;}div:hover{background-color:rgba(77, 138, 104, 0.34)}")
       (head (title "My Blog"))
       (body 
             (h1 "Under Construction")
             ,(render-posts)
             (form ((action
                     ,(embed/url insert-post-handler)))
              (input ((name "title")))
              (input ((name "body")))
              (input ((type "submit"))))))))
  (define (insert-post-handler request)
    (blog-insert-post!
     BLOG (parse-post (request-bindings request)))
    (render-blog-page request))
  (send/suspend/dispatch response-generator))

; render-post
; #32a852
(define (render-post a-post)
   `(div ((class "post"))
         (h3 ,(string-append "Title: " (post-title a-post)))
         (p ,(string-append "Post: " (post-body a-post)))))

; render-posts
(define (render-posts)
  `(div ((class "posts"))
        ,@(map render-post (blog-posts BLOG))))
;(define (render-posts posts)
;  (cond [(empty? posts) `(div ((class "posts")))]
;         [(cons? posts) `(div ((class "posts")) ,@(map render-post posts))]))