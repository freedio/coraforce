vocabulary: force/lang/force

public static section

( Performs a thread switch if indicated. )
protected static :: (next)  ( TODO implement ) ;;

=== Global Constants ===

( Returns the cell size in bytes. )
: cell ( -- cell#:C )  CELL, ;

	test: cell: checks if cell size conforms with current architecture.
	given sp0!
	when: cell
	then: TARGET_ARCH_CELL_SIZE !=
		  depth 0 !=
	test;

( Returns the cell shift, i.e. (%cell | 8 cell * %cell = )
: %cell ( -- %cell:C )  cell 8 u* ;

	test: %cell: checks if cell shift conforms with current architecture.
	given sp0!
	when: %cell
	then: TARGET_ARCH_CELL_SIZE 8* !=
		  depth 0 !=
	test;

( Adds cell size to x. )
: cell+ ( x -- x+cell# )  CELLPLUS, ;

	test: cell+: checks if cell addition is correct.
	given sp0!  24
	when: cell+
	then: TARGET_ARCH_CELL_SIZE 24 + !=
		  depth 0 !=
	test;

	test: cell+: checks if cell+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ cell+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Multiplies n by cell size. )
: cells ( n -- n*cell# )  CELLTIMES, ;

	test: cells: checks if cell multiplication is correct.
	given sp0!  24
	when: cells
	then: TARGET_ARCH_CELL_SIZE 24 u* !=
		  depth 0 !=
	test;

	test: cells: checks if cells fails gracefully on an empty stack.
	given sp0!
	when: capture{ cells }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Adds n cells to x. )
: cells+ ( x n -- x+n*cell# )  CELLSPLUS, ;

	test: cells+: checks if cell multadd is correct.
	given sp0!  100 24
	when: cells+
	then: TARGET_ARCH_CELL_SIZE 24 u* 100 + !=
		  depth 0 !=
	test;

	test: cells+: checks if cells+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ cells+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: cells+: checks if cells+ fails gracefully on a stack with only one entry.
	given sp0!  222
	when: capture{ cells+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides u by the cell size. )
: cell/ ( u -- u/cell# )  CELLUBY, ;

	test: cell/: checks if cell size division is correct.
	given sp0!  1024
	when: cell/
	then: 1024 TARGET_ARCH_CELL_SIZE u/ !=
		  depth 0 !=
	test;

	test: cell/: checks if cell/ fails gracefully on an empty stack.
	given sp0!
	when: capture{ cell/ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Pushes constant 0. )
: 0 ( -- 0 )  ZERO, ;  alias false

	test: 0: checks if constant 0 is pushed.
	given sp0!
	when: 0
	then: 0 !=
		  depth 0 !=
	test;

( Pushes double-word constant 0. )
: d#0 ( -- d#0 )  DZERO, ;

	test: d#0: checks if constant d#0 is pushed.
	given sp0!
	when: d#0
	then: d0 !=
		  depth 0 !=
	test;

( Pushes quad-word constant 0. )
: q#0 ( -- q#0 )  QZERO, ;

	test: q#0: checks if constant q#0 is pushed.
	given sp0!
	when: q#0
	then: q0 !=
		  depth 0 !=
	test;

( Pushes oct-word constant 0. )
: o#0 ( -- o#0 )  OZERO, ;

	test: o#0: checks if constant o#0 is pushed.
	given sp0!
	when: o#0
	then: o0 !=
		  depth 0 !=
	test;

( Pushes constant 1. )
: 1 ( -- 1 )  ONE, ;

	test: 1: checks if constant 1 is pushed.
	given sp0!
	when: 1
	then: 1 !=
		  depth 0 !=
	test;

( Pushes double-word constant 1. )
: d#1 ( -- d#1 )  DONE, ;

	test: d#1: checks if constant d#1 is pushed.
	given sp0!
	when: d#1
	then: 1 d!=
		  depth 0 !=
	test;

( Pushes quad-word constant 1. )
: q#1 ( -- q#1 )  QONE, ;

	test: q#1: checks if constant q#1 is pushed.
	given sp0!
	when: q#1
	then: 1 q!=
		  depth 0 !=
	test;

( Pushes oct-word constant 1. )
: o#1 ( -- o#1 )  OONE, ;

	test: o#1: checks if constant o#1 is pushed.
	given sp0!
	when: o#1
	then: 1 o!=
		  depth 0 !=
	test;

( Pushes constant -1. )
: −1 ( -- -1 )  MONE, ;  alias true  alias -1

	test: -1: checks if constant -1 is pushed.
	given sp0!
	when: -1
	then: -1 !=
		  depth 0 !=
	test;

( Pushes double-word constant −1. )
: d#−1 ( -- d#−1 )  DMONE, ;

	test: d#−1: checks if constant d#−1 is pushed.
	given sp0!
	when: d#−1
	then: −1 d!=
		  depth 0 !=
	test;

( Pushes quad-word constant −1. )
: q#−1 ( -- q#−1 )  QMONE, ;

	test: q#−1: checks if constant q#−1 is pushed.
	given sp0!
	when: q#−1
	then: −1 q!=
		  depth 0 !=
	test;

( Pushes oct-word constant −1. )
: o#−1 ( -- o#−1 )  OMONE, ;

	test: o#−1: checks if constant o#−1 is pushed.
	given sp0!
	when: o#−1
	then: −1 o!=
		  depth 0 !=
	test;
	
( Pushes a blank. )
: bl ( -- ␣ )  BLANK, ;  alias ␣

	test: bl: checks if a blank is pushed.
	given sp0!
	when: bl
	then: $20 !=
		  depth 0 !=
	test;

--- Initialization Vector Structure ---

0000  dup private constant @PSP				( Address of the parameter stack. )
cell+ dup private constant #PSP				( Size of the parameter stack in cells. )
cell+ dup private constant @RSP				( Address of the return stack. )
cell+ dup private constant #RSP				( Size of the return stack in cells. )
cell+ dup private constant @XSP				( Address of the extra stack. )
cell+ dup private constant #XSP				( Size of the extra stack in cells. )
cell+ dup private constant @@SourceFile		( Address of the variable containing the source file name. )
cell+ dup private constant @#SourceLine		( Address of the variable containing the source line number. )
cell+ dup private constant @#SourceColumn	( Address of the variable containing the source column number. )
cell+ dup private constant ExHandler#		( Address of the exception handler )
drop

=== Stack Operations ===
	
( Initial parameter stack pointer. )
private variable PSP0
( Initial return stack pointer. )
private variable RSP0

--- Parameter Stack Operations ---

( Returns initial parameter stack pointer sp. )
: sp0 ( -- sp )  PSP0 @ ;

	test: sp0: checks if the initial stack pointer is returned.
	given sp0!
	when: sp0
	then: PSP0 @ !=
		  depth 0 !=
	test;

( Returns stack pointer sp. )
: sp@ ( -- sp )  GETSP, ;

	test: sp@: checks if the stack pointer on an empty stack is equal to initial SP, and decreases by 1 cell when pushing.
	given sp0!
	when: sp@ sp@
	then: sp0 cell - !=
		  sp0 !=
		  depth 0 !=
	test;

( Sets the stack pointer to sp. )
: sp! ( sp -- )  SETSP, ;

	test: sp!: checks if the stack pointer is set to sp.
	given 1024 sp!
	when: sp@
	then: 1024 !=
		  depth 0 !=
	@end: sp0!
	test;

	test: sp!: checks if sp! fails gracefully on an empty stack.
	given sp0!
	when: capture{ sp! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Resets the parameter stack pointer to the initial stack pointer. )
: sp0! ( -- )  sp0 sp! ;

	test: sp0!: checks if the stack pointer is reset to zero.
	given 0 1 2 3 4 5 6 7 8 9
	when: sp0!
	then: sp@ sp0 !=
		  depth 0 !=
	test;

( Returns the stack size in cells. )
: sp# ( -- u )  PSIZE, ;

	test: sp#: checks if the stack can be set to the bottom.
	given sp0!
	when: sp0 sp# cells - sp!
	then: capture{ dup }capture sp0!
		  captured@ ParameterStackOverflow !=
	test;

( Returns the number of occupied stack cells. )
: depth ( -- # )  sp0 sp@ MINUS, cell/ 1- ;

	test: depth: checks if the initial depth is 0.
	given sp0!
	when: depth
	then: 0 !=
		  depth 0 !=
	test;

	test: depth: checks if the depth is correctly reported.
	given sp0! 1 2 3
	when: depth
	then: 3 !=
		  depth 0 !=
	test;

( Duplicates top of parameter stack. )
: dup ( x -- x x )  DUP, ;

	test: dup: checks if the current entry is duplicated.
	given sp0! 12345678
	when: dup
	then: !=
		  depth 0 !=
	test;

	test: dup: checks if dup fails gracefully on an empty stack.
	given sp0!
	when: capture{ dup }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Drops the top of stack. )
: drop ( x -- )  DROP, ;

	test: drop: checks if the current entry is dropped.
	given sp0! 12345678
	when: drop
	then: depth 0 !=
	test;

	test: drop: checks if drop fails gracefully on an empty stack.
	given sp0!
	when: capture{ drop }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Exchanges top and second of stack. )
: swap ( x2 x1 -- x1 x2 )  SWAP, ;

	test: swap: checks if the TOP and 2OP are swapped.
	given sp0! 12345678 45645645
	when: swap
	then: 12345678 !=
		  45645645 !=
		  depth 0 !=
	test;

	test: swap: checks if swap fails gracefully on an empty stack.
	given sp0!
	when: capture{ swap }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: swap: checks if swap fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ swap }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Copies second over top of stack. )
: over ( x2 x1 -- x2 x1 x2 )  OVER, ;

	test: over: checks if the 2OP is copied over the TOP.
	given sp0! 12345678 45645645
	when: over
	then: 12345678 !=
		  45645645 !=
		  12345678 !=
		  depth 0 !=
	test;

	test: over: checks if over fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ swap }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: over: checks if over fails gracefully on an empty stack.
	given sp0!
	when: capture{ over }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: over: checks if over fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ over }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Tucks top behind second of stack (swap over). )
: tuck ( x2 x1 -- x1 x2 x1 )  TUCK, ;

	test: tuck: checks if the TOP is copied under the 2OP.
	given sp0! 45645645 12345678
	when: tuck
	then: 12345678 !=
		  45645645 !=
		  12345678 !=
		  depth 0 !=
	test;

	test: tuck: checks if tuck fails gracefully on an empty stack.
	given sp0!
	when: capture{ tuck }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: tuck: checks if tuck fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ tuck }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Drops second of stack. (swap drop) )
: nip ( x2 x1 -- x1 )  NIP, ;

	test: nip: checks if the 2OP is dropped.
	given sp0! 45645645 12345678
	when: nip
	then: 12345678 !=
		  depth 0 !=
	test;

	test: nip: checks if nip fails gracefully on an empty stack.
	given sp0!
	when: capture{ nip }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: nip: checks if nip fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ nip }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Rotates stack triple up. )
: rot ( x3 x2 x1 -- x2 x1 x3 )  ROT, ;

	test: rot: checks if the stack triple is rotated.
	given sp0! 45645645 12345678 -9897363
	when: rot
	then: 45645645 !=
		  -9897363 !=
		  12345678 !=
		  depth 0 !=
	test;

	test: rot: checks if rot fails gracefully on an empty stack.
	given sp0!
	when: capture{ rot }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: rot: checks if rot fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ rot }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: rot: checks if rot fails gracefully on a stack with only two entries.
	given sp0!  2134155 453465
	when: capture{ rot }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

( Rotates stack triple down. )
: -rot ( x3 x2 x1 -- x1 x3 x2 )  NEGROT, ;

	test: -rot: checks if the stack triple is rotated.
	given sp0! 45645645 12345678 -9897363
	when: -rot
	then: 12345678 !=
		  45645645 !=
		  -9897363 !=
		  depth 0 !=
	test;

	test: -rot: checks if -rot fails gracefully on an empty stack.
	given sp0!
	when: capture{ -rot }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: -rot: checks if -rot fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ -rot }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: -rot: checks if -rot fails gracefully on a stack with only two entries.
	given sp0!  2134155 453465
	when: capture{ -rot }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

( Duplicates top stack pair. )
: 2dup ( y x -- y x y x )  2DUP, ;

	test: 2dup: checks if the top stack pair is duplicated.
	given sp0! 45645645 12345678
	when: -rot
	then: 12345678 !=
		  45645645 !=
		  12345678 !=
		  45645645 !=
		  depth 0 !=
	test;

	test: 2dup: checks if 2dup fails gracefully on an empty stack.
	given sp0!
	when: capture{ 2dup }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: 2dup: checks if 2dup fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ 2dup }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Drops top of stack pair. )
: 2drop ( y x -- )  2DROP, ;

	test: 2drop: checks if the top stack pair is dropped.
	given sp0! 45645645 12345678
	when: 2drop
	then: depth 0 !=
	test;

	test: 2drop: checks if 2drop fails gracefully on an empty stack.
	given sp0!
	when: capture{ 2drop }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: 2drop: checks if 2drop fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ 2drop }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Swaps top and second of stack pair. )
: 2swap ( y2 x2 y1 x1 -- y1 x1 y2 x2 )  2SWAP, ;

	test: 2swap: checks if the top stack pair is swapped with the next stack pair.
	given sp0! 45645645 -12345678 -9897363 222222222
	when: 2drop
	then: -12345678 !=
		  45645645 !=
		  222222222 !=
		  -9897363 !=
	      depth 0 !=
	test;

	test: 2swap: checks if 2swap fails gracefully on an empty stack.
	given sp0!
	when: capture{ 2swap }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: 2swap: checks if 2swap fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ 2swap }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: 2swap: checks if 2swap fails gracefully on a stack with only two entries.
	given sp0!  2134155 0
	when: capture{ 2swap }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: 2swap: checks if 2swap fails gracefully on a stack with only three entries.
	given sp0!  2134155 0 -1
	when: capture{ 2swap }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 3 !=
	test;

( Copies second of stack pair over top pair. )
: 2over ( y2 x2 y1 x1 -- y2 x2 y1 x1 y2 x2 )  2OVER, ;

	test: 2over: checks if the second stack pair is copied over the top stack pair.
	given sp0! 45645645 -12345678 -9897363 222222222
	when: 2drop
	then: -12345678 !=
		  45645645 !=
		  222222222 !=
		  -9897363 !=
		  -12345678 !=
		  45645645 !=
	      depth 0 !=
	test;

	test: 2over: checks if 2over fails gracefully on an empty stack.
	given sp0!
	when: capture{ 2over }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: 2over: checks if 2over fails gracefully on a stack with only one entry.
	given sp0!  2134155
	when: capture{ 2over }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: 2over: checks if 2over fails gracefully on a stack with only two entries.
	given sp0!  2134155 0
	when: capture{ 2over }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: 2over: checks if 2over fails gracefully on a stack with only three entries.
	given sp0!  2134155 0 -1
	when: capture{ 2over }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 3 !=
	test;

