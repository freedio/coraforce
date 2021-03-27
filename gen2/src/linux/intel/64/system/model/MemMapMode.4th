( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux MemMapMode model for FORCE-linux 4.19.0-5-amd64 ******

U4 enumset: MemMapMode
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  4 :base
  symbol Fixed                        ( map address is fixed: MAP_FIXED )
  symbol Anonymous                    ( anonymous area, not backed by a file: MAP_ANONYMOUS )
  symbol 32bit                        ( maps the area into the first 2GB of the memory address space: MAP_32BIT )
  1 skip
  symbol GrowsDown                    ( memory area is a stack: MAP_GROWSDOWN )
  4 skip
  symbol Locked                       ( locks the memory area ... dangerous: MAP_LOCKED )
  symbol NoSwap                       ( do not reserve swap space for this area: MAP_NORESERVE )
  symbol Populate                     ( populate [read-ahead] the area: MAP_POPULATE )
  symbol Nonblock                     ( prevent read-ahead: MAP_NONBLOCK )
  symbol Stack                        ( currently no effect, might be useful in the future: MAP_STACK )
  symbol HugeTable                    ( uses huge pages for allocation: MAP_HUGETBL )
  symbol Persistent                   ( special use: MAP_SYNC )
  symbol FixedFlexible                ( map fixed, unless collision, in which case allocation fails: MAP_FIXED_NOREPLACE )
  5 skip
  symbol Uninitialized                ( only for embedded devices: MAP_UNINITIALIZED )
  21 << 26 =symbol HugeTable2MB       ( uses 2MB pages: MAP_HUGE_2MB )
  31 << 26 =symbol HugeTable1GB       ( uses 1GB pages: MAP_HUGE_1G )



  === Methods ===



enumset;

------
Form various include files under /usr/include:

map type: 4 bits = base

fixed:          0x10
anonymous:      0x20
32bit:          0x40
growsdown:      0x100
locked:         0x2000
noreserve:      0x4000
populate:       0x8000
nonblock:       0x10000
stack:          0x20000
hugetbl:        0x40000
sync:           0x80000
fixednoreplace: 0x100000
uninitialized:  0x4000000

hugetbl_2mb:    21 << 26
hugetbl_1gb:    31 << 26
------
