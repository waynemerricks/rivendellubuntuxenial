#!/bin/bash
#Updates the system
#Update
echo Updating Distro...
sleep 1
echo
echo
apt update
apt -y upgrade
echo
echo
#Install Desktop Environment (XFCE)
echo Installing XFCE and tools...
sleep 1
echo
echo
apt -y install --no-install-recommends xubuntu-desktop xfce4-terminal xfce4-volumed xfce4-power-manager xfce4-indicator-plugin xfce4-datetime-plugin xfce4-cpugraph-plugin xfce4-netload-plugin xfce4-xkb-plugin xfce4-screenshooter xfce4-whiskermenu-plugin xubuntu-icon-theme xfwm4-themes plymouth-theme-xubuntu-logo file-roller mousepad thunar-archive-plugin indicator-sound indicator-power indicator-application catfish menulibre librsvg2-common hicolor-icon-theme xdg-utils libgtk-3-bin gvfs-backends gvfs-fuse

#Remove Pulse Audio because we don't need it
apt -y remove pulseaudio

#Install network manager and some nice themes
apt -y install --no-install-recommends network-manager-gnome fonts-liberation fonts-droid-fallback gtk-theme-config libnss-mdns

#Add Guest Additions
apt -y install virtualbox-guest-dkms

#Add vino (VNC)
apt -y install vino

#Clean up apt (it will moan that things are no longer needed)
apt -y autoremove
echo
echo Done