( Picks the uth stack cell. )
: pick ( ... u -- ... xu )  PICK, ;

	test: pick: checks if the uth element is picked from the stack.
	given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
	when: 5 pick
	then: 12345678 !=
		  depth 7 !=
	test;

	test: pick: checks if pick succeeds on a stack with u and exactly u+1 entries.
	given sp0!
	when: 0 1 2 3 4 4 pick
	then: 0 !=
		  depth 3 !=
	test;

	test: pick: checks if pick fails gracefully on an empty stack.
	given sp0!
	when: capture{ pick }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: pick: checks if pick fails gracefully on an empty stack with u.
	given sp0!
	when: capture{ 4 pick }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: pick: checks if pick fails gracefully on an empty stack with u and u-1 entries.
	given sp0!
	when: capture{ 1 2 3 4 4 pick }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 4 !=
	test;

( Rotates u cells on the stack up. )
: roll ( xn xm ... xu u -- xm ... xu xn )  ROLL, ;

	test: roll: checks if the stack is rotated around u cells.
	given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
	when: 5 roll
	then: -9897363 !=
		  666666666 !=
		  55555555555 !=
		  -234265446 !=
		  222222222 !=
		  -9897363 !=
		  12345678 !=
		  45645645 !=
		  depth 7 !=
	test;

	test: roll: checks if roll fails gracefully on an empty stack.
	given sp0!
	when: capture{ roll }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: roll: checks if roll succeeds on a stack with u and exactly u entries.
	given sp0!
	when: 0 1 2 3 4 roll
	then: 0 !=
		  depth 3 !=
	test;

	test: roll: checks if roll fails gracefully on an empty stack with u.
	given sp0!
	when: capture{ 4 roll }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: roll: checks if roll fails gracefully on an empty stack with u and u-1 entries.
	given sp0!
	when: capture{ 1 2 3 4 roll }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 4 !=
	test;

( Rotates u cells on the stack down. )
: -roll ( xn xm ... xu u -- xu xn xm ... )  NEGROLL, ;

	test: roll: checks if the stack is rotated around u cells.
	given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
	when: 5 -roll
	then: 55555555555 !=
		  -234265446 !=
		  222222222 !=
		  -9897363 !=
		  666666666 !=
		  12345678 !=
		  45645645 !=
		  depth 7 !=
	test;

	test: -roll: checks if -roll succeeds on a stack with u and exactly u entries.
	given sp0!
	when: 0 1 2 3 4 roll
	then: 2 !=
		  depth 3 !=
	test;

	test: -roll: checks if -roll fails gracefully on an empty stack.
	given sp0!
	when: capture{ -roll }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: -roll: checks if -roll fails gracefully on an empty stack with u.
	given sp0!
	when: capture{ 4 -roll }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: -roll: checks if -roll fails gracefully on an empty stack with u and u-1 entries.
	given sp0!
	when: capture{ 1 2 3 4 -roll }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 4 !=
	test;

( Duplicates top of stack unless it's zero. )
: ?dup ( x -- x [x] )  ?DUP, ;

	test: ?dup: checks if duped if not 0.
	given sp0! 345236576
	when: ?dup
	then: !=
		  depth 0 !=
	test;

	test: ?dup: checks if not duped if 0.
	given sp0! 0
	when: ?dup
	then: 0 !=
		  depth 0 !=
	test;

	test: ?dup: checks if ?dup fails gracefully on an empty stack.
	given sp0!
	when: capture{ ?dup }capture
	then: captured@ ParameterStackUnderflow !=
	test;

--- Return Stack Operations ---

( Returns initial return stack pointer rp. )
: rp0 ( -- rp )  RSP0 @ ;

	test: rp0: checks if the initial stack pointer is returned.
	given sp0!
	when: rp0
	then: RSP0 @ !=
		  depth 0 !=
	test;

( Returns return stack pointer rp. )
: rp@ ( -- rp )  GETRP, ;

	test: rp@: checks if the stack pointer increases by 1 cell when pushing.
	given sp0!
	when: rp@ 0 >r rp@ rdrop
	then: cell - !=
		  depth 0 !=
	test;

( Sets the return stack pointer to rp. )
: rp! ( rp -- )  SETRP, ;

	test: rp!: checks if the stack pointer is set correctly.
	given sp0!
	when: rp@ cell+ rp! rp@ rdrop
	then: cell - !=
		  depth 0 !=
	test;

( Moves top of return stack to parameter stack. )
: r> ( -- x |R: x -- )  FROMR, ;

	test: r>: checks if the return stack element appears on the parameter stack and that rp is decreased.
	given sp0!
	when: rp@  123435467 >r r>  rp@ swap
	then: 123435467 !=
		  !=
		  depth 0 !=
	test;

( Moves top of parameter stack to return stack. )
: >r ( x -- |R: -- x )  TOR, ;

	test: >r: checks if the parameter stack element appears on the return stack and that rp is increased.
	given sp0! 123435467
	when: rp@ swap >r rp@ r>
	then: 123435467 !=
		  cell - !=
		  depth 0 !=
	test;

( Copies top of return stack to parameter stack. )
: r@ ( -- x |R: x -- x )  RFETCH, ;

	test: r@: checks if the return stack element appears on the parameter stack and that rp is not decreased.
	given sp0!
	when: rp@  123435467 >r r@ r>  rp@ -rot
	then: !=
		  !=
		  depth 0 !=
	test;

( Copies top of parameter stack to return stack. )
: r! ( x -- x |R: -- x )  RCOPY, ;

	test: r!: checks if a copy of the parameter stack element appears on the return stack and that rp is decreased.
	given sp0!  123435467
	when: rp@ swap r! r> ( rp' x x |R: ) rp@ -rot
	then: !=
		  !=
		  depth 0 !=
	test;

( Drops top of return stack. )
: rdrop ( -- |R: x -- )  RDROP, ;

	test: rdrop: checks if the return stack element appears on the parameter stack and the return stack is decreased.
	given sp0!  123435467
	when: rp@ swap >r rdrop ( rp' |R: ) rp@
	then: !=
		  depth 0 !=
	test;

( Duplicates top of return stack. )
: rdup ( -- |R: x -- x x )  RDUP, ;

	test: rdup: checks if a copy of the return stack element appears on the return stack and the return stack is decreased.
	given sp0!
	when: rp@ rdup r> r@ ( rp' x x |R: ) rp@ -rot
	then: !=
		  !=
		  depth 0 !=
	test;

( Returns the inner loop index. )
: i ( -- index |R: limit index -- limit index )  LOOPINDEX, ;

	test: i: checks if the index appears on the parameter stack and the return stack is unchanged.
	given sp0!  12345678 >r -981765814 >r
	when: rp@ i rp@ swap rdrop rdrop
	then: -981765814 !=
		  !=
		  depth 0 !=
	test;

( Returns the inner loop limit. )
: limit ( -- limit |R: limit index -- limit index )  LOOPLIMIT, ;

	test: limit: checks if the limit appears on the parameter stack and the return stack is unchanged.
	given sp0!  12345678 >r -981765814 >r
	when: rp@ limit rp@ swap rdrop rdrop
	then: 12345678 !=
		  !=
		  depth 0 !=
	test;

( Returns the outer loop index. )
: j ( -- index1 |R: limit1 index1 limit2 index2 -- limit1 index1 limit2 index2 )  LOOPINDEX2, ;

	test: j: checks if the outer index appears on the parameter stack and the return stack is unchanged.
	given sp0!  12345678 >r -981765814 >r 666666666 >r 77777777 >r
	when: rp@ j rp@ swap rdrop rdrop rdrop rdrop
	then: -981765814 !=
		  !=
		  depth 0 !=
	test;

( Returns the outer loop limit. )
: ljmit ( -- limit1 |R: limit1 index1 limit2 index2 -- limit1 index1 limit2 index2 )  LOOPLIMIT2, ;

	test: ljmit: checks if the outer index appears on the parameter stack and the return stack is unchanged.
	given sp0!  12345678 >r -981765814 >r 666666666 >r 77777777 >r
	when: rp@ j rp@ swap rdrop rdrop rdrop rdrop
	then: 12345678 !=
		  !=
		  depth 0 !=
	test;

( Prepares for leaving a DO-LOOP loop. )
: unloop ( -- )  2RDROP, ;

	test: unloop: checks if the index and limit are dropped from the return stack.
	given sp0!  12345678 >r -981765814 >r
	when: rp@ unloop rp@
	then: 2 cells + !=
		  depth 0 !=
	test;

( Pushes return stack depth n. )
: rdepth ( -- n )  rp0 rp@ r− cell/ ;

	test: rdepth: checks if the return stack depth is correctly reported.
	given sp0!
	when: rp@ rp0 - cell/ rdepth
	then: !=
		  depth 0 !=
	test;

=== Stack Arithmetics ===

( Trap on overflow. )
: !O! ( -- )  TRAPOV, ;

	test: !O!: check if overflow triggers trap.
	given MAX_I 2
	when: capture{ + !O! }capture
	then: captured@ ArithmeticOverflow !=
		  depth 0 !=
	test;

	test: !O!: check if non-overflow doesn't trigger trap.
	given 1 2
	when: capture{ − !O! }capture
	then: captured@ 0 !=
		  -1 !=
		  depth 0 !=
	test;

( Trap on carry. )
: !C! ( -- )  TRAPCY, ;

	test: !C!: check if carry triggers trap.
	given MAX_C 2
	when: capture{ + !O! }capture
	then: captured@ ArithmeticOverflow !=
		  depth 0 !=
	test;

	test: !C!: check if borrow triggers trap.
	given MAX_C 2
	when: capture{ r− !C! }capture
	then: captured@ ArithmeticOverflow !=
		  depth 0 !=
	test;

	test: !C!: check if non-carry doesn't trigger trap (even when overflow).
	given MAX_I 2
	when: capture{ + !C! }capture
	then: captured@ 0 !=
		  drop
		  depth 0 !=
	test;

( Adds x1 to x2. )
: − ( x2 x1 -- x2+x1 )  PLUS, ;  alias -

	test: +: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: +
	then: 4753 !=
		  depth 0 !=
	test;

	test: +: checks if + fails gracefully on an empty stack.
	given sp0!
	when: capture{ + }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: +: checks if + fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ + }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Subtracts x1 from x2. )
: − ( x2 x1 -- x2−x1 )  MINUS, ;  alias -

	test: +: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: −
	then: -4660 !=
		  depth 0 !=
	test;

	test: −: checks if − fails gracefully on an empty stack.
	given sp0!
	when: capture{ − }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −: checks if − fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ − }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Multiplies x2 with x1. )
: × ( x2 x1 -- x2×x1 )  TIMES, ;  alias *

	test: ×: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: ×
	then: 197,862‬ !=
		  depth 0 !=
	test;

	test: ×: checks if the result is arithmetically correct.
	given sp0!  -13 -12
	when: ×
	then: 156 !=
		  depth 0 !=
	test;

	test: ×: checks if × fails gracefully on an empty stack.
	given sp0!
	when: capture{ × }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ×: checks if × fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ × }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Multiplies u2 with u1, unsigned. )
: u× ( u2 u1 -- u2×u1 )  UTIMES, ;  alias u*

	test: u×: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: ×
	then: 197,862‬ !=
		  depth 0 !=
	test;

	test: u×: checks if the result is arithmetically correct.
	given sp0!  -13 -12
	when: ×
	then: 156 !=
		  depth 0 !=
	test;

	test: u×: checks if u× fails gracefully on an empty stack.
	given sp0!
	when: capture{ u× }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u×: checks if u× fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u× }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides x2 through x1. )
: ÷ ( x2 x1 -- x2÷x1 )  THROUGH, ;  alias /

	test: ÷: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: ÷
	then: 112 !=
		  depth 0 !=
	test;

	test: ÷: checks if ÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ÷: checks if ÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ ÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides u2 through u1, unsigned. )
: u÷ ( u2 u1 -- u2÷u1 )  UTHROUGH, ;  alias u/

	test: u÷: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: u÷
	then: 112 !=
		  depth 0 !=
	test;

	test: u÷: checks if u÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ u÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u÷: checks if u÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides x1 through x2. )
: r÷ ( x2 x1 -- x1÷x2 )  RTHROUGH, ;  alias /

	test: r÷: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: r÷
	then: 112 !=
		  depth 0 !=
	test;

	test: r÷: checks if r÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ r÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: r÷: checks if r÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ r÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides u1 through u2, unsigned. )
: ur÷ ( u2 u1 -- u1÷u2 )  URTHROUGH, ;  alias u/

	test: ur÷: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: ur÷
	then: 112 !=
		  depth 0 !=
	test;

	test: ur÷: checks if ur÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ur÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ur÷: checks if ur÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ ur÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Computes remainder "modulo" of x2 through x1. )
: % ( x2 x1 -- x2%x1 )  MODULO, ;  alias mod

	test: %: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: %
	then: 7 !=
		  depth 0 !=
	test;

	test: %: checks if % fails gracefully on an empty stack.
	given sp0!
	when: capture{ % }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: %: checks if % fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ % }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Computes remainder "modulo" of u2 through u1, unsigned. )
: u% ( u2 u1 -- u2%u1 )  UMODULO, ;  alias umod

	test: u%: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: u%
	then: 7 !=
		  depth 0 !=
	test;

	test: u%: checks if u% fails gracefully on an empty stack.
	given sp0!
	when: capture{ u% }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u%: checks if u% fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u% }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Computes remainder "modulo" of x1 through x2. )
: r% ( x2 x1 -- x1%x2 )  RMODULO, ;  alias rmod

	test: r%: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: r%
	then: 7 !=
		  depth 0 !=
	test;

	test: r%: checks if r% fails gracefully on an empty stack.
	given sp0!
	when: capture{ r% }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: r%: checks if r% fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ r% }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Computes remainder "modulo" of u1 through u2, unsigned. )
: u% ( u2 u1 -- u1%u2 )  URMODULO, ;  alias urmod

	test: ur%: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: ur%
	then: 7 !=
		  depth 0 !=
	test;

	test: ur%: checks if ur% fails gracefully on an empty stack.
	given sp0!
	when: capture{ ur% }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ur%: checks if ur% fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ ur% }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides x2 through x1 and returns quotient and remainder "modulo". )
: %÷ ( x2 x1 -- x2%x1 x2÷x1 )  MODDIV, ;  alias /mod

	test: %÷: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: %÷
	then: 112 !=
		  7 !=
		  depth 0 !=
	test;

	test: %÷: checks if %÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ %÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: %÷: checks if %÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ %÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides u2 through u1 and returns quotient and remainder "modulo", unsigned. )
: u%÷ ( u2 u1 -- u2%u1 u2÷u1 )  UMODDIV, ;  alias u/mod

	test: u%÷: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: u÷
	then: 112 !=
		  7 !=
		  depth 0 !=
	test;

	test: u%÷: checks if u%÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ u%÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u%÷: checks if u%÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u%÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides x1 through x2 and returns quotient and remainder "modulo". )
: r%÷ ( x2 x1 -- x1%x2 x1÷x2 )  RMODDIV, ;  alias r/mod

	test: r%÷: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: r÷
	then: 112 !=
		  7 !=
		  depth 0 !=
	test;

	test: r%÷: checks if r%÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ r%÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: r%÷: checks if r%÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ r%÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Divides u1 through u2 and returns quotient and remainder "modulo", unsigned. )
: ur%÷ ( u2 u1 -- u1%u2 u1÷u2 )  URDIVMOD, ;  alias ur/mod

	test: ur%÷: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: ur÷
	then: 112 !=
		  7 !=
		  depth 0 !=
	test;

	test: ur%÷: checks if ur%÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ur%÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ur%÷: checks if ur%÷ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ ur%÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Returns n = n3+n2×n1. )
