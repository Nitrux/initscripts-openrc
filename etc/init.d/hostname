#!/sbin/openrc-run

description="Set hostname based on /etc/hostname"

depend() {
    need localmount
    before net
}

start() {
    ebegin "Setting hostname based on /etc/hostname"
    if [ -f /etc/hostname ]; then
        local HOSTNAME=$(cat /etc/hostname)
        hostname "${HOSTNAME}"
        eend $?
    else
        eerror "/etc/hostname does not exist"
        return 1
    fi
}

stop() {
    # No stop function needed as the hostname cannot be "unset"
    return 0
}

status() {
    # Display the current hostname
    einfo "Current hostname: $(hostname)"
}
