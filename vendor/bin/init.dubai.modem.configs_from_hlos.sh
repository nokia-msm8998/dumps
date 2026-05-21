#! /vendor/bin/sh

SVN_DATAONLY="02"
SVN="04"
DEBUG_TAG="configs_from_hlos"

# get ro.boot.model and part number from boot cmdline
cmline=`cat /proc/cmdline`
# find "androidboot.model" and remove previous charactores
model=$(echo ${cmline#*androidboot.model=})
# remove characters after androidboot.model parameter
model=$(echo ${model%%' '*})

pn=$(echo ${cmline#*MfgDataPartNum=})
pn=$(echo ${pn%%' '*})

log -p d -t $DEBUG_TAG "boot.model: $model part number: $pn"

# update multisim config to modem share memory
multisim_config_modem_shared_path="/mnt/vendor/persist/hlos_rfs/shared/multisim_config"
if [ -f $multisim_config_modem_shared_path ]; then
    rm $multisim_config_modem_shared_path
fi

multisim=`getprop persist.radio.multisim.config`
log -p d -t $DEBUG_TAG "persist.radio.multisim.config : $multisim"
echo $multisim > $multisim_config_modem_shared_path
chown vendor_rfs.vendor_rfs_shared $multisim_config_modem_shared_path
chmod 660 $multisim_config_modem_shared_path

# update device_model.txt
model_file="/mnt/vendor/persist/hlos_rfs/shared/device_model.txt"
need_update="1"
if [ -f $model_file ]; then
    value=`cat $model_file`
    if [ "$model" == "$value" ]; then
        need_update="0"
    fi
fi

if [ "$need_update" == "1" ]; then
    rm $model_file
    echo "$model" > $model_file
    chown vendor_rfs.vendor_rfs_shared  $model_file
    chmod 660 $model_file
    log -p v -t $DEBUG_TAG  "save model to rfs"
else
     log -p v -t $DEBUG_TAG  "model not changed"
fi

# data-only or simulate data-only device
data_only_file="/mnt/vendor/persist/hlos_rfs/shared/data_only_device.txt"
force_data_only_file="/mnt/vendor/persist/hlos_rfs/shared/force_data_only_device.txt"
force_sw_mcfg_update_file="/mnt/vendor/persist/hlos_rfs/shared/sw_mcfg_forced_update.txt"
force_hw_mcfg_update_file="/mnt/vendor/persist/hlos_rfs/shared/hw_mcfg_forced_update.txt"
data_only="0"
need_update="1"
countrycode=`getprop ro.hon.plat.countrycode`


if [ "$model" == "TA60" ]; then
    data_only="1"
elif [ "$model" == "CT40P" ]; then
# pn example:CT40P-L1N-28R11BF
    app=$(echo ${pn:14:1})
    if [ "$app" == "D" ]; then
        data_only="1"
    fi
fi

# Turkey data only SKU
if [ "$countrycode" == "T" ]; then
    data_only="1"
fi


if [ -f $force_data_only_file ]; then
    force_data_only=`cat $force_data_only_file`
    log -p v -t $DEBUG_TAG  "force_data_onlye: $force_data_only"
    if [ "$force_data_only" == "1" ]; then
        data_only="1"
    else
        data_only="0"
    fi
fi
log -p d -t $DEBUG_TAG "getprop ro.hon.plat.dataonly : $data_only"
log -p d -t $DEBUG_TAG "getprop ro.hon.plat.countrycode : $countrycode"

setprop ro.hon.plat.dataonly $data_only
setprop ro.vendor.hon.plat.dataonly $data_only

if [ -f $data_only_file ]; then
    value=`cat $data_only_file`
    if [ "$data_only" == "$value" ]; then
        need_update="0"
    fi
fi

# delete useless files.
if [ -f $force_sw_mcfg_update_file ]; then
    value=`cat $force_sw_mcfg_update_file`
    if [ "$value" == "1" ]; then
        log -p v -t $DEBUG_TAG  "force sw mcfg update"
    else
         rm $force_sw_mcfg_update_file
    fi
fi
if [ -f $force_hw_mcfg_update_file ]; then
    value=`cat $force_hw_mcfg_update_file`
    if [ "$value" == "1" ]; then
        log -p v -t $DEBUG_TAG  "force hw mcfg update"
    else
        rm $force_hw_mcfg_update_file
    fi
fi

if [ "$need_update" == "1" ]; then
    rm $data_only_file
    echo "$data_only" > $data_only_file
    chown vendor_rfs.vendor_rfs_shared  $data_only_file
    chmod 660 $data_only_file
    log -p v -t $DEBUG_TAG  "save data_only to rfs"
    rm $force_sw_mcfg_update_file
    echo 1 > $force_sw_mcfg_update_file
    chown vendor_rfs.vendor_rfs_shared  $force_sw_mcfg_update_file
    chmod 660 $force_sw_mcfg_update_file
else
    log -p v -t $DEBUG_TAG  "data_only not changed"
fi

# SVN
svn_file="/mnt/vendor/persist/hlos_rfs/shared/svn.txt"
need_update="1"
svn=$SVN
if [ "$data_only" == "1" ]; then
    svn=$SVN_DATAONLY
fi

setprop ro.hsm.compliance.svn $svn

if [ -f $svn_file ]; then
    value=`cat $svn_file`
    if [ "$svn" == "$value" ]; then
        need_update="0"
    fi
fi

if [ "$need_update" == "1" ]; then
    rm $svn_file
    echo $svn > $svn_file
    chown vendor_rfs.vendor_rfs_shared  $svn_file
    chmod 660 $svn_file
    log -p v -t $DEBUG_TAG  "save svn to rfs"
else
    log -p v -t $DEBUG_TAG  "svn not changed"
fi
