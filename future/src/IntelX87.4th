vocabulary: force/numext/intelx87 implements force/lang/float

( Duplicates top of float stack. )
: fdup ( :F: r -- r r )  FDUP, ;

	test: fdup: checks if the TOF is duplicated.
	given fp0! sp0! 12.5
	when: fdup
	then: !f=
		  depth !0=
		  fdepth !0=
	test;

	test: fdup: checks if fdup fails gracefully on an empty stack.
	given fp0!
	when: capture{ fdup }capture
	then: captured@ FloatStackUnderflow !=
	test;

( Drops top of float stack. )
: fdrop ( :F: r -- )  FDROP, ;

	test: fdrop: checks if the TOF is dropped.
	given fp0! sp0! 12.5  9.999999
	when: fdrop
	then: depth !0=
		  fdepth !0=
	test;

	test: fdrop: checks if fdrop fails gracefully on an empty stack.
	given fp0!
	when: capture{ fdrop }capture
	then: captured@ FloatStackUnderflow !=
	test;

( Swaps top and second of float stack. )
: fswap ( :F: r2 r1 -- r1 r2 )  FSWAP, ;

	test: fswap: checks if the TOF and 2OF are exchanged.
	given fp0! sp0! 12.5  9.999999
	when: fswap
	then: 12.5 !f=
		  9.999999 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: fswap: checks if fswap fails gracefully on an empty stack.
	given fp0!
	when: capture{ fswap }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: fswap: checks if fswap fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ fswap }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Copies second over top of float stack. )
: fover ( :F: r2 r1 -- r2 r1 r2 )  FOVER, ;

	test: fswap: checks if the TOF and 2OF are exchanged.
	given fp0! sp0! 12.5  9.999999
	when: fswap
	then: 12.5 !f=
		  9.999999 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: fswap: checks if fswap fails gracefully on an empty stack.
	given fp0!
	when: capture{ fswap }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: fswap: checks if fswap fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ fswap }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Rotates float stack triple. )
: frot ( :F: r3 r2 r1 -- r2 r1 r3 )  FROT, ;

	test: frot: checks if the float stack is rotated.
	given fp0! sp0! 12.5  9.999999  10.0e+15
	when: frot
	then: 12.5 !f=
		  10.0e+15 !f=
		  9.999999 !f=
		  depth !0=
		  fdepth !0=
	@end: fp0!
	test;

	test: frot: checks if frot fails gracefully on an empty stack.
	given fp0!
	when: capture{ frot }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: frot: checks if frot fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ frot }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: frot: checks if frot fails gracefully on a stack with only two entries.
	given fp0!  12.5  5.3e-12
	when: capture{ frot }capture
	then: captured@ FloatStackUnderflow !=
	test;

( Rotates float stack triple backwards. )
: f-rot ( :F: r3 r2 r1 -- r1 r3 r2 )  FNEGROT, ;

	test: f-rot: checks if the float stack is rotated.
	given fp0! sp0! 12.5  9.999999  10.0e+15
	when: frot
	then: 9.999999 !f=
		  12.5 !f=
		  10.0e+15 !f=
		  depth !0=
		  fdepth !0=
	@end: fp0!
	test;

	test: f-rot: checks if f-rot fails gracefully on an empty stack.
	given fp0!
	when: capture{ f-rot }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: f-rot: checks if f-rot fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ f-rot }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: f-rot: checks if f-rot fails gracefully on a stack with only two entries.
	given fp0!  12.5  5.3e-12
	when: capture{ f-rot }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 2 !=
	@end: fp0!
	test;

( Duplicates pair of floats. )
: f2dup ( :F: r2 r1 -- r2 r1 r2 r1 )  F2DUP, ;

	test: f2dup: checks if the float stack pair is duplicated.
	given fp0! sp0! 12.5  9.999999
	when: f2dup
	then: 9.999999 !f=
		  12.5 !f=
		  9.999999 !f=
		  12.5 !f=
		  depth !0=
		  fdepth !0=
	@end: fp0!
	test;

	test: f2dup: checks if f-rot fails gracefully on an empty stack.
	given fp0!
	when: capture{ f2dup }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: f2dup: checks if f2dup fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ f2dup }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Pushes 0.0 onto the float stack. )
