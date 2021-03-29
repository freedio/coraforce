( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The string formatter vocabulary for FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/stringform
import ForthBase
import model/FormatPara
import model/FormatControlFlags

------
General format of the formatting instructions:

%[flags][width][.precision][:argindex]conversion

where:  [flags]     is a series of the following flags in any order [duplicates ignored]:
        - (dash)    makes the result left-justified
        # (hash)    uses conversion dependent alternate form (see formatter)
        + (plus)    forces a sign on numeric results, even when positive or zero (signed only)
          (space)   forces a leading space on positive and zero numeric results (signed only)
        0 (zero)    pads the result with zeroes
        : (ellips)  pads the result with dots
        _ (ellips)  pads the result with underscores
        * (aster)   pads the result with asterisks
        , (comma)   includes locale specific grouping characters
        ( (lpar)    forces negative numbers to be enclosed in parentheses rather than being
                    preceded with a minus sign
        < (again)   reuse last argument index

        [width]     is the minimum number of characters written to the output
        [precision] in general is the maximum number of characters written to the output; for
                    floating point values of the e and f conversion, it is the number of digits
                    after the decimal separator; for scientific values of the g conversion, it
                    is the total number of digits in the magnitude after rounding.
        [argindex]  is the argument number to be used instead of the next argument.  If the
                    argument index is specified, the argument index will not be incremented,
                    if it is absent, the next argument according to the argument index will be
                    used, after which the index is incremented.

        [width], [precision] and [argindex] must be a positive unsigned decimal number or zero,
        except for [width]. [argindex] refers to the arguments on the stack, top-down, i.e.
        0 refers to the last specified argument, and the argument index also grows from 0 up
        (arguments are fetched using "pick").

        [conversion] is a letter defining the kind of conversion, sometimes followed by further
                    conversion characters as described below:
        b           produces either 'true' or 'false' (locale dependent)
                    if the hash flag is set, produces 'yes' or 'no' instead (locale dependent)
                    if the zero flag is set, produces 'on' or 'off' instead (locale dependent)
        B           produces either 'TRUE' or 'FALSE' (locale dependent)
                    if the hash flag is set, produces 'YES' or 'NO' instead (locale dependent)
                    if the zero flag is set, produces 'ON' or 'OFF' instead (locale dependent)
        s           produces a string
        S           produces a string, converted to uppercase
        c           produces a single Unicode character
        C           produces a single uppercase Unicode character
        d           produces a signed decimal integer
        D           same
                    if the hash flag ist set for d or D formats, an unsigned decimal is produced
        o           produces an unsigned octal integer
        O           same
        x           produces an unsigned hexadecimal integer with letters 'a' .. 'f' for digit>9
        X           produces an unsigned hexadecimal integer with letters 'A' .. 'F' for digit>9
                    if the hash flag ist set for any of the o, O, x or X formats, a signed
                        number is produced
        e           produces a floating point value in the format ±x.xxx...e±xxx
        E           produces a floating point value in the format ±x.xxx...E±xxx
        f           produces a floating point value avoiding the e±xxx part until too large
        F           produces a floating point value avoiding the E±xxx part until too large
        g           produces a floating point value in scientific notation.
        G           produces a floating point value in scientific notation (uppercase E).
        %           produces a percentage with a trailing '%'
        ‰           produces a permillage with a trailing '‰'
        n           produces a platform specific new line (flags/width/precision are ignored)
        t           produces a date, time or instant according to trailing format specifiers:
            h       hour of day in 24-hour clock (0..23)
            hh      hour of day in 24-hour clock (00..23)
            H       hour of day in 12-hour clock (1..12)
            HH      hour of day in 12-hour clock (01..12)
            m       minute of hour (0..59)
            mm      minute of hour (00..59)
            s       second of minute (0..59)
            ss      second of minute (00..59)
            S       millisecond of second (0..999)
            SS      millisecond of second (000..999)
            n       nanosecond of millisecond (0..999999)
            nn      nanosecond of millisecond (000000..999999)
            p       am/pm
            P       AM/PM
            z       time zone in ±00.00 format
            Z       time zone name, including daylight saving when appropriate
            Y       year (no leading zeroes)
            YY      year with 2 digits, no century
            YYY     4-digit year
            YYYY    same
            M       month of year (1..12)
            MM      month of year (01..12)
            MMM     month as abbreviated name in current locale
            MMMM    month as full name in current locale
            w       week of year (1..52)
            ww      week of year (01..52)
            D       day of month (1..31)
            DD      day of month (01..31)
            d       day of year (1..366)
            dd      day of year (001..366)
            t       full time 24, formatted like hh:mm
            T       full time 12, formatted like HH:mmp
            f       full time 24 with seconds, formatted like hh:mm:ss
            F       full time 12 with seconds, formatted like HH:mm:ssp
                    if the hash flag is set, the ':' in the above 4 formats are suppressed.
            a       American date, formatted like MM/DD/YY
            A       American date with century, formatted like MM/DD/YYYY
            i       ISO 8601 date, formatted like ±YYYY-MM-DD
            I       ISO 8601 datetime, formatted like ±YYYY-MM-DD'T'hh:mm
            II      ISO 8601 datetime, formatted like ±YYYY-MM-DD'T'hh:mm:ss
            III     ISO 8601 datetime, formatted like ±YYYY-MM-DD'T'hh:mm:ss.f
                    if the hash flag is set, the datetime separator 'T' is replaced with a space
------

class: StringFormat
  requires ForthBase
  requires FormatPara
  requires FormatControlFlags



  === Interface ===

  def |$| ( ... # t$ -- r$ )                          ( format # args ... using template t$ to result r$ )



  === Implementation ===

  create Output  1024 allot                           ( Rendering area )
  create Number  128 allot                            ( Number conversion buffer )
  FormatPara val Para                                 ( String formatting parameters )

  : +>yes/no ( ... a # -- ... a # )  arg# pick if  "yes"  else  "no"  then  insert ;
  : +>YES/NO ( ... a # -- ... a # )  arg# pick if  "YES"  else  "NO"  then  insert ;
  : +>on/off ( ... a # -- ... a # )  arg# pick if  "on"  else  "off"  then  insert ;
  : +>ON/OFF ( ... a # -- ... a # )  arg# pick if  "ON"  else  "OFF"  then  insert ;
  : +>bool ( ... a # -- ... a # )                     ( pick-a-bool )
    Alternate my Para Control?− if  >yes/no  else  PadZeroes my Para Control?− if  >on/off  else
      arg# pick if  "true"  else  "false"  then  insert  then  then ;
  : +>BOOL ( ... a # -- ... a # )                     ( pick-a-BOOL )
    Alternate my Para Control?− if  >YES/NO  else  PadZeroes my Para Control bit?− if  >ON/OFF  else
      arg# pick if  "TRUE"  else  "FALSE"  then  insert  then  then ;
  : +>string ( ... a # -- ... a # )  arg# pick insert ;
  : +>STRING ( ... a # -- ... a # )  arg# pick INSERT ;
  : +>char ( ... a # -- ... a # )  arg# pick  8u<< 1+ CHAR tuck !  insert ;
  : +>CHAR ( ... a # -- ... a # )  arg# pick  >upper 8u<< 1+ CHAR tuck !  insert ;
  : +>decimal ( ... a # -- ... a # )
    arg# pick  10 Alternate my Para Control? if  >unsigned  else  >signed  then ;  alias +>DECIMAL
  : +>octnum ( ... a # -- ... a # )
    arg# pick  8 Alternate my Para Control? if  >signed  else  >unsigned  then ;  alias +>OCTNUM
  : +>hexnum ( ... a # -- ... a # )
    arg# pick  16 Alternate my Para Control? if  >signed  else  >unsigned  then ;
  : +>HEXNUM ( ... a # -- ... a # )
    Uppercase my Para Control+  >hexnum ;
  : +>percent ( ... a # -- ... a # ) '%' 8u<< 1+ CHAR tuck !  insert ;

  create RULES                                        ( the rules set [in the order bBsScCdDoOxXeEfFgG%nt] )
    ' +>bool ', ' +>BOOL ', ' +>string ', ' +>STRING ', ' +>char ', ' +>CHAR ',
    ' +>decimal ', ' +>DECIMAL ', ' +>octnum ', ' +>OCTNUM ',  ' +>hexnum ', ' +>HEXNUM ',
    ' +>expon ', ' +>EXPON ',  ' +>float ', ' +>FLOAT ',  ' +>scient ', ' +>SCIENT ',
    ' +>percent ', ' +>newline ', ' +>time ',

  : format ( ... a # -- ... a' #' )                   ( render upcoming formatting clause in a#, advance past it to a'#' )
    parseFlags  parseWidth
    0 my Para Precision!  dup if  over c@ '.' = if  parsePrecision  then  then
    0 my Para ArgIndex!  dup if  over c@ ':' = if  parseArgIndex  then  then
    my Para Control ReuseArgument bit@-! if  my Para NextArg@1−!  then
    dup if  over c@ "bBsScCdDoOxXeEfFgG%nt" count rot cfind ?dupunless
      "Warning: Unknown formatting rule '"e. eemit 27H eemit  sourceFile@ ?dupif
        " in "e. e. '(' eemit sourceLine@ e. '.' eemit  sourceColumn@ "): skipped."..  then
        exit  then  then
    >r 1-> RULES r> cells+ @ execute ;
  : c+> ( c -- )  Output tuck wcount + c!  $++ ;
  : |$| ( ... # t$1 -- r$2 )                          ( format # args ... using template t$1 to result r$2 )
    Output 1024 0 cfill  swap FormatPara new my Para !
    count begin ?dup while  over c@ '%' = if  1+> format  else  over c@ c+> 1->  then  repeat  drop
    my Para Arg#@ udrop  Output ;

class;
