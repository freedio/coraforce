( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The UTF-8 vocabulary of FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/core
import ForthBase

vocabulary: UTF8

--- UTF-8 Operations ---

------
• The typical error condition — trying to read past the end of the buffer, or invalid UTF-8 character — is signaled with -1
  instead of a uc, since -1 is not valid in UTF-8, whereas 0 is.
• The length indicator measures the number of UTF-8 characters in the string, not the number of bytes.  To get the number
  of bytes in the string (including the length indicator), use $>#.
• Further note that the layout of the length field reflects the maximum size of the string.  A length of 10 (hex 0AH)
  can be expressed as
    0AH         for a string with maximum size 127
    C0H 8AH     for a string with maximum size 2048
    C0H 80H 8AH for a string with maximum size 63488
    ... a.s.o.
  i.e. the maximum number that can be expressed with the length indicator as a "UTF-8 character" determines the maximum size
  of the string itself --- because the length indicator cannot be resized once the string has been created.  Choosing a
  (pseudo) UTF-8 character as length indicator instead of just a byte/word/dword count makes the maximum string size
  variable without having to choose a fancy system accommodating for different lengths, or losing extra bytes when always
  having to use a dword length field though most strings are much shorter than that, or being restricted to 256 bytes as
  in the standard FORTH setting.
------

------ old pool of definitions; dispose after version 2.0 at the latest
: c$@++ ( a -- a' uc|-1 )  FETCHUC$INC, ;             ( read next UTF-8 character uc from buffer at address a, and increment )
: $# ( a -- # )  c$@++ nip ;                          ( Length # of UTF-8 string at address a )
: $count ( a$ -- a # )  FETCHUC$INC, ;                ( Address and Length of counted UTF-8 string )
: 0count ( aº -- a # )  dup begin c$++ 0= until  1 − over − ;  ( Address and Length of zero-terminated UTF-8 string )
: $= ( $1 $2 -- ? )                                   ( check if two UTF-8 strings are equal )
  c$@++ rot c$@++ rot over = if
    0 udo  c$@++ rot c$@++ rot = unlessever  2 #drop false exitloop  then  loop
    2 #drop true exit  then
  3 #drop false ;
: c$>> ( a # -- a' #−1 uc|-1 || a 0 -1 )              ( read next UFT-8 character from buffer a/#, or return -1 if not OK )
  dup unlessever  dup 1 −  else  swap c$@++ rot 1 − swap  then ;
------

: c$@++ ( a # -- a' #' uc|-1 )  GETUC, ;              ( read next UTF-8 char uc from buffer at a with length #, and advance )
: $# ( $ -- #|-1 )  8 c$@++ -rot 2drop ;  alias count ( Length of UTF-8 string $, or -1 if the length is invalid )
: $count ( $ -- a #|-1 )  8 c$@++ nip ;               ( Address a and Length # of counted UTF-8 string $, -1 if invalid )
: 0count ( a⁰ -- a #|-1 )
  dup -1 begin  c$@++  1 < until  ?dup -1 = if  2nip exit  then  drop 1 − over − ;
: $++ ( a -- )  INCUC, unless  "UTF-8 length overflow!" ABORT crash  then ;  ( increment UTF-8 length )


: c$@++ ( a # -- a' #' uc|-1 )                        ( read next UTF-8 char uc [-1 if error] from buffer a#, and advance )
  dup 0= if  -1 exit  then                              ( string is empty -> no char )
  ->c 7 bit?? exitunless                                ( exit if ASCII )
      ( 7 # RAX BT  CY ?JMP
  c0-> 7 r−

vocabulary;