: 0.0 ( :F: -- 0.0 )  0.0, ;

	test: 0.0: checks if the float stack contains exactly 0.0.
	given fp0! sp0!
	when: 0.0
	then: 0 >f !f=
		  depth !0=
		  fdepth !0=
	test;

( Pushes 1.0 onto the float stack. )
: 1.0 ( :F: -- 1.0 )  1.0, ;

	test: 1.0: checks if the float stack contains exactly 1.0.
	given fp0! sp0!
	when: 1.0
	then: 1 >f !f=
		  depth !0=
		  fdepth !0=
	test;

( Pushes -1.0 onto the float stack. )
: −1.0 ( :F: -- −1.0 )  −1.0, ;  alias -1.0

	test: −1.0: checks if the float stack contains exactly −1.0.
	given fp0! sp0!
	when: −1.0
	then: −1 >f !f=
		  depth !0=
		  fdepth !0=
	test;

( Pushes 10.0 onto the float stack. )
: 10.0 ( :F: -- 10.0 )  10.0, ;

	test: 10.0: checks if the float stack contains exactly 10.0.
	given fp0! sp0!
	when: 10.0
	then: 10 >f !f=
		  depth !0=
		  fdepth !0=
	test;

( Pushes π onto the float stack. )
: π ( :F: -- π )  PI, ;  alias pi

	test: π: checks if the float stack contains exactly π.
	given fp0! sp0!
	when: π
	then: fdup fabs fover !f= fcos -1 >f !f=
		  depth !0=
		  fdepth !0=
	test;

--- Arithmetic Operations ---

( Adds two floats )
: f+ ( :F: f2 f1 -- f2+f1. )  FADD, ;

	test: f+: checks if the TOF and 2OF are added.
	given fp0! sp0! 12.5  9.999999
	when: f+
	then: 22.499999 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f+: checks if f+ fails gracefully on an empty stack.
	given fp0!
	when: capture{ f+ }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: f+: checks if f+ fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ f+ }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Adds 32-bit integer to float )
: f+i ( i -- :F: f -- f+i. )  FIADD, ;

	test: f+i: checks if the TOF and TOP are added.
	given fp0! sp0! 12.5  3
	when: f+i
	then: 15.5 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f+i: checks if f+i fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ f+i }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: f+i: checks if f+i fails gracefully on an empty floating point stack.
	given fp0! sp0! 12
	when: capture{ f+i }capture
	then: captured@ FloatStackUnderflow !=
		  12 !=
		  depth !0=
	@end: fp0!
	test;

( Subtracts two floats. )
: f− ( :F: f2 f1 -- f2−f1 )  FSUB, ;  alias f-

	test: f−: checks if the TOF and 2OF are subtracted.
	given fp0! sp0! 12.5  9.999999
	when: f−
	then: 2.500001‬ !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f−: checks if f− fails gracefully on an empty stack.
	given fp0!
	when: capture{ f− }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: f−: checks if f− fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ f− }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Subtracts 32-bit integer from float )
: f−i ( i -- :F: f -- f−i. )  FISUB, ;  alias f-i

	test: f−i: checks if the TOF and TOP are subtracted.
	given fp0! sp0! 12.5  3
	when: f−i
	then: 9.5 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f−i: checks if f−i fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ f−i }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: f−i: checks if f−i fails gracefully on an empty floating point stack.
	given fp0! sp0! 12
	when: capture{ f−i }capture
	then: captured@ FloatStackUnderflow !=
		  12 !=
		  depth !0=
	@end: fp0!
	test;

( Subtracts two floats reverse. )
: rf− ( :F: f2 f1 -- f1−f2 )  FSUBR, ;  alias rf-

	test: rf−: checks if the TOF and 2OF are subtracted.
	given fp0! sp0! 12.5  9.999999
	when: rf−
	then: -2.500001‬ !f=
		  depth !0=
		  fdepth !0=
	test;

	test: rf−: checks if rf− fails gracefully on an empty stack.
	given fp0!
	when: capture{ rf− }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: rf−: checks if rf− fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ rf− }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Subtracts float from 32-bit integer )
