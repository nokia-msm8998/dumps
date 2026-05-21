#!/system/bin/sh

umask 022

request_feature=$1
request_path=$2

tombstore_dir=/data/tombstones/
anr_dir=/data/anr/
case $request_feature in
     anr)
     if [ -d "$anr_dir" ]; then
         cd $anr_dir
         recent_created_file=$(ls -tc | head -n1)
         cp -rf $recent_created_file $request_path
     fi
     ;;

     tombstones)
     if [ -d "$tombstore_dir" ]; then
         cd $tombstore_dir
         recent_created_file=$(ls -tc | head -n1)
         request_path=$(getprop persist.vendor.hsm.tombstone.filepath)
         cp -rf $recent_created_file $request_path
     fi
     ;;

     kernel_dynamic_logs)
        request_cmd=$(getprop persist.vendor.hsm.kerdynalog.requestcmd)
        eval $request_cmd
     ;;
esac
