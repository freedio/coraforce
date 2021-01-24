( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Shared Memory Information model for FORCE-linux 4.19.0-5-amd64 ******

structure: SharedMemoryInfo2
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

  N4 val #CurrentSegments         ( Number of current segments in use: shm_info.user_ids )
  U8 val Total#SharedPages        ( Total number of shared pages: shm_info.shm_tot )
  U8 val #ResidentPages           ( Number of resident shared pages: shm_info.shm_rss )
  U8 val #SwappedPages            ( Number of swapped shared pages: shm_info.shm_swp )
  U8 val #SwapAttempts            ( Unused since Linux 2.4: shm_info.swap_attempts )
  U8 val #SwapSuccesses           ( Unused since Linux 2.4: shm_info.swap_successes )



  === Methods ===


structure;