: i−f ( i -- :F: f -- i−f. )  FISUBR, ;  alias i-f

	test: i−f: checks if the TOF and TOP are subtracted.
	given fp0! sp0! 12.5  3
	when: i−f
	then: -9.5 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: i−f: checks if i−f fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ i−f }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: i−f: checks if i−f fails gracefully on an empty floating point stack.
	given fp0! sp0! 12
	when: capture{ i−f }capture
	then: captured@ FloatStackUnderflow !=
		  12 !=
		  depth !0=
	@end: fp0!
	test;

( Multiplies two floats. )
: f× ( :F: f2 f1 -- f2×f1 )  FMPY, ;  alias f*

	test: f×: checks if the TOF and 2OF are multiplied.
	given fp0! sp0! 12.5  9.999999
	when: f×
	then: ‭124.9999875‬ !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f×: checks if f× fails gracefully on an empty stack.
	given fp0!
	when: capture{ f× }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: f×: checks if f× fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ f× }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Multiplies float with 32-bit integer. )
: f×i ( i -- :F: f -- f×i. )  FIMPY, ;  alias f*i

	test: f×i: checks if the TOF and TOP are multiplied.
	given fp0! sp0! 12.5  3
	when: f×i
	then: 37.5 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f×i: checks if f×i fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ f×i }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: f×i: checks if f×i fails gracefully on an empty floating point stack.
	given fp0! sp0! 12
	when: capture{ f×i }capture
	then: captured@ FloatStackUnderflow !=
		  12 !=
		  depth !0=
	@end: fp0!
	test;

( Divides two floats. )
: f÷ ( :F: f2 f1 -- f2÷f1 )  FDIV, ;  alias f/

	test: f÷: checks if the TOF and 2OF are divided.
	given fp0! sp0! 12.5  9.999999
	when: f÷
	then: ‭1.250,000,125 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f÷: checks if f÷ fails gracefully on an empty stack.
	given fp0!
	when: capture{ f÷ }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: f÷: checks if f÷ fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ f÷ }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Divides float through 32-bit integer. )
: f÷i ( i -- :F: f -- f÷i. )  FIDIV, ;  alias f/i

	test: f÷i: checks if the TOF and TOP are divided.
	given fp0! sp0! 12.6  3
	when: f÷i
	then: 4.2 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f÷i: checks if f÷i fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ f÷i }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: f÷i: checks if f÷i fails gracefully on an empty floating point stack.
	given fp0! sp0! 12
	when: capture{ f÷i }capture
	then: captured@ FloatStackUnderflow !=
		  12 !=
		  depth !0=
	@end: fp0!
	test;

( Divides two floats reverse. )
: rf÷ ( :F: f2 f1 -- f1÷f2 )  FDIVR, ;  alias f/

	test: rf÷: checks if the TOF and 2OF are divided.
	given fp0! sp0! 12.5  9.999999
	when: rf÷
	then: ‭0.799,999,92 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: rf÷: checks if rf÷ fails gracefully on an empty stack.
	given fp0!
	when: capture{ rf÷ }capture
	then: captured@ FloatStackUnderflow !=
	test;

	test: rf÷: checks if rf÷ fails gracefully on a stack with only one entry.
	given fp0!  12.5
	when: capture{ rf÷ }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Divides 32-bit integer through float. )
: i÷f ( i -- :F: f -- i÷f. )  FIDIVR, ;  alias i/f

	test: i÷f: checks if the TOF and TOP are divided.
	given fp0! sp0! 12.5  3
	when: i÷f
	then: 0.24 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: i÷f: checks if i÷f fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ i÷f }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

	test: i÷f: checks if i÷f fails gracefully on an empty floating point stack.
	given fp0! sp0! 12
	when: capture{ i÷f }capture
	then: captured@ FloatStackUnderflow !=
		  12 !=
		  depth !0=
	@end: fp0!
	test;

