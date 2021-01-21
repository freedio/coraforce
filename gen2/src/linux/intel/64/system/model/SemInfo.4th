( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Semaphore Info model for FORCE-linux 4.19.0-5-amd64 ******

structure: SemInfo
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  N4 val #Mappings                          ( Numbe of entries in semaphore map: semmap )
  N4 val Max#Sets                           ( Maximum number of of semaphore sets: semmni )
  N4 val Max#Semaphores                     ( Maximum number of semaphores in all sets: semmns )
  N4 val MaxUndo                            ( System-wide maximum number of undo structures: semmnu )
  N4 val Max#Semaphores/Set                 ( Maximum number of semaphores per set: semmsl )
  N4 val Max#Operations                     ( Maximum number of operations for 'operateOn': semopm )
  N4 val Max#Undo/Process                   ( Maximum number of undo structures per process: semume )
  N4 val Undo#  alias Total#Sets            ( Size of the Undo structure: semusz / alias: curr total # of semaphore sets / system )
  N4 val MaxValue                           ( Maximum semaphore value: semvmx )
  N4 val MaxAdjustment  alias Total#Sems    ( Maximum value that can be recorded for semaphore adjustment / alias: current ... )
                                            ( ... total number of semaphores in the system )


  === Methods ===


structure;
