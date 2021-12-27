import argparse
import os

HOST = ''
PORT = 4446

parser = argparse.ArgumentParser(description='SDR Listener')
parser.add_argument('-P','--sdr_port',help='PORT to send SDR data to')

def tcp_server():
	os.system('nc -lvp {} | nc -lvp 1234'.format(args.sdr_port))

tcp_server()
