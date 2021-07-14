----------------------------------------------- 2021-07-15 08:51:02.872542
UDP message received [1329] bytes :

INVITE sip:testuser1003@10.20.29.2:51605 SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;did=e4c.9ec2>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKc63a.dad31646d9243069d41eaf18e0ea40c9.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc63a.c704fdbf31527c59c4c4b721bf9db25d.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bK7Xluyaom;rport=5080
From: <sip:external@incoming-foreign-dom.external.test>;tag=36A623DE-60EFDAD6000CCE2D-E96AC700
To: <sip:testuser1003@incoming-foreign-dom.scenarios.test>
CSeq: 10 INVITE
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2_b2b-1
Max-Forwards: 69
P-Asserted-Identity: <sip:external@incoming-foreign-dom.external.test>
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 30000 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30001
a=ptime:50
a=direction:both

----------------------------------------------- 2021-07-15 08:51:02.876292
UDP message sent (606 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKc63a.dad31646d9243069d41eaf18e0ea40c9.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc63a.c704fdbf31527c59c4c4b721bf9db25d.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bK7Xluyaom;rport=5080
From: <sip:external@incoming-foreign-dom.external.test>;tag=36A623DE-60EFDAD6000CCE2D-E96AC700
To: <sip:testuser1003@incoming-foreign-dom.scenarios.test>;tag=42769SIPpTag011
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2_b2b-1
CSeq: 10 INVITE
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-15 08:51:03.393142
UDP message sent (1099 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKc63a.dad31646d9243069d41eaf18e0ea40c9.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc63a.c704fdbf31527c59c4c4b721bf9db25d.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bK7Xluyaom;rport=5080
From: <sip:external@incoming-foreign-dom.external.test>;tag=36A623DE-60EFDAD6000CCE2D-E96AC700
To: <sip:testuser1003@incoming-foreign-dom.scenarios.test>;tag=42769SIPpTag011
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2_b2b-1
CSeq: 10 INVITE
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;did=e4c.9ec2>
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45011 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-15 08:51:03.680095
UDP message received [1032] bytes :

ACK sip:10.20.29.2:51605;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKc63a.e3e6fa03bdec818d57a5e28017afd15b.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc63a.b15de8a4e9cf8bebad5dd15718a014f8.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKxpnpVa0t;rport=5080
From: <sip:external@incoming-foreign-dom.external.test>;tag=36A623DE-60EFDAD6000CCE2D-E96AC700
To: <sip:testuser1003@incoming-foreign-dom.scenarios.test>;tag=42769SIPpTag011
CSeq: 10 ACK
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2_b2b-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-07-15 08:51:05.191460
UDP message received [1017] bytes :

BYE sip:10.20.29.2:51605;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=36A623DE-60EFDAD6000CCE2D-E96AC700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKd63a.294ccd7e93a7535d7a8eed15a443369f.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKd63a.f704b8bdd7cf6848e455cb233b0b8dec.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKiz33EaxZ;rport=5080
From: <sip:external@incoming-foreign-dom.external.test>;tag=36A623DE-60EFDAD6000CCE2D-E96AC700
To: <sip:testuser1003@incoming-foreign-dom.scenarios.test>;tag=42769SIPpTag011
CSeq: 11 BYE
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2_b2b-1
Max-Forwards: 68
P-Asserted-Identity: <sip:external@incoming-foreign-dom.external.test>
Content-Length: 0


----------------------------------------------- 2021-07-15 08:51:05.191665
UDP message sent (602 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKd63a.294ccd7e93a7535d7a8eed15a443369f.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKd63a.f704b8bdd7cf6848e455cb233b0b8dec.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKiz33EaxZ;rport=5080
From: <sip:external@incoming-foreign-dom.external.test>;tag=36A623DE-60EFDAD6000CCE2D-E96AC700
To: <sip:testuser1003@incoming-foreign-dom.scenarios.test>;tag=42769SIPpTag011
Call-ID: NGCP%incoming_foreign_dom%///1-42789@10.20.29.2_b2b-1
CSeq: 11 BYE
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length:     0


