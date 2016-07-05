# Retropie-Manager
Recalbox-Manager fork for RetroPie 4.x

![alt tag](https://github.com/botolo78/RetroPie-Manager/blob/retropie/screenshot.png)

# About

This is a very dirty Recalbox-Manager fork aimed to be used with RetroPie 4.x **running on Raspberry Pi**.

Original repository: https://github.com/recalbox/recalbox-manager

# Features
With Retropie-Manager you can
- Monitor the raspberry health and disk space
- Edit the Emulation Station config file
- Edit the RetroArch config file
- Edit the autostart.sh script
- View the Emulation Station log file
- Manage your BIOS files
- Manage your ROMS

# Limitations

- In this release the virtual gamepad page has been removed.
- It is tested in Raspberry Pi. Some users reported problems to install it on an ubuntu-based RetroPie installation (the ubuntu repositories don't have the virtualenv package).
- It doesn't support subdirectories at ROMs dir (as reported [here](https://github.com/botolo78/RetroPie-Manager/issues/9))


# Install
```sh
$ sudo apt-get install virtualenv python-dev
```

```sh
$ cd
$ git clone https://github.com/botolo78/RetroPie-Manager.git
$ cd RetroPie-Manager
$ make install
```

# Usage

```sh
$ /home/pi/RetroPie-Manager/bin/python /home/pi/RetroPie-Manager/manage.py runserver 0.0.0.0:8000 --settings=project.settings_production --noreload
```
Open your browser and go to **http://your_retropie_ip:8000/**

# Autostart
To make Retropie-Manager to start with your raspberry edit your autostart.sh

```sh
$ sudo nano /opt/retropie/configs/all/autostart.sh
```
and add this command before **emulationstation #auto**

```sh
/home/pi/RetroPie-Manager/bin/python /home/pi/RetroPie-Manager/manage.py runserver 0.0.0.0:8000 --settings=project.settings_production --noreload > /dev/null 2>&1 &
```

# Update
```sh
$ sudo kill -9 $(pgrep -f RetroPie-Manager)
$ cd 
$ cd Retropie-Manager
$ make clean
$ git reset --hard HEAD
$ git pull
$ make install
```

# Reinstall
```sh
$ sudo kill -9 $(pgrep -f RetroPie-Manager)
$ cd 
$ rm -rf Retropie-Manager
$ git clone https://github.com/botolo78/RetroPie-Manager.git
$ cd RetroPie-Manager
$ make install
```
# Stop RetroPie-Manager

```sh
$ sudo kill -9 $(pgrep -f RetroPie-Manager)
```

# Known bugs

- (FIXED) You'll get a 404 error trying to delete roms
