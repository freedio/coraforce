( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Open Mode model for FORCE-linux 4.19.0-5-amd64 ******

enumset: OpenMode
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  symbol ForRead                                        ( File [to be] opened for reading: O_RDONLY )
  symbol ForWrite                                       ( File [to be] opened for writing: O_WRONLY )
  symbol Append                                         ( append mode: O_APPEND )
  symbol Asynch                                         ( asynchronous [signal based] access: O_ASYNC )
  symbol CloseOnExecute                                 ( close file on execute: O_CLOEXEC )
  symbol Create                                         ( create file if it doesn't exist: O_CREAT )
  symbol Direct                                         ( prevent system caching: O_DIRECT )
  symbol Directory                                      ( file must be a directory: O_DIRECTORY )
  symbol DataSync                                       ( data must be written to hardware before write returns: O_DYNC )
  symbol LargeFile                                      ( File is larger than older limit: O_LARGEFILE )
  symbol NoAccessTime                                   ( don't update last access time if possible: O_NOATIME )
  symbol NoControlTTY                                   ( Device does not become controlling device: O_NOCTTY )
  symbol NoFollow                                       ( prevents following symbol links: _NOFOLLOW )
  symbol NonBlocking                                    ( open file in non-blocking mode, if possible: O_NONBLOCK|O_NDELAY )
  symbol PathOnly                                       ( file is only path, not really opened: O_PATH )
  symbol FullSync                                       ( like DataSync, but includes also metadata: O_SYNC )
  symbol TempFile                                       ( interpret file as directory and create tempfile in it: O_TMPFILE )
  symbol Truncate                                       ( truncate file to 0 if it is writable: O_TRUNC )



  === Methods ===



enumset;
