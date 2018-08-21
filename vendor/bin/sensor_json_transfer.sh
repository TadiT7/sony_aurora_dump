#! /vendor/bin/sh

SWLABEL=`getprop ro.semc.version.sw_revision`
VERSIONTEXT=`head -n 1 /persist/sensors/version.txt`
DST_CONFIG_JSON_FILE_DIR="persist/sensors/registry/config"
DST_SOMC_JSON_FILE_DIR="persist/sensors/registry/somc"
DST_JSON_FILE_DIR="persist/sensors"
SRC_JSON_FILE_DIR="vendor/etc/sensors/registry"

if [ $SWLABEL = $VERSIONTEXT ] && [ -n $VERSIONTEXT ]; then
  exit
fi

if [ -e $DST_CONFIG_JSON_FILE_DIR ]; then
  rm -rf $DST_CONFIG_JSON_FILE_DIR
fi

if [ -e $DST_SOMC_JSON_FILE_DIR ]; then
  rm -rf $DST_SOMC_JSON_FILE_DIR
fi

if [ -e $SRC_JSON_FILE_DIR ]; then
  cp -a $SRC_JSON_FILE_DIR $DST_JSON_FILE_DIR
fi
