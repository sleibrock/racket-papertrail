#lang info
(define collection   'multi)
(define pkg-authors  '("Steven Leibrock <steven.leibrock@gmail.com>"))
(define pkg-desc     "Logging functions to send data to Papertrail")
(define version      "0.1")

(define deps         '("base"))
(define build-deps   '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings  '(("scribblings/papertrail.scrbl" ())))
