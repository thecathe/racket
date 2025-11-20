#lang racket

(require racket/list
         db
         rebellion/type/enum
         net/url
         web-server/http
         web-server/dispatch)

(provide enum->csv
         url->request
         role roles role->string role/default role/admin role/user role/guest
         site sites site->string site/default site/academic site/blog site/dev site/db site/worldbuilding)

; enum->csv
(define (enum->csv an-enum an-enum->string)
  (define (enum-keyset->csv a-keyset key->string)
    (define (enum-keyset->string-list a-keyset key->string)
      (map key->string a-keyset))
    (string-join
     (enum-keyset->string-list a-keyset key->string)
     ", "))
  (enum-keyset->csv (an-enum) an-enum->string))

; url->request
(define (url->request u)
    (make-request #"GET" (string->url u) empty
                  (delay empty) #f "1.2.3.4" 80 "4.3.2.1"))

; role-enum
(define-enum-type role (role/admin role/user role/guest))
(define (roles) '(role/admin role/user))
(define/contract (role->string a-role)
  (-> role? string?)
  (match a-role
    [(== role/admin) "role/admin"]
    [(== role/user) "role/user"]
    [(== role/guest) "role/guest"]))

(define role/default role/guest)
;(struct role/current (role) #:mutable #:auto-value role/default)

; site-enum
(define-enum-type site (site/academic site/blog site/dev site/db site/worldbuilding))
(define (sites) '(site/academic site/blog site/dev site/db site/worldbuilding))
(define/contract (site->string a-site)
  (-> site? string?)
  (match a-site
    [(== site/academic) "site/academic"]
    [(== site/blog ) "site/blog"]
    [(== site/db) "site/db"]
    [(== site/dev) "site/dev"]
    [(== site/worldbuilding) "site/worldbuilding"]))

(define site/default site/academic)
;(struct site/current (site) #:mutable #:auto-value role/guest)
