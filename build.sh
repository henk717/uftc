sudo docker build . -t uftc && sudo rm uftc.vhd
sudo ./d2vm convert uftc:latest -o uftc.vhd --bootloader grub --boot-size 4000 --size 14G --network-manager none $*
