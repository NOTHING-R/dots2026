#!/bin/sh

# Load Xresources (fonts, dpi)
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Load xprofile (env settings)
[ -f ~/.xprofile ] && . ~/.xprofile

# Input settings (touchpad)
xinput set-prop "SYNA3071:00 06CB:82F1 Touchpad" "libinput Tapping Enabled" 1
xinput set-prop "SYNA3071:00 06CB:82F1 Touchpad" "libinput Natural Scrolling Enabled" 1

# Background
~/.fehbg &

# Export X environment to systemd user session so portals and file pickers work
systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS

# System services (START HERE)
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
picom &
dwmblocks &
dunst &
nm-applet &
blueman-applet &
flameshot &
ibus-daemon -drx &

# Start window manager
exec dwm
