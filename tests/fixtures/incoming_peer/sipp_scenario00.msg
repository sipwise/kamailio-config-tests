----------------------------------------------- 2021-07-21 12:54:08.270041
UDP message sent (557 bytes):

INVITE sip:4311000@incoming-peer.scenarios-lnp.test SIP/2.0
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-128684-1-0
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
CSeq: 1 INVITE
Contact: <sip:004321001@172.30.1.2:52602>
Max-Forwards: 70
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 172.30.1.2
s=-
c=IN IP4 172.30.1.2
t=0 0
m=audio 46003 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-21 12:54:08.270169
UDP message received [317] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-128684-1-0;rport=52602
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-21 12:54:08.989450
UDP message received [746] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=128684SIPpTag001;did=dd8.5d51>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Via: SIP/2.0/UDP 172.30.1.2:52602;rport=52602;branch=z9hG4bK-128684-1-0
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>;tag=51BF81BF-60F7FCD000079A96-87FFF700
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
CSeq: 1 INVITE
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-07-21 12:54:09.568639
UDP message received [950] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=128684SIPpTag001;did=dd8.5d51>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Via: SIP/2.0/UDP 172.30.1.2:52602;rport=52602;branch=z9hG4bK-128684-1-0
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>;tag=51BF81BF-60F7FCD000079A96-87FFF700
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
CSeq: 1 INVITE
Content-Type: application/sdp
Content-Length: 176
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.2.109
s=-
c=IN IP4 192.168.2.109
t=0 0
m=audio 30472 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30473
a=ptime:50

----------------------------------------------- 2021-07-21 12:54:09.568850
UDP message sent (737 bytes):

ACK sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-128684-1-5
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>;tag=51BF81BF-60F7FCD000079A96-87FFF700
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
Route: <sip:192.168.2.109;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1:5062;lr=on;ftag=128684SIPpTag001;did=dd8.5d51>
CSeq: 1 ACK
Contact: <sip:004321001@172.30.1.2:52602>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 12:54:11.076910
UDP message sent (737 bytes):

BYE sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-128684-1-9
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>;tag=51BF81BF-60F7FCD000079A96-87FFF700
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
CSeq: 2 BYE
Contact: <sip:004321001@172.30.1.2:52602>
Route: <sip:192.168.2.109;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1:5062;lr=on;ftag=128684SIPpTag001;did=dd8.5d51>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 12:54:11.363907
UDP message received [616] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=128684SIPpTag001>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=128684SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Via: SIP/2.0/UDP 172.30.1.2:52602;rport=52602;branch=z9hG4bK-128684-1-9
From: <sip:004321001@127.0.2.1>;tag=128684SIPpTag001
To: <sip:4311000@incoming-peer.scenarios-lnp.test>;tag=51BF81BF-60F7FCD000079A96-87FFF700
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2
CSeq: 2 BYE
Content-Length: 0