: ×+ ( n3 n2 n1 -- n )  TIMESPLUS, ;  alias *+

	test: ×+: checks if the result is arithmetically correct.
	given sp0!  4711 42 13
	when: ×+
	then: 5257 !=
		  depth 0 !=
	test;

	test: ×+: checks if ×+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ×+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ×+: checks if ×+ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ ×+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: ×+: checks if ×+ fails gracefully on a stack with only two entries.
	given sp0!  4711 42
	when: capture{ ×+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

( Returns u = u3+u2×u1. )
: u×+ ( u3 u2 u1 -- u )  UTIMESPLUS, ;  alias u*+

	test: u×+: checks if the result is arithmetically correct.
	given sp0!  4711 42 13
	when: u×+
	then: 5257 !=
		  depth 0 !=
	test;

	test: u×+: checks if u×+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ u×+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u×+: checks if u×+ fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u×+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: u×+: checks if u×+ fails gracefully on a stack with only two entries.
	given sp0!  4711 42
	when: capture{ u×+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

( Increments second of stack. )
: nxt ( x2 x1 -- x2+1 x1 )  INCS, ;

	test: nxt: checks if the result is arithmetically correct.
	given sp0!  42 13
	when: nxt
	then: 13 !=
		  43 !=
		  depth 0 !=
	test;

	test: nxt: checks if nxt fails gracefully on an empty stack.
	given sp0!
	when: capture{ nxt }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: nxt: checks if nxt fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ nxt }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Advances cursor of buffer with address a and length # by u bytes. )
: +> ( a # u -- a+u #-u )  ADV, ;

	test: +>: checks if both 2OP and TOP are affected in the right direction.
	given sp0!  42 13
	when: 12 +>
	then: 1 !=
		  54 !=
		  depth 0 !=
	test;

	test: +>: checks if +> fails gracefully on an empty stack.
	given sp0!
	when: capture{ +> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: +>: checks if +> fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ +> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: +>: checks if +> fails gracefully on a stack with only two entries.
	given sp0!  42 13
	when: capture{ +> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

( Rounds n2 up to the next multiple of n1. )
: →| ( n2 n1 -- n3 )  tuck 1− + over / * ;  alias >|

	test: →|: checks if the result is arithmetically correct.
	given sp0!  42
	when: 8 →|
	then: 48 !=
		  depth 0 !=
	test;

	test: →|: checks if the result is arithmetically correct.
	given sp0!  -42
	when: 8 →|
	then: -40 !=
		  depth 0 !=
	test;

	test: →|: checks if →| fails gracefully on an empty stack.
	given sp0!
	when: capture{ →| }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: →|: checks if →| fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ →| }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Rounds u2 up to the next multiple of u1. )
: u→| ( u2 u1 -- u3 )  tuck 1− + over u/ u* ;  alias >|

	test: u→|: checks if the result is arithmetically correct.
	given sp0!  42
	when: 8 u→|
	then: 48 !=
		  depth 0 !=
	test;

	test: u→|: checks if the result is arithmetically correct.
	given sp0!  -42
	when: 8 →|
	then: -40 !=
		  depth 0 !=
	test;

	test: u→|: checks if u→| fails gracefully on an empty stack.
	given sp0!
	when: capture{ u→| }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u→|: checks if u→| fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u→| }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Rounds n2 down to the next multiple of n1. )
: |← ( n2 n1 -- n3 )  over r% − ;  alias |<

	test: |←: checks if the result is arithmetically correct.
	given sp0!  42
	when: 8 |←
	then: 40 !=
		  depth 0 !=
	test;

	test: |←: checks if the result is arithmetically correct.
	given sp0!  -42
	when: 8 |←
	then: -48 !=
		  depth 0 !=
	test;

	test: |←: checks if |← fails gracefully on an empty stack.
	given sp0!
	when: capture{ |← }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: |←: checks if |← fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ |← }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Rounds u2 down to the next multiple of u1. )
: u|← ( u2 u1 -- u3 )  over ur% − ;  alias |<

	test: u|←: checks if the result is arithmetically correct.
	given sp0!  42
	when: 8 u|←
	then: 40 !=
		  depth 0 !=
	test;

	test: u|←: checks if the result is arithmetically correct.
	given sp0!  -42
	when: 8 u|←
	then: -48 !=
		  depth 0 !=
	test;

	test: u|←: checks if u|← fails gracefully on an empty stack.
	given sp0!
	when: capture{ u|← }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u|←: checks if u|← fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u|← }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Negates n. )
: ± ( n -- −n )  NEG, ;  alias negate

	test: ±: checks if the result is arithmetically correct.
	given sp0!  4711
	when: ±
	then: -4711 !=
		  depth 0 !=
	test;

	test: ±: checks if the result is arithmetically correct.
	given sp0!  -42
	when: ±
	then: 42 !=
		  depth 0 !=
	test;

	test: ±: checks if ± fails gracefully on an empty stack.
	given sp0!
	when: capture{ ± }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Returns the absolute value of n. )
: abs ( n -- |n| )  ABS, ;

	test: abs: checks if the result is arithmetically correct.
	given sp0!  4711
	when: abs
	then: 4711 !=
		  depth 0 !=
	test;

	test: abs: checks if the result is arithmetically correct.
	given sp0!  -42
	when: abs
	then: 42 !=
		  depth 0 !=
	test;

	test: abs: checks if abs fails gracefully on an empty stack.
	given sp0!
	when: capture{ abs }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Selects the lesser of two signed numbers n1 and n2. )
: min ( n2 n1 -- n1|n2 )  MIN2, ;

	test: min: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: min
	then: 42 !=
		  depth 0 !=
	test;

	test: min: checks if the result is arithmetically correct.
	given sp0!  -4711 42
	when: min
	then: -4711 !=
		  depth 0 !=
	test;

	test: min: checks if min fails gracefully on an empty stack.
	given sp0!
	when: capture{ min }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: min: checks if min fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ min }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Selects the lesser of two unsigned numbers u1 and u2. )
: umin ( u2 u1 -- u1|u2 )  UMIN2, ;

	test: umin: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: umin
	then: 42 !=
		  depth 0 !=
	test;

	test: umin: checks if the result is arithmetically correct.
	given sp0!  -4711 42
	when: min
	then: 42 !=
		  depth 0 !=
	test;

	test: umin: checks if umin fails gracefully on an empty stack.
	given sp0!
	when: capture{ umin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: umin: checks if umin fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ umin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Selects the bigger of two signed numbers n1 and n2. )
: max ( n2 n1 -- n1|n2 )  MAX2, ;

	test: max: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: max
	then: 4711 !=
		  depth 0 !=
	test;

	test: max: checks if the result is arithmetically correct.
	given sp0!  -4711 42
	when: max
	then: 42 !=
		  depth 0 !=
	test;

	test: max: checks if max fails gracefully on an empty stack.
	given sp0!
	when: capture{ max }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: max: checks if max fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ max }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Selects the bigger of two unsigned numbers u1 and u2. )
: umax ( u2 u1 -- u1|u2 )  UMAX2, ;

	test: umax: checks if the result is arithmetically correct.
	given sp0!  4711 42
	when: umax
	then: 4711 !=
		  depth 0 !=
	test;

	test: umax: checks if the result is arithmetically correct.
	given sp0!  -4711 42
	when: umax
	then: -4711 !=
		  depth 0 !=
	test;

	test: umax: checks if umax fails gracefully on an empty stack.
	given sp0!
	when: capture{ umax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: umax: checks if umax fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ umax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Checks if x is at least xmin [inclusive lower boundary] and less than xmax [exclusive upper boundary], i.e. xmin ⇐ x < xmax. )
: within ( x xmin xmax -- ? )  ISWITHIN, ;

	test: within: checks if the test is correct when x is between.
	given sp0!
	when: 4 2 8 within
	then: true !=
		  depth 0 !=
	test;

	test: within: checks if the test is correct when x is lower.
	given sp0!
	when: -4 2 8 within
	then: false !=
		  depth 0 !=
	test;

	test: within: checks if the test is correct when x is higher.
	given sp0!
	when: 14 2 8 within
	then: false !=
		  depth 0 !=
	test;

	test: within: checks if the test is correct when x is xmax.
	given sp0!
	when: 8 2 8 within
	then: false !=
		  depth 0 !=
	test;

	test: within: checks if the test is correct when x is xmin.
	given sp0!
	when: 2 2 8 within
	then: true !=
		  depth 0 !=
	test;

	test: within: checks if the test is correct when x is negative and in range.
	given sp0!
	when: -2 -8 8 within
	then: true !=
		  depth 0 !=
	test;

	test: within: checks if within fails gracefully on an empty stack.
	given sp0!
	when: capture{ within }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: within: checks if within fails gracefully on a stack with only one entry.
	given sp0!  1
	when: capture{ within }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

	test: within: checks if within fails gracefully on a stack with only two entries.
	given sp0!  1 2
	when: capture{ within }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !2=
	test;

	test: within: checks if within fails gracefully on a stack with empty range.
	given sp0!
	when: capture{ 10 100 6 within }capture
	then: captured@ EmptyRange !=
		  depth 0 !=
	test;


=== Logical Stack Operations ===

--- Logops ---

( Conjoins two stack cells x1 and x2 giving x3. )
: and ( x2 x1 -- x3 )  AND, ;

	test: and: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: and
	then: 46 !=
		  depth 0 !=
	test;

	test: and: checks if and fails gracefully on an empty stack.
	given sp0!
	when: capture{ and }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: and: checks if and fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ and }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Bijoins two stack cells x1 and x2 giving x3. )
: or ( x2 x1 -- x3 )  OR, ;

	test: or: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: and
	then: 4719 !=
		  depth 0 !=
	test;

	test: or: checks if or fails gracefully on an empty stack.
	given sp0!
	when: capture{ or }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: or: checks if or fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ or }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Disjoins two stack cells x1 and x2 giving x3. )
: xor ( x2 x1 -- x3 )  XOR, ;

	test: xor: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: and
	then: 4685 !=
		  depth 0 !=
	test;

	test: xor: checks if xor fails gracefully on an empty stack.
	given sp0!
	when: capture{ xor }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: xor: checks if xor fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ xor }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Complements stack cell x1. )
: not ( x1 -- ¬x1 )  NOT, ;

	test: not: checks if the result is arithmetically correct.
	given sp0!  4711
	when: not
	then: -4712 !=
		  depth 0 !=
	test;

	test: not: checks if not fails gracefully on an empty stack.
	given sp0!
	when: capture{ not }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Conjoins x2 with the complement of x1 giving x3. )
: andn ( x2 x1 -- x3 )  NOT, AND, ;

	test: andn: checks if the result is arithmetically correct.
	given sp0!  42 4711
	when: andn
	then: 8 !=
		  depth 0 !=
	test;

	test: andn: checks if andn fails gracefully on an empty stack.
	given sp0!
	when: capture{ andn }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: andn: checks if andn fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ andn }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

--- Shift and Rotate ---

( Shifts u logically left by # bits. )
: u<< ( u # -- u' )  SHL, ;  alias u≪

	test: u<<: checks if the result is arithmetically correct.
	given sp0!  4711
	when: 5 u<<
	then: 150,742 !=
		  depth 0 !=
	test;

	test: u<<: checks if u<< fails gracefully on an empty stack.
	given sp0!
	when: capture{ u<< }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u<<: checks if u<< fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u<< }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Shifts u logically right by # bits. )
: u>> ( u # -- u' )  SHR, ;  alias u≫

	test: u>>: checks if the result is arithmetically correct.
	given sp0!  4711
	when: 5 u>>
	then: 147 !=
		  depth 0 !=
	test;

	test: u>>: checks if the result is arithmetically correct.
	given sp0!  -4711
	when: 5 u>>
	then: 7FF,FFFF,FFFF,FDC7‬H !=
		  depth 0 !=
	test;

	test: u>>: checks if u>> fails gracefully on an empty stack.
	given sp0!
	when: capture{ u>> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u>>: checks if u>> fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ u>> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Shifts n arithmetically left by # bits.  This is the same as logically, but will produce OV instead of CY. )
: << ( n # -- n' )  SAL, ;  alias ≪

	test: <<: checks if the result is arithmetically correct.
	given sp0!  4711
	when: 5 <<
	then: 150,742 !=
		  depth 0 !=
	test;

	test: <<: checks if << fails gracefully on an empty stack.
	given sp0!
	when: capture{ << }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: <<: checks if << fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ << }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Shifts u arithmetically right by # bits. )
: >> ( u # -- u' )  SAR, ;  alias ≫

	test: >>: checks if the result is arithmetically correct.
	given sp0!  4711
	when: 5 u>>
	then: 147 !=
		  depth 0 !=
	test;

	test: >>: checks if the result is arithmetically correct.
	given sp0!  -4711
	when: 5 u>>
	then: -148 !=
		  depth 0 !=
	test;

	test: >>: checks if >> fails gracefully on an empty stack.
	given sp0!
	when: capture{ >> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: >>: checks if >> fails gracefully on a stack with only one entry.
	given sp0!  42
	when: capture{ >> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

=== Storage Operations ===

( Returns signed byte b at address a. )
: b@ ( a -- b )  BFETCH, ;

	test: b@: checks if indeed a signed byte is fetched.
	given sp0!  666
	when: sp@ b@
	then: -102 !=
		  drop depth 0 !=
	test;

	test: b@: checks if b@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ b@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: b@: checks if b@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 b@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: b@: checks if b@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 b@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns unsigned byte c at address a. )
: c@ ( a -- c )  CFETCH, ;

	test: c@: checks if indeed an unsigned byte is fetched.
	given sp0!  666
	when: sp@ b@
	then: 154 !=
		  drop depth 0 !=
	test;

	test: c@: checks if c@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ c@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c@: checks if c@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 c@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: c@: checks if c@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 c@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns signed word s at address a. )
: s@ ( a -- s )  SFETCH, ;

	test: s@: checks if indeed a signed word is fetched.
	given sp0!  123,456
	when: sp@ s@
	then: -7,616 !=
		  drop depth 0 !=
	test;

	test: s@: checks if s@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ s@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: s@: checks if s@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 s@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: s@: checks if s@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 s@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns unsigned word w at address a. )
: w@ ( a -- w )  WFETCH, ;

	test: w@: checks if indeed an unsigned word is fetched.
	given sp0!  123,456
	when: sp@ w@
	then: 57,920‬ !=
		  drop depth 0 !=
	test;

	test: w@: checks if w@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ w@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w@: checks if w@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 w@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: w@: checks if w@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 w@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Returns signed double-word i at address a. )
: i@ ( a -- i )  IFETCH, ;

	test: i@: checks if indeed a signed double-word is fetched.
	given sp0!  i#123,456,789,012
	when: sp@ i@
	then: i#-1,097,262,572‬ d!=
		  ddrop depth 0 !=
	test;

	test: i@: checks if i@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ i@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: i@: checks if i@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 i@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: i@: checks if i@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 i@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns unsigned double-word d at address a. )
: d@ ( a -- d )  DFETCH, ;

	test: d@: checks if indeed an unsigned double-word is fetched.
	given sp0!  d#123,456,789,012
	when: sp@ d@
	then: d#3,197,704,724‬‬ d!=
		  ddrop depth 0 !=
	test;

	test: d@: checks if d@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ d@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d@: checks if d@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 d@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: d@: checks if d@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 d@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns signed quad-word ℓ at address a. )
