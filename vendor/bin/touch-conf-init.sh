#!/vendor/bin/sh
TAG="TOUCH-CONF-INIT"
cfg_path="/sys/bus/i2c/devices/4-004a/cfg_path"
cfg_path_tmp="/sys/bus/i2c/devices/4-004b/cfg_path"

if [ "$cfg_path" -eq "" ]; then
	log -p v -t $TAG "Touch is not mxt IC"
	exit 0
fi

if [ -f /data/vendor/touch/mxt.raw ]; then
	log -p v -t $TAG "Already has normal cfg file under /data/vendor/touch"
	echo "custom" > $cfg_path
else
	log -p v -t $TAG "Set path to /vendor/firmware"
	echo "default" > $cfg_path
	echo "default" > $cfg_path_tmp
fi

log -p v -t $TAG "list touch path:`cat $cfg_path`"


