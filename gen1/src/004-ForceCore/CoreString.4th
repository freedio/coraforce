( Copyright © 2020 by Coradec GmbH.  All rights reserved. )

=== Core String Vocabulary ===

( Core Strings are not objects, but buffers in RAM with a length and a UTF8 body.
  The symbol for Core Strings and String literals is "$", for UTF8 characters "uc".
  All characters in the string body are UTF8 characters.
  The length is a variable-length quantity built like a UTF8-char, but with the full range, i.e. up to 8 bytes.
  Note that the lengths is NOT necessarily the number of characters in the string, as some UCs are more than one byte long.
  This library also supports string buffers in the form [address, length], or SEC [a #].
  Core Strings are considered immutable --- respect this expectation and modify copies of the original only only!
)

: uc> ( a # -- a' #' uc|-1 )  GETUC, ;    ( get next UC from a string buffer, or -1 if buffer empty or bad sequence )
: count ( a$ -- a # )  COUNT, ;    ( turn a core string into a buffer )
: $# ( a$ -- # )  STRINGLEN, ;    ( count the characters in a core string )
: $+ ( a$ b$ c$ -- c$ )  STRINGCONCAT, ;    ( concatenate strings a$ and b$ in buffer at c$, which must have enough space )