: ℓ@ ( a -- ℓ )  LFETCH, ;  alias l@

	test: l@: checks if indeed a signed quad-word is fetched.
	given sp0!  ℓ#$ABCD,EF01,2345,6789,ABCD
	when: sp@ ℓ@
	then: ℓ#-EF01,2345,6789,ABCE,H q!=
		  qdrop depth 0 !=
	test;

	test: ℓ@: checks if ℓ@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ℓ@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ℓ@: checks if ℓ@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 ℓ@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: ℓ@: checks if ℓ@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 ℓ@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns unsigned quad-word q at address a. )
: q@ ( a -- q )  QFETCH, ;

	test: q@: checks if indeed an unsigned quad-word is fetched.
	given sp0!  q#$ABCD,EF01,2345,6789,ABCD
	when: sp@ d@
	then: q#EF01,2345,6789,ABCD,H q!=
		  qdrop depth 0 !=
	test;

	test: q@: checks if q@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ q@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q@: checks if q@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 q@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: q@: checks if q@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 q@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns signed oct-word h at address a. )
: h@ ( a -- h )  HFETCH, ;

	test: h@: checks if indeed a signed oct-word is fetched.
	given sp0!  h#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789,ABCD
	when: sp@ h@
	then: h#-10FE,DCBA,9876,5432‬,10FE,DCBA,9876,5433H o!=
		  odrop depth 0 !=
	test;

	test: h@: checks if h@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ h@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: h@: checks if h@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 h@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: h@: checks if h@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 h@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Returns unsigned oct-word q at address a. )
: o@ ( a -- o )  OFETCH, ;

	test: o@: checks if indeed an unsigned oct-word is fetched.
	given sp0!  o#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789,ABCD
	when: sp@ o@
	then: o#EF01,2345,6789,ABCD,EF01,2345,6789,ABCD,H o!=
		  odrop depth 0 !=
	test;

	test: o@: checks if o@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ o@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: o@: checks if o@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 o@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: o@: checks if o@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 o@ }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Exchanges signed byte at address a with b, returning previous value b'. )
: b@! ( b a -- b' )  BXCHG,  DROP, ;

	test: b@!: checks if the previous byte is returned and the new byte was stored.
	given sp0!  $ABCD
	when: 3 sp@ b@!
	then: -51 !=
		  $AB03 !=
		  depth 0 !=
	test;

	test: b@!: checks if b@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ b@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: b@!: checks if b@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ b@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: b@!: checks if b@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 b@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: b@!: checks if b@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 b@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Exchanges unsigned byte at address a with c, returning previous value c'. )
: c@! ( c a -- c' )  CXCHG,  DROP, ;

	test: c@!: checks if the previous byte is returned and the new byte was stored.
	given sp0!  $ABCD
	when: 12 sp@ c@!
	then: 205 !=
		  $AB0C !=
		  depth 0 !=
	test;

	test: c@!: checks if c@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ c@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c@!: checks if c@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ c@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c@!: checks if c@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 c@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: c@!: checks if c@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 c@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Exchanges signed word at address a with s, returning previous value s'. )
: s@! ( s a -- s' )  SXCHG,  DROP, ;

	test: s@!: checks if the previous word is returned and the new word was stored.
	given sp0!  $6789ABCD
	when: -666 sp@ s@!
	then: -51 !=
		  $6789FD66 !=
		  depth 0 !=
	test;

	test: s@!: checks if s@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ s@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: s@!: checks if s@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ s@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: s@!: checks if s@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 s@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: s@!: checks if s@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 s@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Exchanges unsigned word at address a with w, returning previous value w'. )
: w@! ( w a -- w' )  CXCHG,  DROP, ;

	test: w@!: checks if the previous word is returned and the new word was stored.
	given sp0!  $6789ABCD
	when: -12 sp@ w@!
	then: 43,981 !=
		  $6789FFEE !=
		  depth 0 !=
	test;

	test: w@!: checks if w@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ w@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w@!: checks if w@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ w@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w@!: checks if w@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 w@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: w@!: checks if w@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 w@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;

( Exchanges signed double-word at address a with i, returning previous value i'. )
: i@! ( i a -- i' )  IXCHG,  DROP, ;

	test: i@!: checks if the previous double-word is returned and the new double-word was stored.
	given sp0!  i#$6789,ABCD,EF01
	when: -1 sp@ i@!
	then: i#-1,412,567,295‬ d!=
		  i#$6789,FFFF,FFFF d!=
		  depth 0 !=
	test;

	test: i@!: checks if i@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ i@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: i@!: checks if i@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ i@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: i@!: checks if i@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 i@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: i@!: checks if i@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 i@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Exchanges unsigned double-word at address a with d, returning previous value d'. )
: d@! ( d a -- d' )  DXCHG,  DROP, ;

	test: d@!: checks if the previous double-word is returned and the new double-word was stored.
	given sp0!  d#$6789,ABCD,EF01
	when: 123456 sp@ d@!
	then: d#‭2,882,400,001‬ d!=
		  d#$6789,0001,E240 d!=
		  depth 0 !=
	test;

	test: d@!: checks if d@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ d@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d@!: checks if d@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ d@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d@!: checks if d@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 d@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: d@!: checks if d@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 d@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Exchanges signed quad-word at address a with ℓ, returning previous value ℓ'. )
: ℓ@! ( ℓ a -- ℓ' )  LXCHG,  DROP, ;  alias l@!

	test: ℓ@!: checks if the previous quad-word is returned and the new quad-word was stored.
	given sp0!  ℓ#$6789,ABCD,EF01,2345,6789
	when: ℓ#-4711 sp@ ℓ@!
	then: -ℓ#‭5432,10FE,DCBA,9877‬H q!=
		  ℓ#$6789,‭FFFF,FFFF,FFFF,ED99‬ q!=
		  depth 0 !=
	test;

	test: ℓ@!: checks if ℓ@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ ℓ@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ℓ@!: checks if ℓ@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ ℓ@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ℓ@!: checks if ℓ@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 ℓ@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: ℓ@!: checks if ℓ@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 ℓ@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Exchanges unsigned quad-word at address a with q, returning previous value q'. )
: q@! ( q a -- q' )  QXCHG,  DROP, ;

	test: q@!: checks if the previous quad-word is returned and the new quad-word was stored.
	given sp0!  q#$6789,ABCD,EF01,2345,6789
	when: ℓ#-4711 sp@ q@!
	then: ‭q#ABCD,EF01,2345,6789,H‬ q!=
		  q#$6789,‭FFFF,FFFF,FFFF,ED99 q!=
		  depth 0 !=
	test;

	test: q@!: checks if q@! fails gracefully on an empty stack.
	given sp0!
	when: capture{ q@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q@!: checks if q@! fails gracefully on a stack with only one entry.
	given sp0!  666
	when: capture{ q@! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q@!: checks if q@! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 q@! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 1 !=
	test;

	test: q@!: checks if q@! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 q@! }capture
	then: captured@ NullPointer !=
		  depth 1 !=
	test;
	
( Returns signed byte b at address a and post-increments. )
: b@++ ( a -- a+1 b )  BFETCHINC, ;

	test: b@++: checks if the correct signed byte is returned and the address is incremented.
	given sp0!  666
	when: sp@ b@++
	then: -102 !=
		  sp@ cell+ 1 + !=
		  depth 0 !=
	test;

	test: b@++: checks if b@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ b@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: b@++: checks if b@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 b@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: b@++: checks if b@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 b@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns unsigned byte c at address a and post-increments. )
: c@++ ( a -- a+1 c )  CFETCHINC, ;

	test: c@++: checks if the correct unsigned byte is returned and the address is incremented.
	given sp0!  666
	when: sp@ c@++
	then: 154 !=
		  sp@ cell+ 1 + !=
		  depth 0 !=
	test;

	test: c@++: checks if c@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ c@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c@++: checks if c@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 c@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c@++: checks if c@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 c@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns signed word s at address a and post-increments. )
: s@++ ( a -- a+2 s )  SFETCHINC, ;

	test: s@++: checks if the correct signed word is returned and the address is incremented.
	given sp0!  ‭3,333,333‬
	when: sp@ s@++
	then: ‭‭-9003‬‬ !=
		  sp@ cell+ 2 + !=
		  depth 0 !=
	test;

	test: s@++: checks if s@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ s@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: s@++: checks if s@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 s@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: s@++: checks if s@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 s@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns unsigned word w at address a and post-increments. )
: w@++ ( a -- a+2 w )  WFETCHINC, ;

	test: w@++: checks if the correct unsigned word is returned and the address is incremented.
	given sp0!  ‭3,333,333‬
	when: sp@ w@++
	then: ‭‭‭56533‬‬‬ !=
		  sp@ cell+ 2 + !=
		  depth 0 !=
	test;

	test: w@++: checks if w@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ w@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w@++: checks if w@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 w@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: w@++: checks if w@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 w@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns signed double-word i at address a and post-increments. )
: i@++ ( a -- a+4 i )  IFETCHINC, ;

	test: i@++: checks if the correct signed double-word is returned and the address is incremented.
	given sp0!  i#‭$6789,ABCD,EF01
	when: sp@ i@++
	then: i#-1,412,567,295‬ d!=
		  sp@ cell+ 4 + !=
		  depth 0 !=
	test;

	test: i@++: checks if i@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ i@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: i@++: checks if i@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 i@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: i@++: checks if i@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 i@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns unsigned double-word d at address a and post-increments. )
: d@++ ( a -- a+4 d )  DFETCHINC, ;

	test: d@++: checks if the correct unsigned double-word is returned and the address is incremented.
	given sp0!  ‭d#$6789,ABCD,EF01
	when: sp@ d@++
	then: d#2,882,400,001 d!=
		  sp@ cell+ 4 + !=
		  depth 0 !=
	test;

	test: d@++: checks if d@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ d@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d@++: checks if d@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 d@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: d@++: checks if d@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 d@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns signed quad-word ℓ at address a and post-increments. )
: ℓ@++ ( a -- a+8 ℓ )  LFETCHINC, ;  alias l@++

	test: ℓ@++: checks if the correct signed quad-word is returned and the address is incremented.
	given sp0!  ‭ℓ#$6789,ABCD,EF01,2345,6789
	when: sp@ ℓ@++
	then: -ℓ#‭5432,10FE,DCBA,9877‬H q!=
		  sp@ cell+ 8 + !=
		  depth 0 !=
	test;

	test: ℓ@++: checks if ℓ@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ℓ@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ℓ@++: checks if ℓ@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 ℓ@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: ℓ@++: checks if ℓ@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 ℓ@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns unsigned quad-word q at address a and post-increments. )
: q@++ ( a -- a+8 q )  QFETCHINC, ;

	test: q@++: checks if the correct unsigned quad-word is returned and the address is incremented.
	given sp0!  q#‭$6789,ABCD,EF01,2345,6789
	when: sp@ q@++
	then: q#ABCD,EF01,2345,6789H‬ q!=
		  sp@ cell+ 8 + !=
		  depth 0 !=
	test;

	test: q@++: checks if q@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ q@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q@++: checks if q@++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 q@++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: q@++: checks if q@++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 q@++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns signed byte b at a-1. )
: −−b@ ( a -- a−1 b )  DECBFETCH, ;  alias --b@

	test: −−b@: checks if the correct signed byte is returned and the address is decremented.
	given sp0!  −4711
	when: sp@ 1 + −−b@
	then: -103 !=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−b@: checks if −−b@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−b@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−b@: checks if −−b@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−b@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−b@: checks if −−b@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−b@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns unsigned byte c at a-1. )
: −−c@ ( a -- a−1 c )  DECCFETCH, ;  alias --c@

	test: −−c@: checks if the correct unsigned byte is returned and the address is decremented.
	given sp0!  -4711
	when: sp@ 1 + −−c@
	then: 153 !=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−c@: checks if −−c@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−c@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−c@: checks if −−b@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−c@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−c@: checks if −−c@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−c@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns signed word s at a-2. )
: −−s@ ( a -- a−2 b )  DECSFETCH, ;  alias --s@

	test: −−s@: checks if the correct signed word is returned and the address is decremented.
	given sp0!  ‭123,456,789‬
	when: sp@ 2 + −−s@
	then: ‭-13,035‬ !=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−s@: checks if −−s@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−s@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−s@: checks if −−s@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−s@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−s@: checks if −−s@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−s@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns unsigned word w at a-2. )
: −−w@ ( a -- a−2 w )  DECWFETCH, ;  alias --w@

	test: −−w@: checks if the correct unsigned word is returned and the address is decremented.
	given sp0!  ‭123,456,789‬
	when: sp@ 2 + −−w@
	then: ‭‭52,501‬ !=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−w@: checks if −−w@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−w@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−w@: checks if −−w@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−w@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−w@: checks if −−w@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−w@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns signed double-word i at a-4. )
: −−i@ ( a -- a−4 i )  DECIFETCH, ;  alias --i@

	test: −−i@: checks if the correct signed double-word is returned and the address is decremented.
	given sp0!  i#‭123,456,789‬,012,345
	when: sp@ 4 + −−i@
	then: ‭i#-2,045,911,175‬ d!=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−i@: checks if −−i@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−i@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−i@: checks if −−i@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−i@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−i@: checks if −−i@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−i@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns unsigned double-word d at a-4. )
: −−d@ ( a -- a−4 d )  DECDFETCH, ;  alias --d@

	test: −−d@: checks if the correct unsigned double-word is returned and the address is decremented.
	given sp0!  d#‭123,456,789‬,012,345
	when: sp@ 4 + −−d@
	then: ‭d#2,249,056,121‬ d!=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−d@: checks if −−d@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−d@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−d@: checks if −−d@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−d@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−d@: checks if −−d@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−d@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns signed quad-word ℓ at a-8. )
: −−ℓ@ ( a -- a−8 ℓ )  DECLFETCH, ;  alias --l@

	test: −−ℓ@: checks if the correct signed quad-word is returned and the address is decremented.
	given sp0!  ℓ#‭‭$6789,ABCD,EF01,2345,6789
	when: sp@ 8 + −−ℓ@
	then: ‭ℓ#-6,066,930,334,832,433,271‬‬ q!=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−ℓ@: checks if −−ℓ@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−ℓ@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−ℓ@: checks if −−ℓ@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−ℓ@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−ℓ@: checks if −−ℓ@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−ℓ@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Pre-decrements address a and returns unsigned quad-word q at a-8. )
: −−q@ ( a -- a−8 q )  DECQFETCH, ;  alias --q@

	test: −−q@: checks if the correct unsigned quad-word is returned and the address is decremented.
	given sp0!  q#‭‭$6789,ABCD,EF01,2345,6789
	when: sp@ 8 + −−q@
	then: q#ABCD,EF01,2345,6789H q!=
		  sp@ cell+ !=
		  depth 0 !=
	test;

	test: −−q@: checks if −−q@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−q@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−q@: checks if −−q@ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −−q@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−q@: checks if −−q@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−q@ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets byte at address a to c. )
: c! ( c a -- )  CSTORE, ;

	test: c!: checks if byte c is in fact stored at address a.
	given sp0!  -1
	when: sp@ 42 swap c!
	then: -214 !=
		  depth 0 !=
	test;

	test: c!: checks if only byte c is stored at address a.
	given sp0!  0
	when: sp@ -42 swap c!
	then: 214 !=
		  depth 0 !=
	test;

	test: c!: checks if c! fails gracefully on an empty stack.
	given sp0!
	when: capture{ c! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c!: checks if c! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 c! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c!: checks if c! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 c! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets word at address a to w. )
