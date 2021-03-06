#!/bin/bash -e

# If you don't delete both, tzdata won't reconfigure properly
on_chroot sh -e << EOF
rm -f /etc/localtime /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
EOF

install -m 755 files/regenerate_ssh_host_keys		${ROOTFS_DIR}/etc/init.d/
install -m 755 files/apply_noobs_os_config		${ROOTFS_DIR}/etc/init.d/
install -m 755 files/resize2fs_once			${ROOTFS_DIR}/etc/init.d/

install -d						${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d
install -m 644 files/ttyoutput.conf			${ROOTFS_DIR}/etc/systemd/system/rc-local.service.d/

install -m 644 files/50raspi				${ROOTFS_DIR}/etc/apt/apt.conf.d/
install -m 440 files/group_sudo				${ROOTFS_DIR}/etc/sudoers.d



on_chroot sh -e - <<EOF
systemctl disable hwclock.sh
systemctl disable nfs-common
systemctl disable rpcbind
systemctl disable ssh
systemctl enable regenerate_ssh_host_keys
systemctl enable apply_noobs_os_config
systemctl enable resize2fs_once
systemctl set-default multi-user.target
EOF

on_chroot sh -e - << \EOF
for GRP in input spi i2c gpio; do
	groupadd -f -r $GRP
done
for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev sudo; do
  adduser pi $GRP
done
EOF

on_chroot sh -e - <<EOF
dpkg-reconfigure -f noninteractive tzdata
setupcon --force --save-only -v
EOF

on_chroot sh -e - <<EOF
usermod --pass='*' root
EOF

rm -f ${ROOTFS_DIR}/etc/ssh/ssh_host_*_key*
