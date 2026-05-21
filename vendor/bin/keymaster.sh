#!/vendor/bin/sh

PRODUCT=`getprop ro.model`
KMVERSION=`getprop ro.boot.kmversion`
log -p i -t "HIDL-INTF" $PRODUCT

if [ "$PRODUCT" == "CT60" ] || [ "$PRODUCT" == "CT40" ] || [ "$PRODUCT" == "CN80" ] ;
then
    if [ "$KMVERSION" == "4"  ];
    then
        ln -sf /vendor/lib64/hw/keymaster-impl-qti.so /mnt/keymaster
        ln -sf /vendor/lib64/hw/gatekeeper-impl-qti.so /mnt/gatekeeper
    else
        ln -sf /vendor/lib64/hw/keymaster-impl.so /mnt/keymaster
        ln -sf /vendor/lib64/hw/gatekeeper-impl.so /mnt/gatekeeper
    fi;
else
    ln -sf /vendor/lib64/hw/keymaster-impl-qti.so /mnt/keymaster
    ln -sf /vendor/lib64/hw/gatekeeper-impl-qti.so /mnt/gatekeeper
fi;
