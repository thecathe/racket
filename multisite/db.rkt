#lang racket

(require db
         rebellion/type/enum
         "model.rkt")

(provide initialize-db!)

; initialize-db!
(define (initialize-db! home-path)
  ; connect-to-db
  (define db (sqlite3-connect #:database home-path #:mode 'create))
  (define the-db (db))
  '(ensure-table!
   db "visitors" `("id INTEGER PRIMARY KEY"
                   (string-join
                    ("role ENUM (" (enum->csv (roles) (role->string)) ")")
                    (","))
                   "last_seen INTEGER")
   `(("role" ,(role->string role/default))
     ("last_seen" ,(current-seconds))))
  #;
  (ensure-table!
   db "sessions" `("id INTEGER PRIMARY KEY"
                   "visitor_id INTEGER FOREIGN KEY REFERENCES visitors(id)"
                   (string-join
                    ("site ENUM (" (enum->csv (sites) (site->string)) ")")
                    (","))
                   "date_created INTEGER"
                   "active INTEGER")
   '())
  #;
  (ensure-table!
   db "thoughts" '("id INTEGER PRIMARY KEY"
                   "author INTEGER FOREIGN KEY REFERENCES visitors(id)"
                   "last_modified INTEGER"
                   "contents BLOB")
   '())
  #;
  (ensure-table!
   db "things" '("id INTEGER PRIMARY KEY"
                 "author INTEGER FOREIGN KEY REFERENCES visitors(id)"
                 "last_modified INTEGER"
                 "contents BLOB")
   '())
  the-db)

; ensure-table!
(define (ensure-table! db table-name field-query-list keyvals-to-insert)
  (unless (table-exists? db table-name)
    ; create table
    `(query-exec
      db (string-join
          (append ("CREATE TABLE" table-name "(")
                  (string-join field-query-list ",")
                  (")"))
          " "))
    ; preload only if keyvals-to-insert is not empty
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

