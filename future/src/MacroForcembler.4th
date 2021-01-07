






: BTSTSET, ( x # -- x ? )  LOCK  RAX 0 [RSP] BTS  RAX RAX SBB ;  ( do we need the LOCK?  the stack should not be shared with other processes! )
