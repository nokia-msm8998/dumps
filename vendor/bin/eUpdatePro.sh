#!/vendor/bin/sh
TAG="VM1-USB-Touch"

autoupdate=0

decrypt=`getprop vold.decrypt`
if [ "$decrypt" != "trigger_restart_framework" ]; then
	log -p v -t $TAG "vold.decrypt= $decrypt, wait system more stable"
	exit 0;
fi

fw=`getprop ro.vendor.hon.touch.ver.fw`
if [ "$fw" != "" ]; then
	exit 0;
fi

#pid=`/vendor/bin/pidof eGTouchD`
#if [ "$pid" != "" ]; then
#	log -p v -t $TAG "Kill unused eGTouchD"
#	/vendor/bin/kill $pid
#fi

if [ $autoupdate -ne 0 ]; then
	file_name=`ls /vendor/firmware/ETP*.exp`
	file_name=`echo $file_name | tr ' ' '\n' | sort -r | head -1`
	file_version=`echo "${file_name#*_V}" | sed -e 's/\.[^.]*$//'`


	log -p v -t $TAG "Start Checking FW"
	log -p v -t $TAG "TP OS file FW : $file_version"
fi

cd /data/vendor/eGTouch
#Read controller information (Retry mechanism)
retry=0
while [ $retry -ne 5 ]
do
	retry=$(( $retry + 1 ))
	rm UpdateLog*.csv
	/vendor/bin/eUpdatePro -C /dev/hidraw -i
	[ $? -eq 0 ] && break
	log -p v -t $TAG "Retry checking Controller FW"
done

IFS=","
tp_version=`cat UpdateLog*.csv |  while read Type TypeValue Model ModelValue Version VersionValue;
do
	if [ "$VersionValue" != "" ]; then
		if [ "$TypeValue" != "BootLoader" ]; then
			setprop ro.vendor.hon.touch.usb.type $TypeValue
		fi
		setprop ro.vendor.hon.touch.usb.model $ModelValue
		echo "${VersionValue}"
	fi
done`
rm UpdateLog*.csv
log -p v -t $TAG "TP Controller FW : $tp_version"

#Begin Auto Update
if [ $autoupdate -eq 0 ]; then
	log -p v -t $TAG "TP FW Skip auto-update"
	setprop ro.vendor.hon.touch.ver.fw $tp_version
        setprop ro.hon.touch.ver.fw $tp_version
	exit 0
elif [ "$file_version" != "$tp_version" ]; then
	log -p v -t $TAG "TP FW need to upgrade"
	setprop vendor.hon.usb.touch.autoupdate true
	setprop persist.hon.usb.touch.calibrated 0
else
	log -p v -t $TAG "TP FW Already up-to-date"
	setprop ro.vendor.hon.touch.ver.fw $tp_version
        setprop ro.hon.touch.ver.fw $tp_version
	exit 0
fi

cd /data/vendor/eGTouch
echo 0 > /sys/bus/platform/devices/soc:honeywell,mcu_touch@0/mcu_control
log -p v -t $TAG "Start Upgrading FW"
#Update FW to controller (Retry mechanism)
retry=0
while [ $retry -ne 5 ]
do
	retry=$(( $retry + 1 ))
	/vendor/bin/eUpdatePro -C /dev/hidraw -f $file_name
	#Read controller information
	rm UpdateLog*.csv
	/vendor/bin/eUpdatePro -C /dev/hidraw -i
	IFS=","
	cat UpdateLog*.csv |  while read Type TypeValue Model ModelValue Version VersionValue;
	do
		log -p v -t $TAG "Check FW version:$VersionValue"
		if [ "$VersionValue" == "$file_version" ]; then
			if [ "`getprop ro.vendor.hon.touch.usb.type`" == "" ]; then
				setprop ro.vendor.hon.touch.usb.type $TypeValue
			fi
			setprop ro.vendor.hon.touch.ver.fw $VersionValue
                        setprop ro.hon.touch.ver.fw $VersionValue
			break
		fi
	done
	rm UpdateLog*.csv
	[ "`getprop ro.vendor.hon.touch.ver.fw`" == "$file_version" ] && break
done

log -p v -t $TAG "FW Update Done"
echo 1 > /sys/bus/platform/devices/soc:honeywell,mcu_touch@0/mcu_control

setprop vendor.hon.usb.touch.autoupdate false
