#!/vendor/bin/sh
# Copyright (c) 2013-2016 Sony Mobile Communications Inc.

# idd data is less than 10k.
max=8000
src_dir=$1
dst_dir=$2
dd=/vendor/bin/dd
ls=/vendor/bin/ls
rm=/vendor/bin/rm
mkdir=/vendor/bin/mkdir
tune2fs=/vendor/bin/tune2fs_vendor
chmod=/vendor/bin/chmod
wc=/vendor/bin/wc

$mkdir -p $dst_dir
for i in `$ls $src_dir`; do
    len=`$wc -c < $src_dir/$i`

    if [ $len -ge 1 ]; then
        echo "SONY-idd-new-record\n" >> $dst_dir/$i
        $tune2fs -l /dev/block/platform/msm_sdcc.1/by-name/$i >> $dst_dir/$i
        echo "SONY-idd: Len:$len" >> $dst_dir/$i

        if [ $len -ge $max ]; then
            $dd if=$src_dir/$i bs=1 skip=$(($len - $max)) >> $dst_dir/$i 2> /dev/null
        else
            $dd if=$src_dir/$i bs=$max >> $dst_dir/$i 2> /dev/null
        fi
    fi
    $chmod -R 666 $dst_dir/$i
    $rm $src_dir/$i
done
