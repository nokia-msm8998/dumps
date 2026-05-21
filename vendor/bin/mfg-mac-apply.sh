#!/vendor/bin/sh

addr=`getprop ro.hsm.wlan.addr`
addr2=`getprop ro.hsm.auxwlan.addr`

align_addr() {

  local tmp=$1
  local len=${#1}
  local delta

  if [ $len -gt 12 ]; then
    return 1
  elif [ $len -lt 12 ]; then
    let delta=12-$len
    while [ $delta -gt 0 ]; do
      let delta-=1
      tmp=`echo 0$tmp`
    done
  fi

  addr=$tmp

  return 0

}

format_addr() {

  local tmp
  local byte
  local start

  align_addr $1

  if [ $? -eq 1 ]; then
    return 1
  fi

  for start in 0 2 4 6 8 10
  do
    byte=${addr:$start:2}
    if [ -z $tmp ]; then
      tmp=$byte
    else
      tmp=`echo $tmp:$byte`
    fi
  done

  addr=$tmp

  return 0

}

addr_check()
{
  local start

  if [ -z $1 ];  then
    echo "ERROR, Can't getprop ro.hsm.addr"
    return 1
  fi

  align_addr $1

  if [ $? -eq 1 ]; then
    return 1
  fi

  for start in 0 2 4 6 8 10
  do
    byte_check=${addr:$start:2}
    if [ "$byte_check" != "ff" -a $byte_check -ne 0 ]; then
      return 0
    else
      echo $byte_check
      continue
    fi
  done

  echo "ERROR, addr is zero or ff"
  return 1
}

# format_addr accept $addr and output the result to it.
format_addr $addr
addr_str=$addr
addr=$addr2
format_addr $addr
addr2_str=$addr
echo $addr_str $addr2_str > /sys/kernel/icnss/mac_addr

sleep 1

addr=`getprop ro.hsm.bt.addr`
addr_check $addr
if [ $? -eq 0 ]; then
  echo "write bluetooth mac address"
  format_addr $addr
  if [ $? -eq 0 ]; then
     setprop ro.vendor.bt.boot.macaddr $addr
     echo "write bluetooth mac address success"
  fi
else
  echo "write bluetooth mac address fail"
fi

