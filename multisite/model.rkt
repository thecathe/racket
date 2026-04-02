#lang racket

(require racket/list
         db
         rebellion/type/enum
         net/url
         web-server/http
         web-server/dispatch)

(provide enum->csv
         url->request
         enum/role roles enum/role->string role/default role/admin role/user role/guest
         enum/site sites enum/site->string site/default site/academic site/blog site/dev site/db site/worldbuilding
         enum/table tables enum/table->string table/visitors table/sessions table/thoughts table/things table/blog
         ;enum/table tables enum/table->string enum/table/visitors enum/table/sessions enum/table/thoughts enum/table/things enum/table/blog
         )

; url->request
(define (url->request u)
    (make-request #"GET" (string->url u) empty
                  (delay empty) #f "1.2.3.4" 80 "4.3.2.1"))

; enum->csv
(define (enum->csv an-enum an-enum->string)
  (define (enum-keyset->csv a-keyset key->string)
    (define (enum-keyset->string-list a-keyset key->string)
      (map key->string a-keyset))
    (string-join
     (enum-keyset->string-list a-keyset key->string)
     ", "))
  (enum-keyset->csv (an-enum) an-enum->string))

; enum/table
(define-enum-type enum/table (table/visitors table/sessions table/thoughts table/things table/blog))
(define (tables) (list table/visitors table/sessions table/thoughts table/things table/blog))
(define/contract (enum/table->string a-table)
  (-> enum/table? string?)
  (match a-table
    [(== table/visitors) "table/visitors"]
    [(== table/sessions) "table/sessions"]
    [(== table/thoughts) "table/thoughts"]
    [(== table/things) "table/things"]
    [(== table/blog) "table/blog"]))

; enum/role
(define-enum-type enum/role (role/admin role/user role/guest))
(define (roles) '(role/admin role/user))
(define/contract (enum/role->string a-role)
  (-> enum/role? string?)
  (match a-role
    [(== role/admin) "role/admin"]
    [(== role/user) "role/user"]
    [(== role/guest) "role/guest"]))

(define role/default role/guest)
;(struct role/current (role) #:mutable #:auto-value role/default)

; enum/site-enum
(define-enum-type enum/site (site/academic site/blog site/dev site/db site/worldbuilding))
(define (sites) '(site/academic site/blog site/dev site/db site/worldbuilding))
(define/contract (enum/site->string a-site)
  (-> enum/site? string?)
  (match a-site
    [(== site/academic) "site/academic"]
    [(== site/blog ) "site/blog"]
    [(== site/db) "site/db"]
    [(== site/dev) "site/dev"]
    [(== site/worldbuilding) "site/worldbuilding"]))

(define site/default site/academic)
;(struct site/current (site) #:mutable #:auto-value role/guest)
