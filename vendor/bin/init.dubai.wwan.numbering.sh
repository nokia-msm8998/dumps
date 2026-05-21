#!/vendor/bin/sh

#Compliance versions
data_only=`getprop ro.hon.plat.dataonly`
if [ "$data_only" == "1" ]; then
    setprop ro.hsm.compliance.os.ver OS.07.001.DO
    setprop ro.hsm.compliance.mbn.ver MBN.03.002.DO
#    setprop ro.hsm.compliance.svn 01  moved to init.dubai.modem.configs_from_hlos.sh
else
    setprop ro.hsm.compliance.os.ver OS.07.001
    setprop ro.hsm.compliance.mbn.ver MBN.03.002
#    setprop ro.hsm.compliance.svn 03  moved to init.dubai.modem.configs_from_hlos.sh
fi
