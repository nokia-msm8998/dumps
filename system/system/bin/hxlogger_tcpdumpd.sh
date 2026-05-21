#!/system/bin/sh

umask 022

request_operation=$(getprop persist.vendor.hsm.tcpdumpd.operation)
request_path=$(getprop persist.vendor.hsm.tcpdumpd.filepath)

if [ "$request_operation" = "start" ]; then
    request_interface=$(getprop persist.vendor.hsm.tcpdumpd.interface)
    tcpdump -i $request_interface -w $request_path
fi

if [ "$request_operation" = "stop" ]; then
    pkill -x tcpdump
fi
