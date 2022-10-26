#lang scribble/manual
@require[@for-label[encode-ITA_2
                    racket/base
                    ;typed/racket/base
                    ]]

@title{encode-ITA_2}
@author{lazerbeak12345}

@defmodule[encode-ITA_2]

@margin-note{
  Be aware if you site this that I used Wikipedia as my source 😅.
}

Encodes strings in the ITA2 character encoding.

Works out of the box with `typed/racket`

@defproc[(encode-ITA_2 [input string?])
         (listof exact-nonnegative-integer?)]{
  Converts @racket[input] into a list of numbers representing the encoding of your
text as ITA_2 format.

  Be aware that the length of the returned list is usually going to be longer
than the number of chars represented. That's because, like in Unicode, control
codes indicate which bank of characters are being addressed.

  @racket[input] may only be composed of characters within this set:

  @itemlist[
    @item{@racket[#\null]}
    @item{Any of @racket{ABCDEFGHIJKLMNOPQRSTUVWXYZ} (standard English
                                                               alphabet)}
    @item{@racket[#\linefeed]}
    @item{@racket[#\return]}
    @item{Any of @racket{0123456789} (standard decimal number set)}
    @item{Any of @racket["-',!:(+)£?&./;"]}
    @item{@racket[#\u07] (the bell character)}
  ]

  Just be aware: ITA and it's dereviatives are @italic{not} compatible with
Ascii or any Unicode.
}
