( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux IPC Mode model for FORCE-linux 4.19.0-5-amd64 ******

package /linux/intel/64/system/model

U1 enumset: PollEventSet

  symbol In                   ( Data ready to read: POLLIN )
  symbol Except               ( An exception has occurred: POLLPRI )
  symbol Out                  ( Data can be written )
  symbol Closed               ( Peer closed socket or writing half pipe: POLLRDHUP )
  symbol Error                ( Error condition [revents only]: POLLERR )
  symbol Hangup               ( Peer closed connection [revents only]: POLLHUP )
  symbol Invalid              ( Request invalid, filedescr not open [revents only]: POLLNVAL )

enumset;
