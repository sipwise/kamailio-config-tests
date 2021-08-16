----------------------------------------------- 2021-08-16 06:46:31.895215
UDP message received [1401] bytes :

INVITE sip:testuser1002@10.20.29.2:51607 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=4C85A051-6119EDA7000C7EAC-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=4C85A051-6119EDA7000C7EAC-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=4C85A051-6119EDA7000C7EAC-8BB80700;did=c52.7001;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5934.850595cf7b8c6d5598ad2d5f06890547.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK5934.ea430803a2fe3d27015d8014bd9ef726.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKOslfRark;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=4C85A051-6119EDA7000C7EAC-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
CSeq: 1037 INVITE
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
m=audio 30028 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30029
a=ptime:50

----------------------------------------------- 2021-08-16 06:46:32.199454
UDP message sent (871 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5934.850595cf7b8c6d5598ad2d5f06890547.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK5934.ea430803a2fe3d27015d8014bd9ef726.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKOslfRark;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=4C85A051-6119EDA7000C7EAC-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692000SIPpTag011
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
CSeq: 1037 INVITE
Allow: INVITE, INFO, PRACK, ACK, BYE, CANCEL, OPTIONS, NOTIFY, REGISTER, SUBSCRIBE, REFER, PUBLISH, UPDATE, MESSAGE
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
Allow-Events: talk,hold,conference,refer,check-sync
Contact: <sip:10.20.29.2:51607;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:33.381712
UDP message received [429] bytes :

CANCEL sip:testuser1002@10.20.29.2:51607 SIP/2.0
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5934.850595cf7b8c6d5598ad2d5f06890547.0
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=4C85A051-6119EDA7000C7EAC-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
CSeq: 1037 CANCEL
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
Max-Forwards: 69
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:33.381779
UDP message sent (428 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5934.850595cf7b8c6d5598ad2d5f06890547.0
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=4C85A051-6119EDA7000C7EAC-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
CSeq: 1037 CANCEL
Contact: <sip:10.20.29.2:51607;transport=UDP>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:33.382884
UDP message sent (996 bytes):

SIP/2.0 487 Request terminated
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5934.850595cf7b8c6d5598ad2d5f06890547.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK5934.ea430803a2fe3d27015d8014bd9ef726.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKOslfRark;rport=5080
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=4C85A051-6119EDA7000C7EAC-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=4C85A051-6119EDA7000C7EAC-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=4C85A051-6119EDA7000C7EAC-8BB80700;ngcplb=yes;socket=sip:192.168.211.202:5060>, <sip:127.0.0.1:5062;lr=on;ftag=4C85A051-6119EDA7000C7EAC-8BB80700;did=c52.7001;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
CSeq: 1037 INVITE
Contact: <sip:10.20.29.2:51607;transport=UDP>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:33.383153
UDP message received [423] bytes :

ACK sip:testuser1002@10.20.29.2:51607 SIP/2.0
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5934.850595cf7b8c6d5598ad2d5f06890547.0
From: <sip:43110001003@incoming-shared-line.scenarios-pbx.test>;tag=4C85A051-6119EDA7000C7EAC-8BB80700
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
CSeq: 1037 ACK
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2_pbx-1
Max-Forwards: 69
Content-Length: 0


