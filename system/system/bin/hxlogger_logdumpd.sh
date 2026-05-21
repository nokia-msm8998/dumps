#!/system/bin/sh

umask 022

echo "HXLogger Copy initiated ..."

request_path=$(getprop persist.vendor.hsm.logdumpd.filepath)
logdump_path="$request_path/logdump.log"
echo $logdump_path
logdumpd -f $logdump_path -b all -v threadtime -D -d
    if [ -f "$logdump_path" ]; then
        echo "logdump if"
        cd $request_path
        toybox split -b 8m logdump.log logdump.log.
        rm -rf logdump.log
    fi
echo "Logdump completed"
