# racket-papertrail - a Papertrail Racket library 

A [Papertrail](https://papertrailapp.com/) library for [Racket](https://racket-lang.org/).

![a dummy papertrail demo image](https://raw.githubusercontent.com/sleibrock/racket-papertrail/master/images/sample.png)

## About

Papertrail is a service used to capture your program's/system's log messages and store them in an easy-to-access place. They use the [syslog](https://en.wikipedia.org/wiki/Syslog) standard to capture messages from servers or programs, and have written a service in Go called [remote_syslog2](https://github.com/papertrail/remote_syslog2). However, sometimes you don't always want to interop with your application's server and just want to capture data from the local program.

The aim of `racket-papertrail` is to send log messages from a Racket application to a target Papertrail destination sink. It can also send data to an output port like STDIN (if you modify the `current-output-port` parameter) so it can perform logging locally and remotely to Papertrail.

## Installing

`papertrail.rkt` can be installed through the standard Racket package manager `raco`.


## Using Papertrail

Create a new `paper` struct with `new-papertrail`, then initialize a logger through `create-paper-logger`.
```
(require papertrail)

(define p (new-papertrail "logs4.papertrailapp.com" 12345 "racket"))
(define log (create-paper-logger p))

(log "Hello world!")
(log "This is a fatal warning" "FATAL")
```
