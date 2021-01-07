\ IntClauses vocabulary for GForth Linux-4.19 amd64

vocabulary IntClauses
also IntClauses definitions
needs IntClauseMacros.gf

: #drop ( ... #u -- )  [UDROP], ;
: #nip ( ... #u -- )  [UNIP], ;
: #pick ( ... #u -- xu )  [UPICK], ;

: #+ ( n1 #n2 -- n1+n2 )  [PLUS], ;
: #- ( n1 #n2 -- n1-n2 )  [MINUS], ; alias #−
: #* ( n1 #n2 -- n1*n2 )  [TIMES], ; alias #×
: #u* ( u1 #u2 -- u1*u2 )  [UTIMES], ; alias #u×
: #/ ( n1 #n2 -- n1/n2 )  [THROUGH], ;
: #u/ ( u1 #u2 -- u1/u2 )  [UTHROUGH], ;
: #mod ( n1 #n2 -- n1%n2 )  [MODULO], ;
: #umod ( u1 #u2 -- u1%u2 )  [MODULO], ;
: #/mod ( n1 #n2 -- n1%n2 n1/n2 )  [QUOTREM], ;
: #u/mod ( u1 #u2 -- u1%u2 u1/u2 )  [UQUOTREM], ;
: #<< ( n #u -- n<<u )  [LSHIFT], ; alias #u<<
: #>> ( n #u -- n>>u )  [RSHIFT], ;
: #u>> ( u1 #u2 -- u1>>u2 )  [URSHIFT], ;
: #<u< ( u1 #u2 -- u1<u<u2 )  [LROT], ;
: #>u> ( u1 #u2 -- u1>u>u2 )  [RROT], ;
: #and ( u1 #u2 -- u1⊙u2 )  [AND], ;
: #or ( u1 #u2 -- u1⊕u2 )  [OR], ;
: #xor ( u1 #u2 -- u1¤u2 )  [XOR], ;
: #andn ( u1 #u2 -- u1⊙~u2 )  [ANDN], ;
: #bit? ( u ## -- ? )  [BT], ;
: #bit+? ( u ## -- u' ? ) [BTS], ;
: #bit-? ( u ## -- u' ? ) [BTR], ;  alias ##−?
: #bit~? ( u ## -- u' ? ) [BTC], ;  alias ##×?
: #bit+ ( u ## -- u' ) [BS], ;
: #bit- ( u ## -- u' ) [BR], ;  alias ##−
: #bit~ ( u ## -- u' ) [BC], ;  alias ##×
: #bit ( # -- u ) [BIT], ;

: #c! ( a #c -- )  [CSTORE], ;
: #w! ( a #w -- )  [WSTORE], ;
: #d! ( a #d -- )  [DSTORE], ;
: #q! ( a #q -- )  [QSTORE], ; alias #!
: #c!++ ( a #c -- a+1 )  [CSTOREINC], ;
: #w!++ ( a #w -- a+2 )  [WSTOREINC], ;
: #d!++ ( a #d -- a+4 )  [DSTOREINC], ;
: #q!++ ( a #q -- a+8 )  [QSTOREINC], ; alias #!++

