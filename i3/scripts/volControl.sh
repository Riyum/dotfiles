#!/bin/bash

# volume control with 100% limit #

# getdefaultsinkname() {
#     pacmd stat | awk -F": " '/^Default sink name: /{print $2}'
# }

getdefaultsinkvol() {
    pactl list sinks | grep '^[[:space:]]Volume:' | \
        head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
}

getmutestat() {
    pactl list sinks | grep Mute | cut -f2 | cut -d" " -f2
}

# setdefaulsinkvol() {
#     pactl set-sink-volume "$(getdefaultsinkname)" $1
# }

# if ! pulseaudio --check; then
#     echo "Puseaudio Inactive"
#     exit
# fi

MUTE=$(getmutestat)
VOL=$(getdefaultsinkvol)
STEP=5

case "$1" in
-inc)
    if [ "$MUTE" = "yes" ]; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    fi
    ((NEWVOL = $VOL + $STEP))
    if [ $NEWVOL -le 100 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ +$STEP%
    else
        pactl set-sink-volume @DEFAULT_SINK@ 100%
    fi
    ;;
-dec)
    if [ "$MUTE" = "yes" ]; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    fi
    ((NEWVOL = $VOL - $STEP))
    if [ $NEWVOL -ge 0 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ -$STEP%
    else
        pactl set-sink-volume @DEFAULT_SINK@ 0%
    fi
    ;;
*)
    exit 1
    ;;
esac
