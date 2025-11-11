# -*- coding: utf-8 -*-

__author__ = 'Mayank Gupta'
__version__ = '1.0P1'
__license__ = 'License :: MIT License'

import socket
import threading,ssl
import re
class porn():
	def __init__(self):
		s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.bind((HOST,PORT))
		print(f'Server Started at {HOST}:{PORT}')
		s.listen()
		while True:
			conn, client_addr = s.accept()
			threading.Thread(target=self.handle,args=(conn,client_addr,)).start()
	def hparsec_resv(self,data):
		headers =  data.split(b'\r\n\r\n')[0]
		if headers:
			html = data[len(headers)+4:]
			headers=headers.decode().split("\r\n")
			out={}
			out["status"]=headers[0].split()[1]
			if len(headers[0].split()) == 4:
				out["status_text"]=headers[0].split()[2]+" "+headers[0].split()[3]
			else:
				out["status_text"]=headers[0].split()[2]
			for n in headers[1:]:
				temp=n.split(":")
				value=""
				for n in temp[1:]:
					value+=n+":"
				out[temp[0].lower()]=value[1:len(value)-1]
			return out
	def toserver(self,data):
		try:
			so=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
			so.connect((wwwWebsite,WebsitePort))
			so.settimeout(50)
			so = ssl.create_default_context().wrap_socket(so, server_hostname=Website)
			so.send(data)
			s=b''
			while True:
				d=so.recv(2048)
				if not d:break
				s+=d
			return s
		except:
			s=b'HTTP/1.1 200 OK\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nContent-Type: text/html\r\nDate: Sat, 15 Feb 2020 07:04:42 GMT\r\nConnection: close\r\n\r\n<html><head><title>ISP ERROR</title></head><body><p style="text-align: center;">&nbsp;</p><p style="text-align: center;">&nbsp;</p><p style="text-align: center;">&nbsp;</p><p style="text-align: center;">&nbsp;</p><p style="text-align: center;">&nbsp;</p><p style="text-align: center;">&nbsp;</p><p style="text-align: center;"><span><strong>**YOU ARE NOT AUTHORIZED TO ACCESS THIS WEB PAGE AS PER THE DOT COMPLIANCE**</strong></span></p><p style="text-align: center;"><span><strong>**YOUR ISP SUCKS**</strong></span></p></body></html>'
			return s
	def filterbeforesend(self,ss):
		final=ss.replace(Website.encode(),YourWebsite.encode()).replace(b'Transfer-Encoding: chunked\r\n',b'').replace(b'Location: https://www.'+YourWebsite.encode()+b'\r\n',b'Location: http://'+YourWebsite.encode()+b'\r\n')
		return re.sub(b'\r\n\r\n.*?\r\n', b'\r\n\r\n',final)
	def json_to_send(self,d,endi):
		# print(d)
		s=f"{d['method']} {d['query']} HTTP/1.1\r\n"
		d['host']=wwwWebsite
		d['connection']='close'
		for n in d.keys():
			if n not in ["query","method","accept-encoding","accept"]:
				ss=f"{n}: {d[n]}\r\n"
				s+=ss
		s+=f"\r\n{endi}"
		return s.encode('ascii')
	def hparsec(self,data):
		headers =  data.split(b'\r\n\r\n')[0]
		img=data.split(b'\r\n\r\n')[1].decode()
		if headers:
			html = data[len(headers)+4:]
			headers=headers.decode().split("\r\n")
			out={}
			out["query"]=headers[0].split()[1]
			out["method"]=headers[0].split()[0]
			for n in headers[1:]:
				temp=n.split(":")
				value=""
				for n in temp[1:]:
					value+=n+":"
				out[temp[0].lower()]=value[1:len(value)-1]
			return out,img
	def handle(self,conn,ip):
		rawreq = conn.recv(2048)
		temp='HTTP/1.1 200 OK\r\nConnection: close\r\n\r\n{}'
		jso,ok=self.hparsec(rawreq)
		newsend=self.json_to_send(jso,ok)
		what=self.toserver(newsend)
		response_header=self.hparsec_resv(what)
		conn.send(self.filterbeforesend(what))
		conn.close()
		print(f"HTTP/1.1   {jso['query']:<50} {jso['method']:<10} {response_header['status_text']+' '+response_header['status']:<15} {ip[0]}")

if __name__ == '__main__':
	WebsitePort=443
	wwwWebsite="www.xnxx.com"
	Website='xnxx.com'
	YourWebsite='mayank.com' #Your Website Here
	HOST="127.0.0.1"
	PORT=80
	porn()