: #c+! ( a #c -- )  [ADDC], ;
: #w+! ( a #w -- )  [ADDW], ;
: #d+! ( a #d -- )  [ADDD], ;
: #q+! ( a #q -- )  [ADDQ], ; alias #+!
: #c-! ( a #c -- )  [SUBC], ; alias #c−!  alias #b-!  alias #b−!
: #w-! ( a #w -- )  [SUBW], ; alias #w−!  alias #s-!  alias #s−!
: #d-! ( a #d -- )  [SUBD], ; alias #d−!  alias #i-!  alias #d−!
: #q-! ( a #q -- )  [SUBQ], ; alias #q−!  alias #-!  alias #−!
: #q@-! ( a #q -- )  [FETCHSUBQ], ; alias #q@−!  alias #@-!  alias #@−!
: #b*! ( a #b -- )  [MPYB], ; alias #b×!
: #c*! ( a #c -- )  [MPYC], ; alias #c×!
: #s*! ( a #s -- )  [MPYS], ; alias #s×!
: #w*! ( a #w -- )  [MPYW], ; alias #w×!
: #i*! ( a #i -- )  [MPYI], ; alias #i×!
: #d*! ( a #d -- )  [MPYD], ; alias #d×!
: #l*! ( a #l -- )  [MPYL], ; alias #q×!  alias #*!  alias #×!
: #q*! ( a #q -- )  [MPYQ], ; alias #q×!  alias #u*!  alias #u×!
: #b/! ( a #b -- )  [DIVB], ; alias #b÷!
: #c/! ( a #c -- )  [DIVD], ; alias #c÷!
: #s/! ( a #s -- )  [DIVS], ; alias #s÷!
: #w/! ( a #w -- )  [DIVW], ; alias #w÷!
: #i/! ( a #i -- )  [DIVI], ; alias #i÷!
: #d/! ( a #d -- )  [DIVD], ; alias #d÷!
: #l/! ( a #l -- )  [DIVL], ; alias #l÷!  alias #/!  alias #÷!
: #q/! ( a #q -- )  [DIVQ], ; alias #q÷!  alias #u/!  alias #u÷!
: #bmod! ( a #b -- )  [MODC], ; alias #b%!
: #cmod! ( a #c -- )  [MODC], ; alias #c%!
: #smod! ( a #s -- )  [MODW], ; alias #s%!
: #wmod! ( a #w -- )  [MODW], ; alias #w%!
: #imod! ( a #i -- )  [MODD], ; alias #i%!
: #dmod! ( a #d -- )  [MODD], ; alias #d%!
: #lmod! ( a #l -- )  [MODQ], ; alias #l%!  alias #mod!  alias #%!
: #qmod! ( a #q -- )  [MODQ], ; alias #q%!  alias #umod!  alias #u%!
: #cand! ( a #c -- )  [ANDC], ;
: #wand! ( a #w -- )  [ANDW], ;
: #dand! ( a #d -- )  [ANDD], ;
: #qand! ( a #q -- )  [ANDQ], ; alias #and!
: #cor! ( a #c -- )  [ORC], ;
: #wor! ( a #w -- )  [ORW], ;
: #dor! ( a #d -- )  [ORD], ;
: #qor! ( a #q -- )  [ORQ], ; alias #or!
: #cxor! ( a #c -- )  [XORC], ;
: #wxor! ( a #w -- )  [XORW], ;
: #dxor! ( a #d -- )  [XORD], ;
: #qxor! ( a #q -- )  [XORQ], ; alias #xor!
: #b<<! ( a #u -- )  [BSAL], ;
: #b>>! ( a #u -- )  [BSAR], ;
: #c<<! ( a #u -- )  [CSHL], ;
: #c>>! ( a #u -- )  [CSHR], ;
: #s<<! ( a #u -- )  [SSAL], ;
: #s>>! ( a #u -- )  [SSAR], ;
: #w<<! ( a #u -- )  [WSHL], ;
: #w>>! ( a #u -- )  [WSHR], ;
: #i<<! ( a #u -- )  [ISAL], ;
: #i>>! ( a #u -- )  [ISAR], ;
: #d<<! ( a #u -- )  [DSHL], ;
: #d>>! ( a #u -- )  [DSHR], ;
: #l<<! ( a #u -- )  [LSAL], ; alias #<<!
: #l>>! ( a #u -- )  [LSAR], ; alias #>>!
: #q<<! ( a #u -- )  [QSHL], ; alias #u<<!
: #q>>! ( a #u -- )  [QSHR], ; alias #u>>!
: #v<<! ( a #u -- )  [VSAL], ;
: #v>>! ( a #u -- )  [VSAR], ;
: #o<<! ( a #u -- )  [OSHL], ;
: #o>>! ( a #u -- )  [OSHR], ;

: #bit@ ( a #u -- ? )  [BTAT], ;
: #bit+@ ( a #u -- ? )  [BTSAT], ;
: #bit-@ ( a #u -- ? )  [BTRAT], ; alias #bit−@
: #bit~@ ( a #u -- ? )  [BTCAT], ; alias #bit×@
: #bit+! ( a #u -- )  [BSAT], ;
: #bit-! ( a #u -- )  [BRAT], ; alias #bit−!
: #bit~! ( a #u -- )  [BCAT], ; alias #bit×!

: #cells ( #u -- u*cell )  [CELLS], ;
: #cells+ ( #u -- u*cell )  [CELLSPLUS], ;

: #+> ( a # #u -- a+u #-u )  [ADVANCE], ;
: #u*+ ( u1 u2 #u3 -- u1*u3+u2 )  [UNUMBUILD], ;
: #u*+! ( u1 a #u2 -- )  [UNUMBUILDAT], ;

------
: #= ( x1 #x2 -- x1=x2 )  [ISEQUAL], ;
: #≠ ( x1 #x2 -- x1≠x2 )  [ISNOTEQUAL], ; alias #<>
: #< ( n1 #n2 -- n1<n2 )  [ISLESS], ;
: #≥ ( n1 #n2 -- n1≥n2 )  [ISNOTLESS], ; alias #>=
: #> ( n1 #n2 -- n1>n2 )  [ISGREATER], ;
: #≤ ( n1 #n2 -- n1≤n2 )  [ISNOTGREATER], ; alias #<=
: #u< ( u1 #u2 -- u1<u2 )  [ISBELOW], ;
: #u≥ ( u1 #u2 -- u1≥u2 )  [ISNOTBELOW], ; alias #u>=
: #u> ( u1 #u2 -- u1>u2 )  [ISABOVE], ;
: #u≤ ( u1 #u2 -- u1≤u2 )  [ISNOTABOVE], ; alias #u<=
------

