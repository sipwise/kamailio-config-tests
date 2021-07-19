----------------------------------------------- 2021-07-19 16:24:57.700106
UDP message sent (658 bytes):

INVITE sip:testuser1003@invite-allowedcli-match-alias.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51619;branch=z9hG4bK-176808-1-0
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 1 INVITE
Contact: <sip:testuser1002@10.20.29.2:51619>
Max-Forwards: 70
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2192.168.1.152
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45047 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-19 16:24:57.700809
UDP message received [398] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51619;branch=z9hG4bK-176808-1-0;rport=51619
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-19 16:24:57.771346
UDP message received [593] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51619;rport=51619;branch=z9hG4bK-176808-1-0
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 1 INVITE
Proxy-Authenticate: Digest realm="invite-allowedcli-match-alias.scenarios.test", nonce="YPWMZWD1izmaagckORb3dRbLlq90u7JE"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-19 16:24:57.772324
UDP message sent (536 bytes):

ACK sip:testuser1003@invite-allowedcli-match-alias.scenarios.test:5060 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51619;rport=51619;branch=z9hG4bK-176808-1-0
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 1 ACK
Contact: <sip:testuser1002@10.20.29.2:51619>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-19 16:24:58.285523
UDP message sent (892 bytes):

INVITE sip:testuser1003@invite-allowedcli-match-alias.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51619;branch=z9hG4bK-176808-1-5
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 2 INVITE
Contact: <sip:testuser1002@10.20.29.2:51619>
Max-Forwards: 70
Proxy-Authorization: Digest username="testuser1002",realm="invite-allowedcli-match-alias.scenarios.test",uri="sip:192.168.1.152:5060",nonce="YPWMZWD1izmaagckORb3dRbLlq90u7JE",response="9ad9b9e784227b71b9e9f5288bce1ec1",algorithm=MD5
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45047 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-19 16:24:58.287587
UDP message received [398] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51619;branch=z9hG4bK-176808-1-5;rport=51619
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 2 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-19 16:24:59.175987
UDP message received [968] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=176808SIPpTag001;did=b39.f87;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyBZPjYDF2x/AEFwcngsbUNsdH8hf2l+YgAMWGtJXyslbXxtVix2a2NrJGBkWUt2ByYlAQ-->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.29.2:51619;rport=51619;branch=z9hG4bK-176808-1-5
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=76C2584B-60F58B3A000EA551-3D1BA700
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 2 INVITE
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-07-19 16:24:59.763506
UDP message received [1172] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=176808SIPpTag001;did=b39.f87;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyBZPjYDF2x/AEFwcngsbUNsdH8hf2l+YgAMWGtJXyslbXxtVix2a2NrJGBkWUt2ByYlAQ-->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.29.2:51619;rport=51619;branch=z9hG4bK-176808-1-5
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=76C2584B-60F58B3A000EA551-3D1BA700
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 2 INVITE
Content-Type: application/sdp
Content-Length: 176
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 30204 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30205
a=ptime:50

----------------------------------------------- 2021-07-19 16:24:59.763982
UDP message sent (963 bytes):

ACK sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51619;branch=z9hG4bK-176808-1-10
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=76C2584B-60F58B3A000EA551-3D1BA700
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=176808SIPpTag001;did=b39.f87;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyBZPjYDF2x/AEFwcngsbUNsdH8hf2l+YgAMWGtJXyslbXxtVix2a2NrJGBkWUt2ByYlAQ-->
CSeq: 2 ACK
Contact: <sip:testuser1002@10.20.29.2:51619>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-19 16:25:01.280091
UDP message sent (963 bytes):

BYE sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51619;branch=z9hG4bK-176808-1-14
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=76C2584B-60F58B3A000EA551-3D1BA700
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 3 BYE
Contact: <sip:testuser1002@10.20.29.2:51619>
Route: <sip:192.168.1.152;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=176808SIPpTag001;did=b39.f87;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyBZPjYDF2x/AEFwcngsbUNsdH8hf2l+YgAMWGtJXyslbXxtVix2a2NrJGBkWUt2ByYlAQ-->
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-19 16:25:02.243551
UDP message received [798] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=176808SIPpTag001;vsf=dWpydikdITIkKyBZPjYDF2x/AEFwcngsbUNsdH8hf2l+YgAMWGtJXyslbXxtVix2a2NrJGBkWUt2ByYlAQ--;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=176808SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.1.152:5060>
Via: SIP/2.0/UDP 10.20.29.2:51619;rport=51619;branch=z9hG4bK-176808-1-14
From: "4311013" <sip:testuser1002@invite-allowedcli-match-alias.scenarios.test>;tag=176808SIPpTag001
To: <sip:testuser1003@invite-allowedcli-match-alias.scenarios.test>;tag=76C2584B-60F58B3A000EA551-3D1BA700
Call-ID: NGCP%invite_allowedcli_match_alias%///1-176808@10.20.29.2
CSeq: 3 BYE
Content-Length: 0


