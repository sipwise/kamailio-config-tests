----------------------------------------------- 2021-07-05 18:05:28.222319
UDP message sent (646 bytes):

INVITE sip:testuser1001@invite-redirect-tel-uri.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:52633;branch=z9hG4bK-65445-1-0
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>
Diversion: <tel:+43111222333>;reason=unconditional;privacy=off;counter=1
P-Asserted-Identity: <tel:+4311129>
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 1 INVITE
Contact: <sip:testuser1000@10.20.30.1:52633>
Max-Forwards: 70
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.30.1
s=-
c=IN IP4 10.20.30.1
t=0 0
m=audio 46077 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-05 18:05:28.223193
UDP message received [281] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.30.1:52633;branch=z9hG4bK-65445-1-0;rport=52633
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:28.362496
UDP message received [470] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.30.1:52633;rport=52633;branch=z9hG4bK-65445-1-0
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 1 INVITE
Proxy-Authenticate: Digest realm="invite-redirect-tel-uri.scenarios.test", nonce="YOMu9GDjLcjdbPZCCRRK37E3AHH865R4"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:28.362816
UDP message sent (452 bytes):

ACK sip:testuser1001@invite-redirect-tel-uri.scenarios.test:5060 SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:52633;rport=52633;branch=z9hG4bK-65445-1-0
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130@invite-redirect-tel-uri.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 1 ACK
Contact: <sip:testuser1000@10.20.30.1:52633>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:28.869286
UDP message sent (874 bytes):

INVITE sip:testuser1001@invite-redirect-tel-uri.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:52633;branch=z9hG4bK-65445-1-5
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>
Diversion: <tel:+43111222333>;reason=unconditional;privacy=off;counter=1
P-Asserted-Identity: <tel:+4311129>
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 2 INVITE
Contact: <sip:testuser1000@10.20.30.1:52633>
Max-Forwards: 70
Proxy-Authorization: Digest username="testuser1000",realm="invite-redirect-tel-uri.scenarios.test",uri="sip:192.168.1.152:5060",nonce="YOMu9GDjLcjdbPZCCRRK37E3AHH865R4",response="8376a2cb472c33d21fc80f766d62e3f6",algorithm=MD5
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.30.1
s=-
c=IN IP4 10.20.30.1
t=0 0
m=audio 46077 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-05 18:05:28.871797
UDP message received [281] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.30.1:52633;branch=z9hG4bK-65445-1-5;rport=52633
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:004311130>
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 2 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:31.648035
UDP message received [922] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=65445SIPpTag001;did=cba.8281;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dHx5SklQR3l3ank/HTsALAMRSjQWFAw4MzQxVAMMHmsBJx9rBBcCKBICDCUleTEcBB0-;vst=dHx5SlZXRXl3aXJGNDwYMx4AAmsBFQEjJDImDVodFypZIAQsWQcEIx0RFyM5JGsNEhoGfQEmEzdKBA8pHRU->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.30.1:52633;rport=52633;branch=z9hG4bK-65445-1-5
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>;tag=3D64D403-60E32DCB00028282-9950C700
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 2 INVITE
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-07-05 18:05:32.282912
UDP message received [1144] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=65445SIPpTag001;did=cba.8281;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dHx5SklQR3l3ank/HTsALAMRSjQWFAw4MzQxVAMMHmsBJx9rBBcCKBICDCUleTEcBB0-;vst=dHx5SlZXRXl3aXJGNDwYMx4AAmsBFQEjJDImDVodFypZIAQsWQcEIx0RFyM5JGsNEhoGfQEmEzdKBA8pHRU->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.30.1:52633;rport=52633;branch=z9hG4bK-65445-1-5
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>;tag=3D64D403-60E32DCB00028282-9950C700
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 2 INVITE
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 31498 RTP/AVP 8
a=direction:both
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:31499
a=ptime:50

----------------------------------------------- 2021-07-05 18:05:32.283356
UDP message sent (916 bytes):

ACK sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:52633;branch=z9hG4bK-65445-1-9
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>;tag=3D64D403-60E32DCB00028282-9950C700
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=65445SIPpTag001;did=cba.8281;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dHx5SklQR3l3ank/HTsALAMRSjQWFAw4MzQxVAMMHmsBJx9rBBcCKBICDCUleTEcBB0-;vst=dHx5SlZXRXl3aXJGNDwYMx4AAmsBFQEjJDImDVodFypZIAQsWQcEIx0RFyM5JGsNEhoGfQEmEzdKBA8pHRU->
CSeq: 2 ACK
Contact: <sip:testuser1000@10.20.30.1:52633>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:33.800329
UDP message sent (871 bytes):

BYE sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:52633;branch=z9hG4bK-65445-1-13
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>;tag=3D64D403-60E32DCB00028282-9950C700
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 3 BYE
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=65445SIPpTag001;did=cba.8281;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dHx5SklQR3l3ank/HTsALAMRSjQWFAw4MzQxVAMMHmsBJx9rBBcCKBICDCUleTEcBB0-;vst=dHx5SlZXRXl3aXJGNDwYMx4AAmsBFQEjJDImDVodFypZIAQsWQcEIx0RFyM5JGsNEhoGfQEmEzdKBA8pHRU->
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:34.280748
UDP message received [735] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=65445SIPpTag001;vsf=dHx5SklQR3l3ank/HTsALAMRSjQWFAw4MzQxVAMMHmsBJx9rBBcCKBICDCUleTEcBB0-;vst=dHx5SlZXRXl3aXJGNDwYMx4AAmsBFQEjJDImDVodFypZIAQsWQcEIx0RFyM5JGsNEhoGfQEmEzdKBA8pHRU-;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=65445SIPpTag001;ngcplb=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.30.1:52633;rport=52633;branch=z9hG4bK-65445-1-13
From: <tel:+4311129>;tag=65445SIPpTag001
To: <tel:+4311130>;tag=3D64D403-60E32DCB00028282-9950C700
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1
CSeq: 3 BYE
Content-Length: 0


