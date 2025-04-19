FROM debian:bookworm
RUN apt update && apt install sudo freerdp2-x11 yad fvwm xterm xinit mingetty polkitd nano udiskie mc mtr -y
COPY tcfiles/thinclient /usr/bin/thinclient
COPY tcfiles/set-hostname /usr/bin/set-hostname
COPY tcfiles/099_tc /etc/sudoers.d/099_tc
RUN chmod +x /usr/bin/*

RUN mkdir -p /etc/systemd/system/getty@tty1.service.d
COPY tcfiles/autologin /etc/systemd/system/getty@tty1.service.d/override.conf
RUN systemctl enable getty@tty1.service

COPY tcfiles/tc-copyconfig.service /etc/systemd/system/tc-copyconfig.service
RUN systemctl enable tc-copyconfig.service

RUN useradd -ms /bin/bash thinclient
COPY tcfiles/.fvwm /home/thinclient/.fvwm
COPY tcfiles/bashrc /home/thinclient/.bashrc
USER thinclient
WORKDIR /home/thinclient

RUN touch dynamic_hostname