: w! ( w a -- )  WSTORE, ;

	test: w!: checks if word w is in fact stored at address a.
	given sp0!  -1
	when: sp@ 4711 swap w!
	then: ‭-60,825‬ !=
		  depth 0 !=
	test;

	test: w!: checks if only word w is stored at address a.
	given sp0!  0
	when: sp@ -42 swap w!
	then: ‭65,494‬ !=
		  depth 0 !=
	test;

	test: w!: checks if w! fails gracefully on an empty stack.
	given sp0!
	when: capture{ w! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w!: checks if w! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 w! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: w!: checks if w! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 w! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets double-word at address a to d. )
: d! ( d a -- )  DSTORE, ;

	test: d!: checks if double-word d is in fact stored at address a.
	given sp0!  i#-1
	when: sp@ d#‭2345678901‬ swap d!
	then: ‭‭i#-1,949,288,395‬‬ d!=
		  depth 0 !=
	test;

	test: d!: checks if only double-word d is stored at address a.
	given sp0!  0
	when: sp@ -42 swap d!
	then: d#‭4,294,967,254‬‬ d!=
		  depth 0 !=
	test;

	test: d!: checks if d! fails gracefully on an empty stack.
	given sp0!
	when: capture{ d! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d!: checks if d! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 d! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: d!: checks if d! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 d! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets quad-word at address a to q. )
: q! ( q a -- )  QSTORE, ;

	test: q!: checks if quad-word q is in fact stored at address a.
	given sp0!  ℓ#-1
	when: sp@ q#$ABCD,EF01,2345,6789 swap q!
	then: ‭‭ℓ#-1949288395‬‬ q!=
		  depth 0 !=
	test;

	test: q!: checks if only quad-word q is stored at address a.
	given sp0!  q#0
	when: sp@ ℓ#-42 swap q!
	then: ‭‭q# $FFFF,FFFF,FFFF,FFD6‬ q!=
		  depth 0 !=
	test;

	test: q!: checks if q! fails gracefully on an empty stack.
	given sp0!
	when: capture{ q! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q!: checks if q! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 q! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: q!: checks if q! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 q! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets oct-word at address a to o. )
: o! ( o a -- )  OSTORE, ;

	test: o!: checks if oct-word o is in fact stored at address a.
	given sp0!  -1
	when: sp@ o#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789 swap o!
	then: ‭‭o#$ABCD,EF01,2345,6789,ABCD,EF01,2345,6789 o!=
		  depth 0 !=
	test;

	test: o!: checks if only oct-word o is stored at address a.
	given sp0!  o#0
	when: sp@ h#-42 swap q!
	then: ‭o#$FFFF,FFFF,FFFF,FFFF,FFFF,FFFF,FFFF,FFD6‬ o!=
		  depth 0 !=
	test;

	test: o!: checks if o! fails gracefully on an empty stack.
	given sp0!
	when: capture{ o! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: o!: checks if o! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 o! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: o!: checks if o! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 o! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Stores # least significant bytes of x at address a. )
: #! ( x a # -- )  STORE#, ;

	test: #!: checks if byte is stored at address a when #=1.
	given sp0!  -1
	when: sp@ 4711 swap 1 #!
	then: ‭-153‬ !=
		  depth 0 !=
	test;

	test: #!: checks if word is stored at address a when #=2.
	given sp0!  -1
	when: sp@ 4711 swap 2 #!
	then: ‭‭-60,825‬ !=
		  depth 0 !=
	test;

	test: #!: checks if 3 bytes are stored at address a when #=3.
	given sp0!  -1
	when: sp@ 4711 swap 3 #!
	then: ‭‭‭-16,772,505‬ !=
		  depth 0 !=
	test;

	test: #!: checks if double-word is stored at address a when #=4.
	given sp0!  ℓ#-1
	when: sp@ d#123,456,798,012,345 swap 4 #!
	then: ‭ℓ#-2,045,911,175‬‬ !=
		  depth 0 !=
	test;

	test: #!: checks if nothing is stored at address a when #=0.
	given sp0!  -1
	when: sp@ q#123,456,798,012,345 swap 0 #!
	then: ‭-1‬‬ !=
		  depth 0 !=
	test;

	test: #!: checks if nothing is stored at address a when #<0.
	given sp0!  -1
	when: sp@ q#123,456,798,012,345 swap -4 #!
	then: ‭-1‬‬ !=
		  depth 0 !=
	test;

	test: #!: checks if #! fails gracefully on an empty stack.
	given sp0!
	when: capture{ #! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: #!: checks if #! fails gracefully on a stack with only 1 entry.
	given sp0!  1
	when: capture{ #! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: #!: checks if #! fails gracefully on a stack with only 2 entries.
	given sp0!  sp@ 1
	when: capture{ #! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: #!: checks if #! fails gracefully with a bad address.
	given sp0!
	when: capture{ 0 -1 1 #! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: #!: checks if #! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 0 1 #! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets byte at address a to c and post-increments. )
: c!++ ( a c -- a+1 )  CSTOREINC, ;

	test: c!++: checks if byte c is stored at address a, and address is incremented.
	given sp0!  -1
	when: sp@ 42 c!++
	then: sp@ cell+ 1 + !=
		  -214 !=
		  depth 0 !=
	test;

	test: c!++: checks if only byte c is stored at address a.
	given sp0!  0
	when: sp@ -42 swap c!++
	then: sp@ cell+ 1 + !=
		  214 !=
		  depth 0 !=
	test;

	test: c!++: checks if c!++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ c!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c!++: checks if c!++ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ c!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c!++: checks if c!++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 c!++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c!++: checks if c!++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 c!++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets word at address a to w and post-increments. )
: w!++ ( a w -- a+2 )  WSTOREINC, ;

	test: w!++: checks if word w is stored at address a, and address is incremented.
	given sp0!  -1
	when: sp@ 4711 w!++
	then: sp@ cell+ 2 + !=
		  ‭-60,825‬ !=
		  depth 0 !=
	test;

	test: w!++: checks if only word w is stored at address a.
	given sp0!  0
	when: sp@ -42 swap w!++
	then: sp@ cell+ 2 + !=
		  65,494‬ !=
		  depth 0 !=
	test;

	test: w!++: checks if w!++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ w!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w!++: checks if w!++ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ w!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w!++: checks if w!++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 w!++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: w!++: checks if w!++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 w!++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets double-word at address a to d and post-increments. )
: d!++ ( a d -- a+4 )  DSTOREINC, ;

	test: d!++: checks if double-word d is stored at address a, and address is incremented.
	given sp0!  d#-1
	when: sp@ ‭d#2,345,678,901‬ d!++
	then: sp@ cell+ 4 + !=
		  ‭‭i#-1,949,288,395‬‬ d!=
		  depth 0 !=
	test;

	test: d!++: checks if only double-word d is stored at address a.
	given sp0!  d#0
	when: sp@ i#-42 swap d!++
	then: sp@ cell+ 4 + !=
		  ‭d#4,294,967,254‬‬ d!=
		  depth 0 !=
	test;

	test: d!++: checks if d!++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ d!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d!++: checks if d!++ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ d!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d!++: checks if d!++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 d!++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: d!++: checks if d!++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 d!++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets quad-word at address a to q and post-increments. )
: q!++ ( a q -- a+8 )  QSTOREINC, ;

	test: q!++: checks if quad-word q is stored at address a, and address is incremented.
	given sp0!  ℓ#-1
	when: sp@ ‭q#$ABCD,EF01,2345,6789‬ q!++
	then: sp@ cell+ 8 + !=
		  ‭‭‭‭ℓ#-1,949,288,395‬‬ q!=
		  depth 0 !=
	test;

	test: q!++: checks if only quad-word q is stored at address a.
	given sp0!  q#0
	when: sp@ ℓ#-42 swap d!++
	then: sp@ cell+ 8 + !=
		  ‭‭q#$FFFF,FFFF,FFFF,FFD6‬ q!=
		  depth 0 !=
	test;

	test: q!++: checks if q!++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ q!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q!++: checks if q!++ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ q!++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q!++: checks if q!++ fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 q!++ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: q!++: checks if q!++ fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 q!++ }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets byte at address a to c and post-decrements. )
: c!−− ( a c -- a−1 )  CSTOREDEC, ;  alias c!--

	test: c!−−: checks if byte c is stored at address a, and address is decremented.
	given sp0!  -1
	when: sp@ 42 c!−−
	then: sp@ cell+ 1 − !=
		  -214 !=
		  depth 0 !=
	test;

	test: c!−−: checks if only byte c is stored at address a.
	given sp0!  0
	when: sp@ -42 swap c!++
	then: sp@ cell+ 1 − !=
		  214 !=
		  depth 0 !=
	test;

	test: c!−−: checks if c!−− fails gracefully on an empty stack.
	given sp0!
	when: capture{ c!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c!−−: checks if c!−− fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ c!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c!−−: checks if c!−− fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 c!−− }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c!−−: checks if c!−− fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 c!−− }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets word at address a to w and post-decrements. )
: w!−− ( a w -- a−2 )  WSTOREDEC, ;

	test: w!−−: checks if word w is stored at address a, and address is decremented.
	given sp0!  -1
	when: sp@ 4711 w!−−
	then: sp@ cell+ 2 − !=
		  ‭-60,825‬ !=
		  depth 0 !=
	test;

	test: w!−−: checks if only word w is stored at address a.
	given sp0!  0
	when: sp@ -42 swap w!−−
	then: sp@ cell+ 2 − !=
		  65,494‬ !=
		  depth 0 !=
	test;

	test: w!−−: checks if w!−− fails gracefully on an empty stack.
	given sp0!
	when: capture{ w!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w!−−: checks if w!−− fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ w!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w!−−: checks if w!−− fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 w!−− }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: w!−−: checks if w!−− fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 w!−− }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets double-word at address a to d and post-decrements. )
: d!−− ( a d -- a−4 )  DSTOREDEC, ;

	test: d!−−: checks if double-word d is stored at address a, and address is decremented.
	given sp0!  i#-1
	when: sp@ d#‭2,345,678,901‬ d!−−
	then: sp@ cell+ 4 − !=
		  i#-1,949,288,395‬‬ d!=
		  depth 0 !=
	test;

	test: d!−−: checks if only double-word d is stored at address a.
	given sp0!  d#0
	when: sp@ i#-42 swap d!−−
	then: sp@ cell+ 4 − !=
		  ‭d#4,294,967,254‬‬ d!=
		  depth 0 !=
	test;

	test: d!−−: checks if d!−− fails gracefully on an empty stack.
	given sp0!
	when: capture{ d!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d!−−: checks if d!−− fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ d!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d!−−: checks if d!−− fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 d!−− }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: d!−−: checks if d!−− fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 d!−− }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets quad-word at address a to q and post-decrements. )
: q!−− ( a q -- a−8 )  QSTOREDEC, ;

	test: q!−−: checks if quad-word q is stored at address a, and address is decremented.
	given sp0!  ℓ#-1
	when: sp@ q#‭$ABCD,EF01,2345,6789‬ q!−−
	then: sp@ cell+ 8 − !=
		  ‭‭‭‭ℓ#-1,949,288,395‬‬ q!=
		  depth 0 !=
	test;

	test: q!−−: checks if only quad-word q is stored at address a.
	given sp0!  q#0
	when: sp@ ℓ#-42 swap d!−−
	then: sp@ cell+ 8 − !=
		  q#‭‭$FFFF,FFFF,FFFF,FFD6‬ q!=
		  depth 0 !=
	test;

	test: q!−−: checks if q!−− fails gracefully on an empty stack.
	given sp0!
	when: capture{ q!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q!−−: checks if q!−− fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ q!−− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q!−−: checks if q!−− fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 q!−− }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: q!−−: checks if q!−− fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 q!−− }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Pre-decrements address a and sets byte at address a-1 to c. )
: −−c! ( a c -- a−1 )  DECCSTORE, ;  alias --c!

	test: −−c!: checks if byte c is stored at address a−1, and address is decremented.
	given sp0!  -1
	when: sp@ 42 −−c!
	then: sp@ cell+ 1 − !=
		  ‭-54529‬ !=
		  depth 0 !=
	test;

	test: −−c!: checks if only byte c is stored at address a.
	given sp0!  0
	when: sp@ -42 swap c!++
	then: sp@ cell+ 1 − !=
		  ‭54784‬ !=
		  depth 0 !=
	test;

	test: −−c!: checks if −−c! fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−c! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−c!: checks if −−c! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ −−c! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−c!: checks if −−c! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 −−c! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−c!: checks if −−c! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−c! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Pre-decrements address a and sets word at address a−2 to w. )
: −−w! ( a w -- a−2 )  DECWSTORE, ;  alias −−w!

	test: −−w!: checks if word w is stored at address a, and address is decremented.
	given sp0!  -1
	when: sp@ 2 + 4711 −−w!
	then: sp@ cell+ !=
		  ‭-60,825‬ !=
		  depth 0 !=
	test;

	test: −−w!: checks if only word w is stored at address a.
	given sp0!  0
	when: sp@ 2 + -42 swap −−w!
	then: sp@ cell+ !=
		  65,494‬ !=
		  depth 0 !=
	test;

	test: −−w!: checks if −−w! fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−w! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−w!: checks if −−w! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ −−w! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−w!: checks if −−w! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 −−w! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−w!: checks if −−w! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−w! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Pre-decrements address a and sets double-word at address a−4 to d. )
: −−d! ( a d -- a−4 )  DECDSTORE, ;

	test: −−d!: checks if double-word d is stored at address a, and address is decremented.
	given sp0!  i#-1
	when: sp@ ‭d#2,345,678,901‬ −−d!
	then: sp@ 4 + cell+ !=
		  ‭‭i#-1,949,288,395‬‬ d!=
		  depth 0 !=
	test;

	test: −−d!: checks if only double-word d is stored at address a.
	given sp0!  0
	when: sp@ 4 + -42 swap −−d!
	then: sp@ cell+ !=
		  ‭d#4,294,967,254‬‬ d!=
		  depth 0 !=
	test;

	test: −−d!: checks if −−d! fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−d! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−d!: checks if −−d! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ −−d! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−d!: checks if −−d! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 −−d! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−d!: checks if −−d! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−d! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Pre-decrements address a and sets quad-word at address a−8 to q. )
: −−q! ( a q -- a−8 )  DECQSTORE, ;

	test: −−q!: checks if quad-word q is stored at address a, and address is decremented.
	given sp0!  ℓ#-1
	when: sp@ ‭8 + q#$ABCD,EF01,2345,6789‬ −−q!
	then: sp@ cell+ !=
		  ‭‭‭‭ℓ#-1,949,288,395‬‬ q!=
		  depth 0 !=
	test;

	test: −−q!: checks if only quad-word q is stored at address a.
	given sp0!  q#0
	when: sp@ 8 + ℓ#-42 swap −−d!
	then: sp@ cell+ !=
		  ‭‭q#$FFFF,FFFF,FFFF,FFD6‬ q!=
		  depth 0 !=
	test;

	test: −−q!: checks if −−q! fails gracefully on an empty stack.
	given sp0!
	when: capture{ −−q! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−q!: checks if −−q! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ −−q! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: −−q!: checks if −−q! fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 0 −−q! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: −−q!: checks if −−q! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −−q! }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Sets cell at address a to 0. )
