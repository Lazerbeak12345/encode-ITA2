#lang typed/racket/base
(module+ test (require typed/rackunit))
(provide encode-ITA_2 string->ita_2)
(: string->ita_2 (String . -> . (Listof Exact-Nonnegative-Integer)))
(define-type L/F (U Null 'LETTERS 'FIGURES))
(define (string->ita_2 str)
  (define mode : (U L/F Void) (void))
  (apply append
         (for/list : (Listof (Listof Exact-Nonnegative-Integer))
                   ([char str])
              (define vals : (Pair L/F Exact-Nonnegative-Integer)
                (case char
                  ; My source for this was Wikipedia. (The only thing I sourced was the table from characters to values)
                  [(#\null)      '(() . #x00)]
                  [(#\E) '(LETTERS .    #x01)] [(#\3) '(FIGURES . #x01)]
                  [(#\linefeed)  '(() . #x02)]
                  [(#\A) '(LETTERS .    #x03)] [(#\-) '(FIGURES . #x03)]
                  [(#\space)     '(() . #x04)]
                  [(#\S) '(LETTERS .    #x05)] [(#\') '(FIGURES . #x05)]
                  [(#\I) '(LETTERS .    #x06)] [(#\8) '(FIGURES . #x06)]
                  [(#\U) '(LETTERS .    #x07)] [(#\7) '(FIGURES . #x07)]

                  [(#\return)    '(() . #x08)]
                  [(#\D) '(LETTERS .    #x09)] [(#\u05)'(FIGURES . #x09)] ; Enquiry
                  [(#\R) '(LETTERS .    #x0A)] [(#\4)  '(FIGURES . #x0A)]
                  [(#\J) '(LETTERS .    #x0B)] [(#\u07)'(FIGURES . #x0B)] ; bell
                  [(#\N) '(LETTERS .    #x0C)] [(#\,)  '(FIGURES . #x0C)]
                  [(#\F) '(LETTERS .    #x0D)] [(#\!)  '(FIGURES . #x0D)]
                  [(#\C) '(LETTERS .    #x0E)] [(#\:)  '(FIGURES . #x0E)]
                  [(#\K) '(LETTERS .    #x0F)] [(#\()  '(FIGURES . #x0F)]

                  [(#\T) '(LETTERS .    #x10)] [(#\5) '(FIGURES . #x10)]
                  [(#\Z) '(LETTERS .    #x11)] [(#\+) '(FIGURES . #x11)]
                  [(#\L) '(LETTERS .    #x12)] [(#\)) '(FIGURES . #x12)]
                  [(#\W) '(LETTERS .    #x13)] [(#\2) '(FIGURES . #x13)]
                  [(#\H) '(LETTERS .    #x14)] [(#\£) '(FIGURES . #x14)]
                  [(#\Y) '(LETTERS .    #x15)] [(#\6) '(FIGURES . #x15)]
                  [(#\P) '(LETTERS .    #x16)] [(#\0) '(FIGURES . #x16)]
                  [(#\Q) '(LETTERS .    #x17)] [(#\1) '(FIGURES . #x17)]

                  [(#\O) '(LETTERS .    #x18)] [(#\9) '(FIGURES . #x18)]
                  [(#\B) '(LETTERS .    #x19)] [(#\?) '(FIGURES . #x19)]
                  [(#\G) '(LETTERS .    #x1A)] [(#\&) '(FIGURES . #x1A)]
                  #|figs------------------1B|#
                  [(#\M) '(LETTERS .    #x1C)] [(#\.) '(FIGURES . #x1C)]
                  [(#\X) '(LETTERS .    #x1D)] [(#\/) '(FIGURES . #x1D)]
                  [(#\V) '(LETTERS .    #x1E)] [(#\;) '(FIGURES . #x1E)]
                  ; Delete char is ltr in ltr mode
                  [(#\u7F)'(LETTERS .   #x1F)] #|ltrs---------------1F|#
                  [else (raise-user-error "invalid ITA2 char" char)]))
              (define ltrsorfigs (car vals))
              (define num (cdr vals))
              (cond [(null? ltrsorfigs) ; Control char shared between ltrs and figs
                     (list num)]
                    [(or (eq? ltrsorfigs mode) ; Don't duplicate the mode signal
                         (null? mode))
                     (list num)]
                    [else
                      (set! mode ltrsorfigs)
                      ; Send the needed mode signal when switching
                      (list (if (eq? 'LETTERS mode)
                                #x1F
                                #x1B)
                            num)]))))
(define encode-ITA_2 string->ita_2)
(module+ test
         (test-equal? "test letter"
                      (encode-ITA_2 "A")
                      '(31 3))
         (test-equal? "test figure"
                      (encode-ITA_2 "!")
                      '(27 13))
         (test-equal? "test control"
                      (encode-ITA_2 "\n")
                      '(2))
         (test-equal? "change from letter to figure"
                      (encode-ITA_2 "A!")
                      '(31 3 27 13))
         (test-equal? "change from letter to control"
                      (encode-ITA_2 "A\n")
                      '(31 3 2))
         (test-equal? "change from figure to letter"
                      (encode-ITA_2 "!A")
                      '(27 13 31 3))
         (test-equal? "change from figure to control"
                      (encode-ITA_2 "!\n")
                      '(27 13 2))
         (test-equal? "change from control to letter"
                      (encode-ITA_2 "\nA")
                      '(2 31 3))
         (test-equal? "change from control to figure"
                      (encode-ITA_2 "\n!")
                      '(2 27 13))
         (test-equal? "test alphabet"
                      (encode-ITA_2 "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
                      '(31 #x03 #x19 #x0E #x09 #x01 #x0D #x1A #x14 #x06 #x0B
                        #x0F #x12 #x1C #x0C #x18 #x16 #x17 #x0A #x05 #x10 #x07
                        #x1E #x13 #x1D #x15 #x11))
         (test-equal? "test numbers"
                      (encode-ITA_2 "0123456789")
                      '(27 #x16 #x17 #x13 #x01 #x0A #x10 #x15 #x07 #x06 #x18))
         (test-equal? "test random stuff"
                      (encode-ITA_2 "-',!:(+)£?&./;")
                      '(27 #x03 #x05 #x0C #x0D #x0E #x0F #x11 #x12 #x14 #x19
                       #x1A #x1C #x1D #x1E))
         (test-equal? "hello world"
                      ; ITA2 only does uppercase
                      (encode-ITA_2 "HELLO, WORLD!")
                      '(31 #x14 #x01 #x12 #x12 #x18 27 #x0C #x04 31 #x13 #x18
                        #x0A #x12 #x09 27 #x0D))
         (test-equal? "del"
                      (encode-ITA_2 "\u7F")
                      '(31 31))
         (test-equal? "bell"
                      (encode-ITA_2 "\u07")
                      '(27 11))
         (test-equal? "space"
                      (encode-ITA_2 " ")
                      '(4))
         (test-equal? "null"
                      (encode-ITA_2 "\u0")
                      '(0))
         (test-equal? "linefeed"
                      (encode-ITA_2 "\n")
                      '(2))
         (test-equal? "return"
                      (encode-ITA_2 "\r")
                      '(8))
         (test-equal? "enq"
                      (encode-ITA_2 "\u05")
                      '(27 #x09)))
