( Copyright © 2020 by Coradec GmbH.  All rights reserved. )

****** FORTH vocabulary for FORCE-64 (linux 4.19.0-5-amd64) ******

import RichForce

alias: @ q@ ( a -- x )                                ( fetch cell x from address a )
alias: 2@ o@ ( a -- x₂ x₁ )                           ( fetch double cell x₂x₁ from address a )
alias: ! q! ( x a -- )                                ( store cell x at address a )
alias: 2! o! ( x₂ x₁ a -- )                           ( store double cell x₂x₁ at address a )
alias: !x++ !q++ ( a x -- a+x# )                      ( store cell x at address a and increment the address )
alias: !++ q!++ ( x a -- a+x# )                       ( store cell x at address a and increment the address )
alias: --!x --!q ( a x -- a−x# )                      ( decrement the address and store cell x at address a−8 )
alias: −−!x −−!q ( a x -- a−x# )                      ( decrement the address and store cell x at address a−8 )
alias: --! --q! ( x a -- a−x# )                       ( decrement the address and store cell x at address a−8 )
alias: −−! −−q! ( x a -- a−x# )                       ( decrement the address and store cell x at address a−8 )
alias: !2++ !o++ ( a x₂ x₁ -- a+2×x# )                ( store double cell x₁x₂ at address a and increment the address )
alias: 2!++ o!++ ( x₂ x₁ a -- a+2×x# )                ( store double cell x₁x₂ at address a and increment the address )
alias: --!2 --!o ( a x₂ x₁ -- a−2×x# )                ( decrement the address and store doube cell x₁x₂ at address a−16 )
alias: −−!2 −−!o ( a x₂ x₁ -- a−2×x# )                ( decrement the address and store doube cell x₁x₂ at address a−16 )
alias: --2! --o! ( x₂ x₁ a -- a−2×x# )                ( decrement the address and store doube cell x₁x₂ at address a−16 )
alias: −−2! −−o! ( x₂ x₁ a -- a−2×x# )                ( decrement the address and store doube cell x₁x₂ at address a−16 )
alias: fill qfill ( a # x -- )                        ( fill block with length # at address a with cell x )
alias: find qfind ( a # x -- )                        ( lookup first occurrence of cell x in block at a with length # )
alias: move qmove ( sa ta # -- )                      ( move # cells from block at sa to block at ta )

: 0! ( a -- )  alias off                              ( store 0 / false at address a )
: −1! ( a -- )  alias -1!  alias off                  ( store -1 / true at address a )
