#!/vendor/bin/sh
# Copyright (C) 2014 Sony Mobile Communications Inc.

if [ -d /sys/fs/selinux/trap ]; then
  echo "0" > /sys/fs/selinux/trap/enable;
  if [ -e /system/etc/selinux_trap.rules ]; then
    # Parse default Mask Rules
    while read line; do
      case "$line" in
        [-+],*) echo "$line" > /sys/fs/selinux/trap/add_exception;;
        \#*)    ;; # comment (NOP)
        *)      ;; # syntax error (NOP)
      esac
    done < /system/etc/selinux_trap.rules
  fi
  # Enable the Trap Module if NOT product phones
  for p in `cat /proc/cmdline`;
  do
    case $p in
      oemandroidboot.securityflags=0x00000000 ) echo "1" > /sys/fs/selinux/trap/enable; break ;;
      oemandroidboot.securityflags=0x00000001 ) echo "1" > /sys/fs/selinux/trap/enable; break ;;
      oemandroidboot.securityflags=0x00000002 ) break ;;
      oemandroidboot.securityflags=0x00000003 ) break ;;
      * ) ;;
    esac;
  done
fi