: 0! ( a -- )  0 swap ! ;  alias off

( Sets cell at address a to -1. )
: −1! ( a -- )  −1 swap ! ;  alias -1!  alias on

=== Storage Arithmetics ===

( Adds c to byte at address a. )
: c+! ( c a -- )  CADD, ;

	test: c+!: checks if c is added to byte at address a.
	given sp0!  -1
	when: sp@ 8 swap c+!
	then: ‭‭‭‭‭-249‬ !=
		  depth 0 !=
	test;

	test: c+!: checks if c+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ c+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c+!: checks if c+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ c+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: c+!: checks if c+! fails gracefully with a bad address.
	given sp0!
	when: capture{ 0 -1 c+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c+!: checks if c+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 0 c+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Adds w to word at address a. )
: w+! ( w a -- )  WADD, ;

	test: w+!: checks if w is added to word at address a.
	given sp0!  -1
	when: sp@ 4711 swap w+!
	then: ‭‭‭‭‭‭-60,825‬ !=
		  depth 0 !=
	test;

	test: w+!: checks if w+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ w+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w+!: checks if w+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ w+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: w+!: checks if w+! fails gracefully with a bad address.
	given sp0!
	when: capture{ 0 -1 w+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: w+!: checks if w+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 0 w+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Adds d to double-word at address a. )
