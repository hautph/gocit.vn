#!/bin/bash

set -e

set -u

# required packages (apt-get install)
# xorriso
# syslinux

ISOFILE=debian-netinst.iso
ISOFILE_FINAL=debian-netinst-mod.iso
ISODIR=debian-iso
ISODIR_WRITE=$ISODIR-rw

# download ISO:
wget -nc -O $ISOFILE http://cdimage.debian.org/debian-cd/7.0.0/amd64/iso-cd/debian-7.0.0-amd64-netinst.iso || true

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
  -r -J -V "luma-wheezy" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -partition_offset 16 \
  -boot-load-size 4 \
  -boot-info-table \
  -isohybrid-mbr "/usr/lib/syslinux/isohdpfx.bin" \
  -o $ISOFILE_FINAL \
  ./$ISODIR_WRITE

# and if that doesn't work:
# http://askubuntu.com/questions/6684/preseeding-ubuntu-server
