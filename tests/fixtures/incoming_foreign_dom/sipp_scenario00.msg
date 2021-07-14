----------------------------------------------- 2021-07-15 08:51:02.428206
UDP message sent (590 bytes):

INVITE sip:4311001@incoming-foreign-dom.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51604;branch=z9hG4bK-42789-1-0
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 1 INVITE
Contact: <sip:external@10.20.29.2:51604>
Max-Forwards: 70
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45008 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-15 08:51:02.428580
UDP message received [348] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51604;branch=z9hG4bK-42789-1-0;rport=51604
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-15 08:51:02.465579
UDP message received [355] bytes :

SIP/2.0 101 Connecting
Via: SIP/2.0/UDP 10.20.29.2:51604;rport=51604;branch=z9hG4bK-42789-1-0
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 1 INVITE
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-15 08:51:02.976069
UDP message received [826] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=42789SIPpTag001;did=2eb.6fe;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.29.2:51604;rport=51604;branch=z9hG4bK-42789-1-0
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>;tag=272DD5B6-60EFDAD6000CC9AB-C33E0700
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 1 INVITE
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-07-15 08:51:03.535318
UDP message received [1048] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=42789SIPpTag001;did=2eb.6fe;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.29.2:51604;rport=51604;branch=z9hG4bK-42789-1-0
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>;tag=272DD5B6-60EFDAD6000CC9AB-C33E0700
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 1 INVITE
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 30020 RTP/AVP 8
a=direction:both
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30021
a=ptime:50

----------------------------------------------- 2021-07-15 08:51:03.535591
UDP message sent (816 bytes):

ACK sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51604;branch=z9hG4bK-42789-1-6
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>;tag=272DD5B6-60EFDAD6000CC9AB-C33E0700
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=42789SIPpTag001;did=2eb.6fe;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
CSeq: 1 ACK
Contact: <sip:external@10.20.29.2:51604>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-15 08:51:05.046181
UDP message sent (817 bytes):

BYE sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51604;branch=z9hG4bK-42789-1-10
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>;tag=272DD5B6-60EFDAD6000CC9AB-C33E0700
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 2 BYE
Contact: <sip:external@10.20.29.2:51604>
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=42789SIPpTag001;did=2eb.6fe;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-15 08:51:05.311928
UDP message received [656] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=42789SIPpTag001;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=42789SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.29.2:51604;rport=51604;branch=z9hG4bK-42789-1-10
From: <sip:external@incoming-foreign-dom.external.test>;tag=42789SIPpTag001
To: <sip:4311001@incoming-foreign-dom.scenarios.test>;tag=272DD5B6-60EFDAD6000CC9AB-C33E0700
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2
CSeq: 2 BYE
Content-Length: 0


