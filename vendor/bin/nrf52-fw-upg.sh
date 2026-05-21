#!/vendor/bin/sh

TAG="NRF52-FW-UPG"

#log -p v -t "$TAG"  "sart, check nrf52 fw ver"
FW_VER=$(getprop persist.vendor.hon.nrf52.fw.ver)
OTA_VER=$(getprop ro.hon.nrf52.ota.ver)
log -p v -t "$TAG" "FW VER: $FW_VER"
log -p v -t "$TAG" "OTA VER: $OTA_VER"
if [ "$OTA_VER" != "" ] && [ "$FW_VER" != "$OTA_VER" ]; then
	log -p v -t "$TAG" "trigger fw upg"
	#TODO: let nrf52 hidl not publish when fw updating
	setprop persist.vendor.hon.nrf52.fw.ver "updating"
	setprop persist.vendor.hon.nrf52.fw.upg true
	log -p v -t "$TAG" "wait for 120s"
	sleep 120;
	log -p v -t "$TAG" "stop fw upg"
	#TODO: need read ver from chip or just set it here
	#setprop persist.vendor.hon.nrf52.fw.ver $OTA_VER
	setprop persist.vendor.hon.nrf52.fw.upg false
fi
#log -p v -t "$TAG"  "stop"
