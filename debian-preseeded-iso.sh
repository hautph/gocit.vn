#!/bin/bash

set -e

set -u

# required packages (apt-get install)
# xorriso
# syslinux

ISOFILE=debian-amd64-netinst-3cx.iso
ISOFILE_FINAL=debian-amd64-netinst-3cx-mod.iso
ISODIR=debian-iso
ISODIR_WRITE=$ISODIR-rw

# download ISO:
#wget -nc -O $ISOFILE https://downloads.3cx.com/downloads/debian9iso/debian-amd64-netinst-3cx.iso || true

echo 'mounting ISO9660 filesystem...'
# source: http://wiki.debian.org/DebianInstaller/Preseed/EditIso
[ -d $ISODIR ] || mkdir -p $ISODIR
sudo mount -o loop $ISOFILE $ISODIR

echo 'coping to writable dir...'
rm -rf $ISODIR_WRITE || true
[ -d $ISODIR_WRITE ] || mkdir -p $ISODIR_WRITE
rsync -a -H --exclude=TRANS.TBL $ISODIR/ $ISODIR_WRITE

echo 'unmount iso dir'
sudo umount $ISODIR

echo 'correcting permissions...'
chmod 755 -R $ISODIR_WRITE

echo 'copying preseed file...'
cp preseed.final $ISODIR_WRITE/preseed.cfg

echo 'edit isolinux/txt.cfg...'
sed 's/initrd.gz/initrd.gz file=\/cdrom\/preseed.cfg/' -i $ISODIR_WRITE/isolinux/txt.cfg

echo 'fixing MD5 checksums...'
pushd $ISODIR_WRITE
  md5sum $(find -type f) > md5sum.txt
popd

echo 'making ISO...'
# genisoimage -o $ISOFILE_FINAL \
#   -r -J -no-emul-boot -boot-load-size 4 \
#   -boot-info-table \
#   -b isolinux/isolinux.bin \
#   -c isolinux/boot.cat ./$ISODIR_WRITE

echo 'making hybrid ISO...'


xorriso -as mkisofs \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
	-o $ISOFILE_FINAL \
	./$ISODIR_WRITE
rm -rf debian-iso debian-iso-rw
# and if that doesn't work:
# http://askubuntu.com/questions/6684/preseeding-ubuntu-server
