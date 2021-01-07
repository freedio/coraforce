vocabulary: force/lang/forcen

( Selects the least of # signed numbers. )
: nmin ( n# ... n1 # -- n )  maxcellv lit swap 0 udo  min  loop ;

	test: nmin: checks if the result is arithmetically correct.
	given sp0!  4711 42 666 32687
	when: 4 nmin
	then: 42 !=
		  depth 0 !=
	test;

	test: nmin: checks if the result is arithmetically correct.
	given sp0!  -4711 42 666 32687
	when: 4 nmin
	then: -4711 !=
		  depth 0 !=
	test;

	test: nmin: checks if nmin can handle stack range 1.
	given sp0!  -4711 42 666 32687
	when: 1 nmin
	then: 32687 !=
		  depth 3 !=
	test;

	test: nmin: checks if nmin can handle stack range 0.
	given sp0!  -4711 42 666 32687
	when: capture{ 0 nmin }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: nmin: checks if nmin can handle negative stack range.
	given sp0!  -4711 42 666 32687
	when: capture{ -10 nmin }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: nmin: checks if nmin fails gracefully on an empty stack.
	given sp0!
	when: capture{ nmin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !0=
	test;

	test: nmin: checks if nmin fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 2 nmin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

	test: nmin: checks if nmin fails gracefully on a stack with not enough entries.
	given sp0!   1 2 3 4
	when: capture{ 5 nmin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Selects the greatest of # signed numbers. )
: nmax ( n# ... n1 # -- n )  mincellv lit swap 0 udo  max  loop ;

	test: nmax: checks if the result is arithmetically correct.
	given sp0!  4711 42 666 32687
	when: 4 nmax
	then: 32687 !=
		  depth 0 !=
	test;

	test: nmax: checks if the result is arithmetically correct.
	given sp0!  -4711 42 666 32687
	when: 4 nmax
	then: 32687 !=
		  depth 0 !=
	test;

	test: nmax: checks if nmax can handle stack range 1.
	given sp0!  -4711 42 666 32687
	when: 1 nmax
	then: 32687 !=
		  depth 3 !=
	test;

	test: nmax: checks if nmax can handle stack range 0.
	given sp0!  -4711 42 666 32687
	when: capture{ 0 nmax }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: nmax: checks if nmax can handle negative stack range.
	given sp0!  -4711 42 666 32687
	when: capture{ -10 nmax }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: nmax: checks if nmax fails gracefully on an empty stack.
	given sp0!
	when: capture{ nmax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !0=
	test;

	test: nmax: checks if nmax fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 2 nmax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

	test: nmax: checks if nmax fails gracefully on a stack with not enough entries.
	given sp0!   1 2 3 4
	when: capture{ 5 nmax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Selects the least of # unsigned numbers. )
: numin ( u# ... u1 # -- u )  -1 swap 0 udo  umin  loop ;

	test: numin: checks if the result is arithmetically correct.
	given sp0!  4711 42 666 32687
	when: 4 numin
	then: 42 !=
		  depth 0 !=
	test;

	test: numin: checks if the result is arithmetically correct.
	given sp0!  -4711 42 666 32687
	when: 4 numin
	then: 42 !=
		  depth 0 !=
	test;

	test: numin: checks if numin can handle stack range 1.
	given sp0!  -4711 42 666 32687
	when: 1 numin
	then: 32687 !=
		  depth 3 !=
	test;

	test: numin: checks if numin can handle stack range 0.
	given sp0!  -4711 42 666 32687
	when: capture{ 0 numin }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: numin: checks if numin can handle negative stack range.
	given sp0!  -4711 42 666 32687
	when: capture{ -10 numin }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: numin: checks if numin fails gracefully on an empty stack.
	given sp0!
	when: capture{ numin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !0=
	test;

	test: numin: checks if numin fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 2 numin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

	test: numin: checks if numin fails gracefully on a stack with not enough entries.
	given sp0!   1 2 3 4
	when: capture{ 5 numin }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Selects the greatest of # unsigned numbers. )
: numax ( u# ... u1 # -- u )  0 swap 0 udo  umax  loop ;

	test: numax: checks if the result is arithmetically correct.
	given sp0!  4711 42 666 32687
	when: 4 numax
	then: 32687 !=
		  depth 0 !=
	test;

	test: numax: checks if the result is arithmetically correct.
	given sp0!  -4711 42 666 32687
	when: 4 numax
	then: -4711 !=
		  depth 0 !=
	test;

	test: numax: checks if numax can handle stack range 1.
	given sp0!  -4711 42 666 32687
	when: 1 numax
	then: 32687 !=
		  depth 3 !=
	test;

	test: numax: checks if numax can handle stack range 0.
	given sp0!  -4711 42 666 32687
	when: capture{ 0 numax }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: numax: checks if numax can handle negative stack range.
	given sp0!  -4711 42 666 32687
	when: capture{ -10 numax }capture
	then: captured@ InvalidStackRange !=
		  depth 4 !=
	test;

	test: numax: checks if umax fails gracefully on an empty stack.
	given sp0!
	when: capture{ numax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !0=
	test;

	test: numax: checks if numax fails gracefully on a stack with only one entry.
	given sp0!
	when: capture{ 2 numax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

	test: numax: checks if numax fails gracefully on a stack with not enough entries.
	given sp0!   1 2 3 4
	when: capture{ 5 numax }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !1=
	test;

( Returns size # in bytes of n.  Note that size of n=0 will be reported as 0, so to get at least 1, use "1 max nsize" )
: nsize ( n -- n # )  NSIZE, ;

	test: nsize: checks if the test is correct for different numbers.
	given sp0!
	when: 0 nsize
		  1 nsize
		  10 nsize
		  100 nsize
		  1000 nsize
		  10000 nsize
		  100000 nsize
		  100000000 nsize
		  -1 nsize
		  -10000 nsize
		  10 rev
	then: 0 != 
		  1 !=
		  1 !=
		  1 !=
		  2 !=
		  3 !=
		  4 !=
		  1 !=
		  2 !=
		  depth 0 !=
	test;

	test: nsize: checks if nsize fails gracefully on an empty stack.
	given sp0!
	when: capture{ nsize }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !0=
	test;

( Returns size # in bytes of u.  Note that size of u=0 will be reported as 0, so to get at least 1, use "1 max usize" )
: usize ( n -- n # )  USIZE, ;

	test: usize: checks if the test is correct for different numbers.
	given sp0!
	when: 0 nsize
		  1 nsize
		  10 nsize
		  100 nsize
		  1000 nsize
		  10000 nsize
		  100000 nsize
		  100000000 nsize
		  -1 nsize
		  -10000 nsize
		  10 rev
	then: 0 != 
		  1 !=
		  1 !=
		  1 !=
		  2 !=
		  3 !=
		  4 !=
		  cell !=
		  cell !=
		  depth 0 !=
	test;

	test: usize: checks if usize fails gracefully on an empty stack.
	given sp0!
	when: capture{ usize }capture
	then: captured@ ParameterStackUnderflow !=
		  depth !0=
	test;