( Negates top of the float stack. )
: f± ( :F: f -- −f )  FNEG, ;  alias fneg

	test: f±: checks if the TOF is negated.
	given fp0! sp0! 12.5
	when: f±
	then: -12.5 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: f±: checks if f± fails gracefully on an empty parameter stack.
	given fp0! sp0! 0.0
	when: capture{ f± }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Calculates the absolute value of the top of the float stack. )
: |f| ( :F: f -- |f| )  FABS, ;  alias fabs

	test: |f|: checks if the TOF is abs'ed.
	given fp0! sp0! 12.5 -12.5
	when: |f| fover |f|
	then: !f=  12.5 !f=
		  depth !0=
		  fdepth !0=
	test;

	test: |f|: checks if |f| fails gracefully on an empty float stack.
	given fp0!  0.0
	when: capture{ |f| }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth 1 !=
	@end: fp0!
	test;

( Returns the lesser of two floating point values. )
: fmin ( :F: f2 f1 -- f3 )  FMIN2, ;

	test: fmin: checks if the result is arithmetically correct.
	given fp0!  47.11 3.141,592,654
	when: fmin
	then: 3.141592654 !=
		  fdepth !0=
	test;

	test: fmin: checks if the result is arithmetically correct.
	given fp0!  -47.11 3.141,592,654
	when: fmin
	then: -47.11 !=
		  fdepth !0=
	test;

	test: fmin: checks if fmin fails gracefully on an empty float stack.
	given fp0!
	when: capture{ fmin }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
	test;

	test: fmin: checks if fmin fails gracefully on a float stack with only one entry.
	given fp0!  42.0
	when: capture{ fmin }capture
	then: captured@ ParameterStackUnderflow !=
		  42.0 !f=
		  fdepth !0=
	test;

( Returns the bigger of two floating point values. )
: fmax ( :F: f2 f1 -- f3 )  FMAX2, ;

	test: fmax: checks if the result is arithmetically correct.
	given fp0!  47.11 3.141,592,654
	when: fmax
	then: 47.11 !=
		  fdepth !0=
	test;

	test: fmax: checks if the result is arithmetically correct.
	given fp0!  -47.11 3.141,592,654
	when: fmin
	then: 3.141,592,654 !=
		  fdepth !0=
	test;

	test: fmax: checks if fmax fails gracefully on an empty float stack.
	given fp0!
	when: capture{ fmax }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
	test;

	test: fmax: checks if fmax fails gracefully on a float stack with only one entry.
	given fp0!  42.0
	when: capture{ fmax }capture
	then: captured@ ParameterStackUnderflow !=
		  42.0 !f=
		  fdepth !0=
	test;

( Tests if floating point value is 0.0. )
: f0= ( -- f=0.0 :F: f -- )  FISZERO, ;

	test: f0=: checks if the result is arithmetically correct.
	given fp0!  sp0!
	when: 0.0 f0=
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0=: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!
	when: 1.0 f0=
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0=: another one...
	given fp0!  sp0!
	when: −1.0 f0=
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0=: checks if f0= fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f0= }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

( Tests if floating point value is not 0.0. )
: f0≠ ( -- f≠0.0 :F: f -- )  FISNOTZERO, ;  alias f0−  alias f0-

	test: f0≠: checks if the result is arithmetically correct.
	given fp0!  sp0!
	when: 0.0 f0≠
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≠: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!
	when: 1.0 f0≠
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≠: another one...
	given fp0!  sp0!
	when: −1.0 f0≠
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≠: checks if f0≠ fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f0≠ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

( Tests if floating point value is negative. )
: f0< ( -- f<0.0 :F: f -- )  FISNEGATIVE, ;

	test: f0<: checks if the result is arithmetically correct.
	given fp0!  sp0!
	when: −1.0 f0<
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0<: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!
	when: 0.0 f0<
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0<: another one...
	given fp0!  sp0!
	when: 1.0 f0<
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0<: checks if f0< fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f0< }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

( Tests if floating point value is not negative. )
: f0≥ ( -- f≥0.0 :F: f -- )  FISNOTNEGATIVE, ;  alias f0>=

	test: f0≥: checks if the result is arithmetically correct.
	given fp0!  sp0!
	when: 1.0 f0≥
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≥: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!
	when: 0.0 f0≥
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≥: another one...
	given fp0!  sp0!
	when: −1.0 f0≥
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≥: checks if f0≥ fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f0≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

