#!/system/bin/sh

umask 022

if [ "`getprop sys.boot_completed`" != "1" ]; then
    log -p i -t "HON-POW" "wait for sys.boot_completed"
    sleep 10;
fi

if [ -z "`getprop ro.com.google.gmsversion`" ]; then
    log -p i -t "HON-POW" "NON-GMS version, skip Doze mode setting"
    exit
fi

if [ "$1" == "enable" ];
then
    dumpsys deviceidle enable
else
    dumpsys deviceidle disable
fi

log -p i -t "HON-POW" "Doze mode on/off: $1"
