#!/vendor/bin/sh -x
#
# Copyright (C) 2017 Sony Mobile Communications Inc.
# All rights, including trade secret rights, reserved.

umask 022

active_customization="$(/vendor/bin/getprop ro.semc.version.cust.active)"
log -p i -t customized_media_copy "Copying media for active customization: $active_customization"

if [ $# -ne 1 ]; then
  log -p e -t customized_media_copy "Usage: customized_media_copy.sh <customization-directory>"
  exit 1
fi

customization_dir="$1$active_customization"
if ! [ -d "$customization_dir" ]; then
  log -p i -t customized_media_copy "Found no active_customization directory"
  exit 0
fi

src_dir="$customization_dir/media/audio/"
if ! [ -d "$src_dir" ]; then
  log -p i -t customized_media_copy "Found no media in active customization"
  exit 0
fi

dest_dir=/data/media/0/

remove() {
  for dir in /oem/android-config/*/media/audio/"$1"/; do
    for file in "$dir/"*; do
      filename="$(basename "$file")"
      dest_file="$2/$filename"
      if [ -e "$dest_file" ]; then
        log -p i -t customized_media_copy "Removing $filename"
        rm "$dest_file"
      fi
    done
  done
}

copy() {
  if [ -d "$1" ]; then
    cp -n "$1/"* "$2/"
  fi
}

log -p i -t customized_media_copy "Removing old customized media from $dest_dir"

remove "ringtones" "$dest_dir/Ringtones/" &
remove "notifications" "$dest_dir/Notifications/" &
remove "alarms" "$dest_dir/Alarms/" &

wait

log -p i -t customized_media_copy "Copying from $src_dir to $dest_dir"

copy "$src_dir/ringtones/" "$dest_dir/Ringtones/" &
copy "$src_dir/notifications/" "$dest_dir/Notifications/" &
copy "$src_dir/alarms/" "$dest_dir/Alarms/" &

wait

log -p i -t customized_media_copy "Copying complete"
exit 0

