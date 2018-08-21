#!/vendor/bin/sh
# Copyright (c) 2017 Sony Mobile Communications Inc.
# Set sl.config.kl only if startup-logger_done file is not available
file="/mnt/rca/startup-logger_done"
if [ ! -e "$file" ] ; then
   `setprop sl.config.kl enable`
fi
