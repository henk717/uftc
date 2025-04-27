FROM debian:bookworm

COPY tcfiles/debian.sources /etc/apt/sources.list.d/debian.sources

RUN apt update && apt install sudo curl freerdp2-x11 yad fvwm xterm xinit mingetty polkitd net-tools wpasupplicant systemd-resolved enca nano udiskie mc mtr firmware-linux firmware-linux-nonfree firmware-iwlwifi firmware-realtek firmware-atheros firmware-brcm80211 firmware-b43-installer open-vm-tools ffmpeg pipewire-audio pamixer -y
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

COPY tcfiles/dhcp.network /etc/systemd/network/dhcp.network

COPY tcfiles/xorg.conf /etc/X11/xorg.conf.d/thinclient.conf

RUN useradd -ms /bin/bash thinclient -G video,audio,netdev,render,cdrom,plugdev

COPY tcfiles/.fvwm /home/thinclient/.fvwm
COPY tcfiles/bashrc /home/thinclient/.bashrc
COPY Version /tcversion

# Block stock files from being tampered with to harden even more
RUN chown -R root:thinclient /home/thinclient/ && chmod 1775 /home/thinclient/

COPY icaclient.deb* /tmp/
RUN apt install /tmp/icaclient.deb -y && rm /tmp/icaclient.deb || true

USER thinclient
WORKDIR /home/thinclient

RUN touch dynamic_hostname
