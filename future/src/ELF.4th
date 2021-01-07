( @/system/os/linux/ELF )

vocabulary: /system/os/linux/ELF implements /system/os/EFF

: transform ( source$ object$ -- )
  ELF# createTable @TARGET-VOC !
  loadModule  newest-vocabulary@ transformModule  saveObject ;

vocabulary;