( Tests if floating point value is positive. )
: f0> ( -- f>0.0 :F: f -- )  FISPOSITIVE, ;

	test: f0>: checks if the result is arithmetically correct.
	given fp0!  sp0!
	when: 1.0 f0>
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0>: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!
	when: 0.0 f0>
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0>: another one...
	given fp0!  sp0!
	when: −1.0 f0>
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0>: checks if f0> fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f0> }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

( Tests if floating point value is not positive. )
: f0≤ ( -- f≤0.0 :F: f -- )  FISNOTPOSITIVE, ;  alias f0<=

	test: f0≤: checks if the result is arithmetically correct.
	given fp0!  sp0!
	when: −1.0 f0≤
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≤: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!
	when: 0.0 f0≤
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≤: another one...
	given fp0!  sp0!
	when: 1.0 f0≤
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f0≤: checks if f0≤ fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f0≤ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

( Compares two floats for equality. )
: f= ( -- f2=f1 :F: f2 f1 -- )  FISEQUAL, ;

	test: f=: checks if the result is arithmetically correct.
	given fp0!  sp0!  47.11
	when: 47.11 f=
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f=: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!  47.11
	when: 42.0 f=
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f=: another one...
	given fp0!  sp0!  47.11
	when: -666.0 f0≤
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f=: checks if f= fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f= }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

	test: f=: checks if f= fails gracefully on a float stack with only one entry.
	given fp0!  sp0!  42.0
	when: capture{ f= }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !1=
		  depth !0=
	test;

( Compares two floats for inequality. )
: f≠ ( -- f2≠f1 :F: f2 f1 -- )  FISNOTEQUAL, ;  alias f<>

	test: f≠: checks if the result is arithmetically correct.
	given fp0!  sp0!  47.11
	when: 47.11 f≠
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≠: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!  47.11
	when: 42.0 f≠
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≠: another one...
	given fp0!  sp0!  47.11
	when: -666.0 f≠
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≠: checks if f≠ fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f≠ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≠: checks if f≠ fails gracefully on a float stack with only one entry.
	given fp0!  sp0!  42.0
	when: capture{ f≠ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !1=
		  depth !0=
	test;

( Checks if one floating point values is less than another. )
: f< ( -- f2<f1 :F: f2 f1 -- )  FISLESS, ;

	test: f<: checks if the result is arithmetically correct.
	given fp0!  sp0!  42.0
	when: 47.11 f<
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f<: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!  42.0
	when: 42.0 f<
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f<: another one...
	given fp0!  sp0!  42.0
	when: -666.0 f<
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f<: checks if f< fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f< }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

	test: f<: checks if f< fails gracefully on a float stack with only one entry.
	given fp0!  sp0!  42.0
	when: capture{ f< }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !1=
		  depth !0=
	test;

( Checks if one floating point values is greater than or equal to another. )
: f≥ ( -- f2≥f1 :F: f2 f1 -- )  FISNOTLESS, ;  alias f>=

	test: f≥: checks if the result is arithmetically correct.
	given fp0!  sp0!  42.0
	when: 47.11 f≥
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f<: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!  42.0
	when: 42.0 f≥
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≥: another one...
	given fp0!  sp0!  42.0
	when: -666.0 f≥
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≥: checks if f≥ fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≥: checks if f≥ fails gracefully on a float stack with only one entry.
	given fp0!  sp0!  42.0
	when: capture{ f≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !1=
		  depth !0=
	test;

( Checks if one floating point values is greater than another. )
: f> ( -- f2>f1 :F: f2 f1 -- )  FISGREATER, ;

	test: f>: checks if the result is arithmetically correct.
	given fp0!  sp0!  47.11
	when: 42 f<
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f>: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!  47.11
	when: 47.11 f<
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f>: another one...
	given fp0!  sp0!  -666.0
	when: 47.11 f<
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f>: checks if f> fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f> }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

	test: f>: checks if f> fails gracefully on a float stack with only one entry.
	given fp0!  sp0!  42.0
	when: capture{ f> }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !1=
		  depth !0=
	test;

