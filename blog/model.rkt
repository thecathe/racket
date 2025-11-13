#lang racket

(provide blog? blog-posts
         post? post-title post-body post-comments
         initialize-blog!
         blog-insert-post!
         post-insert-comment!)

(struct blog (home-path posts) #:mutable #:prefab)
(struct post (title body comments) #:mutable #:prefab)

; initialize-blog!
(define (initialize-blog! home-path)
  ; if no blog found, return default (empty list)
  (define (log-missing-exn-handler exn)
    (blog (path->string home-path) empty))
  ; read the blog
  (define the-blog
    (with-handlers ([exn? log-missing-exn-handler])
      (with-input-from-file home-path read)))
  (set-blog-home-path! the-blog (path->string home-path))
  ; load the blog
  the-blog)
     
; save blog
(define (save-blog! a-blog)
  (define (write-to-blog)
    (write a-blog))
  (with-output-to-file (blog-home-path a-blog)
    write-to-blog
    #:exists 'replace))

; blog-insert-post
(define (blog-insert-post! a-blog title body)
  (set-blog-posts!
   a-blog
   (cons (post title body empty) (blog-posts a-blog)))
  (save-blog! a-blog))

; post-insert-comment
(define (post-insert-comment! a-blog a-post a-comment)
  (set-post-comments!
   a-post
   (append (post-comments a-post) (list a-comment)))
  (save-blog! a-blog))
