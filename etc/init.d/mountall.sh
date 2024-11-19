#!/sbin/openrc-run

description="Mount all filesystems as specified in /etc/fstab"

depend() {
    need localmount
    need checkfs
    need checkroot-bootclean
    after bootmisc
}

start() {
    ebegin "Mounting all local filesystems"
    mount_all_local
    eend $?

    # Ensure /var/log/fsck is available for fsck logs
    mkdir -p /var/log/fsck

    # Reactivate swap in case it is on a filesystem that was just mounted
    if [ "$(cat /proc/cmdline)" != *noswap* ]; then
        ebegin "Activating swap space"
        swapon -a -e 2>/dev/null || :
        eend $?
    fi

    # Update mount options for tmpfs now that swap is active
    mount -o remount /run
    mount -o remount /run/lock
    mount -o remount /dev/shm
    mount -o remount /tmp
}

stop() {
    # No stop needed, as we do not unmount filesystems on service stop
    return 0
}

mount_all_local() {
    # Perform the mount operations for local filesystems excluding special filesystem types
    # and network-based filesystems
    mount -a -t nonfs,nfs4,smbfs,cifs,ncp,ncpfs,coda,ocfs2,gfs,gfs2,ceph -O no_netdev
}