: d+! ( d a -- )  DADD, ;

	test: d+!: checks if d is added to double-word at address a.
	given sp0!  i#-1
	when: sp@ >r d#123,456,789,012 r> d+!
	then: ‭i#-4,294,967,297 d!=
		  depth 0 !=
	test;

	test: d+!: checks if d+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ d+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d+!: checks if d+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ d+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: d+!: checks if d+! fails gracefully with a bad address.
	given sp0!
	when: capture{ d#0 -1 d+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: d+!: checks if d+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ d#0 0 d+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Adds q to quad-word at address a. )
: q+! ( q a -- )  QADD, ;

	test: q+!: checks if q is added to quad-word at address a.
	given sp0!  ℓ#-1
	when: sp@ >r q#123,456,789,012 r> q+!
	then: ‭ℓ#-4,294,967,297 !=
		  depth 0 !=
	test;

	test: q+!: checks if q+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ q+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q+!: checks if q+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ q+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: q+!: checks if q+! fails gracefully with a bad address.
	given sp0!
	when: capture{ q#0 -1 q+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: q+!: checks if q+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ q#0 0 q+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Adds o to oct-word at address a. )
: o+! ( o a -- )  OADD, ;

	test: o+!: checks if o is added to oct-word at address a.
	given sp0!  h#-1
	when: sp@ >r o#123,456,789,012,345,678,901,234 r> o+!
	then: ‭o#123,456,789,012,345,678,901,233 o!=
		  depth 0 !=
	test;

	test: o+!: checks if o+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ o+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: o+!: checks if o+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ o+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: o+!: checks if o+! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 o+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: o+!: checks if o+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 o+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Subtracts c from byte at address a. )
: c−! ( c a -- )  CSUB, ;  alias c-!

	test: c−!: checks if c is subtracted from byte at address a.
	given sp0!  -1
	when: sp@ −8 swap c−!
	then: ‭‭‭‭‭-249‬ !=
		  depth 0 !=
	test;

	test: c−!: checks if c−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ c−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c−!: checks if c−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ c−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: c−!: checks if c−! fails gracefully with a bad address.
	given sp0!
	when: capture{ 0 -1 c−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c−!: checks if c−! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 0 c−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Subtracts w from word at address a. )
: w−! ( w a -- )  WSUB, ;  alias w-!

	test: w−!: checks if w is subtracted from word at address a.
	given sp0!  -1
	when: sp@ −4711 swap w−!
	then: ‭‭‭‭‭‭-60,825‬ !=
		  depth 0 !=
	test;

	test: w−!: checks if w−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ w−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: w−!: checks if w−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ w−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: w−!: checks if w−! fails gracefully with a bad address.
	given sp0!
	when: capture{ 0 -1 w−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: w−!: checks if w−! fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 0 w−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Subtracts d from double-word at address a. )
: d−! ( d a -- )  DSUB, ;  alias d-!

	test: d−!: checks if d is subtracted from double-word at address a.
	given sp0!  i#-1
	when: sp@ >r i#−123,456,789,012 r> d−!
	then: ‭i#-4,294,967,297 d!=
		  depth 0 !=
	test;

	test: d−!: checks if d−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ d−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: d−!: checks if d−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ d−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: d−!: checks if d−! fails gracefully with a bad address.
	given sp0!
	when: capture{ d#0 -1 d−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Subtracts q from quad-word at address a. )
: q−! ( q a -- )  QSUB, ;  alias q-!

	test: q−!: checks if q is subtracted from quad-word at address a.
	given sp0!  ℓ#-1
	when: sp@ >r ℓ#−123,456,789,012 r> q−!
	then: ‭ℓ#-4,294,967,297 !=
		  depth 0 !=
	test;

	test: q−!: checks if q−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ q−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: q−!: checks if q−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ q−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Subtracts o from oct-word at address a. )
: o−! ( o a -- )  OSUB, ;  alias o-!

	test: o−!: checks if o is subtracted from oct-word at address a.
	given sp0!  h#-1
	when: sp@ >r h#-123,456,789,012,345,678,901,234 r> o−!
	then: ‭o#123,456,789,012,345,678,901,233 o!=
		  depth 0 !=
	test;

	test: o−!: checks if o−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ o−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: o−!: checks if o−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ o−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: o−!: checks if o−! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 o−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: o−!: checks if o−! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 o−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

=== Logical Memory Operations ===

--- Bitops ---

/*
 * In the following bit operations, the "memory starting at address a" indicates an open range of
 * memory with origin a.  The bit number # can be quite a large number, and the actual operation
 * takes place on cell (a + # u/ %cell).  Bit (# u% %cell) will be tested or affected by the
 * operation.
 */

( Tests if bit # is set in memory starting at address a. )
: bit@ ( a # -- ? )  BTSTAT, ;

	test: bit@: checks if bit 0 is set.
	given sp0!  1
	when: sp@ 0 bit@
	then: true !=
		  drop  depth 0 !=
	test;

	test: bit@: checks if bit 8 is not set.
	given sp0!  1
	when: sp@ 8 bit@
	then: false !=
		  drop  depth 0 !=
	test;

	test: bit@: checks if bit 194 is set.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit@
	then: true !=
		  4qdrop  depth 0 !=
	test;

	test: bit@: checks if bit 200 is set.
	given sp0!  q#256  q#0  q#0  q#0
	when: sp@ 200 bit@
	then: false !=
		  4qdrop  depth 0 !=
	test;

	test: bit@: checks if bit@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@: checks if bit@ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@: checks if bit@ fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@: checks if bit@ fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@ }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Sets bit # in memory starting at address a. )
: bit+! ( a # -- )  BSETAT, ;

	test: bit+!: checks if bit 0 is set.
	given sp0!  0
	when: sp@ 0 bit+!
	then: 1 !=
		  depth 0 !=
	test;

	test: bit+!: checks if bit 8 is set.
	given sp0!  0
	when: sp@ 8 bit+!
	then: 256 !=
		  depth 0 !=
	test;

	test: bit+!: checks if bit 194 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 194 bit+!
	then: 3 qpick q#2 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit+!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit+!
	then: 3 qpick q#256 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit+!: checks if bit+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit+!: checks if bit+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit+!: checks if bit+! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit+!: checks if bit+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Clears bit # in memory starting at address a. )
: bit−! ( a # -- )  BCLRAT, ;  alias bit-!

	test: bit−!: checks if bit 0 is clear.
	given sp0!  −1
	when: sp@ 0 bit−!
	then: −2 !=
		  depth 0 !=
	test;

	test: bit−!: checks if bit 8 is clear.
	given sp0!  256
	when: sp@ 8 bit−!
	then: 0 !=
		  depth 0 !=
	test;

	test: bit−!: checks if bit 194 is set.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit−!
	then: 3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit−!: checks if bit 200 is set.
	given sp0!  q#256  q#0  q#0  q#0
	when: sp@ 200 bit−!
	then: 3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit−!: checks if bit−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit−!: checks if bit−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit−!: checks if bit−! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit−!: checks if bit−! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Flips bit # in memory starting at address a. )
: bit×! ( a # -- )  BCHGAT, ;  alias bit*!

	test: bit×!: checks if bit 0 is clear.
	given sp0!  −1
	when: sp@ 0 bit×!
	then: −2 !=
		  depth 0 !=
	test;

	test: bit×!: checks if bit 0 is set.
	given sp0!  0
	when: sp@ 0 bit×!
	then: 1 !=
		  depth 0 !=
	test;

	test: bit×!: checks if bit 194 is clear.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit×!
	then: 3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit×!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit×!
	then: 3 qpick q#256 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit×!: checks if bit×! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit×! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit×!: checks if bit×! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit×! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit×!: checks if bit×! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit×! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit×!: checks if bit×! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit×! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Non-atomically tests and sets bit # in memory starting at address a. )
: bit@+! ( a # -- ? )  BTSTSETAT, ;

	test: bit@+!: checks if bit 0 is set.
	given sp0!  0
	when: sp@ 0 bit@+!
	then: false !=
		  1 !=
		  depth 0 !=
	test;

	test: bit@+!: checks if bit 8 is set.
	given sp0!  256
	when: sp@ 8 bit@+!
	then: true !=
		  256 !=
		  depth 0 !=
	test;

	test: bit@+!: checks if bit 194 is set.
	given sp0!  q#2  q#0  q#0  q#0
	when: sp@ 194 bit@+!
	then: true !=
		  3 qpick q#2 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@+!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit@+!
	then: false !=
		  3 qpick q#256 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@+!: checks if bit@+! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@+!: checks if bit@+! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@+! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@+!: checks if bit@+! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@+!: checks if bit@+! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@+! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Non-atomically tests and clears bit # in memory starting at address a. )
: bit@−! ( a # -- ? )  BTSTCLRAT, ;  alias bit@-!

	test: bit@−!: checks if bit 0 is clear.
	given sp0!  −1
	when: sp@ 0 bit@−!
	then: true !=
		  −2 !=
		  depth 0 !=
	test;

	test: bit@−!: checks if bit 8 is clear.
	given sp0!  0
	when: sp@ 8 bit@−!
	then: false !=
		  0 !=
		  depth 0 !=
	test;

	test: bit@−!: checks if bit 194 is set.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit@−!
	then: true !=
		  3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@−!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit@−!
	then: false !=
		  3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@−!: checks if bit@−! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@−!: checks if bit@−! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@−! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@−!: checks if bit@−! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@−!: checks if bit@−! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@−! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Non-atomically tests and flips bit # in memory starting at address a. )
: bit@×! ( a # -- > )  BTSTCHGAT, ;  alias bit@*!

	test: bit@×!: checks if bit 0 is clear.
	given sp0!  −1
	when: sp@ 0 bit@×!
	then: true !=
		  −2 !=
		  depth 0 !=
	test;

	test: bit@×!: checks if bit 0 is set.
	given sp0!  0
	when: sp@ 0 bit@×!
	then: false !=
		  1 !=
		  depth 0 !=
	test;

	test: bit@×!: checks if bit 194 is clear.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit@×!
	then: true !=
		  3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit×!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit@×!
	then: 3 qpick q#256 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@×!: checks if bit@×! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@×! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@×!: checks if bit@×! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@×! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@×!: checks if bit@×! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@×! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@×!: checks if bit@×! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@×! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Atomically tests and sets bit # in memory starting at address a. )
: bit@+!! ( a # -- ? )  ABTSTSETAT, ;

	test: bit@+!!: checks if bit 0 is set.
	given sp0!  0
	when: sp@ 0 bit@+!!
	then: false !=
		  1 !=
		  depth 0 !=
	test;

	test: bit@+!!: checks if bit 8 is set.
	given sp0!  256
	when: sp@ 8 bit@+!!
	then: true !=
		  256 !=
		  depth 0 !=
	test;

	test: bit@+!!: checks if bit 194 is set.
	given sp0!  q#2  q#0  q#0  q#0
	when: sp@ 194 bit@+!!
	then: true !=
		  3 qpick q#2 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@+!!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit@+!!
	then: false !=
		  3 qpick q#256 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@+!!: checks if bit@+!! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@+!! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@+!!: checks if bit@+!! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@+!! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@+!!: checks if bit@+!! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@+!! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@+!!: checks if bit@+!! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@+!! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Atomically tests and clears bit # in memory starting at address a. )
: bit@−!! ( a # -- ? )  ABTSTCLRAT, ;  alias bit@-!!

	test: bit@−!!: checks if bit 0 is clear.
	given sp0!  −1
	when: sp@ 0 bit@−!!
	then: true !=
		  −2 !=
		  depth 0 !=
	test;

	test: bit@−!!: checks if bit 8 is clear.
	given sp0!  0
	when: sp@ 8 bit@−!!
	then: false !=
		  0 !=
		  depth 0 !=
	test;

	test: bit@−!!: checks if bit 194 is set.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit@−!!
	then: true !=
		  3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@−!!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit@−!!
	then: false !=
		  3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@−!!: checks if bit@−!! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@−!! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@−!!: checks if bit@−!! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@−!! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@−!!: checks if bit@−!! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@−!! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@−!!: checks if bit@−!! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@−!! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

( Atomically tests and flips bit # in memory starting at address a. )
: bit@×!! ( a # -- > )  ABTSTCHGAT, ;  alias bit@*!!

	test: bit@×!!: checks if bit 0 is clear.
	given sp0!  −1
	when: sp@ 0 bit@×!!
	then: true !=
		  −2 !=
		  depth 0 !=
	test;

	test: bit@×!!: checks if bit 0 is set.
	given sp0!  0
	when: sp@ 0 bit@×!!
	then: false !=
		  1 !=
		  depth 0 !=
	test;

	test: bit@×!!: checks if bit 194 is clear.
	given sp0!  q#4  q#0  q#0  q#0
	when: sp@ 194 bit@×!!
	then: true !=
		  3 qpick q#0 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit×!: checks if bit 200 is set.
	given sp0!  q#0  q#0  q#0  q#0
	when: sp@ 200 bit@×!!
	then: 3 qpick q#256 q!=
		  4qdrop  depth 0 !=
	test;

	test: bit@×!!: checks if bit@×!! fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit@×!! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: bit@×!!: checks if bit@×!! fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ sp@ bit@×!! }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: bit@×!!: checks if bit@×!! fails gracefully with a bad address.
	given sp0!
	when: capture{ o#0 -1 bit@×!! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: bit@×!!: checks if bit@×!! fails gracefully with a null pointer.
	given sp0!
	when: capture{ o#0 0 bit@×!! }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

=== Block operations ===

( Fills byte buffer of length # at address a with c. )
: cfill ( a # c -- )  CFILL, ;

	test: cfill: checks if buffer is partially filled with the byte.
	given sp0!  create cfillbfr  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  −1 c,
	when: cfillbfr 10 20H cfill
	then: cfillbfr 10 0 do  c@++ 20H !=  loop  10 0 do  c@++ 0 !=  loop
		  b@ -1 !=
		  depth 0 !=
	test;

	test: cfill: checks if cfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ cfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: cfill: checks if cfill fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 cfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: cfill: checks if cfill fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 cfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: cfill: checks if cfill fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 cfill }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: cfill: checks if cfill fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 cfill }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Fills word buffer of length # at address a with w. )
: wfill ( a # w -- )  WFILL, ;

	test: wfill: checks if buffer is partially filled with the word.
	given sp0!  create wfillbfr  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  −1 w,
	when: wfillbfr 10 4711 wfill
	then: wfillbfr 10 0 do  w@++ 4711 !=  loop  10 0 do  w@++ 0 !=  loop
		  s@ −1 !=
		  depth 0 !=
	test;

	test: wfill: checks if wfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ wfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: wfill: checks if wfill fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 wfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: wfill: checks if wfill fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 wfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: wfill: checks if wfill fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 wfill }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: wfill: checks if wfill fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 wfill }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Fills double-word buffer of length # at address a with d. )
: dfill ( a # d -- )  DFILL, ;

	test: dfill: checks if buffer is partially filled with the double-word.
	given sp0!  create dfillbfr  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,
	when: dfillbfr 10 d#123,456,789 dfill
	then: dfillbfr 10 0 do  d@++ d#123,456,789 !=  loop  10 0 do  d@++ 0 !=  loop
		  i@ −1 !=
		  depth 0 !=
	test;

	test: dfill: checks if dfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ dfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: dfill: checks if dfill fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 dfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: dfill: checks if dfill fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 dfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: dfill: checks if dfill fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 dfill }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: dfill: checks if dfill fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 dfill }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Fills quad-word buffer of length # at address a with q. )
: qfill ( a # q -- )  QFILL, ;

	test: qfill: checks if buffer is partially filled with the quad-word.
	given sp0!  create qfillbfr  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,
	when: qfillbfr 10 q#123,456,789,012,345 qfill
	then: qfillbfr 10 0 do  q@++ q#123,456,789,012,345 !=  loop  10 0 do  q@++ 0 !=  loop
		  ℓ@ −1 !=
		  depth 0 !=
	test;

	test: qfill: checks if qfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ qfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: qfill: checks if qfill fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 qfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: qfill: checks if qfill fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 qfill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: qfill: checks if qfill fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 qfill }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: qfill: checks if qfill fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 qfill }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Fills oct-word buffer of length # at address a with o. )
: ofill ( a # o -- )  OFILL, ;

	test: ofill: checks if buffer is partially filled with the oct-word.
	given sp0!  create ofillbfr  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,  0 o,
	when: ofillbfr 10 o#123,456,789,012,345,678,901,234 ofill
	then: ofillbfr 10 0 do  o@++ q#123,456,789,012,345 !=  loop  10 0 do  o@++ 0 !=  loop
		  h@ −1 !=
		  depth 0 !=
	test;

	test: ofill: checks if ofill fails gracefully on an empty stack.
	given sp0!
	when: capture{ ofill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ofill: checks if ofill fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 ofill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: ofill: checks if ofill fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 ofill }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: ofill: checks if ofill fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 ofill }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: ofill: checks if ofill fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 ofill }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Looks up byte c in byte buffer of length # at address a.  Returns 0 if not found, otherwise index u of the location *after* the first occurrence. )
: cfind ( a # c -- u )  CFIND, ;

	test: cfind: checks if the byte is found in the buffer.
	given sp0!  create cfindbfr  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0AH c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  −1 c,
	when: cfindbfr 10 0AH cfind
	then: 9 !=
		  depth 0 !=
	test;

	test: cfind: checks if the byte is not found in the buffer.
	given sp0!
	when: cfindbfr 10 0BH cfind
	then: 0 !=
		  depth 0 !=
	test;

	test: cfind: checks if cfind fails gracefully on an empty stack.
	given sp0!
	when: capture{ cfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: cfind: checks if cfind fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 cfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: cfind: checks if cfind fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 cfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: cfind: checks if cfind fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 cfind }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: cfind: checks if cfind fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 cfind }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Looks up word w in word buffer of length # at address a.  Returns 0 if not found, otherwise index u of the location *after* the first occurrence. )
: wfind ( a # w -- u )  WFIND, ;

	test: wfind: checks if the word is found in the buffer.
	given sp0!  create wfindbfr  0 w,  0 w,  4711 w,  0 w,  0 w,  0 w,  0 w,  0 w,  4711 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  −1 w,
	when: cfindbfr 10 4711 wfind
	then: 3 !=
		  depth 0 !=
	test;

	test: wfind: checks if the word is not found in the buffer.
	given sp0!
	when: wfindbfr 10 4722 wfind
	then: 0 !=
		  depth 0 !=
	test;

	test: wfind: checks if wfind fails gracefully on an empty stack.
	given sp0!
	when: capture{ wfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: wfind: checks if wfind fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 wfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: wfind: checks if wfind fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 wfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: wfind: checks if wfind fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 wfind }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: wfind: checks if wfind fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 wfind }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Looks up double-word d in dword buffer of length # at address a.  Returns 0 if not found, otherwise index u of the location *after* the first occurrence. )
: dfind ( a # d -- u )  DFIND, ;

	test: dfind: checks if the double-word is found in the buffer.
	given sp0!  create dfindbfr  0 d,  0 d,  4711 d,  0 d,  0 d,  0 d,  0 d,  0 d,  d#123,456,789,012 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  0 d,  −1 d,
	when: dfindbfr 10 d#123,456,789,012 dfind
	then: 9 !=
		  depth 0 !=
	test;

	test: dfind: checks if the double-word is not found in the buffer.
	given sp0!
	when: dfindbfr 10 711 dfind
	then: 0 !=
		  depth 0 !=
	test;

	test: dfind: checks if dfind fails gracefully on an empty stack.
	given sp0!
	when: capture{ dfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: dfind: checks if dfind fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 dfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: dfind: checks if dfind fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 dfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: dfind: checks if dfind fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 dfind }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: dfind: checks if dfind fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 dfind }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Looks up quad-word q in qword buffer of length # at address a.  Returns 0 if not found, otherwise index u of the location *after* the first occurrence. )
: qfind ( a # q -- u )  QFIND, ;

	test: qfind: checks if the quad-word is found in the buffer.
	given sp0!  create qfindbfr  0 q,  0 q,  4711 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  d#123,456,789,012 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  0 q,  −1 q,
	when: qfindbfr 10 d#123,456,789,012 qfind
	then: 10 !=
		  depth 0 !=
	test;

	test: qfind: checks if the quad-word is not found in the buffer.
	given sp0!
	when: qfindbfr 10 711 qfind
	then: 0 !=
		  depth 0 !=
	test;

	test: qfind: checks if qfind fails gracefully on an empty stack.
	given sp0!
	when: capture{ qfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: qfind: checks if qfind fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 qfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: qfind: checks if qfind fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 qfind }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: qfind: checks if qfind fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 qfind }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: qfind: checks if qfind fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 qfind }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Moves byte buffer of length # at address sa to location ta, which must be allocated.  Overlapping areas are correctly taken care of. )
: cmove ( sa ta # -- )  CMOVE, ;

	test: cmove: checks if buffer is partially copied.
	given sp0!  create cmovetgt  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  0 c,  −1 c,
		  create cmovesrc  1 c,  2 c,  3 c,  4 c,  5 c,  6 c,  7 c,  8 c,  9 c,  10 c,  11 c,  12 c,  13 c,  14 c,  15 c,  16 c,  17 c,  18 c,  19 c,  20 c,  −1 c,
	when: cmovesrc cmovetgt 10 cmove
	then: cmovetgt cmovesrc 10 0 do  swap c@++ rot c@++ rot !=  loop  drop  10 0 do  c@++ 0 !=  loop
		  b@ -1 !=
		  depth 0 !=
	test;

	test: cmove: checks if reverse move is applied when danger of overriding.
	given sp0!
	when: cmovesrc dup 1 + 10 cmove
	then: 12 10 9 8 7 6 5 4 3 2 1 1 cmovesrc 12 for  c@++ rot !=  next  drop
		  depth 0 !=
	test;

	test: cmove: checks if cfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ cmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: cmove: checks if cmove fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 cmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: cmove: checks if cmove fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 1 $20 cmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: cmove: checks if cmove fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −1 $20 cmove }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: cmove: checks if cmove fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 −1 $20 cmove }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Moves word buffer of length # at address sa to location ta, which must be allocated.  Overlapping areas are correctly taken care of. )
: wmove ( sa ta # -- )  WMOVE, ;

	test: wmove: checks if buffer is partially copied.
	given sp0!  create wmovetgt  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  0 w,  −1 w,
		  create wmovesrc  1 w,  2 w,  3 w,  4 w,  5 w,  6 w,  7 w,  8 w,  9 w,  10 w,  11 w,  12 w,  13 w,  14 w,  15 w,  16 w,  17 w,  18 w,  19 w,  20 w,  −1 w,
	when: wmovesrc wmovetgt 10 wmove
	then: wmovetgt wmovesrc 10 0 do  swap w@++ rot w@++ rot !=  loop  drop  10 0 do  w@++ 0 !=  loop
		  s@ -1 !=
		  depth 0 !=
	test;

	test: wmove: checks if reverse move is applied when danger of overriding.
	given sp0!
	when: wmovesrc dup 2 + 10 wmove
	then: 12 10 9 8 7 6 5 4 3 2 1 1 wmovesrc 12 for  w@++ rot !=  next  drop
		  depth 0 !=
	test;

	test: wmove: checks if cfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ wmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: wmove: checks if wmove fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 wmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: wmove: checks if wmove fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 1 $20 wmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: wmove: checks if wmove fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 −1 $20 wmove }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: wmove: checks if wmove fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 -1 $20 wmove }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Moves double-word buffer of length # at address sa to location ta, which must be allocated.  Overlapping areas are correctly taken care of. )
: dmove ( sa ta # -- )  DMOVE, ;

	test: dmove: checks if buffer is partially copied.
	given sp0!  create dmovetgt  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  d#0 d,  i#−1 d,
		  create wmovesrc  d#1 d,  d#2 d,  d#3 d,  d#4 d,  d#5 d,  d#6 d,  d#7 d,  d#8 d,  d#9 d,  d#10 d,  d#11 d,  d#12 d,  d#13 d,  d#14 d,  d#15 d,  d#16 d,  d#17 d,  d#18 d,  d#19 d,  d#20 d,  i#−1 d,
	when: dmovesrc dmovetgt 10 dmove
	then: dmovetgt dmovesrc 10 0 do  swap d@++ rot d@++ rot d!=  loop  drop  10 0 do  d@++ d#0 d!=  loop
		  i@ i#-1 !=
		  depth 0 !=
	test;

	test: dmove: checks if reverse move is applied when danger of overriding.
	given sp0!
	when: dmovesrc dup d# + 10 dmove
	then: d#12 d#10 d#9 d#8 d#7 d#6 d#5 d#4 d#3 d#2 d#1 d#1 dmovesrc 12 for  d@++ rot d!=  next  drop
		  depth 0 !=
	test;

	test: dmove: checks if cfill fails gracefully on an empty stack.
	given sp0!
	when: capture{ dmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: dmove: checks if dmove fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 dmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: dmove: checks if dmove fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 1 $20 dmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: dmove: checks if dmove fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 -2 $20 dmove }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: dmove: checks if dmove fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 -1 $20 dmove }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Moves quad-word buffer of length # at address sa to location ta, which must be allocated.  Overlapping areas are correctly taken care of. )
: qmove ( sa ta # -- )  QMOVE, ;

	test: qmove: checks if buffer is partially copied.
	given sp0!  create qmovetgt  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  q#0 d,  i#−1 d,
		  create wmovesrc  q#1 d,  q#2 d,  q#3 d,  q#4 d,  q#5 d,  q#6 d,  q#7 d,  q#8 d,  q#9 d,  q#10 d,  q#11 d,  q#12 d,  q#13 d,  q#14 d,  q#15 d,  q#16 d,  q#17 d,  q#18 d,  q#19 d,  q#20 d,  i#−1 d,
	when: qmovesrc qmovetgt 10 qmove
	then: qmovetgt qmovesrc 10 0 do  swap q@++ rot q@++ rot q!=  loop  drop  10 0 do  q@++ q#0 q!=  loop
		  ℓ@ ℓ#-1 !=
		  depth 0 !=
	test;

	test: qmove: checks if reverse move is applied when danger of overriding.
	given sp0!
	when: qmovesrc dup q# + 10 qmove
	then: q#12 q#10 q#9 q#8 q#7 q#6 q#5 q#4 q#3 q#2 q#1 q#1 qmovesrc 12 for  q@++ rot d!=  next  drop
		  depth 0 !=
	test;

	test: qmove: checks if qmove fails gracefully on an empty stack.
	given sp0!
	when: capture{ qmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: qmove: checks if qmove fails gracefully on an stack with only one entry.
	given sp0!
	when: capture{ $20 qmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

	test: qmove: checks if qmove fails gracefully on an stack with only two entries.
	given sp0!
	when: capture{ 10000 $20 qmove }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 2 !=
	test;

	test: qmove: checks if qmove fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 10000 $20 qmove }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: qmove: checks if qmove fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 10000 $20 qmove }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

=== UTF-8 String Operations ===

( Reads the next unicode character uc from UTF8-buffer at address a and increments cursor a. )
: c$@++ ( a -- a' uc )  FETCHUC$INC, ;

	test: c$@++: checks if all UCs are found.
	given sp0!  create c$@++-buffer  "Hэllo, Wørld ㊣!",
	when: '!' '㊣' bl 'd' 'l' 'r' 'ø' 'W' bl ',' 'o' 'l' 'l' 'э' 'H' c$@++-buffer c$@++
	then: dup 15 !=
		  0 do  c$@++ rot !=  loop  drop
		  depth 0 !=
	test;

	test: c$@++: checks if c$@++ fails gracefully on an empty stack.
	given sp0!
	when: capture{ c$@++ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Returns length # of UTF-8 string at address a — in characters, not bytes. )
: c$@ ( a -- # )  c$@++ nip ;

	test: c$@: checks if length is correct.
	given sp0!  create c$@-buffer  "Hэllo, Wørld ㊣!",
	when: c$@-buffer c$@
	then: 15 !=
		  depth 0 !=
	test;

	test: c$@: checks if c$@ fails gracefully on an empty stack.
	given sp0!
	when: capture{ c$@ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Returns address a and length # of UTF-8 string a$. )
: $count ( a$ -- a # )  c$@++ ;

	test: count: checks if the correct unsigned byte is returned and the address is incremented.
	given sp0!  4711
	when: sp@ count
	then: 103 !=
		  sp@ cell+ 1 + !=
		  depth 0 !=
	test;

	test: count: checks if count fails gracefully on an empty stack.
	given sp0!
	when: capture{ count }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: count: checks if count fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 count }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: count: checks if count fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 count }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;
	
( Returns address a and length # of zero terminated UTF-8 string aº. )
: 0count ( aº -- a # )  dup begin c$++ 0= until  1− over − ;

	test: 0count: checks if the byte is found in the buffer.
	given sp0!  create 0count-buffer  "Hello, world" count 0 do  c$@++ c$,  loop  .--  0 c,
	when: 0count-buffer 0count
	then: 9 !=
		  depth 0 !=
	test;

( Compares two UTF-8 strings at addresses a1 and a2. )
: $= ( a1 a2 -- ? )  c$@++ rot c$@++ rot over = if  0 udo  c$@++ rot c$@++ rot = unlessever  2 #drop false exitloop  then  loop  2 #drop true exit  then  3 #drop false ;

	test: $=: checks that both buffers are equal.
	given sp0!  create $=-buffer_a1  "Hэllo, Wørld ㊣!",  create $=-buffer_a2  "Hэllo, Wørld ㊣!",
	when: $=-buffer_a1 $=-buffer_a2 $=
	then: true !=
		  depth 0 !=
	test;

	test: $=: checks that both buffers are different in content.
	given sp0!  create $=-buffer_b1  "Hэllo, Wørld ㊣!",  create $=-buffer_b2  "Hэllo, Wørld ㊢!",
	when: $=-buffer_b1 $=-buffer_b2 $=
	then: false !=
		  depth 0 !=
	test;

	test: $=: checks that second buffer is smaller than first one.
	given sp0!  create $=-buffer_c1  "Hэllo, Wørld ㊣!",  create $=-buffer_c2  "Hэllo, Wørld ㊣",
	when: $=-buffer_c1 $=-buffer_c2 $=
	then: false !=
		  depth 0 !=
	test;

	test: $=: checks that second buffer is bigger than first one.
	given sp0!  create $=-buffer_c1  "Hэllo, Wørld ㊣",  create $=-buffer_c2  "Hэllo, Wørld ㊣!",
	when: $=-buffer_c1 $=-buffer_c2 $=
	then: false !=
		  depth 0 !=
	test;

	test: $=: checks if $= fails gracefully on an empty stack.
	given sp0!
	when: capture{ $= }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: $=: checks if $= fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ $=-buffer_c1 $= }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: $=: checks if $= fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 $= }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: $=: checks if $= fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 $= }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

( Reads the next unicode character uc from UTF8-buffer at address a with length # and advances the cursor.  If the buffer is empty, returns 0 and does not advance the cursor. )
: c$>> ( a # -- a' #−1 uc || a 0 -- a 0 0 )  dup unlessever  dup  else  swap c$@++ rot 1 − swap  then ;

	test: c$>>: checks if all UCs are found.
	given sp0!  create c$>>-buffer  "Hэllo, Wørld ㊣!",
	when: '!' '㊣' bl 'd' 'l' 'r' 'ø' 'W' bl ',' 'o' 'l' 'l' 'э' 'H' c$>>-buffer c$>>
	then: dup 15 !=
		  begin  dup  while  c$>> -rot 2swap !=  repeat
		  0 !=  drop
		  depth 0 !=
	test;

	test: c$>>: checks if function dies nothing with an empty buffer.
	given sp0!
	when: c$>>-buffer 0 c$>>
	then: 0 !=  c$>>-buffer !=
		  depth 0 !=
	test;

	test: c$>>: checks if c$>> fails gracefully on an empty stack.
	given sp0!
	when: capture{ c$>> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c$>>: checks if c$>> fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ c$>>-buffer_c1 c$>> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: c$>>: checks if c$>> fails gracefully with a bad address.
	given sp0!
	when: capture{ -1 1 c$>> }capture
	then: captured@ InvalidMemoryAddress !=
		  depth 0 !=
	test;

	test: c$>>: checks if c$>> fails gracefully with a null pointer.
	given sp0!
	when: capture{ 0 1 c$>> }capture
	then: captured@ NullPointer !=
		  depth 0 !=
	test;

=== Conditions ===

( Tests if x is 0. )
: 0= ( x -- x=0 )  ISZERO, ;

	test: 0=: checks if the test correctly discovers zero.
	given sp0!
	when: 0 0=
	then: true !=
		  depth 0 !=
	test;

	test: 0=: checks if the test correctly discovers non-zero (< 0).
	given sp0!
	when: −42 0=
	then: false !=
		  depth 0 !=
	test;

	test: 0=: checks if the test correctly discovers non-zero (> 0).
	given sp0!
	when: 4711 0=
	then: false !=
		  depth 0 !=
	test;

	test: 0=: checks if 0= fails gracefully on an empty stack.
	given sp0!
	when: capture{ 0= }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x is not 0. )
: 0≠ ( x -- x≠0 )  ISNOTZERO, ;  alias 0−  alias 0-  alias 0<>

	test: 0≠: checks if the test correctly discovers zero.
	given sp0!
	when: 0 0≠
	then: false !=
		  depth 0 !=
	test;

	test: 0≠: checks if the test correctly discovers non-zero (< 0).
	given sp0!
	when: −42 0≠
	then: true !=
		  depth 0 !=
	test;

	test: 0≠: checks if the test correctly discovers non-zero (> 0).
	given sp0!
	when: 4711 0≠
	then: true !=
		  depth 0 !=
	test;

	test: 0≠: checks if 0≠ fails gracefully on an empty stack.
	given sp0!
	when: capture{ 0≠ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x is negative / less than zero. )
: 0< ( x -- x<0 )  ISNEGATIVE, ;

	test: 0<: checks if the test correctly discovers zero.
	given sp0!
	when: 0 0<
	then: false !=
		  depth 0 !=
	test;

	test: 0<: checks if the test correctly discovers negative.
	given sp0!
	when: −42 0<
	then: true !=
		  depth 0 !=
	test;

	test: 0<: checks if the test correctly discovers positive.
	given sp0!
	when: 4711 0<
	then: false !=
		  depth 0 !=
	test;

	test: 0<: checks if 0< fails gracefully on an empty stack.
	given sp0!
	when: capture{ 0> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x is positive / greater than zero. )
: 0> ( x -- x>0 )  ISPOSITIVE, ;

	test: 0>: checks if the test correctly discovers zero.
	given sp0!
	when: 0 0>
	then: false !=
		  depth 0 !=
	test;

	test: 0>: checks if the test correctly discovers negative.
	given sp0!
	when: −42 0>
	then: false !=
		  depth 0 !=
	test;

	test: 0>: checks if the test correctly discovers positive.
	given sp0!
	when: 4711 0>
	then: true !=
		  depth 0 !=
	test;

	test: 0>: checks if 0> fails gracefully on an empty stack.
	given sp0!
	when: capture{ 0> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x less than or equal to zero. )
: 0≤ ( x -- x≤0 )  ISNOTPOSITIVE, ;  alias 0<=

	test: 0≤: checks if the test correctly discovers zero.
	given sp0!
	when: 0 0≤
	then: true !=
		  depth 0 !=
	test;

	test: 0≤: checks if the test correctly discovers negative.
	given sp0!
	when: −42 0≤
	then: true !=
		  depth 0 !=
	test;

	test: 0≤: checks if the test correctly discovers positive.
	given sp0!
	when: 4711 0≤
	then: false !=
		  depth 0 !=
	test;

	test: 0≤: checks if 0≤ fails gracefully on an empty stack.
	given sp0!
	when: capture{ 0≤ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x is greater than or equal to zero. )
: 0≥ ( x -- x≥0 )  ISNOTNEGATIVE, ;  alias 0>=

	test: 0≥: checks if the test correctly discovers zero.
	given sp0!
	when: 0 0≥
	then: true !=
		  depth 0 !=
	test;

	test: 0≥: checks if the test correctly discovers negative.
	given sp0!
	when: −42 0≥
	then: false !=
		  depth 0 !=
	test;

	test: 0≥: checks if the test correctly discovers positive.
	given sp0!
	when: 4711 0≥
	then: true !=
		  depth 0 !=
	test;

	test: 0≥: checks if 0≥ fails gracefully on an empty stack.
	given sp0!
	when: capture{ 0≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x is equal to y. )
: = ( x y -- x=y )  ISEQUAL, ;

	test: =: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 =
	then: true !=
		  depth 0 !=
	test;

	test: =: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 =
	then: false !=
		  depth 0 !=
	test;

	test: =: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 ≠
	then: false !=
		  depth 0 !=
	test;

	test: =: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 =
	then: false !=
		  depth 0 !=
	test;

	test: =: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 ≠
	then: false !=
		  depth 0 !=
	test;

	test: =: checks if = fails gracefully on an empty stack.
	given sp0!
	when: capture{ = }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: =: checks if = fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 = }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if x is not equal to y. )
: ≠ ( x y -- x≠y )  ISNOTEQUAL, ;  alias <>

	test: ≠: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 ≠
	then: false !=
		  depth 0 !=
	test;

	test: ≠: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 ≠
	then: true !=
		  depth 0 !=
	test;

	test: ≠: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 ≠
	then: true !=
		  depth 0 !=
	test;

	test: ≠: checks if the test correctly discovers greater.
	given sp0!
	when: 4711 −42 ≠
	then: true !=
		  depth 0 !=
	test;

	test: ≠: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 ≠
	then: true !=
		  depth 0 !=
	test;

	test: ≠: checks if ≠ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ≠ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ≠: checks if ≠ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 ≠ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if n1 is less than n2. )
: < ( n1 n2 -- n1<n2 )  ISLESS, ;

	test: <: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 <
	then: false !=
		  depth 0 !=
	test;

	test: <: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 <
	then: true !=
		  depth 0 !=
	test;

	test: <: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 <
	then: true !=
		  depth 0 !=
	test;

	test: <: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 <
	then: false !=
		  depth 0 !=
	test;

	test: <: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 <
	then: false !=
		  depth 0 !=
	test;

	test: <: checks if < fails gracefully on an empty stack.
	given sp0!
	when: capture{ < }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: <: checks if < fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 < }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if u1 is less than u2. )
: u< ( u1 u2 -- u1<u2 )  ISBELOW, ;

	test: u<: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 u<
	then: false !=
		  depth 0 !=
	test;

	test: u<: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 u<
	then: false !=
		  depth 0 !=
	test;

	test: u<: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 u<
	then: true !=
		  depth 0 !=
	test;

	test: u<: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 u<
	then: true !=
		  depth 0 !=
	test;

	test: u<: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 u<
	then: false !=
		  depth 0 !=
	test;

	test: u<: checks if u< fails gracefully on an empty stack.
	given sp0!
	when: capture{ u< }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u<: checks if u< fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 u< }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if n1 is greater than n2. )
: > ( n1 n2 -- n1>n2 )  ISGREATER, ;

	test: >: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 >
	then: false !=
		  depth 0 !=
	test;

	test: >: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 >
	then: false !=
		  depth 0 !=
	test;

	test: >: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 >
	then: false !=
		  depth 0 !=
	test;

	test: >: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 >
	then: true !=
		  depth 0 !=
	test;

	test: >: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 >
	then: true !=
		  depth 0 !=
	test;

	test: >: checks if > fails gracefully on an empty stack.
	given sp0!
	when: capture{ > }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: >: checks if > fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 > }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if u1 is greater than u2. )
: u> ( u1 u2 -- u1>u2 )  ISABOVE, ;

	test: u>: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 u>
	then: false !=
		  depth 0 !=
	test;

	test: u>: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 u>
	then: true !=
		  depth 0 !=
	test;

	test: u>: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 u>
	then: false !=
		  depth 0 !=
	test;

	test: u>: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 u>
	then: false !=
		  depth 0 !=
	test;

	test: u>: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 u>
	then: true !=
		  depth 0 !=
	test;

	test: u>: checks if u> fails gracefully on an empty stack.
	given sp0!
	when: capture{ u> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u>: checks if u> fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 u> }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if n1 is less than or equal to n2. )
: ≤ ( n1 n2 -- n1≤n2 )  ISNOTGREATER, ;  alias <=

	test: ≤: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 ≤
	then: true !=
		  depth 0 !=
	test;

	test: ≤: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 ≤
	then: true !=
		  depth 0 !=
	test;

	test: ≤: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 ≤
	then: true !=
		  depth 0 !=
	test;

	test: ≤: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 ≤
	then: false !=
		  depth 0 !=
	test;

	test: ≤: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 ≤
	then: false !=
		  depth 0 !=
	test;

	test: ≤: checks if ≤ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ≤ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ≤: checks if ≤ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 ≤ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if u1 is less than or equal to u2. )