: #=if ( x1 #x2 -- )  [IFEQUAL], ;
: #≠if ( x1 #x2 -- )  [IFNOTEQUAL], ; alias #<>if
: #<if ( n1 #n2 -- )  [IFLESS], ;
: #≥if ( n1 #n2 -- )  [IFNOTLESS], ; alias #>=if
: #>if ( n1 #n2 -- )  [IFGREATER], ;
: #≤if ( n1 #n2 -- )  [IFNOTGREATER], ; alias #<=if
: #u<if ( u1 #u2 -- )  [IFBELOW], ;
: #u≥if ( u1 #u2 -- )  [IFNOTBELOW], ; alias #u>=if
: #u>if ( u1 #u2 -- )  [IFABOVE], ;
: #u≤if ( u1 #u2 -- )  [IFNOTABOVE], ; alias #u<=if
: #=?if ( x1 #x2 -- )  [DUPIFEQUAL], ;
: #≠?if ( x1 #x2 -- )  [DUPIFNOTEQUAL], ; alias #<>if
: #<?if ( n1 #n2 -- )  [DUPIFLESS], ;
: #≥?if ( n1 #n2 -- )  [DUPIFNOTLESS], ; alias #>=if
: #>?if ( n1 #n2 -- )  [DUPIFGREATER], ;
: #≤?if ( n1 #n2 -- )  [DUPIFNOTGREATER], ; alias #<=if
: #u<?if ( u1 #u2 -- )  [DUPIFBELOW], ;
: #u≥?if ( u1 #u2 -- )  [DUPIFNOTBELOW], ; alias #u>=if
: #u>?if ( u1 #u2 -- )  [DUPIFABOVE], ;
: #u≤?if ( u1 #u2 -- )  [DUPIFNOTABOVE], ; alias #u<=if
: ##?if ( u ## -- )  [BTIF], ;
: ##+?if ( u ## -- )  [BTSIF], ;
: ##-?if ( u ## -- )  [BTRIF], ;  alias ##−?if
: ##~?if ( u ## -- )  [BTCIF], ;  alias ##×?if
: #=ifever ( x1 #x2 -- )  [IFEVEREQUAL], ;
: #≠ifever ( x1 #x2 -- )  [IFEVERNOTEQUAL], ; alias #<>if
: #<ifever ( n1 #n2 -- )  [IFEVERLESS], ;
: #≥ifever ( n1 #n2 -- )  [IFEVERNOTLESS], ; alias #>=if
: #>ifever ( n1 #n2 -- )  [IFEVERGREATER], ;
: #≤ifever ( n1 #n2 -- )  [IFEVERNOTGREATER], ; alias #<=if
: #u<ifever ( u1 #u2 -- )  [IFEVERBELOW], ;
: #u≥ifever ( u1 #u2 -- )  [IFEVERNOTBELOW], ; alias #u>=if
: #u>ifever ( u1 #u2 -- )  [IFEVERABOVE], ;
: #u≤ifever ( u1 #u2 -- )  [IFEVERNOTABOVE], ; alias #u<=if
: #=?ifever ( x1 #x2 -- )  [DUPIFEVEREQUAL], ;
: #≠?ifever ( x1 #x2 -- )  [DUPIFEVERNOTEQUAL], ; alias #<>if
: #<?ifever ( n1 #n2 -- )  [DUPIFEVERLESS], ;
: #≥?ifever ( n1 #n2 -- )  [DUPIFEVERNOTLESS], ; alias #>=if
: #>?ifever ( n1 #n2 -- )  [DUPIFEVERGREATER], ;
: #≤?ifever ( n1 #n2 -- )  [DUPIFEVERNOTGREATER], ; alias #<=if
: #u<?ifever ( u1 #u2 -- )  [DUPIFEVERBELOW], ;
: #u≥?ifever ( u1 #u2 -- )  [DUPIFEVERNOTBELOW], ; alias #u>=if
: #u>?ifever ( u1 #u2 -- )  [DUPIFEVERABOVE], ;
: #u≤?ifever ( u1 #u2 -- )  [DUPIFEVERNOTABOVE], ; alias #u<=if
: ##?ifever ( u ## -- )  [BTIF], ;
: ##+?ifever ( u ## -- )  [BTSIF], ;
: ##-?ifever ( u ## -- )  [BTRIF], ;  alias ##−?if
: ##~?ifever ( u ## -- )  [BTCIF], ;  alias ##×?if
: #=unless ( x1 #x2 -- )  [IFNOTEQUAL], ;
: #≠unless ( x1 #x2 -- )  [IFEQUAL], ; alias #<>unless
: #<unless ( n1 #n2 -- )  [IFNOTLESS], ;
: #≥unless ( n1 #n2 -- )  [IFLESS], ; alias #>=unless
: #>unless ( n1 #n2 -- )  [IFNOTGREATER], ;
: #≤unless ( n1 #n2 -- )  [IFGREATER], ; alias #<=unless
: #u<unless ( u1 #u2 -- )  [IFNOTBELOW], ;
: #u≥unless ( u1 #u2 -- )  [IFBELOW], ; alias #u>=unless
: #u>unless ( u1 #u2 -- )  [IFNOTABOVE], ;
: #u≤unless ( u1 #u2 -- )  [IFABOVE], ; alias #u<=unless

