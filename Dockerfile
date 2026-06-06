FROM debian:trixie

COPY tcfiles/debian.sources /etc/apt/sources.list.d/debian.sources

RUN apt update && apt install sudo curl wget freerdp3-x11 yad fvwm xterm xinit light lightdm polkitd net-tools iw wpasupplicant systemd-resolved nm-connection-editor ethtool ifupdown network-manager-pptp-gnome network-manager-l2tp-gnome network-manager-openvpn-gnome network-manager-sstp-gnome enca nano udiskie mc mtr cups mesa-utils firmware-linux firmware-linux-nonfree firmware-iwlwifi firmware-realtek firmware-atheros firmware-brcm80211 open-vm-tools ffmpeg pulseaudio pamixer x11-xserver-utils adwaita-icon-theme-legacy libfuse2 rsync -y

COPY icaclient.deb* /tmp/
RUN apt install /tmp/icaclient.deb -y && rm /tmp/icaclient.deb || true

COPY Moonlight.AppImage* /usr/bin/moonlight

COPY tcfiles/thinclient /usr/bin/thinclient
COPY tcfiles/set-hostname /usr/bin/set-hostname
COPY tcfiles/firstboot /usr/bin/firstboot
COPY tcfiles/auto-maintenance.debian /usr/bin/auto-maintenance
COPY tcfiles/099_tc /etc/sudoers.d/099_tc
COPY tcfiles/usb-access.rules /etc/udev/rules.d/usb-access.rules
RUN chmod +x /usr/bin/*

COPY tcfiles/autologin /etc/lightdm/lightdm.conf.d/autologin.conf

COPY tcfiles/tc-copyconfig.service /etc/systemd/system/tc-copyconfig.service
RUN systemctl enable tc-copyconfig.service

COPY tcfiles/tc-copynm.service /etc/systemd/system/tc-copynm.service
RUN systemctl enable tc-copynm.service

COPY tcfiles/tc-wifipower.service /etc/systemd/system/tc-wifipower.service
RUN systemctl enable tc-wifipower.service

COPY tcfiles/tc-wakeonlan.service /etc/systemd/system/tc-wakeonlan.service
RUN systemctl enable tc-wakeonlan.service

COPY tcfiles/tc-certmanager.service /etc/systemd/system/tc-certmanager.service
RUN systemctl enable tc-certmanager.service

COPY tcfiles/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

COPY tcfiles/xorg.conf /etc/X11/xorg.conf.d/thinclient.conf

#This line is for pipewire, because pipewire has limited mic support its currently replaced with pulseaudio
#Pulseaudio has the auto switch behavior by default
#COPY tcfiles/pipewire-pulse.conf /etc/pipewire/pipewire-pulse.conf.d/thinclient.conf

RUN useradd -ms /bin/bash thinclient -G video,audio,netdev,render,cdrom,plugdev

COPY tcfiles/.fvwm /home/thinclient/.fvwm
#COPY tcfiles/bashrc /home/thinclient/.bashrc
#COPY tcfiles/xinitrc /home/thinclient/.xinitrc
COPY Version /tcversion
COPY tcconfig_override* /home/thinclient/
RUN mkdir /home/thinclient/.config
RUN mkdir /home/thinclient/.config/systemd

# Block stock files from being tampered with to harden even more
RUN chown -R root:thinclient /home/thinclient/ && chmod 1775 /home/thinclient/
RUN chown thinclient:thinclient /home/thinclient/.config

USER thinclient
WORKDIR /home/thinclient

RUN touch dynamic_hostname

