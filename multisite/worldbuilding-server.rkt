#lang racket

(require web-server/servlet
         web-server/formlets
         web-server/dispatch
         db)

(provide/contract (start (request? . -> . response?)))