: #=unlessever ( x1 #x2 -- )  [IFEVERNOTEQUAL], ;
: #≠unlessever ( x1 #x2 -- )  [IFEVEREQUAL], ; alias #<>unlessever
: #<unlessever ( n1 #n2 -- )  [IFEVERNOTLESS], ;
: #≥unlessever ( n1 #n2 -- )  [IFEVERLESS], ; alias #>=unlessever
: #>unlessever ( n1 #n2 -- )  [IFEVERNOTGREATER], ;
: #≤unlessever ( n1 #n2 -- )  [IFEVERGREATER], ; alias #<=unlessever
: #u<unlessever ( u1 #u2 -- )  [IFEVERNOTBELOW], ;
: #u≥unlessever ( u1 #u2 -- )  [IFEVERBELOW], ; alias #u>=unlessever
: #u>unlessever ( u1 #u2 -- )  [IFEVERNOTABOVE], ;
: #u≤unlessever ( u1 #u2 -- )  [IFEVERABOVE], ; alias #u<=unlessever

: #=?unless ( x1 #x2 -- )  [DUPIFNOTEQUAL], ;
: #≠?unless ( x1 #x2 -- )  [DUPIFEQUAL], ; alias #<>unless
: #<?unless ( n1 #n2 -- )  [DUPIFNOTLESS], ;
: #≥?unless ( n1 #n2 -- )  [DUPIFLESS], ; alias #>=unless
: #>?unless ( n1 #n2 -- )  [DUPIFNOTGREATER], ;
: #≤?unless ( n1 #n2 -- )  [DUPIFGREATER], ; alias #<=unless
: #u<?unless ( u1 #u2 -- )  [DUPIFNOTBELOW], ;
: #u≥?unless ( u1 #u2 -- )  [DUPIFBELOW], ; alias #u>=unless
: #u>?unless ( u1 #u2 -- )  [DUPIFNOTABOVE], ;
: #u≤?unless ( u1 #u2 -- )  [DUPIFABOVE], ; alias #u<=unless

: #=?unlessever ( x1 #x2 -- )  [DUPIFEVERNOTEQUAL], ;
: #≠?unlessever ( x1 #x2 -- )  [DUPIFEVEREQUAL], ; alias #<>unlessever
: #<?unlessever ( n1 #n2 -- )  [DUPIFEVERNOTLESS], ;
: #≥?unlessever ( n1 #n2 -- )  [DUPIFEVERLESS], ; alias #>=unlessever
: #>?unlessever ( n1 #n2 -- )  [DUPIFEVERNOTGREATER], ;
: #≤?unlessever ( n1 #n2 -- )  [DUPIFEVERGREATER], ; alias #<=unlessever
: #u<?unlessever ( u1 #u2 -- )  [DUPIFEVERNOTBELOW], ;
: #u≥?unlessever ( u1 #u2 -- )  [DUPIFEVERBELOW], ; alias #u>=unlessever
: #u>?unlessever ( u1 #u2 -- )  [DUPIFEVERNOTABOVE], ;
: #u≤?unlessever ( u1 #u2 -- )  [DUPIFEVERABOVE], ; alias #u<=unlessever

: ##?unless ( u ## -- )  [BTUNLESS], ;
: ##+?unless ( u ## -- )  [BTSUNLESS], ;
: ##-?unless ( u ## -- )  [BTRUNLESS], ;  alias ##−?unless
: ##~?unless ( u ## -- )  [BTCUNLESS], ;  alias ##×?unless

: #.s ( -- )  [DEBUGLIT], ;

previous
