#!/vendor/bin/sh
TAG="TouchModeInit"
log -p v -t $TAG "Detecting for TA60..."

#Detect I2C PCAP
if [ -e /dev/egalax_i2c ]; then
	log -p i -t $TAG "Detect I2C PCAP"
else
	log -p i -t $TAG "No I2c PCAP"
	exit;
fi

mode="`/vendor/bin/getprop persist.hon.setting.touchmode`"
if [ "$mode" != "" ]; then
	log -p i -t $TAG "chagne to $mode mode"
	echo "$mode" > /sys/bus/i2c/devices/4-002a/mode
else
	log -p i -t $TAG "used default mode"
fi
