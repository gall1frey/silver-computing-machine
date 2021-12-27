# SDR MiTM
Author: [Gallifrey](https://github.com/gall1frey) (Mallika)

This is my submission for Sainya Ranakshetram 2021 SDR Level 3. This framework can be used to generate trojans to spy on SDR communications and spawning reverse shells - both on Linux and Windows.

## Notes
1. This repository helps **generate** a trojan. The repository itself is not a trojan. However, for the sake of simplicity, one linux and one windows trojan have been already generated. These can be found in their respective directories. These trojans assume the attacker's IP to be `192.168.0.157`.
2. The project has been made keeping minimal dependencies in mind, that is, as long as a computer (Linux or Windows) has the driver for the SDR installed, the **trojan will work**. It doesn't need the victim to have anything else installed.
3. **Assumptions made**:
  * The attacker and the victim are on the **same network**. (This assumption can be worked around using port forwarding and stuff)
  * The attacker has a Linux machine, preferably `Ubuntu 20.04` or `Kali 2021.04`. However, a windows machine with `Kali running on WSL2` has also been tested and works fine.
  * The victim machine has an **SDR driver installed**.
4. I did not understand the challenge, so this solution is my interpretation of it. I interpreted the challenge as follows:
  * **Machine A (victim)** exists in a remote location, receiving communications via Software Defined Radio.
  * **Machine B (attacker)** wishes to have access to this communication, but is out of range of machine A.
  * The trojan is generated on B and planted in A using some social engineering techniques.
  * The trojan has to:
      1. Send SDR communications over to B.
      2. Provide B a backdoor into A.
  * The trojan achieves this by:
      1. Piping input from A's SDR receiver to B over TCP.

        ***Why TCP? Why not SDR itself?***

        *Because I figured machine A will be easily able to find out there is an outgoing transmission and that jeopardises the stealth of the trojan.*
      2. Creating a reverse shell connection.

5. The trojan is made keeping in mind **stealth**. Measures have been taken to ensure it goes undetected for a long time.

6. Finally, due to unavailability of a LimeSDR, this project has been created for and tested on an RTL-SDR. I understand that that was *not* the requirement, but I figured I'd rather submit a working and tested PoC than a untested and uncertain PoC that may or may not work, and may or may not be correct.

## Dependencies
The project has been made keeping minimal dependencies in mind. It just won't do to have our exploit be dependent on a certain program when those may or may not be found on the victim's machine.

The windows reverse shell is achieved using **visual basic**

linux reverse shell uses **/dev/tcp**

Due to the absence of a LimeSDR, and difficulties in obtaining one, the project works, and has been tested on a **RTL-SDR**.

### List of Dependencies
The machine used to generate trojans must have:
```
1. g++-mingw-w64-x86-64 (assuming the victim windows machine is a 64 bit one)
2. python3
  a. os
  b. system
  c. base64
  d. socket
  e. gzip
  f. pyinstaller (if Windows)
  g. GNUradio + osmosdr (if Windows)
  h. argparse
3. g++
```  
The victim machine must have:
```
1. Visual Basic (If windows)
2. bash (If linux)
3. rtl_sdr driver
4. python (If Linux)
  a. socket
  b. os
  c. base64
```
## Usage
Usage of exploit generator has been tested on Ubuntu 20.04 for linux and Kali 2021.4 for windows
### Creation of trojan
#### Linux
1. cd into the project directory
  ```
  cd random_proj2
  ```
2. run ```create_trojan.sh``` as root
```
sudo ./create_trojan.sh
```
3. Target OS = ```linux``` (it is case sensitive)
4. IP address of attacker (shell) = ```IP address on which to get reverse shell```

    Default is ```192.168.0.1```
5. PORT to get reverse shell = ```Port on which to listen for reverse shell```

    Default is ```9999```
6. PORT to get SDR comm = ```Port on which to listen for SDR stream```

    Default is ```4444```

**That's all!**

#### Windows
1. cd into the project directory
  ```
  cd random_proj2
  ```
2. run ```create_trojan.sh``` as root
```
sudo ./create_trojan.sh
```
3. Target OS = ```windows``` (it is case sensitive)
4. IP address of attacker (shell) = ```IP address on which to get reverse shell```

    Default is ```192.168.0.1```

**That's all!**

### Exploiting
#### Linux
The trojan, ```freesweep.deb``` is generated in the `GENERATED_EXPLOIT` directory.

Get this deb file to the victim and have them install the game on their system. A CronRAT infects their system and starts a reverse shell and SDR stream every minute. (the code can me modified to have the cronRAT execute at any interval of time)

**Why CronRAT?**

*It's a relatively newly discovered vector of attack on linux machines, and hence undetected by most antiviruses.*

**Why a deb file, why not a png or pdf?**
*Installing deb files occurs as root. Gets us root privilege faster.*

Accessing the reverse shell: `nc -lvp <PORT SPECIFIED>`

Accessing the SDR stream: `python3 handlers/linux_sdr.py -p <SDR PORT SPECIFIED EARLIER>`

`linux_sdr.py` is available in the root directory of the project, and it allows for listening to custom frequencies. The mechanism has been tested on WSL-Kali Linux and SDR sharp.

#### Windows
The trojans, `util.exe` and `util2.exe` are generated in the `GENERATED_EXPLOIT` directory.

Hide these exe files with any other program and send it to the victim. The process of doing this is shown in the video.

Once the victim opens the file, a reverse shell is spawned.

A sample trojan, generated by the above script is included in this repository, in the `windows_trojan` directory. It is configured to talk to the host with IP address `192.168.0.158` in the same network as the victim.

Access the reverse shell by running `sudo python3 handlers/server.py` and SDR using `sudo python3 handlers/win_sdr.py -p <SDR PORT SPECIFIED EARLIER>` The file can be found in the root directory of the project. *Note that this script will have to be run as root*

**Why root?**

*To bypass any antiviruses/firewalls, the reverse shell payload (written in visual basic) uses HTTP to communicate with the attacker machine. All commands and their responses are sent as HTTP requests to attacker's PORT 80.*

***Note that this project has been tested in an environment where both the attacker and victim machines were in the same Local Area Network***
