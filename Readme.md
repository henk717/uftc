# User Friendly ThinClient

UFTC was born out of my passion for IT, I have always wanted the ability to have thin clients in my home lab yet nothing online I could use for free was what I wanted.
Many organizations I supported across IT departments always wanted the same thing, a lightweight locked down thinclient with a simple login screen.

This project is geared towards that use case, repurpose machines into thin clients or save money by using your own consistent thinclient image with mini PC's.
Super simple to setup, and easy for the end user.

- Henk.Tech

## Features

- Simple UI, your users only see a login screen and a shutdown button just like you'd want!
- Admin options are present but hidden behind secret passwords.
- Users can use the "ping" password to ping the remote server including a full trace route. You don't have to guess where the connection goes wrong just let them send you a picture.
- Error messages that make sense and include your own helpdesk info, your users know exactly who to contact and what to say (Written by an experienced sysadmin who also does first line support).
- Disk image that is not machine bound, you can capture it any time and redeploy your config on other machines. Hostnames change automatically based on the wired adapters mac address.
- Optimized RDP defaults, rdp will just work out of the box with optimal quality. If you need to customize this further the option is available.
- Based on the excellent xfreerdp project like most Linux based thinclients
- Xanmod 6.12 Kernel for wide device compatibility
- Docker as the build system making it easy to build your own custom image.
- auto-maintenance command for system updates (Own risk especially on auto update mode, if a bad update releases and you enabled automatic updates you have to manually roll back your machines).
- No external ports and minimal packages to reduce the attack surface even if the machine is outdated (The UI can be navigated easily over the phone, VNC is not neccesary. Instead if you need to assist users request remote access within the remote desktop.)

## Build your own image

Image building requires docker and can be done inside of WSL2 if desired.

```
./d2vm build . -o uftc.vhd --bootloader grub --boot-size 4000 --size 14G 
```

grub as the bootloader unlocks a few things most importantly uefi support, you also get a seperate fat32 boot partition where you can place the config files when provisioning.
Boot partition is a sizable 4GB to reduce the risk of running out of space for the kernels, with a total size of under 16GB this should fit on a 16GB USB stick if you wish to use a USB Stick for customization and capture.

Important: The modern kernel could not be included in the build process, boot your generated image in a VM once so it can finalize the build. Release images have this step completed.

## Usage

### Flashing to target media

This image is a direct drive image without an installer, you can directly flash it to the target media.
For flashing on Windows Rufus is compatible and directly compatible with the .vhd format.
On Linux you can use ``qemu-img convert /location/of.vhd /dev/targetdevice``

### Installing on the target device

Because we don't have an installer you have every possibility available for deployment that you'd like.
The recommended method is using RescueZilla on a Ventoy USB stick, this will allow you to deploy the provided VHD image as well as capture your own.

### WiFi

WiFi can be enabled by placing a suitable wpa_supplicant.conf on the boot partition.
Here is a template (Don't forget to change the country, I put china as the example due to the broadest range):

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CN
network={
	ssid="SSID GOES HERE"
	psk="Password goes here"
}
```

### Manual setup

If the thinclient is not preconfigured on the boot partition it will automatically boot its configuration screen.
Fill in the fields you require for your deployment, if your server is not connected to a domain leave this blank.
The parameters field are for additional xfreerdp parameters.
The helpdesk field will be used in the middle of error message sentences, for example "Please contact HELPDESK if this is not resolved after 5 minutes."

### Automatic setup

Just like the WiFi the settings for the thinclient software can also be preconfigured by placing a tcconfig file in the boot partition.
The template for this file is as follows (pay attention to the line endings, they need to be linux compatible):

```
server=
domain=
param=
volume=
adminpass=
helpdesk=
config_url=
```

### Remote Setup (Own risk)

If a config_url is defined the thinclient will automatically download its config file every time the login screen is shown.
As a safety measure the config is only written on a succesful download and the previous working URL is backed up to a seperate file (If your new location is succesful the old URL is overwritten).
Should the config become corrupt the backuped up config URL can be used to recover functionality, there are cases where the incorrect URL can become permanent such as migrating your production thinclients to the configuration of your development environment as this sets a working config_url . To help minimize this risk its recommended not to specify a config_url in configurations that are not meant for production (Do not leave it empty as this will disable remote setup, remove the line entirely).

Because of this and the inherent dangers of remote configuration ensure the config file webserver is well secured and the configuration files are well tested before mass deployment.
Even though this functionality was exploit tested it is a possible point of failure if a hacker finds a novel bash exploit or overwrites the RDP server with a malicious one.

tc_hostname in the URL is automatically replaced with the hostname of the thinclient to enable per client configuration.

You implement this functionality strictly on your own risk. If left blank this functionality is fully disabled.

### Citrix Mode

There is a basic Citrix mode on board that can be activated by putting citrix as the server name. Citrix currently needs to be manually configured.

### Root Account

In the release the root account is disabled with two exceptions that do not require a password:
auto-maintenance (Own risk), this tool can be used to manually update the system or can be used to enable automatic updates.
set-hostname , this tool changes the hostname of the thinclient. If the dynamic_hostname file is present in the user account hostnames will be set according to the macaddress of the wired adapter.
(Likewise the thinclient account has no default password)

When self building you can pass a -p parameter to enable the root password.

### Password commands

config : Re-open the config dialogue

terminal: Open the terminal

ping (without your admin password in front): Ping the RDP server with a full traceroute, users can change this to any required destination if needed.

## Terms of Use

- I currently don't know which formal license is the best fit, when using this software please respect the following:
- I am not responsible for what happens with your deployment, its designed to be as robust as I could make it. But should unforseen consequences, bugs or updates happen I am not liable as you accept you use and deploy this on your own risk especially if you enabled automatic updates and your company is now offline due to a bad/incompatible debian update.
- The software is free for both personal and business use and may not be resold. Preinstallation on physical hardware is allowed as long as it is made clear that it runs software based on this free repository.
- You have the freedom to make modifications to this software as long as you do not sell them (Henk.Tech does have the right to sell private modified builds). If distributed publically for free the source code must be provided (If it was modified manually list your changes and how to apply them, don't just post the image). For private internal modifications within your deployment this requirement does not apply  ( MSP's using it for a customer they manage counts as internal), but if anyone asks what software is running point them to the public repo.
- Please share your success stories in https://github.com/henk717/uftc/discussions/categories/show-and-tell , while I give out the software for free my reward is the satisfaction of knowing that my work made a positive difference in your organization. Of course for security reasons it is fine if you leave the company name out, deployment size will do.
- If I pick a formal license that embodies these terms your repo/deployment is retroactively licensed under the license of this (parent) repo on the condition that the new license is an open source license similar to the above (If not the above freedoms apply for any version prior to the license change).
