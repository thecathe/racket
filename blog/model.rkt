#lang racket

(require racket/list
         db)

(provide blog? blog-posts
         post? post-title post-body post-comments post-id->string
         initialize-blog!
         blog-insert-post!
         post-insert-comment!)

;(struct blog (home-path posts) #:mutable #:prefab)
;(struct post (title body comments) #:mutable #:prefab)

(struct blog (db))
(struct post (blog id))
(struct posts (ids))

(define (blog-posts a-blog)
  (define (id->post an-id)
    (post a-blog an-id))
  (map id->post
       (query-list ; for queries that return single column
        (blog-db a-blog)
        "SELECT id FROM posts")))

(define (post-title a-post)
  (query-value
   (blog-db (post-blog a-post))
   "SELECT title FROM posts WHERE id = ?"
   (post-id a-post)))

(define (post-body a-post)
  (query-value
   (blog-db (post-blog a-post))
   "SELECT body FROM posts WHERE id = ?"
   (post-id a-post)))

(define (post-comments a-post)
  (query-list
   (blog-db (post-blog a-post))
   "SELECT content FROM comments WHERE pid = ?"
   (post-id a-post)))

(define (post-id->string a-post)
  (string-append "post-" (number->string (post-id a-post))))

; initialize-blog!
(define (initialize-blog! home-path)
  ; connect to db
  (define db (sqlite3-connect #:database home-path #:mode 'create))
  (define the-blog (blog db))
  (unless (table-exists? db "posts")
    (query-exec
     db
     (string-append "CREATE TABLE posts "
                    "(id INTEGER PRIMARY KEY, title TEXT, body TEXT)")))
  (unless (table-exists? db "comments")
    (query-exec
     db
     "CREATE TABLE comments (pid INTEGER, content TEXT)"))
  the-blog)
  ; if no blog found, return default (empty list)
  ;(define (log-missing-exn-handler exn)
  ;  (blog (path->string home-path) empty))
  ; read the blog
  ;(define the-blog
  ;  (with-handlers ([exn? log-missing-exn-handler])
  ;    (with-input-from-file home-path read)))
  ;(set-blog-home-path! the-blog (path->string home-path))
  ; load the blog
  ;the-blog)
     
; save blog
#;
(define (save-blog! a-blog)
  (define (write-to-blog)
    (write a-blog))
  (with-output-to-file (blog-home-path a-blog)
    write-to-blog
    #:exists 'replace))

; blog-insert-post
(define (blog-insert-post! a-blog title body)
  (query-exec
   (blog-db a-blog)
   "INSERT INTO posts (title, body) VALUES (?, ?)"
   title body))

; post-insert-comment
(define (post-insert-comment! a-blog p a-comment)
  (query-exec
   (blog-db a-blog)
   "INSERT INTO comments (pid, content) VALUES (?, ?)"
   (post-id p) a-comment))
