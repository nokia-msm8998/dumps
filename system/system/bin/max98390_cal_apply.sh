#!/system/bin/sh
#Read Max98390 cal from EEPROM
var=`getprop ro.hsm.max98390l.troom`
#echo $var
cal=${var#*00000}
tinymix "Left DSM Ambient Temp" $cal
tinymix "Left DSM Ambient Temp"

var=`getprop ro.hsm.max98390r.troom`
#echo $var
cal=${var#*00000}
tinymix "Right DSM Ambient Temp" $cal
tinymix "Right DSM Ambient Temp"

var=`getprop ro.hsm.max98390l.rdc`
#echo $var
cal=${var#*00}
tinymix "Left DSM Rdc" $cal
tinymix "Left DSM Rdc"

var=`getprop ro.hsm.max98390r.rdc`
#echo $var
cal=${var#*00}
tinymix "Right DSM Rdc" $cal
tinymix "Right DSM Rdc"
