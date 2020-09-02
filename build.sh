#!/bin/sh
#
# checkn1x build script
# https://asineth.gq/checkn1x
#
VERSION="1.0.6"
ARCH="amd64" # can be set to amd64, i686
CRSOURCE="https://assets.checkra.in/downloads/linux/cli/x86_64/607faa865e90e72834fce04468ae4f5119971b310ecf246128e3126db49e3d4f/checkra1n"

set -e -u -v
apt update
apt install -y --no-install-recommends wget debootstrap grub-pc-bin grub-efi-amd64-bin mtools squashfs-tools xorriso ca-certificates
mkdir -p work/chroot
mkdir -p work/iso/live
mkdir -p work/iso/boot/grub
debootstrap --arch=$ARCH unstable work/chroot
mount --bind /proc work/chroot/proc
mount --bind /sys work/chroot/sys
mount --bind /dev work/chroot/dev
cp /etc/resolv.conf work/chroot/etc
cat << EOF | chroot work/chroot /bin/bash
export DEBIAN_FRONTEND=noninteractive
apt install -y --no-install-recommends linux-image-$ARCH live-boot usbmuxd
sed -i 's/COMPRESS=gzip/COMPRESS=xz/' /etc/initramfs-tools/initramfs.conf
update-initramfs -u
rm -f /etc/mtab
rm -f /etc/fstab
rm -f /etc/ssh/ssh_host*
rm -f /root/.wget-hsts
rm -f /root/.bash_history
rm -rf /var/log/*
rm -rf /var/cache/*
rm -rf /var/backups/*
rm -rf /var/lib/apt/*
rm -rf /var/lib/dpkg/*
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/icons/*
rm -rf /usr/lib/modules/*
exit
EOF
wget -O work/chroot/usr/bin/checkra1n $CRSOURCE
chmod +x work/chroot/usr/bin/checkra1n
mkdir -p work/chroot/etc/systemd/system/getty@tty1.service.d
cat << EOF > work/chroot/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin root %I 
Type=idle
EOF
cat << EOF > work/iso/boot/grub/grub.cfg
insmod all_video
linux /boot/vmlinuz boot=live quiet
initrd /boot/initrd.img
boot
EOF
echo "checkn1x" > work/chroot/etc/hostname
echo "checkra1n" > work/chroot/root/.bashrc
rm -f work/chroot/etc/resolv.conf
umount -lf work/chroot/proc
umount -lf work/chroot/sys
umount -lf work/chroot/dev
cp work/chroot/vmlinuz work/iso/boot
cp work/chroot/initrd.img work/iso/boot
mksquashfs work/chroot work/iso/live/filesystem.squashfs -noappend -e boot -comp xz -Xbcj x86
grub-mkrescue -o checkn1x-$VERSION-$ARCH.iso work/iso