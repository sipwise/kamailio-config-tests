----------------------------------------------- 2021-07-05 18:05:29.946856
UDP message received [1341] bytes :

INVITE sip:testuser1001@10.20.30.1:52634 SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=24430ECE-60E32DC9000C8803-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=24430ECE-60E32DC9000C8803-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=24430ECE-60E32DC9000C8803-9B7C7700;did=e82.d2f1>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.e7fdf4aae72d511626ce9347414fc4e8.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.ce87f0bbfca37d50bdf5d834794573b9.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKD0a~Oaib;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=24430ECE-60E32DC9000C8803-9B7C7700
To: <sip:testuser1001@invite-redirect-tel-uri.scenarios.test>
CSeq: 10 INVITE
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
Max-Forwards: 69
P-Asserted-Identity: <sip:4311129@invite-redirect-tel-uri.scenarios.test>
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 31486 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:31487
a=ptime:50
a=direction:both

----------------------------------------------- 2021-07-05 18:05:29.948518
UDP message sent (739 bytes):

SIP/2.0 302 Moved Temporarily
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.e7fdf4aae72d511626ce9347414fc4e8.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.ce87f0bbfca37d50bdf5d834794573b9.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKD0a~Oaib;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=24430ECE-60E32DC9000C8803-9B7C7700
To: <sip:testuser1001@invite-redirect-tel-uri.scenarios.test>;tag=65405SIPpTag001
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
CSeq: 10 INVITE
Contact: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test;transport=UDP>
Diversion: <sip:4311130@invite-redirect-tel-uri.scenarios.test;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:29.949358
UDP message received [435] bytes :

ACK sip:testuser1001@10.20.30.1:52634 SIP/2.0
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.e7fdf4aae72d511626ce9347414fc4e8.0
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=24430ECE-60E32DC9000C8803-9B7C7700
To: <sip:testuser1001@invite-redirect-tel-uri.scenarios.test>;tag=65405SIPpTag001
CSeq: 10 ACK
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
Max-Forwards: 69
Content-Length: 0


