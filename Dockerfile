FROM debian:bookworm

COPY tcfiles/debian.sources /etc/apt/sources.list.d/debian.sources

RUN apt update && apt install sudo curl wget freerdp2-x11 yad fvwm xterm xinit light mingetty polkitd net-tools iw wpasupplicant systemd-resolved ifupdown ethtool enca nano udiskie mc mtr cups firmware-linux firmware-linux-nonfree firmware-iwlwifi firmware-realtek firmware-atheros firmware-brcm80211 open-vm-tools ffmpeg pulseaudio pamixer x11-xserver-utils -y

COPY icaclient.deb* /tmp/
RUN apt install /tmp/icaclient.deb -y && rm /tmp/icaclient.deb || true

COPY tcfiles/thinclient /usr/bin/thinclient
COPY tcfiles/set-hostname /usr/bin/set-hostname
COPY tcfiles/firstboot /usr/bin/firstboot
COPY tcfiles/auto-maintenance.debian /usr/bin/auto-maintenance
COPY tcfiles/099_tc /etc/sudoers.d/099_tc
RUN chmod +x /usr/bin/*

RUN mkdir -p /etc/systemd/system/getty@tty1.service.d
COPY tcfiles/autologin /etc/systemd/system/getty@tty1.service.d/override.conf
RUN systemctl enable getty@tty1.service

COPY tcfiles/tc-copyconfig.service /etc/systemd/system/tc-copyconfig.service
RUN systemctl enable tc-copyconfig.service

COPY tcfiles/tc-copywpa.service /etc/systemd/system/tc-copywpa.service
RUN systemctl enable tc-copywpa.service

COPY tcfiles/tc-wifipower.service /etc/systemd/system/tc-wifipower.service
RUN systemctl enable tc-wifipower.service

COPY tcfiles/dhcp.network /etc/systemd/network/dhcp.network
COPY tcfiles/interfaces /etc/network/interfaces

COPY tcfiles/xorg.conf /etc/X11/xorg.conf.d/thinclient.conf

#This line is for pipewire, because pipewire has limited mic support its currently replaced with pulseaudio
#Pulseaudio has the auto switch behavior by default
#COPY tcfiles/pipewire-pulse.conf /etc/pipewire/pipewire-pulse.conf.d/thinclient.conf

RUN useradd -ms /bin/bash thinclient -G video,audio,netdev,render,cdrom,plugdev

COPY tcfiles/.fvwm /home/thinclient/.fvwm
COPY tcfiles/bashrc /home/thinclient/.bashrc
COPY Version /tcversion
COPY tcconfig_override* /home/thinclient/

# Block stock files from being tampered with to harden even more
RUN chown -R root:thinclient /home/thinclient/ && chmod 1775 /home/thinclient/

USER thinclient
WORKDIR /home/thinclient

RUN touch dynamic_hostname
