#!/sbin/openrc-run

description="Synchronize system clock to hardware clock on shutdown."

command="/sbin/hwclock"
command_args="--rtc=/dev/rtc0 --systohc"
pidfile="/run/hwclock.pid"

depend() {
    need localmount
    before shutdown
}

start() {
    # No operation needed on start, as udev handles hwclock sync on startup
    einfo "The hardware clock sync on startup is handled by udev rules."
    return 0
}

stop() {
    ebegin "Saving the system clock to the hardware clock"
    if [ "$(uname -s)" = "GNU" ]; then
        $command --directisa --systohc
    else
        $command --rtc=/dev/rtc0 --systohc
    fi
    eend $?
}

status() {
    if [ "$(uname -s)" = "GNU" ]; then
        $command --directisa --show
    else
        $command --rtc=/dev/rtc0 --show
    fi
}