( Checks if one floating point values is less than or equal to another. )
: f≤ ( -- f2≤f1 :F: f2 f1 -- )  FISNOTGREATER, ;  alias f<=

	test: f≤: checks if the result is arithmetically correct.
	given fp0!  sp0!  42.0
	when: 47.11 f≤
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≤: checks if the opposite result is arithmetically correct.
	given fp0!  sp0!  42.0
	when: 42.0 f≤
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≤: another one...
	given fp0!  sp0!  42.0
	when: -666.0 f≤
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≤: checks if f≤ fails gracefully on an empty float stack.
	given fp0!  sp0!
	when: capture{ f≤ }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth !0=
		  depth !0=
	test;

	test: f≤: checks if f≤ fails gracefully on a float stack with only one entry.
	given fp0!  sp0!  42.0
	when: capture{ f≤ }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth !1=
		  depth !0=
	test;

( Checks if a float value is within the bounds. )
: fwithin ( -- flow≤f<fhigh :F: f flow fhigh -- )  FISWITHIN, ;

	test: fwithin: checks if the test is correct when x is between.
	given fp0!  sp0!
	when: 4.0 2.0 8.0 fwithin
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: fwithin: checks if the test is correct when x is lower.
	given sp0!  fp0!
	when: -4.0 2.0 8.0 fwithin
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: fwithin: checks if the test is correct when x is higher.
	given sp0!  fp0!
	when: 14.0 2.0 8.0 fwithin
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: fwithin: checks if the test is correct when x is xmax.
	given sp0!  fp0!
	when: 8.0 2.0 8.0 fwithin
	then: false !=
		  fdepth !0=
		  depth !0=
	test;

	test: fwithin: checks if the test is correct when x is xmin.
	given sp0!  fp0!
	when: 2.0 2.0 8.0 fwithin
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: fwithin: checks if the test is correct when x is negative and in range.
	given sp0!  fp0!
	when: -2.0 -8.0 8.0 fwithin
	then: true !=
		  fdepth !0=
		  depth !0=
	test;

	test: fwithin: checks if fwithin fails gracefully on an empty stack.
	given fp0!
	when: capture{ fwithin }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
	test;

	test: fwithin: checks if fwithin fails gracefully on a stack with only one entry.
	given fp0!  1.0
	when: capture{ fwithin }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !1=
	test;

	test: fwithin: checks if fwithin fails gracefully on a stack with only two entries.
	given fp0!  1.0 2.9
	when: capture{ fwithin }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !2=
	test;

	test: fwithin: checks if fwithin fails gracefully on a stack with empty range.
	given sp0!
	when: capture{ 10.0 100.0 6.0 fwithin }capture
	then: captured@ EmptyRange !=
		  depth !0=
	test;

( Loads float at address a onto the float stack. )
: f@ ( a -- :F: -- f )  FFETCH, ;

	test: f@: checks if a float is loaded.
	given sp0!  fp0!  4005bf0a8b145769H ( 400921fb54442d18h )
	when: sp@ f@
	then: 2.718,281,828,459,045 ( 3.141,592,653,589,793 ) !f=
		  fdepth !0=
		  depth !0=
	test;

	test: f@: checks if f@ fails gracefully on an empty stack.
	given fp0! sp0!
	when: capture{ f@ }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
	test;

( Stores top of float stack to address a. )
: f! ( a -- :F: f -- )  FSTORE, ;

	test: f@: checks if a float is stored.
	given sp0!  fp0!  π 0
	when: sp@ f!
	then: 4009,21fb,5444,2d18,h !=
		  fdepth !0=
		  depth !0=
	test;

	test: f!: checks if f! fails gracefully on an empty stack.
	given fp0! sp0!
	when: capture{ f! }capture
	then: captured@ ParameterStackUnderflow !=
		  fdepth !0=
	test;

	test: f!: checks if f! fails gracefully on an empty float stack.
	given fp0! sp0!
	when: capture{ 0 sp@ f! }capture
	then: captured@ FloatStackUnderflow !=
		  fdepth !0=
		  depth 1 !=
	test;






























vocabulary;