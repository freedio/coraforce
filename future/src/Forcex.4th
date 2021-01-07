vocabulary: force/lang/forcex

( Replaces second of stack with top of stack (drop dup). )
: smash ( x2 x1 -- x1 x1 )  SMASH, ;

	test: smash: checks if the 2OP is smashed.
	given sp0! 45645645 12345678
	when: smash
	then: !=
		  depth !0=
	test;

	test: smash: checks if smash fails gracefully on an empty stack.
	given sp0!
	when: capture{ smash }capture
	then: captured@ ParameterStackUnderflow !=
	test;

( Flips the first and third stack entry (-rot swap). )
: flip ( x3 x2 x1 -- x1 x2 x3 )  FLIP, ;

	test: flip: checks if the TOP and 3OP are exchanged.
	given sp0! 45645645 12345678 -9897363
	when: flip
	then: 45645645 !=
		  12345678 !=
		  -9897363 !=
		  depth !0=
	test;

	test: flip: checks if flip fails gracefully on an empty stack.
	given sp0!
	when: capture{ flip }capture
	then: captured@ ParameterStackUnderflow !=
	test;

( Swaps the second and third stack entry (rot swap). )
: slide ( x3 x2 x1 -- x2 x3 x1 )  SLIDE, ;

	test: slide: checks if the 2OP and 3OP are exchanged.
	given sp0! 45645645 12345678 -9897363
	when: slide
	then: -9897363 !=
		  45645645 !=
		  12345678 !=
		  depth !0=
	test;

	test: slide: checks if slide fails gracefully on an empty stack.
	given sp0!
	when: capture{ slide }capture
	then: captured@ ParameterStackUnderflow !=
	test;

( Drops second of stack pair. )
: 2nip ( y2 x2 y1 x1 -- y1 x1 )  2NIP, ;

	test: 2nip: checks if the sewcond stack pair is dropped.
	given sp0! 45645645 12345678 -9897363 222222222
	when: slide
	then: 222222222 !=
		  -9897363 !=
		  depth !0=
	test;

	test: 2nip: checks if 2nip fails gracefully on an empty stack.
	given sp0!
	when: capture{ 2nip }capture
	then: captured@ ParameterStackUnderflow !=
	test;

( Drops u cells. )
: udrop ( ... u -- )  UDROP, ;

	test: udrop: checks if u stack entries are dropped.
	given sp0! 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
	when: 5 udrop
	then: 12345678 !=
		  45645645 !=
		  depth !0=
	test;

	test: udrop: checks if udrop fails gracefully on an empty stack.
	given sp0!
	when: capture{ udrop }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: udrop: checks if udrop fails gracefully on an empty stack with u.
	given sp0!
	when: capture{ 3 udrop }capture
	then: captured@ ParameterStackUnderflow !=
	test;

( Reverses the order of u entries on the stack. )
: rev ( ... u -- )  REVSTACK, ;

	test: rev: checks if u stack entries are reversed (odd number).
	given sp0! 123 456 789 0 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666
	when: 7 rev
	then: 45645645 !=
		  12345678 !=
		  -9897363 !=
		  222222222 !=
		  -234265446 !=
		  55555555555 !=
		  666666666 !=
		  0 !=
		  879 !=
		  depth 2 !=
	test;

	test: rev: checks if u stack entries are reversed (even number).
	given sp0! 123 456 789 0 45645645 12345678 -9897363 222222222 -234265446 55555555555 666666666 98765432
	when: 8 rev
	then: 45645645 !=
		  12345678 !=
		  -9897363 !=
		  222222222 !=
		  -234265446 !=
		  55555555555 !=
		  666666666 !=
		  98765432 !=
		  0 !=
		  879 !=
		  depth 2 !=
	test;

	test: rev: checks if rev succeeds on an empty stack with 0.
	given sp0!  23 45 67
	when: 0 rev
	then: 67 !=
		  45 !=
		  23 !=
		  depth !0=
	test;

	test: rev: checks if rev fails gracefully on an empty stack.
	given sp0!
	when: capture{ rev }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: rev: checks if rev fails gracefully on an empty stack with u.
	given sp0!
	when: capture{ 3 rev }capture
	then: captured@ ParameterStackUnderflow !=
	test;

--- Bitops ---

