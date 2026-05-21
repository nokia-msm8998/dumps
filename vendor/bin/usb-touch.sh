#!/vendor/bin/sh
TAG="VM1-USB-Touch"
log -p v -t $TAG "Detecting for VM1A..."
timer=0

if [ "`getprop ro.vendor.hon.touch.usb.vendor`" != "" ]; then
	exit 0
fi

#Detect I2C PCAP
if [ -e /dev/egalax_i2c ]; then
	log -p v -t $TAG "Detect I2C PCAP"
	exit 0
fi

while [ $timer -le 100 ]
do
	vendor=`cat /sys/bus/usb/devices/1-1.1/idVendor`
	#Detect which usb touch
	if [ "$vendor" == "0eef" ]; then
		setprop ro.vendor.hon.touch.usb.vendor EETI
	 	break
	elif [ "$vendor" == "03eb" ]; then
		setprop ro.vendor.hon.touch.usb.vendor ATMEL
		break
	fi
	sleep 2
	timer=$(( $timer + 1 ))
done

if [ $timer -gt 100 ]; then
	setprop ro.vendor.hon.touch.usb.vendor unknown
fi
