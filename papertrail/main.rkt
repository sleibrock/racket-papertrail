#lang racket/base

#|
papertrail/main.rkt

A library used to send syslog messages to Papertrailapp.com
|#

; Require our base libraries
(require racket/udp)
(require racket/date)
(require racket/list)
(require racket/string)
(require racket/contract)


;; Exports
(provide *NOFILTER* ; constants
         *DEBUG*
         *INFO*
         *WARN*
         *ERROR*
         *FATAL*

         ; parameters
         papertrail-filter-level
         send-messages-to-output-port
         
         ; primary functions
         init-papertrail
         )


;; Define any constants (filter levels mostly)
(define-values (*NOFILTER* *DEBUG* *INFO* *WARN* *ERROR* *FATAL*)
  (values 0 10 20 30 40 50))


;; Define any parameters we need for Papertrail interactions

;; Define parameters to use for initializing the loggers
;; These will serve as the default values for #<init-papertrail>
;; and can be used through #<syntax:parameterize> 
(define papertrail-host     (make-parameter              ""))
(define papertrail-port     (make-parameter               0))
(define papertrail-sys-name (make-parameter "racket-logger"))


;; Define the base syslog filtering level.
;; If we do (papertrail-filter-level *ERROR*), only
;; messages that are level ERROR or greater will pass
(define papertrail-filter-level (make-parameter 0))


;; Do we also log messages to #<parameter:current-output-port>?
;; This doubles as extra logging functionality for us that we can
;; see logging without needing to look at Papertrail
(define send-messages-to-output-port (make-parameter #f))


;; Determine if a number is between the valid UNIX port range
(define port-number? (between/c 0 65535))


;; Pad a number with zero-digits if it's less than 10
;; Only used for formatting an iso8601 datestring
;; Number -> String
(define (pad-2digits x)
  (if (< x 10) (format "0~a" x) (format "~a" x)))


;; Create an ISO-8601 datestring for sending syslog messages
;; Void -> String
(define (iso8601-datestring)
  (define cdate (current-date))
  (format "~a-~a-~aT~a:~a:~a.000"
          (date-year cdate)
          (pad-2digits (date-month cdate))
          (pad-2digits (date-day cdate))
          (pad-2digits (date-hour cdate))
          (pad-2digits (date-minute cdate))
          (pad-2digits (date-second cdate))))


;; Create five logging functions over a shared UDP socket
;; The sys-name var will determine how Papertrail splits up the syslog systems 
(define (init-papertrail [host     {papertrail-host}]
                         [port     {papertrail-port}]
                         [sys-name {papertrail-sys-name}])

  ; check for errors early
  (unless (string? host)
    (error (format "init-papertrail: 'host' needs string, given ~a" host)))
  (unless (port-number? port)
    (error (format "init-papertrail: 'port' needs port-number [1..65535], given ~a" port)))
  (unless (string? sys-name)
    (error (format "init-papertrail: 'sys-name' needs string, given ~a" sys-name)))
  (when (string=? "" host)
    (error "init-papertrail: Empty hostname given"))
  (when (string=? "" sys-name)
    (error "init-papertrail: Empty sys-name given"))

  ; define a udp socket for sending data
  ; Then connect it to the target host and port
  (define sock (udp-open-socket))
  (udp-connect! sock host port)

  ; create a function that sends a string over a socket
  (define (send-string s)
    (udp-send sock (string->bytes/utf-8 s)))

  ; Create a logging factory when we create our five loggers
  (define (log-factory log-name priority)
    (λ (msg)
      (define sendy-string
        (format "<1>1 ~aZ ~a ~a - - - ~a"
                (iso8601-datestring) sys-name log-name msg))

      ; attempt to send messages (if it passes the filter level)
      (when (>= priority {papertrail-filter-level})
        (when {send-messages-to-output-port}
          (displayln "Port logging active!"))
        (send-string sendy-string))))

  ; return all five functions in one value tuple
  (values (log-factory "DEBUG" 10)
          (log-factory "INFO"  20)
          (log-factory "WARN"  30)
          (log-factory "ERROR" 40)
          (log-factory "FATAL" 90)
          ))


;; Testing stuff (what do I test?)
;; (I don't think I should include any personal Papertrail configs)
(module+ test
  (displayln "No tests to do"))


;; Do I put anything in here?
(module+ main
  (void))

; end
