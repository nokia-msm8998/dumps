#!/vendor/bin/sh
TAG="VM1-USB-Touch"
cfg_file=/vendor/firmware/vm1a_mxt1664t3.raw

STATUS_CFG=0
STATUS_MODE=1

get_usb_info () {
	bus_num=`cat /sys/bus/usb/devices/1-1.1/busnum `
	device_num=`cat /sys/bus/usb/devices/1-1.1/devnum`
	echo usb:$bus_num-$device_num
}

get_file_cfg_ver () {
	if [ -f $1 ]; then
		ver=`cat $1 |  while read Object Index Length Maj Min In_Maj In_Min Mode;
		do
			if [ "$Object" == "0026" ]; then
				echo $Maj.$Min.$In_Maj.$In_Min
			fi
		done`
		echo $ver
	else
		echo ""
	fi
}

get_tp_cfg_ver () {
	ver=`mxt-app -d $( get_usb_info ) -R -T38 -r0 -n4`
	echo ${ver:0:2}.${ver:3:2}.${ver:6:2}.${ver:9:2}
}

get_tp_dex_ver () {
	ver=`mxt-app -d $( get_usb_info ) -R -T38 -r0 -n4`
	echo $((0x${ver:0:2})).$((0x${ver:3:2})).$((0x${ver:6:2})).$((0x${ver:9:2}))
}

get_tp_mode () {
	echo $((0x`mxt-app -d $( get_usb_info ) -R -T38 -r4 -n1`))
}

get_tp_hw_dex_ver () {
	ver=`mxt-app -d $( get_usb_info ) -R -r0 -n2`
	echo $((0x${ver:0:2})).$((0x${ver:3:2}))
}

get_tp_fw_ver () {
	fw_ver=`mxt-app -d $( get_usb_info ) -R -n1 -r2`
	fw_build=`mxt-app -d $( get_usb_info ) -R -n1 -r3`
	echo ${fw_ver:0:1}.${fw_ver:1:1}.${fw_build:0:2}
}

update_cfg () {
	mode=$1

	if [ $mode -eq 0 ]; then
		file=$cfg_file
	elif [ $mode -eq 1 ]; then
		file=${cfg_file:0:31}_heavy_glove${cfg_file:31:4}
	fi

	if [ -f $file ]; then
		status=$2
		log -p v -t $TAG "TP Start Updating"
		count=0
		if [ $status -eq $STATUS_CFG ]; then
			cfg_version=$( get_file_cfg_ver $file )
			while [ $count -lt 5 ]; do
				mxt-app -d $( get_usb_info ) --load $file
				tp_version=$( get_tp_cfg_ver )
				[ "$cfg_version" == "$tp_version" ] && break
				log -p v -t $TAG "TP Update by ota"
			done
		elif [ $status -eq $STATUS_MODE ]; then
			while [ $count -lt 5 ]; do
				mxt-app -d $( get_usb_info ) --load $file
				tp_mode=$( get_tp_mode )
				[ "$tp_mode" == "$mode" ] && break
				count=$(( $count + 1 ))
				log -p v -t $TAG "TP Update by cfg selection"
			done
		fi
		if [ $count -lt 5 ]; then
			echo 0
		else
			echo 1
		fi
	else
		log -p v -t $TAG "Skip CFG Update, CFG File not exist"
		echo 1
	fi
}

update_fw () {
	setprop vendor.hon.usb.touch.autoupdate true
	while true; do
		mxt-app -d $( get_usb_info ) --flash $1
		fw_version=$( get_tp_fw_ver )
		[ "$2" == "$fw_version" ] && break
	done
	setprop vendor.hon.usb.touch.autoupdate false
}

tp_hub_status () {
	cat /sys/bus/i2c/devices/4-0008/touch_status
}

