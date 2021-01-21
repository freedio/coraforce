( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Semaphore Operation model model for FORCE-linux 4.19.0-5-amd64 ******

structure: SemOp
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  U4 val Index                  ( Target semaphore number )
  U4 val Operation              ( Op-Code )
  U4 val Flags                  ( Flags )



  === Methods ===

public:
  construct: new ( semix op SemOpFlags -- )  my Flags!  my Operation!  my Index! ;
static:
  : Array ( SemOp .. SemOp #SemOp -- ★SemOps #SemOp )  ( create a semaphore operation array from the @Semop on the parameter stack )
    trip >x SemOpSize u* allocate dup >x swap 0 udo  SemOpSize 2dup + 4 -roll cmove  loop  drop x> x> ;

structure;
