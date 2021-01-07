class: Object
  public static : size ( -- u )  mySize ;
  protected : _new ( class -- x:Object )  mySize cell+ 4+ dup alloc  tuck 0 cfill  tuck ! ;
;

class: String  Object extension
  U4 Array var Buffer

  private static : newbare ( $ -- x:String )  String _new ;
  static : new ( $ -- x:String )  newbare  ... ;
  : charAt ( u self -- c )  2dup Size @ u< if  Buffer @ elementAt ;
  : length ( self -- u )  Buffer Size @ ;
  : append ( a:String self -- b:String )
;

class: Array of Element  Object extension
  private U4 var Size
  private Element var Buffer

  static : new ( # -- x:Element Array )  Element Array _new  2dup Size !  swap Element size u* zalloc swap Buffer ! ;
  : element@ ( # self -- x:Element )  2dup Size @ u< unless  ArrayIndexOutOfBoundsException throw  then  swap Element size u* swap Buffer + @ ;
  : size ( self -- u )  Size @ ;
;

class: MutableArray of Element  Element Array extension
  : element! ( x:Element # self -- )  2dup Size @ u< unless  ArrayIndexOutOfBoundsException throw  then  swap Element size u* swap Buffer + ! ;
;

class: List of Element
;

class: Map of: Key Value ;
;

-------------- Variant with me, my --------------

class: String  Object extension
  U4 Array var Buffer

  private static : newbare ( $ -- x:String )  String _new ;
  static : new ( $ -- x:String )  newbare  ... ;
  : charAt ( u -- c )  dup my Buffer size @ u< if  my Buffer @ elementAt ;
  : length ( -- u )  my Buffer size @ ;
  : append ( a:String -- b:String )  newbare 2over
;
