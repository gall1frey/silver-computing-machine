import argparse
import os

parser = argparse.ArgumentParser(description='SDR Listener')
parser.add_argument('-p','--sdr_port',help='PORT to send SDR data to')
args = parser.parse_args()

if not args.sdr_port:
	args.sdr_port = 4444

def tcp_server():
	os.system('nc -lvp {} | nc -lvp 1234'.format(args.sdr_port))

tcp_server()
