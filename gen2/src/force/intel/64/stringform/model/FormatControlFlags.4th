( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux format control model for FORCE-linux 4.19.0-5-amd64 ******

package /force/intel/64/core/model

import /force/intel/64/core/ForthBase

U2 enum: FormatControl
  requires ForthBase



  === Fields ===

  symbol LeftAlign                                    ( field is left-aligned )
  symbol Alternate                                    ( use alternate representation )
  symbol ForceSign                                    ( force a sign on the result )
  symbol LeadSpace                                    ( insert a leading space if appropriate )
  symbol PadZeroes                                    ( pad result with zeroes to width )
  symbol PadDots                                      ( pad result with dots to width )
  symbol PadStars                                     ( pad result with asterisks to width )
  symbol PadUnderscore                                ( pad result with underscores to width )
  symbol GroupNums                                    ( insert thousands' groups )
  symbol Parentheses                                  ( surround with parentheses if negative )
  symbol ?Negative                                    ( internal flag: insert closing parenthesis )
  symbol ReuseArgument                                ( re-use argument )
  symbol UPPERCASE                                    ( convert to uppercase )



  === Methods ===



enum;
