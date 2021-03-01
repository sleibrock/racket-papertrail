#lang racket/base

#|
papertrail/main.rkt

A library used to send syslog messages to Papertrailapp.com

Resources used:
https://stackify.com/syslog-101/
https://sematext.com/blog/what-is-syslog-daemons-message-formats-and-protocols/
|#

; Require our base libraries
(require racket/udp)
(require racket/date)
(require racket/list)
(require racket/string)
(require racket/contract)
(require racket/format)


;; Exports
(provide new-papertrail
         create-paper-logger
         close-papertrail
         (struct-out paper)
         )


;; Determine if a number is between the valid UNIX port range
(define port-number? (between/c 0 65535))

;; Create a contract for a non-empty string
(define nonempty-string? (and/c string? (λ (x) (not (string=? "" x)))))


;; Pad a number with zero-digits if it's less than 10
;; Only used for formatting an iso8601 datestring
(define-syntax-rule (pad-2digits x)
  (~a x #:align 'right #:width 2 #:left-pad-string "0"))


;; Create an ISO-8601 datestring for sending syslog messages
;; Void -> String
(define/contract (iso8601-datestring)
  (-> string?)
  (define cdate (current-date))
  (format "~a-~a-~aT~a:~a:~a.000"
          (date-year cdate)
          (pad-2digits (date-month cdate))
          (pad-2digits (date-day cdate))
          (pad-2digits (date-hour cdate))
          (pad-2digits (date-minute cdate))
          (pad-2digits (date-second cdate))))


;; Do we also log messages to #<parameter:current-output-port>?
;; This doubles as extra logging functionality for us that we can
;; see logging without needing to look at Papertrail
(define/contract stdout-logging?
  (parameter/c boolean?)
  (make-parameter #f))


;; The new struct to contain everything.
(define-struct paper (sock host port sys))


;; Create a new paper struct with a helper
(define/contract (new-papertrail host port sys)
  (-> string? port-number? string? paper?)
  (define sock (udp-open-socket))
  (udp-connect! sock host port)
  (paper sock host port sys))


;; Close a paper struct manually (used to kill the UDP connection)
(define/contract (close-papertrail p)
  (-> paper? void?)
  (define sock (paper-sock p))
  (udp-close sock)
  (if (udp-connected? sock)
      (displayln (format "Err: socket not closed by program"))
      (displayln (format "Socket closed successfully"))))


;; Create a logger from a paper struct.
(define/contract (create-paper-logger p)      
  (-> paper? (-> string? void?))
  (define sock (paper-sock p))
  (define sys-name (paper-sys p))
  (λ (msg [type "DEBUG"])
      (define payload
        (format "<1>1 ~aZ ~a ~a - - - ~a"
                (iso8601-datestring) sys-name type msg))
      (udp-send sock (string->bytes/utf-8 payload))))
  

;; Testing stuff (what do I test?)
;; (I don't think I should include any personal Papertrail configs)
(module+ test
  (displayln "No tests to do"))


;; Do I put anything in here?
(module+ main
  (void))

; end