: u≤ ( u1 u2 -- u1≤u2 )  ISNOTABOVE, ;  alias u<=

	test: u≤: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 u≤
	then: true !=
		  depth 0 !=
	test;

	test: u≤: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 u≤
	then: false !=
		  depth 0 !=
	test;

	test: u≤: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 u≤
	then: true !=
		  depth 0 !=
	test;

	test: u≤: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 u≤
	then: true !=
		  depth 0 !=
	test;

	test: u≤: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 u≤
	then: false !=
		  depth 0 !=
	test;

	test: u≤: checks if u≤ fails gracefully on an empty stack.
	given sp0!
	when: capture{ u≤ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u≤: checks if u≤ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 u≤ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if n1 is greater than or equal to n2. )
: ≥ ( n1 n2 -- n1≥n2 )  ISNOTLESS, ;  alias >=

	test: ≥: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 ≥
	then: true !=
		  depth 0 !=
	test;

	test: ≥: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 ≥
	then: false !=
		  depth 0 !=
	test;

	test: ≥: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 ≥
	then: false !=
		  depth 0 !=
	test;

	test: ≥: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 ≥
	then: true !=
		  depth 0 !=
	test;

	test: ≥: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 ≥
	then: true !=
		  depth 0 !=
	test;

	test: ≥: checks if ≥ fails gracefully on an empty stack.
	given sp0!
	when: capture{ ≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: ≥: checks if ≥ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 ≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Tests if u1 is greater than or equal to u2. )
: u≥ ( u1 u2 -- u1≥u2 )  ISNOTBELOW, ;  alias u>=

	test: u≥: checks if the test correctly discovers equality.
	given sp0!
	when: 42 42 u≥
	then: true !=
		  depth 0 !=
	test;

	test: u≥: checks if the test correctly discovers less.
	given sp0!
	when: −42 42 u≥
	then: true !=
		  depth 0 !=
	test;

	test: u≥: checks if the test correctly discovers absolute less.
	given sp0!
	when: 42 4711 u≥
	then: false !=
		  depth 0 !=
	test;

	test: u≥: checks if the test correctly discovers greater.
	given sp0!
	when: 42 −4711 u≥
	then: false !=
		  depth 0 !=
	test;

	test: u≥: checks if the test correctly discovers absolute greater.
	given sp0!
	when: 4711 42 u≥
	then: true !=
		  depth 0 !=
	test;

	test: u≥: checks if u≥ fails gracefully on an empty stack.
	given sp0!
	when: capture{ u≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

	test: u≥: checks if u≥ fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 0 u≥ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

=== Code Invocation ===

( Executes code at address a. )
: execute ( a -- )  EXECUTE, ;

	test: execute: checks if the correct address is invoked.
	given sp0!
	when: 42 4711 ' + >cf execute
	then: 4753 !=
		  depth 0 !=
	test;

	test: execute: checks if execute fails gracefully on an empty stack.
	given sp0!
	when: capture{ execute }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

( Executes code of word at address @w. )
: execWord ( @w -- )  EXECUTEWORD, ;

	test: execWord: checks if the correct address is invoked.
	given sp0!
	when: 42 4711 ' + execWord
	then: 4753 !=
		  depth 0 !=
	test;

	test: execWord: checks if execWord fails gracefully on an empty stack.
	given sp0!
	when: capture{ execWord }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 0 !=
	test;

=== Module Initialization ===

( Initializes the vocabulary from initialization structure at address @initstr when loading. )
private init : init ( @initstr -- @initstr )  dup @PSP + @ 8− PSP0 !  dup @RSP + @ 32+ RSP0 ! ;

vocabulary;