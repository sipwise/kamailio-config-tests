----------------------------------------------- 2021-08-16 06:46:32.180117
UDP message received [1401] bytes :

INVITE sip:testuser1002@10.20.29.2:51608 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;did=c52.8001;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKc36d.7ce580233bccfd51fa7117cf58d114d5.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc36d.f8c42ce424f5550df738464a3888b1ee.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKX~X59aDn;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=7542D5F2-6119EDA8000119E1-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
CSeq: 2069 INVITE
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
Max-Forwards: 69
P-Asserted-Identity: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>
Content-Type: application/sdp
Content-Length: 180
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.211.202
s=-
c=IN IP4 192.168.211.202
t=0 0
m=audio 30058 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30059
a=ptime:50

----------------------------------------------- 2021-08-16 06:46:32.583472
UDP message sent (871 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKc36d.7ce580233bccfd51fa7117cf58d114d5.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc36d.f8c42ce424f5550df738464a3888b1ee.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKX~X59aDn;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=7542D5F2-6119EDA8000119E1-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692044SIPpTag011
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
CSeq: 2069 INVITE
Allow: INVITE, INFO, PRACK, ACK, BYE, CANCEL, OPTIONS, NOTIFY, REGISTER, SUBSCRIBE, REFER, PUBLISH, UPDATE, MESSAGE
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
Allow-Events: talk,hold,conference,refer,check-sync
Contact: <sip:10.20.29.2:51608;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:33.087518
UDP message sent (1423 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKc36d.7ce580233bccfd51fa7117cf58d114d5.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc36d.f8c42ce424f5550df738464a3888b1ee.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKX~X59aDn;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=7542D5F2-6119EDA8000119E1-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692044SIPpTag011
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
CSeq: 2069 INVITE
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>, <sip:127.0.0.1:5062;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;did=c52.8001;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Allow: INVITE, INFO, PRACK, ACK, BYE, CANCEL, OPTIONS, NOTIFY, REGISTER, SUBSCRIBE, REFER, PUBLISH, UPDATE, MESSAGE
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
Allow-Events: talk,hold,conference,refer,check-sync
Contact: <sip:10.20.29.2:51608;transport=UDP>
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45021 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-08-16 06:46:33.642311
UDP message received [1111] bytes :

ACK sip:10.20.29.2:51608;transport=UDP SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;rtpprx=yes;ice_callee=strip;ice_caller=strip;aset=50>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKc36d.4c30913fce599a76e75c85fa86684937.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKc36d.d564b27ba1f197601997fd6bc3025dda.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKz4qCKa0J;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=7542D5F2-6119EDA8000119E1-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692044SIPpTag011
CSeq: 2069 ACK
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-08-16 06:46:35.126376
UDP message received [1060] bytes :

BYE sip:10.20.29.2:51608;transport=UDP SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=7542D5F2-6119EDA8000119E1-8BB80700;rtpprx=yes>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK417d.ad024f67ba26627f958f299d002db3e8.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK417d.e5f1b5de7359e0cbc8be33c40de2572c.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKGdl4vaVn;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=7542D5F2-6119EDA8000119E1-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692044SIPpTag011
CSeq: 2070 BYE
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
Max-Forwards: 68
P-Asserted-Identity: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:35.127056
UDP message sent (620 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK417d.ad024f67ba26627f958f299d002db3e8.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK417d.e5f1b5de7359e0cbc8be33c40de2572c.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKGdl4vaVn;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=7542D5F2-6119EDA8000119E1-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692044SIPpTag011
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
CSeq: 2070 BYE
Contact: <sip:10.20.29.2:51608;transport=UDP>
Content-Length:     0


