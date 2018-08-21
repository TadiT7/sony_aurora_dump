#!/vendor/bin/sh
# *********************************************************************
# * Copyright 2017 (C) Sony Mobile Communications Inc.                *
# * All rights, including trade secret rights, reserved.              *
# *********************************************************************
#

# use product specific script if exist.
if [ -f '/vendor/bin/init.usbmode.product.sh' ] ; then
  exit `/vendor/bin/init.usbmode.product.sh`
fi

TAG="usb"
VENDOR_ID=0FCE
PID_PREFIX=0

get_pid_prefix()
{
  case $1 in
    "mass_storage")
      PID_PREFIX=E
      ;;

    "mtp")
      PID_PREFIX=0
      ;;

    "adb")
      PID_PREFIX=3
      ;;

    "mtp,adb")
      PID_PREFIX=5
      ;;

    "mtp,cdrom")
      PID_PREFIX=4
# Pass "mass_storage" instead of "cdrom".
      USB_FUNCTION="mtp,mass_storage"
      ;;

    "mtp,cdrom,adb")
      PID_PREFIX=4
# Don't enable ADB for PCC mode.
# Pass "mass_storage" instead of "cdrom".
      USB_FUNCTION="mtp,mass_storage"
      ;;

    "rndis")
      PID_PREFIX=7
      ;;

    "rndis,adb")
      PID_PREFIX=8
      ;;

    "midi")
      PID_PREFIX=C
      ;;

    "midi,adb")
      PID_PREFIX=D
      ;;

    *)
      /vendor/bin/log -t ${TAG} -p e "unsupported composition: $1"
      return 1
      ;;
  esac

  return 0
}

set_engpid()
{
  SUPPORT_RMNET=1
  # Use SOMC USB Eng driver since QCOM does not support it.
  # Set VID/PID in "init.usb.configfs.rc" for using Qcom Eng driver
  # when func is "adb" or "rndis,adb".
  case $1 in
    "mtp,adb") PID_PREFIX=5 ;;
    *)
      /vendor/bin/log -t ${TAG} -p i "No eng PID for: $1"
      return 1
      ;;
  esac

  PID=${PID_PREFIX}146
  USB_FUNCTION=${1},serial,diag
  ln -s /config/usb_gadget/g1/functions/cser.dun.0 /config/usb_gadget/g1/configs/b.1/f3
  ln -s /config/usb_gadget/g1/functions/cser.nmea.1 /config/usb_gadget/g1/configs/b.1/f4
  ln -s /config/usb_gadget/g1/functions/diag.diag /config/usb_gadget/g1/configs/b.1/f5
  if [ ${SUPPORT_RMNET}  -eq 1 ] ; then
    USB_FUNCTION=${USB_FUNCTION},rmnet
    ln -s /config/usb_gadget/g1/functions/gsi.rmnet /config/usb_gadget/g1/configs/b.1/f6
  fi
  echo ${USB_FUNCTION} > /config/usb_gadget/g1/configs/b.1/strings/0x409/configuration

  return 0
}

PID_SUFFIX_PROP=$(/vendor/bin/getprop ro.usb.pid_suffix)
USB_FUNCTION=$(/vendor/bin/getprop sys.usb.config)
ENG_PROP=$(/vendor/bin/getprop persist.usb.eng)

get_pid_prefix ${USB_FUNCTION}
if [ $? -eq 1 ] ; then
  exit 1
fi

echo 0x${VENDOR_ID} > /config/usb_gadget/g1/idVendor

PID=${PID_PREFIX}${PID_SUFFIX_PROP}
if [ ${ENG_PROP} -eq 1 ] ; then
  set_engpid ${USB_FUNCTION}
fi

echo 0x${PID} > /config/usb_gadget/g1/idProduct
/vendor/bin/log -t ${TAG} -p i "usb product id: ${PID}"

/vendor/bin/log -t ${TAG} -p i "enabled usb functions: ${USB_FUNCTION}"

exit 0
