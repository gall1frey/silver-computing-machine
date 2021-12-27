import os
import signal
import subprocess
import socket

IP = '192.168.0.157'
PORT = 1337
freq = 1000000
sdr_port = '4444'

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((IP,PORT))

pro = subprocess.Popen('rtl_sdr -f {} - | nc {} {}'.format(freq,IP,sdr_port),shell=True,preexec_fn=os.setsid)
print('rtl_sdr -f 1000000 | nc {} {}'.format(IP,'9999'))
while True:
    freq_ = s.recv(1024).decode().strip()
    if freq_ == 'exit':
        exit()
    if freq_.isdigit():
        freq = int(freq)
        os.killpg(os.getpgid(pro.pid), signal.SIGTERM)
        pro = subprocess.Popen('rtl_sdr -f {}  - | nc {} {}'.format(freq,IP,sdr_port),shell=True,preexec_fn=os.setsid)

os.killpg(os.getpgid(pro.pid), signal.SIGTERM)
