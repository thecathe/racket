#lang racket

(require web-server/servlet
         web-server/formlets
         web-server/dispatch
         db
         "model.rkt"
         ;"db.rkt"
         "html.rkt"
         racket/trace)

(struct env (db))

; initialize-db!
(define (initialize-db! home-path)
  ; connect-to-db
  (define db (sqlite3-connect #:database home-path #:mode 'create))
  (define the-db (env db))
  (ensure-table!
   db "visitors" `("id INTEGER PRIMARY KEY"
                   (string-join
                    ("role ENUM (" (enum->csv (roles) (enum/role->string)) ")")
                    (","))
                   "last_seen INTEGER")
   `(("role" ,(enum/role->string role/default))
     ("last_seen" ,(current-seconds))))
  the-db)

; ensure-table!
(define (ensure-table! db table-name field-query-list keyvals-to-insert)
  (unless `(table-exists? db ,table-name)
    ;(begin
      ; create table
      (query-exec
        db
        (string-join
         (append `("CREATE TABLE" ,table-name "(")
                 `(string-join ,field-query-list ",")
                 (")"))
         " "))
      ; preload only if keyvals-to-insert is not empty
      #;
      `(cond [(not (empty? keyvals-to-insert))
              (query-exec
               db (string-join
                   (append ("INSERT INTO" table-name "(")
                           (string-join ,@(map first keyvals-to-insert) ",")
                           (") VALUES (")
                           (string-join (make-list (length to-preload) "?") ",")
                           (")"))
                   " "))]
             ,@(map second keyvals-to-insert))))

; db/select-table
(define (db/select-table the-db table-name)
  (query-value
    (env-db the-db)
    (string-join `("SELECT * FROM" ,table-name) " ")))

; db/check-existing-tables
(define (db/check-existing-tables the-db)
  (query-list
    (env-db the-db)
    "SELECT name FROM sqlite_master WHERE type='table'"))

; db/tables/show-existing
(define (db/tables/show-existing the-db)
  (define (db/table/show-existing-table a-table)
    `(tr ((class "db_table_row"))
         (td ,a-table)))
  (define (the-tables)
    (db/check-existing-tables the-db))
  #;
  (define (db/check-existing-tables/the-db)
    (db/check-existing-tables the-db))
  #;
  (define (map/db/check-existing-tables/the-db)
    `(map db/table/show-existing-table ,db/check-existing-tables/the-db))
  `(table ((id "table_status_table")
             (class "container db_table"))
            (tr ((class "db_table_row"))
                (th "Table"))
     
            ,@(map db/table/show-existing-table (the-tables))
            ;,@(map db/table/show-existing-table (the-tables))
            ;,(map/db/check-existing-tables/the-db)
            ))
  

; db/check-table-exists
(define (db/check-table-exists the-db table-name)
  (query-value
    (env-db the-db)
    "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='{?}'"
    table-name))

; db/table/show-status
(define (db/table/show-status the-db table-name)
  `(div ((id ,(string-join `("table_status_" ,table-name) ""))
         (class "table_status"))
        (db/check-table-exists the-db ,table-name)))
        
; db/tables/show-status
(define (db/tables/show-status-table the-db)
  (define (db/table/show-status/the-db a-table)
    `(tr ((id ,(string-join `("db_table_status_" ,(enum/table->string a-table)) ""))
          (class "db_table_row"))
         (td ,(enum/table->string a-table))
         (td ,(db/check-table-exists the-db (enum/table->string a-table)))))
  `(table ((id "table_status_table")
           (class "container db_table"))
          (tr ((class "db_table_row"))
              (th "Table") (th "Exists"))
          ,@(map db/table/show-status/the-db (tables))))
  


(provide/contract (start (request? . -> . response?)))

; start
(define (start request)
  (main-dispatch
;   (initialize-db! (build-path (current-directory) "data.sqlite"))
   request))

  
; TODO: move to main.rkt
(define-values (main-dispatch request)
  (dispatch-rules
   [("db") (dispatch/render-db-site request)]
   ;[else (render-db-site '(initialize-db! (build-path (current-directory) "data.sqlite")) request)]
   ))

; dispatch/render-db-site
(define (dispatch/render-db-site request)
  (render-db-site
   (initialize-db! (build-path (current-directory) "data.db"))
   request))

; render-db-site
(define (render-db-site the-db req)
  ; view-db-page-handler 
  (define (view-db-page-handler req)
    (render-db-site the-db req))
  ; view-fresh-db-page-handler
  #;
  (define (view-fresh-db-page-handler req)
    (main-dispatch (url->request "http://localhost:8080/db")))
  ; response-generator
  (define (response-generator embed/url)
    (response/xexpr
     `(html
       ,(site-head (enum/site->string site/db))
       (body (h1 ((class "heading"))
                 ,(string-join `("test" ,(enum/site->string site/db)) ": "))
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
                     "DB"))
             ;,(db/tables/show-status-table the-db)
             ,(db/tables/show-existing the-db)
             ))))
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