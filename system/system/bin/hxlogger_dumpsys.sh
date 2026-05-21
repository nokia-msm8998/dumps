#!/system/bin/sh

umask 022

request_feature=$1
separator="####################################################################################################################"

case $request_feature in
     audio)
        request_audio_filePath=$(getprop persist.vendor.hsm.dumpsys.audio.log.filePath)
        request_audio_filePath=${request_audio_filePath}audio_log.txt
        dumpsys audio >> $request_audio_filePath
        echo $separator >> $request_audio_filePath
     ;;

     wifi)
        request_wifi_filePath=$(getprop persist.vendor.hsm.dumpsys.wifi.log.filePath)
        request_wifi_filePath=${request_wifi_filePath}wifi_log.txt
        dumpsys wifi >> $request_wifi_filePath
        echo $separator >> $request_wifi_filePath
     ;;

     location)
        request_location_filePath=$(getprop persist.vendor.hsm.dumpsys.location.log.filePath)
        request_location_filePath=${request_location_filePath}location_log.txt
        dumpsys location >> $request_location_filePath
        echo $separator >> $request_location_filePath
     ;;

     battery)
        request_battery_filePath=$(getprop persist.vendor.hsm.dumpsys.battery.log.filePath)
        request_battery_filePath=${request_battery_filePath}battery_log.txt
        dumpsys battery >> $request_battery_filePath
        echo $separator >> $request_battery_filePath
     ;;

     wifiscanner)
        request_wifiscanner_filePath=$(getprop persist.vendor.hsm.dumpsys.wifiscanner.log.filePath)
        request_wifiscanner_filePath=${request_wifiscanner_filePath}wifiscanner.txt
        request_wifiscanner_filePath=${request_wifiscanner_filePath%.*}_log.txt
        dumpsys wifiscanner >> $request_wifiscanner_filePath
        echo $separator >> $request_wifiscanner_filePath
     ;;

     nfc)
       request_nfc_filePath=$(getprop persist.vendor.hsm.dumpsys.nfc.log.filePath)
       request_nfc_filePath=${request_nfc_filePath}nfc_log.txt
       dumpsys nfc >> $request_nfc_filePath
       echo $separator >> $request_nfc_filePath
     ;;

     power)
       request_power_filePath=$(getprop persist.vendor.hsm.dumpsys.power.log.filePath)
       request_power_filePath=${request_power_filePath}power_log.txt
       dumpsys power >> $request_power_filePath
       echo $separator >> $request_power_filePath

     ;;
esac
