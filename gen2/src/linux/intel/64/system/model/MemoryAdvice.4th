( Copyright © 2020 by Coradec GmbH.  All rights reserved )

****** The Linux Memory Advice model for FORCE-linux 4.19.0-5-amd64 ******

enum: MemoryAdvice
  package linux/intel/64/system/model
  requires force/intel/64/core/RichForce



  === Fields ===

--- conventional ---
  symbol Normal               ( normal use of memory: MADV_NORMAL )
  symbol Random               ( expect random access: MADV_RANDOM )
  symbol Sequential           ( expect sequential access → may trigger aggressive read-ahead / free after used: MADVSEQUENTIAL )
  symbol WillNeed             ( expect access in near future: MADV_WILLNEED )
  symbol DontNeed             ( don't expect access in near future: MADV_DONTNEED )
--- Linux specific ---
  symbol Remove               ( remove area and its backing store → punches a hole: MADV_REMOVE )
  symbol DontPass             ( don't pass this area down to children when forking: MADV_DONTFORK )
  symbol DoPass               ( do pass this area down to children when forking [default]: MADV_DOFORK )
  symbol HardwarePoison       ( poison the pages in the range, requires admin kernel with CONFIG_MEMORY_FAILURE: MADV_HWPOISON )
  symbol Mergeable            ( make available for merging, requires kernel with CONFIG_KSM: MADV_MERGEABLE )
  symbol Unmergeable          ( make unavailable for merging [default]: MADV_MERGEABLE )
  symbol SoftOffline          ( take area soft-offline, requires kernel with CONFIG_MEMORY_FAILURE: MADV_SOFT_OFFLINE )
  symbol HugePage             ( enable transparent huge pages, requires kernel with CONFIG_TRANSPARENT_HUGEPAGE: MADV_HUGEPAGE )
  symbol NoHugePage           ( disable transparent huge pages: MADV_NOHUGEPAGE )
  symbol NoCoreDump           ( exclude pages in the range from being sent to a core dump: MADV_DONTDUMP )
  symbol InCoreDump           ( include pages in the range in a core dump: MADV_DODUMP )
  symbol Free                 ( application no longer needs this memory range: MADV_FREE )
  symbol WipeOnFork           ( present this array as zeroes for children aftr fork: MADV_WIPEONFORK )
  symbol KeepOnFork           ( revert effect of WipeOnForm [default]: MADV_KEEPONFORK )



  === Methods ===



enum;
