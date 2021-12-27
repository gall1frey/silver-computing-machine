import socket
import sys
import os
import argparse

parser = argparse.ArgumentParser(description='SDR Listener')
parser.add_argument('-p','--sdr_port',help='PORT to send SDR data to')
args = parser.parse_args()

HOST = ''
PORT = 4446

if not args.sdr_port:
	args.sdr_port = 4444

soc = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
	soc.bind((HOST, PORT))

except socket.error as massage:
	print('Bind failed. Error Code : '
		  + str(massage[0]) + ' Message '
		  + massage[1])
	sys.exit()

print('Socket binding operation completed')

soc.listen(1)

conn, address = soc.accept()
print('Connected with ' + address[0] + ':'
	  + str(address[1]))

print("\n\nENTER FREQUENCY IN HERTZ TO CHANGE IT, ENTER 'exit' TO QUIT!\n\n")


def tcp_server():
	print('nc -l {} | nc -lvp 1234'.format(args.sdr_port))
	os.system('nc -l {} | nc -lvp 1234'.format(args.sdr_port))

def change_freq():
	while True:
		freq = input("CHANGE FREQUENCT TO: ")
		if freq == 'exit':
			sys.exit()
		if freq.isdigit():
			tcp_server()
			conn.send(freq.encode())


#tcp_server()
change_freq()
