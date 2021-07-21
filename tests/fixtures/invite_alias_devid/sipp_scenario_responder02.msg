----------------------------------------------- 2021-07-21 10:09:53.040439
UDP message received [1358] bytes :

INVITE sip:4311013@10.20.29.2:51618 SIP/2.0
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;did=734.801;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK3719.e4f67a4d3714130414bfb5086b794fe8.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK3719.5f5bf84d137f4d9a7a1993ec5ffa5298.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKfMNkma83;rport=5080
From: <sip:4311010@invite-alias-devid.scenarios-pbx.test>;tag=62A32CAE-60F7D650000F16F8-3DBCD700
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>
CSeq: 436 INVITE
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2_pbx-1
Max-Forwards: 69
P-Asserted-Identity: <sip:4311010@invite-alias-devid.scenarios-pbx.test>
Content-Type: application/sdp
Content-Length: 176
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.2.109
s=-
c=IN IP4 192.168.2.109
t=0 0
m=audio 30238 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30239
a=ptime:50

----------------------------------------------- 2021-07-21 10:09:53.040949
UDP message sent (604 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK3719.e4f67a4d3714130414bfb5086b794fe8.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK3719.5f5bf84d137f4d9a7a1993ec5ffa5298.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKfMNkma83;rport=5080
From: <sip:4311010@invite-alias-devid.scenarios-pbx.test>;tag=62A32CAE-60F7D650000F16F8-3DBCD700
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=69179SIPpTag011
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2_pbx-1
CSeq: 436 INVITE
Contact: <sip:10.20.29.2:51618;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:53.551672
UDP message sent (1149 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK3719.e4f67a4d3714130414bfb5086b794fe8.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK3719.5f5bf84d137f4d9a7a1993ec5ffa5298.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKfMNkma83;rport=5080
From: <sip:4311010@invite-alias-devid.scenarios-pbx.test>;tag=62A32CAE-60F7D650000F16F8-3DBCD700
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=69179SIPpTag011
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2_pbx-1
CSeq: 436 INVITE
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>, <sip:127.0.0.1:5062;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;did=734.801;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes>
Contact: <sip:10.20.29.2:51618;transport=UDP>
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45048 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-21 10:09:53.831546
UDP message received [1083] bytes :

ACK sip:10.20.29.2:51618;transport=UDP SIP/2.0
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;rtpprx=yes;ice_callee=strip;ice_caller=strip;aset=50>
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK3719.ec7f65832c6f5519f388dc5aa53d3891.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK3719.94cf4b0acb3198d8af2f8e7c23890083.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKsvGu6alZ;rport=5080
From: <sip:4311010@invite-alias-devid.scenarios-pbx.test>;tag=62A32CAE-60F7D650000F16F8-3DBCD700
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=69179SIPpTag011
CSeq: 436 ACK
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2_pbx-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-07-21 10:09:55.418778
UDP message received [1028] bytes :

BYE sip:10.20.29.2:51618;transport=UDP SIP/2.0
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;ngcplb=yes;socket=sip:192.168.2.109:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=62A32CAE-60F7D650000F16F8-3DBCD700;rtpprx=yes>
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK4719.8ebdcd25907288e7994ffd0cb7a8ff64.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK4719.eb1f6743bf7d7349c088854c444d5963.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKBkZ0.aU2;rport=5080
From: <sip:4311010@invite-alias-devid.scenarios-pbx.test>;tag=62A32CAE-60F7D650000F16F8-3DBCD700
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=69179SIPpTag011
CSeq: 437 BYE
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2_pbx-1
Max-Forwards: 68
P-Asserted-Identity: <sip:4311010@invite-alias-devid.scenarios-pbx.test>
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:55.419047
UDP message sent (600 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK4719.8ebdcd25907288e7994ffd0cb7a8ff64.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK4719.eb1f6743bf7d7349c088854c444d5963.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKBkZ0.aU2;rport=5080
From: <sip:4311010@invite-alias-devid.scenarios-pbx.test>;tag=62A32CAE-60F7D650000F16F8-3DBCD700
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=69179SIPpTag011
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2_pbx-1
CSeq: 437 BYE
Contact: <sip:10.20.29.2:51618;transport=UDP>
Content-Length:     0