status=$1
if [ "$status" == "initial" ]; then
	fw_version=$( get_tp_fw_ver )
	log -p v -t $TAG "TP firmware version is $fw_version"

	#Get File FW Version
	file_name=`ls /vendor/firmware/maxtouch*.enc`
	file_name=`echo $file_name | tr ' ' '\n' | sort -r | head -1`
	file_version=`echo "${file_name#*_v}" | sed -e 's/\.[^.]*$//'`

	#If Need OTA Update
	if [ "$file_version" -eq "" ]; then
		log -p v -t $TAG "Skip FW Update, do not have any FW File"
	elif [ "$fw_version" \< "$file_version" ]; then
		if [ -f $file_name ]; then
			log -p v -t $TAG "TP FW OTA Update, update to $file_version"
			update_fw $file_name $file_version

			#Get TP FW Version again
			fw_version=$( get_tp_fw_ver )

		else
			log -p v -t $TAG "TP FW OTA Update, update to $file_version"
		fi
	elif [ "$fw_version" \> "$file_version" ]; then
		log -p v -t $TAG "File FW version is not the latest version"
	else
		log -p v -t $TAG "TP FW is Up to Date"
	fi

	#Get TP CFG Version
	tp_version=$( get_tp_cfg_ver )
	mode=$( get_tp_mode )
	log -p v -t $TAG "TP CFG Version is $tp_version, mode is $mode"

	cfg_version=$( get_file_cfg_ver $cfg_file )
	if [ "$cfg_version" == "" ]; then
		log -p v -t $TAG "Skip CFG Update, do not have any CFG File"
	elif [ "$tp_version" \< "$cfg_version" ]; then
		result=$( update_cfg $mode $STATUS_CFG )
		if [ $result -eq 1 ]; then
			log -p v -t $TAG "CFG Update Fail"
		fi
		log -p v -t $TAG "TP CFG OTA Update to $cfg_version"
	elif [ "$tp_version" \> "$cfg_version" ]; then
		log -p v -t $TAG "CFG File version is not the latest version"
	else
		log -p v -t $TAG "TP CFG is Up to Date"
	fi


	setprop vendor.hon.usb.touch.mode $( get_tp_mode )
	setprop ro.hon.touch.ver.hw $( get_tp_hw_dex_ver )
	setprop ro.hon.touch.ver.fw $( get_tp_fw_ver )
	setprop ro.hon.touch.ver.cfg $( get_tp_dex_ver )

elif [ "$status" == "cfg" ]; then
	change_mode=`getprop vendor.hon.usb.touch.mode`
	mode=$( get_tp_mode )
	if [ $change_mode -eq $mode ]; then
		log -p v -t $TAG "CFG Mode is the same, skip updating"
	else
		log -p v -t $TAG "CFG Start Updating..."
		result=$( update_cfg $change_mode $STATUS_MODE )
		if [ $result -eq 1 ]; then
			log -p v -t $TAG "CFG Update Fail"
			setprop vendor.hon.usb.touch.mode $( get_tp_mode )
		else
			log -p v -t $TAG "CFG Update to CFG Mode $change_mode"
		fi
	fi
	setprop vendor.hon.usb.touch.status normal

elif [ "$status" == "t7" ]; then
	screen_status=`getprop vendor.hon.usb.touch.exist`
	# log -p v -t $TAG "[$screen_status sequence]"
	if [ $screen_status -eq 2 ]; then #suspend
		t7=0000

	elif [ $screen_status -eq 1 ]; then #resume
		t7=2010

		#Wait Reset delay
		while true; do
			st=$( tp_hub_status )
			# log -p v -t $TAG "wait tp active:$st"
			if [ $st == 1 ]; then
				echo 0 > /sys/bus/i2c/devices/4-0008/touch_auto_suspend
				ret=$?
				if [ "$ret" != "0" ]; then
					log -p v -t $TAG "Disable Autosuspend Fail"
					continue
				else
					log -p v -t $TAG "Disable Autosuspend "
					break
				fi
			fi
			if [ $st == 2 ]; then
				if [ "$reset" == "1" ]; then
					log -p v -t $TAG "repeat reset, break"
					break;
				fi
				log -p v -t $TAG "Reset TP"
				echo 1 > /sys/bus/platform/devices/soc\:honeywell,mcu_touch@0/mcu_reset
				ret=$?
				if [ "$ret" != "0" ]; then
					log -p v -t $TAG "Reset TP Fail"
					continue
				else
					reset=1
					sleep 1
				fi

			fi
		done
	else	#Enable autosuspend
		echo 1 > /sys/bus/i2c/devices/4-0008/touch_auto_suspend
		exit 0
	fi

	#Change Sleep Mode
	# log -p v -t $TAG "tp status: $( tp_hub_status )"
	if [ "$reset" != "1" ]; then
		log -p v -t $TAG "Set T7 to $t7"
		mxt-app -d $( get_usb_info ) -W -T7 $t7
		ret=$?
		if [ "$ret" != "0" ]; then
			log -p v -t $TAG "Set T7 to $t7 Fail"
		fi
	fi

	#Enable Autosuspend for suspend sequence
	if [ $screen_status -eq 2 ]; then
		echo 1 > /sys/bus/i2c/devices/4-0008/touch_auto_suspend
		ret=$?
		if [ "$ret" != "0" ]; then
			log -p v -t $TAG "Enable Autosuspend Fail"
		else
			log -p v -t $TAG "Enable Autosuspend"
		fi
	fi

	# log -p v -t $TAG "[end $screen_status]"
fi
