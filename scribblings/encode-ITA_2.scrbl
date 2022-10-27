#lang scribble/manual
@require[@for-label[encode-ITA_2 racket/base]]

@title{encode-ITA_2}
@author{lazerbeak12345}

@defmodule[encode-ITA_2]

@margin-note{
  Be aware if you site this that I used Wikipedia as my source 😅.
  (The only thing I sourced was the table from charcters to values)
}

Encodes strings in the 5 bit ITA2 character encoding.

ITA2 is a modification to Baudot Code.

I made this library because I needed a character encoding as small as possible,
and I didn't want to design my own. UTF-8 is 8 byes wide and Ascii is 7 bits.
Shaving an extra two bits was (at the time) desireable. I've heard rumors of an
official UTF-4 (designed for 4 bit computers, perhaps not unlike the Intel
4004), but I haven't been able to find a spec for this format. If you do find
it anywhere, I'd love to write the library for that.

Works out of the box with `typed/racket`

@defproc[(string->ita_2 [input string?])
         (listof exact-nonnegative-integer?)]{
  Converts @racket[input] into a list of numbers representing the encoding of your
text as ITA_2 format.

  Be aware that the length of the returned list is usually going to be longer
than the number of chars represented. That's because, like in Unicode, control
codes indicate which bank of characters are being addressed.

  The returned numbers range from @racket[0] to @racket[31]. This
makes ITA_2 a 5 bit system.

  @racket[input] may only be composed of characters within this set:

  @itemlist[
    @item{@racket[#\null]}
    @item{
      Any of @racket{ABCDEFGHIJKLMNOPQRSTUVWXYZ}
      (standard English alphabet, uppercase only)
    }
    @item{@racket[#\linefeed]}
    @item{@racket[#\return]}
    @item{Any of @racket{0123456789} (standard decimal number set)}
    @item{Any of @racket["-',!:(+)£?&./;"]}
    @item{@racket[#\u07] (the bell character, for use in terminals)}
    @item{@racket[#\u05] (the enq character, for use in terminals)}
    @item{@racket[#\u7F] (the delete character, for use in terminals)}
  ]

  Just be aware: ITA and its dereviatives are @italic{not} compatible with
Ascii or any Unicode.
}

@defproc[(encode-ITA_2 [input string?])
         (listof exact-nonnegative-integer?)]{
  An alias to @racket[string->ita_2] (see above).
}
