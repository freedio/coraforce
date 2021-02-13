( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Core Module for FORCE-linux 4.19.0-5-amd64 ******

package force/intel/64/core
import RichForce

vocabulary: Core



=== REPL (Read-Eval-Print-Loop) ===

--- Loop ---

: REPL ( -- )  begin  readWord notEmpty? while  EVALUATOR @ execute  repeat  drop ;

vocabulary;
