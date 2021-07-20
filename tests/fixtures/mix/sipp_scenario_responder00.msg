----------------------------------------------- 2021-07-20 11:00:31.613771
UDP message received [1217] bytes :

INVITE sip:E1112@172.30.1.2:52602;transport=udp SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;did=431.e771>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK2aa1.df56c4416da0d978f31f916b91547dd3.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK2aa1.5b8b530dce96fb797ee82335b2ab3b4f.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKQ7TPOaI8;rport=5080
From: <sip:4311049@invite-emergency.scenarios.test>;tag=53E70CC1-60F690AF0008EAB4-BA7EE700
To: <sip:E1112@172.30.1.2>
CSeq: 2935 INVITE
Call-ID: NGCP%invite_emergency%///1-179067@10.20.29.2_pbx-1
Max-Forwards: 69
P-Asserted-Identity: <sip:4311049@invite-emergency.scenarios.test>
Content-Type: application/sdp
Content-Length: 176
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 30626 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30627
a=ptime:50

----------------------------------------------- 2021-07-20 11:00:31.616530
UDP message sent (570 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK2aa1.df56c4416da0d978f31f916b91547dd3.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK2aa1.5b8b530dce96fb797ee82335b2ab3b4f.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKQ7TPOaI8;rport=5080
From: <sip:4311049@invite-emergency.scenarios.test>;tag=53E70CC1-60F690AF0008EAB4-BA7EE700
To: <sip:E1112@172.30.1.2>;tag=179047SIPpTag011
Call-ID: NGCP%invite_emergency%///1-179067@10.20.29.2_pbx-1
CSeq: 2935 INVITE
Contact: <sip:172.30.1.2:52602;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-20 11:00:32.123381
UDP message sent (1003 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK2aa1.df56c4416da0d978f31f916b91547dd3.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK2aa1.5b8b530dce96fb797ee82335b2ab3b4f.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKQ7TPOaI8;rport=5080
From: <sip:4311049@invite-emergency.scenarios.test>;tag=53E70CC1-60F690AF0008EAB4-BA7EE700
To: <sip:E1112@172.30.1.2>;tag=179047SIPpTag011
Call-ID: NGCP%invite_emergency%///1-179067@10.20.29.2_pbx-1
CSeq: 2935 INVITE
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>, <sip:127.0.0.1;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>, <sip:127.0.0.1:5062;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;did=431.e771>
Contact: <sip:172.30.1.2:52602;transport=UDP>
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

----------------------------------------------- 2021-07-20 11:00:32.341996
UDP message received [936] bytes :

ACK sip:172.30.1.2:52602;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK2aa1.8ac59f2766830c4e00c1ce7aa2635028.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK2aa1.a4232a23e01af25b4f87b4ef59883bf8.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bK75Zf4a1J;rport=5080
From: <sip:4311049@invite-emergency.scenarios.test>;tag=53E70CC1-60F690AF0008EAB4-BA7EE700
To: <sip:E1112@172.30.1.2>;tag=179047SIPpTag011
CSeq: 2935 ACK
Call-ID: NGCP%invite_emergency%///1-179067@10.20.29.2_pbx-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-07-20 11:00:33.817566
UDP message received [917] bytes :

BYE sip:172.30.1.2:52602;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700;ngcplb=yes>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=53E70CC1-60F690AF0008EAB4-BA7EE700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKf9a1.d303694b06767ae9e89c3dae003bc76f.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKf9a1.9be24d40c1a4832133ba38f9a88e9712.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKq45F.agi;rport=5080
From: <sip:4311049@invite-emergency.scenarios.test>;tag=53E70CC1-60F690AF0008EAB4-BA7EE700
To: <sip:E1112@172.30.1.2>;tag=179047SIPpTag011
CSeq: 2936 BYE
Call-ID: NGCP%invite_emergency%///1-179067@10.20.29.2_pbx-1
Max-Forwards: 68
P-Asserted-Identity: <sip:4311049@invite-emergency.scenarios.test>
Content-Length: 0


----------------------------------------------- 2021-07-20 11:00:33.817989
UDP message sent (566 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKf9a1.d303694b06767ae9e89c3dae003bc76f.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKf9a1.9be24d40c1a4832133ba38f9a88e9712.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKq45F.agi;rport=5080
From: <sip:4311049@invite-emergency.scenarios.test>;tag=53E70CC1-60F690AF0008EAB4-BA7EE700
To: <sip:E1112@172.30.1.2>;tag=179047SIPpTag011
Call-ID: NGCP%invite_emergency%///1-179067@10.20.29.2_pbx-1
CSeq: 2936 BYE
Contact: <sip:172.30.1.2:52602;transport=UDP>
Content-Length:     0


