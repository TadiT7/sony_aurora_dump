# Copyright (c) 2015 Sony Mobile Communications Inc.
# All rights, including trade secret rights, reserved.
#
# Used to handle FOTA related actions at post-fs-data

function copy_result_file()
{
    local COPY_DIR=$1
    local COPY_FILE=$2
    local USER_GROUP=$3

    if [ ! -d $COPY_DIR ]; then
        mkdir -m 775 $COPY_DIR
        chown $USER_GROUP $COPY_DIR
    fi
    cp /cache/recovery/fota/$COPY_FILE $COPY_DIR/$COPY_FILE
    chown $USER_GROUP $COPY_DIR/$COPY_FILE
    chmod 664 $COPY_DIR/$COPY_FILE
}

# Remove FOTA package on internal sdcard. This is needed
# to avoid SE-Linux vioation.
if [ -e /cache/recovery/fota/executed ]; then
    if [ -e /data/media/0/recovery/update_package ]; then
        rm /data/media/0/recovery/update_package
    fi
fi

# Copy FOTA status files from cache to internal sdcard
# This is needed for FOTA services that are not platform_app
# and cannot access cache due to SE-Linux.
CRYPTO_STATE=$(getprop ro.crypto.state)
CRYPTO_TYPE=$(getprop ro.crypto.type)
if [ -e /cache/recovery/fota/status ]; then
    if [ "$CRYPTO_STATE" = "encrypted" -a "$CRYPTO_TYPE" = "file" ]; then
        copy_result_file /data/misc_de/0/recovery status system:misc
    else
        copy_result_file /data/media/0/recovery status media_rw:media_rw
    fi
fi
if [ -e /cache/recovery/fota/shortreport ]; then
    if [ "$CRYPTO_STATE" = "encrypted" -a "$CRYPTO_TYPE" = "file" ]; then
        copy_result_file /data/misc_de/0/recovery shortreport system:misc
    else
        copy_result_file /data/media/0/recovery shortreport media_rw:media_rw
    fi
fi
