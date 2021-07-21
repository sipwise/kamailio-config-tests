----------------------------------------------- 2021-07-21 10:09:52.094700
UDP message sent (603 bytes):

INVITE sip:4311013@invite-alias-devid.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51617;branch=z9hG4bK-69270-1-0
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 1 INVITE
Contact: <sip:testuser1002@10.20.29.2:51617>
Max-Forwards: 70
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45045 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-21 10:09:52.096166
UDP message received [355] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51617;branch=z9hG4bK-69270-1-0;rport=51617
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:52.122652
UDP message received [543] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51617;rport=51617;branch=z9hG4bK-69270-1-0
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 1 INVITE
Proxy-Authenticate: Digest realm="invite-alias-devid.scenarios-pbx.test", nonce="YPfXfGD31lDQkVog3SD+rscjcgj8+37q"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:52.124363
UDP message sent (481 bytes):

ACK sip:4311013@invite-alias-devid.scenarios-pbx.test:5060 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51617;rport=51617;branch=z9hG4bK-69270-1-0
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 1 ACK
Contact: <sip:testuser1002@10.20.29.2:51617>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:52.630636
UDP message sent (830 bytes):

INVITE sip:4311013@invite-alias-devid.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51617;branch=z9hG4bK-69270-1-5
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 2 INVITE
Contact: <sip:testuser1002@10.20.29.2:51617>
Max-Forwards: 70
Proxy-Authorization: Digest username="testuser1002",realm="invite-alias-devid.scenarios-pbx.test",uri="sip:192.168.2.109:5060",nonce="YPfXfGD31lDQkVog3SD+rscjcgj8+37q",response="6ca5c4b2e29b13fd2a98328229b9747a",algorithm=MD5
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45045 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-21 10:09:52.632189
UDP message received [355] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51617;branch=z9hG4bK-69270-1-5;rport=51617
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 2 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:53.122322
UDP message received [988] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=69270SIPpTag001;did=627.03f;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyNZPjYDF2x/AEFwd3YoJUNvYHsgPH1zZE8DWXlJSzloeWE0EnZmbUcCDhUc>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Via: SIP/2.0/UDP 10.20.29.2:51617;rport=51617;branch=z9hG4bK-69270-1-5
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=77722426-60F7D650000F131C-FCD98700
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 2 INVITE
Content-Length: 0
P-Asserted-Identity: "1003" <sip:1003@invite-alias-devid.scenarios-pbx.test>
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-07-21 10:09:53.769802
UDP message received [1192] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=69270SIPpTag001;did=627.03f;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyNZPjYDF2x/AEFwd3YoJUNvYHsgPH1zZE8DWXlJSzloeWE0EnZmbUcCDhUc>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Via: SIP/2.0/UDP 10.20.29.2:51617;rport=51617;branch=z9hG4bK-69270-1-5
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=77722426-60F7D650000F131C-FCD98700
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 2 INVITE
Content-Type: application/sdp
Content-Length: 176
P-Asserted-Identity: "1003" <sip:1003@invite-alias-devid.scenarios-pbx.test>
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.2.109
s=-
c=IN IP4 192.168.2.109
t=0 0
m=audio 30224 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30225
a=ptime:50

----------------------------------------------- 2021-07-21 10:09:53.770040
UDP message sent (905 bytes):

ACK sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51617;branch=z9hG4bK-69270-1-10
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=77722426-60F7D650000F131C-FCD98700
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
Route: <sip:192.168.2.109;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1:5062;lr=on;ftag=69270SIPpTag001;did=627.03f;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyNZPjYDF2x/AEFwd3YoJUNvYHsgPH1zZE8DWXlJSzloeWE0EnZmbUcCDhUc>
CSeq: 2 ACK
Contact: <sip:testuser1002@10.20.29.2:51617>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:55.284075
UDP message sent (905 bytes):

BYE sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51617;branch=z9hG4bK-69270-1-14
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=77722426-60F7D650000F131C-FCD98700
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 3 BYE
Contact: <sip:testuser1002@10.20.29.2:51617>
Route: <sip:192.168.2.109;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>, <sip:127.0.0.1:5062;lr=on;ftag=69270SIPpTag001;did=627.03f;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=dWpydikdITIkKyNZPjYDF2x/AEFwd3YoJUNvYHsgPH1zZE8DWXlJSzloeWE0EnZmbUcCDhUc>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:55.459601
UDP message received [818] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=69270SIPpTag001;vsf=dWpydikdITIkKyNZPjYDF2x/AEFwd3YoJUNvYHsgPH1zZE8DWXlJSzloeWE0EnZmbUcCDhUc;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=69270SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.2.109:5060>
Via: SIP/2.0/UDP 10.20.29.2:51617;rport=51617;branch=z9hG4bK-69270-1-14
From: <sip:testuser1002@invite-alias-devid.scenarios-pbx.test>;tag=69270SIPpTag001
To: <sip:4311013@invite-alias-devid.scenarios-pbx.test>;tag=77722426-60F7D650000F131C-FCD98700
Call-ID: NGCP%invite_alias_devid%///1-69270@10.20.29.2
CSeq: 3 BYE
Content-Length: 0
P-Asserted-Identity: "1003" <sip:1003@invite-alias-devid.scenarios-pbx.test>


