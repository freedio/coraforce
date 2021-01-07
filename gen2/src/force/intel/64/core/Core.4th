( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Core Module for FORCE-linux 4.19.0-5-amd64 ******

vocabulary: Core  package force/intel/64/core
  requires force/intel/64/core/RichForce



=== REPL (Read-Eval-Print-Loop) ===

--- Loop ---

: REPL ( -- )  begin  readWord notEmpty? while  EVALUATOR @ execute  repeat  drop ;

vocabulary;
