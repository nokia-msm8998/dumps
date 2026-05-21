#!/vendor/bin/sh

#align_addr use to append zero to fulfill the format to avoid unexpected condition happen.
align_addr() {

  local tmp=$1
  local len=${#1}
  local delta

if [ $len -le 4 ]; then
  if [ $len -lt 4 ]; then
    let delta=4-$len
    while [ $delta -gt 0 ]; do
      let delta-=1
      tmp=`echo 0$tmp`
    done
    addr=$tmp
    return 0
  fi
  return 0
else
  if [ $len -gt 24 ]; then
    return 1
  elif [ $len -lt 24 ]; then
    let delta=24-$len
    while [ $delta -gt 0 ]; do
      let delta-=1
      tmp=`echo 0$tmp`
    done
  fi
  addr=$tmp
  return 0
fi
}

format_addr() {

  local tmp
  local dword
  local start

  if [ -z $2 ]; then
    align_addr $1
    if [ $? -eq 1 ]; then
      return 1
    fi
    return 0
  else
    align_addr $2
    if [ $? -eq 1 ]; then
      return 1
    fi
    return 0
  fi

}
addr=`getprop ro.hsm.cal.accel.zero_offset`
format_addr $addr
if [ $? -eq 0 ]; then
  /vendor/bin/sensorcal_apply -a $addr
  echo $addr
fi

addr=`getprop ro.hsm.cal.gyro.zero_offset`
format_addr $addr
if [ $? -eq 0 ]; then
  /vendor/bin/sensorcal_apply -g $addr
  echo $addr
fi

addr=`getprop ro.hsm.calibration.proximity`
format_addr 0 $addr
if [ $? -eq 0 ]; then
  /vendor/bin/sensorcal_apply -p $addr
  echo $addr
fi

