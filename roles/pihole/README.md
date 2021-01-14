# ansible-pi

![](https://raw.github.com/motdotla/ansible-pi/master/ansible-pi.jpg)

Setup your Raspberry Pi as Pi-Hole DNS server, WITHOUT WIFI (Ethernet Only).

It is based on the [complete guide to setting up your raspberry pi without a keyboard and
mouse](http://sendgrid.com/blog/complete-guide-set-raspberry-pi-without-keyboard-mouse/) that goes
along with this repo.

## Requirements

- Flash a **clean** Raspbian Lite image on an SD card
  URL: https://www.raspberrypi.org/downloads/raspbian/
  Mac: Use [ApplePI-Baker](https://www.tweaking4all.com/software/macosx-software/macosx-apple-pi-baker/)
- Enable SSH on the Raspberry (it is disabled by default). You can:
    - use `raspi-config` to enable SSH
    - create a file `/boot/ssh`
- Find the IP address your router will give to the RPI
- You need Ansible installed on your local computer (not the Raspberry Pi)
- Install SSHPass:
  - Ubuntu: `sudo apt install sshpass`
  - MacOS: `brew install http://git.io/sshpass.rb`

## Installation

On your local computer, clone and setup this ansible playbook.

```
git clone https://github.com/stibbons/ansible-rpi-pihole.git
cd ansible-rpi-pihole
cp hosts.example hosts
```

Edit the `hosts` file and set the IP address of your RPI (get this from the router or from the
command line).

Deploy using [ansible](http://www.ansible.com) (install instructions for ansible are in [requirements](#requirements) below).

```
./playbook.yml
```

Or:
```
ansible-playbook playbook.yml -i hosts --ask-pass --become -c paramiko
```

## Installing Ansible on your computer


### On Mac with Homebrew

```
brew install ansible
```

### On Mac without Homebrew

```
cd /tmp
git clone git://github.com/ansible/ansible.git
cd ./ansible
git checkout v1.4.3
sudo make install
sudo easy_install jinja2
sudo easy_install pyyaml
sudo easy_install paramiko
```

## History

This project was originally built when trying out my first Raspberry Pi. The setup process was not
as easy as I wanted.
