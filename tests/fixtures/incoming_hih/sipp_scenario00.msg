----------------------------------------------- 2021-07-15 18:07:54.574155
UDP message sent (760 bytes):

INVITE sip:4311001@incoming-hih.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-445952-1-0
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
CSeq: 1 INVITE
Contact: <sip:004321001@172.30.1.2:52602>
History-Info: <sip:+4313012026@incoming-hih.scenarios.test;user=phone?privacy=history>;index=1
History-Info: <sip:+4311001@incoming-hih.scenarios.test;user=phone;cause=302>;index=1.1
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

----------------------------------------------- 2021-07-15 18:07:54.582804
UDP message received [340] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-445952-1-0;rport=52602
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-15 18:07:56.332690
UDP message received [769] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=445952SIPpTag001;did=09c.1f21>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 172.30.1.2:52602;rport=52602;branch=z9hG4bK-445952-1-0
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>;tag=7DFA4E86-60F05D5B00013184-C33E0700
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
CSeq: 1 INVITE
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-07-15 18:07:57.005211
UDP message received [991] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=445952SIPpTag001;did=09c.1f21>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 172.30.1.2:52602;rport=52602;branch=z9hG4bK-445952-1-0
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>;tag=7DFA4E86-60F05D5B00013184-C33E0700
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
CSeq: 1 INVITE
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 30154 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30155
a=ptime:50
a=direction:both

----------------------------------------------- 2021-07-15 18:07:57.005538
UDP message sent (760 bytes):

ACK sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-445952-1-5
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>;tag=7DFA4E86-60F05D5B00013184-C33E0700
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=445952SIPpTag001;did=09c.1f21>
CSeq: 1 ACK
Contact: <sip:004321001@172.30.1.2:52602>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-15 18:07:58.519503
UDP message sent (760 bytes):

BYE sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 172.30.1.2:52602;branch=z9hG4bK-445952-1-9
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>;tag=7DFA4E86-60F05D5B00013184-C33E0700
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
CSeq: 2 BYE
Contact: <sip:004321001@172.30.1.2:52602>
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=445952SIPpTag001;did=09c.1f21>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-15 18:07:58.919636
UDP message received [639] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=445952SIPpTag001>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=445952SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 172.30.1.2:52602;rport=52602;branch=z9hG4bK-445952-1-9
From: <sip:004321001@incoming-hih.host0.peer.scenarios.test>;tag=445952SIPpTag001
To: <sip:4311001@incoming-hih.scenarios.test>;tag=7DFA4E86-60F05D5B00013184-C33E0700
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2
CSeq: 2 BYE
Content-Length: 0


