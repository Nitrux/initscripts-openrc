#!/sbin/openrc-run

description="Check root filesystem and update mount points after root is mounted."

depend() {
    need localmount
    before mountdevsubfs
    before bootmisc
}

start_pre() {
    # Ensure /var/log/fsck is present for logging
    if [ ! -d /var/log/fsck ]; then
        mkdir -p /var/log/fsck
        chmod 755 /var/log/fsck
    fi
}

start() {
    ebegin "Checking root filesystem and updating mount points"
    
    local FSCK_LOGFILE="/var/log/fsck/checkroot"

    # Function to perform root filesystem checks
    check_fs() {
        einfo "Performing file system checks..."
        local fsck_result=0
        touch ${FSCK_LOGFILE}
        fsck -A -T -C -a -t noopts=_netdev >> ${FSCK_LOGFILE} 2>&1
        fsck_result=$?
        return ${fsck_result}
    }

    # Update mtab and related tasks
    update_mtab() {
        einfo "Updating mtab and reloading mounts..."
        grep -v rootfs /proc/mounts > /etc/mtab
        mount -o remount,rw /
        /etc/init.d/mountdevsubfs reload
        /etc/init.d/mountkernfs reload
    }

    # Check the root filesystem
    check_fs
    local fs_result=$?
    if [ ${fs_result} -ne 0 ]; then
        ewarn "Filesystem checks failed with status ${fs_result}, manual repair might be needed."
    fi

    # Update mtab and other mounts after check
    update_mtab

    eend ${fs_result}
}

stop() {
    # No stop needed as this service does not persist beyond start
    return 0
}

status() {
    # Check if root is writable and swap is on (indicators that the system is running normally)
    if grep " / " /proc/mounts | grep -q "rw,"; then
        einfo "Root filesystem is writable"
    else
        ewarn "Root filesystem is not writable"
    fi

    if [ -f /proc/swaps ] && grep -qE "partition|file" /proc/swaps; then
        einfo "Swap is active"
    else
        ewarn "Swap is inactive"
    fi
}
