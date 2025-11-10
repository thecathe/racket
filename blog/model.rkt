#lang racket

(provide (all-defined-out))

(struct blog (posts) #:mutable)
(struct post (title body comments) #:mutable)

(define BLOG (blog (list)))


; blog-insert-post
(define (blog-insert-post! a-blog a-post)
  (set-blog-posts!
   a-blog
   (cons a-post (blog-posts a-blog))))

; post-insert-comment
(define (post-insert-comment! a-post a-comment)
  (set-post-comments!
   a-post
   (append (post-comments a-post) (list a-comment))))
