#!/bin/bash -e

# FIXME: Package this
install -v -m 755 files/rc.rasppleii_boot		${ROOTFS_DIR}/etc
install -v -m 644 files/rasppleii_boot.service		${ROOTFS_DIR}/etc/systemd/system