( Tests if bit # is set in x. )
: bit? ( x # -- ? )  BCHK, ;

	test: bit?: checks if the result is correct.
	given sp0! 4711
	when: 9 bit?
	then: true !=
		  depth !0=
	test;

	test: bit?: checks if bit? fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit? }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit?: checks if bit? fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit? }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Tests if bit # is set in x, retaining x. )
: bit÷ ( x # -- x ? )  BTST, ;  alias bit/

	test: bit÷: checks if the result is correct.
	given sp0! 4711
	when: 9 bit?
	then: true !=
		  4711 !=
		  depth !0=
	test;

	test: bit÷: checks if bit÷ fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit÷ }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit÷: checks if bit÷ fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit÷ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Sets bit # in x. )
: bit+ ( x # -- x' )  BSET, ;

	test: bit+: checks if the result is correct when bit changes.
	given sp0! 4711
	when: 8 bit+
	then: 4967 !=
		  depth !0=
	test;

	test: bit+: checks if the result is correct when bit does not change.
	given sp0! 4711
	when: 5 bit+
	then: 4711 !=
		  depth !0=
	test;

	test: bit+: checks if bit+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit+ }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit+: checks if bit+ fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Clears bit # in x. )
: bit− ( x # -- x' )  BCLR, ;  alias bit-

	test: bit−: checks if the result is correct when bit changes.
	given sp0! 4711
	when: 9 bit−
	then: 4455 !=
		  depth !0=
	test;

	test: bit−: checks if the result is correct when bit does not change.
	given sp0! 4711
	when: 4 bit−
	then: 4711 !=
		  depth !0=
	test;

	test: bit−: checks if bit− fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit− }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit−: checks if bit− fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit− }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Flips bit # in x. )
: bit× ( x # -- x' )  BCHG, ;  alias bit*

	test: bit−: checks if the result is correct when bit turns off.
	given sp0! 4711
	when: 9 bit×
	then: 4455 !=
		  depth !0=
	test;

	test: bit×: checks if the result is correct when bit turns on.
	given sp0! 4711
	when: 8 bit+
	then: 4967 !=
		  depth !0=
	test;

	test: bit×: checks if bit× fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit× }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit×: checks if bit× fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit× }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Tests bit # in x and sets it.  This operation is not strictly atomic, but parallel-safe, because it operates on a stack cell, and the stack is not shared among threads and processes. )
: bit?+ ( x # -- x' ? )  BTSTSET, ;

	test: bit?+: checks if the result is correct when bit changes.
	given sp0! 4711
	when: 8 bit?+
	then: false
		  4967 !=
		  depth !0=
	test;

	test: bit?+: checks if the result is correct when bit does not change.
	given sp0! 4711
	when: 5 bit?+
	then: true !=
		  4711 !=
		  depth !0=
	test;

	test: bit?+: checks if bit?+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit?+ }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit?+: checks if bit?+ fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit?+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Tests bit # in x and clears it.  This operation is not strictly atomic, but parallel-safe, because it operates on a stack cell, and the stack is not shared among threads and processes. )
: bit?− ( x # -- x' ? )  BTSTCLR, ;  alias bit?-

	test: bit?−: checks if the result is correct when bit changes.
	given sp0! 4711
	when: 9 bit?−
	then: 4455 !=
		  depth !0=
	test;

	test: bit?−: checks if the result is correct when bit does not change.
	given sp0! 4711
	when: 8 bit?−
	then: false
		  4711 !=
		  depth !0=
	test;

	test: bit+: checks if bit+ fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit+ }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit+: checks if bit+ fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit+ }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

( Tests bit # in x and flips it.  This operation is not strictly atomic, but parallel-safe, because it operates on a stack cell, and the stack is not shared among threads and processes. )
: bit?× ( x # -- x' ? )  BTSTCHG, ;  alias bit?*

	test: bit?×: checks if the result is correct when bit turns off.
	given sp0! 4711
	when: 9 bit?−
	then: 4455 !=
		  depth !0=
	test;

	test: bit?×: checks if the result is correct when bit turns on.
	given sp0! 4711
	when: 8 bit?+
	then: false
		  4967 !=
		  depth !0=
	test;

	test: bit?×: checks if bit?× fails gracefully on an empty stack.
	given sp0!
	when: capture{ bit?× }capture
	then: captured@ ParameterStackUnderflow !=
	test;

	test: bit?×: checks if bit?× fails gracefully on a stack with only 1 entry.
	given sp0!  42
	when: capture{ bit?× }capture
	then: captured@ ParameterStackUnderflow !=
		  depth 1 !=
	test;

