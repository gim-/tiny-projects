#JC2-MP Server Management Tool
This script allows anyone to easily deploy and manage [JC2-MP](http://www.jc-mp.com/) server on GNU/Linux (or any \*nix) operating system.

##The script provides:
* Automatic user-friendly JC2-MP server installation
* Server management: start, stop, restart
* Server update
* Server status check
* Server console access

## Dependencies
Script is using [GNU Screen](https://www.gnu.org/software/screen/) in a back-end, so you need to make sure it's installed. You also need to install some libraries for [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) if you're using 64-bit system.

### Debian/Ubuntu x32
```
sudo apt-get update
sudo apt-get install screen
```

### Debian/Ubuntu x64
```
sudo apt-get update
sudo apt-get install screen lib32gcc1 libc6-i386 lib32stdc++6
```

### RedHat/CentOS/Fedora x32
```
yum install screen
```

### RedHat/CentOS/Fedora x64
```
yum install screen glibc.i686 libstdc++.i686
```

### Arch Linux x32
```
pacman -S screen --needed
```

### Arch Linux x64
[multilib repository](https://wiki.archlinux.org/index.php/Multilib) should be enabled first.
```
pacman -S screen lib32-gcc-libs --needed
```

## How to use
First, you need to download the script and allow it to execute
```
wget https://raw.githubusercontent.com/gim-/tiny-projects/master/JC2MP-Server-Management/jc2mp.sh
chmod +x jc2mp.sh
```
Now you can run it: `./jc2mp.sh`

The script is designed to be user-friendly, so everything after this is pretty much straight-forward. At the first start, you will get a prompt whether or not you want to install a new JC2-MP server and where:
<img src="http://storage9.static.itmages.com/i/14/1223/h_1419371136_8625725_b4d552e2e8.png" />
(Note: if you want to use a custom path, please make sure it's absolute (starting from /) and you have write access to it.)

Then it will ask you to specify MaxPlayer limit, port, name and description. If everything succeeds, you will get the main command prompt. Type help to see the list of available commands.
<img src="http://storage7.static.itmages.com/i/14/1223/h_1419371078_2728238_7636146c6f.png" />

