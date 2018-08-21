#!/vendor/bin/sh
#
# Copyright (C) 2017 Sony Mobile Communications Inc.
# All rights, including trade secret rights, reserved.

umask 022
log -p i -t preloads_media_copy "Copying preloads from x_other"
if [ $# -eq 1 ]; then
  # Where the oem_b/system_b is mounted that contains the deletable_media dir
  mountpoint=$1
  # Handle media that shall be deletable.
  # Use fuse/sdcardfs wrapped paths instead of /data path as desination dir.
  # This is done to avoid granting exploitable permissions and to avoid having to change
  # owner, group and permission of the files after the copy of the files.
  dest_dir=/storage/emulated/0
  log -p i -t preloads_media_copy "Copying from $mountpoint/deletable_media"
  for file in $(find ${mountpoint}/deletable_media -mindepth 1 -maxdepth 1); do
     log -p i -t preloads_media_copy "cp -r '$file' '$dest_dir'"
     cp -r $file $dest_dir
  done
  log -p i -t preloads_media_copy "Copying complete"
  exit 0
else
  log -p e -t preloads_media_copy "Usage: preloads_media_copy.sh <system_other-mount-point>"
  exit 1
fi
