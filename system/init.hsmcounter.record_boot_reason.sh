#!/vendor/bin/sh

HSM_COUNTER_SYSTEM_COUNTERS_SYSFS_PATH="/sys/kernel/hsm_counters/system_counters"
HSM_COUNTER_WARM_BOOT=10
HSM_COUNTER_COLD_BOOT=11
HSM_COUNTER_REBOOT=363

iscold_reset=`getprop ro.hsm.reset.reason  | grep cold`
if [ -z "$iscold_reset" ]
then
    counter_id=$HSM_COUNTER_WARM_BOOT
else
    counter_id=$HSM_COUNTER_COLD_BOOT
fi

#Increment the Value
echo "$counter_id++" > $HSM_COUNTER_SYSTEM_COUNTERS_SYSFS_PATH
echo "$HSM_COUNTER_REBOOT++" > $HSM_COUNTER_SYSTEM_COUNTERS_SYSFS_PATH


