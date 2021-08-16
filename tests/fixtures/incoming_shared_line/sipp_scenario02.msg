----------------------------------------------- 2021-08-16 06:46:30.019014
UDP message sent (685 bytes):

INVITE sip:1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51606;branch=z9hG4bK-692096-1-1
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
CSeq: 1 INVITE
Contact: <sip:testuser1003@10.20.29.2:51606>
Max-Forwards: 70
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45015 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-08-16 06:46:30.019101
UDP message received [361] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51606;branch=z9hG4bK-692096-1-1;rport=51606
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 1 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:30.061862
UDP message received [551] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51606;rport=51606;branch=z9hG4bK-692096-1-1
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 1 INVITE
Proxy-Authenticate: Digest realm="incoming-shared-line.scenarios-pbx.test", nonce="YRnu0mEZ7aYAADn4ccoxqD0fZfRIGCYC"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:30.062892
UDP message sent (563 bytes):

ACK sip:1002@incoming-shared-line.scenarios-pbx.test:5060 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51606;rport=51606;branch=z9hG4bK-692096-1-1
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
CSeq: 1 ACK
Contact: <sip:testuser1003@10.20.29.2:51606>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:30.580397
UDP message sent (916 bytes):

INVITE sip:1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51606;branch=z9hG4bK-692096-1-6
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
CSeq: 2 INVITE
Contact: <sip:testuser1003@10.20.29.2:51606>
Max-Forwards: 70
Proxy-Authorization: Digest username="testuser1003",realm="incoming-shared-line.scenarios-pbx.test",uri="sip:192.168.211.202:5060",nonce="YRnu0mEZ7aYAADn4ccoxqD0fZfRIGCYC",response="ddd8bd58c35ce8a6085061d508ba4b19",algorithm=MD5
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45015 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-08-16 06:46:30.580443
UDP message received [361] bytes :

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 10.20.29.2:51606;branch=z9hG4bK-692096-1-6;rport=51606
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 2 INVITE
Server: Sipwise NGCP LB 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:32.394738
UDP message received [1122] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=692096SIPpTag001;did=f12.1af;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=d2JoazMwOy0dNzwRaFdCJmp1fnt1Zm9iOThiYUtjaBsoUkZeCC9jcXxte3B1eic1Sm4/CHhBRiE->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51606;rport=51606;branch=z9hG4bK-692096-1-6
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=5B198A52-6119EDA7000C54A0-52DED700
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 2 INVITE
Allow: INVITE, PRACK, ACK, BYE, CANCEL, OPTIONS, NOTIFY, REGISTER, SUBSCRIBE, REFER, PUBLISH, UPDATE, MESSAGE
Content-Length: 0
P-Asserted-Identity: "1002" <sip:1002@incoming-shared-line.scenarios-pbx.test>
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-08-16 06:46:33.064582
UDP message received [1122] bytes :

SIP/2.0 180 Ringing
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=692096SIPpTag001;did=f12.1af;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=d2JoazMwOy0dNzwRaFdCJmp1fnt1Zm9iOThiYUtjaBsoUkZeCC9jcXxte3B1eic1Sm4/CHhBRiE->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51606;rport=51606;branch=z9hG4bK-692096-1-6
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=796115D3-6119EDA8000104FA-52CEC700
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 2 INVITE
Allow: INVITE, PRACK, ACK, BYE, CANCEL, OPTIONS, NOTIFY, REGISTER, SUBSCRIBE, REFER, PUBLISH, UPDATE, MESSAGE
Content-Length: 0
P-Asserted-Identity: "1002" <sip:1002@incoming-shared-line.scenarios-pbx.test>
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>


----------------------------------------------- 2021-08-16 06:46:33.364599
UDP message received [1330] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=692096SIPpTag001;did=f12.1af;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=d2JoazMwOy0dNzwRaFdCJmp1fnt1Zm9iOThiYUtjaBsoUkZeCC9jcXxte3B1eic1Sm4/CHhBRiE->
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51606;rport=51606;branch=z9hG4bK-692096-1-6
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=796115D3-6119EDA8000104FA-52CEC700
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 2 INVITE
Allow: INVITE, PRACK, ACK, BYE, CANCEL, OPTIONS, NOTIFY, REGISTER, SUBSCRIBE, REFER, PUBLISH, UPDATE, MESSAGE
Content-Type: application/sdp
Content-Length: 180
P-Asserted-Identity: "1002" <sip:1002@incoming-shared-line.scenarios-pbx.test>
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.211.202
s=-
c=IN IP4 192.168.211.202
t=0 0
m=audio 30008 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30009
a=ptime:50

----------------------------------------------- 2021-08-16 06:46:33.366890
UDP message sent (1003 bytes):

ACK sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51606;branch=z9hG4bK-692096-1-11
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=796115D3-6119EDA8000104FA-52CEC700
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>, <sip:127.0.0.1:5062;lr=on;ftag=692096SIPpTag001;did=f12.1af;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=d2JoazMwOy0dNzwRaFdCJmp1fnt1Zm9iOThiYUtjaBsoUkZeCC9jcXxte3B1eic1Sm4/CHhBRiE->
CSeq: 2 ACK
Contact: <sip:testuser1003@10.20.29.2:51606>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:34.878449
UDP message sent (1003 bytes):

BYE sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353038303b707278726f7574653d31 SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51606;branch=z9hG4bK-692096-1-15
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=796115D3-6119EDA8000104FA-52CEC700
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1
CSeq: 3 BYE
Contact: <sip:testuser1003@10.20.29.2:51606>
Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>, <sip:127.0.0.1:5062;lr=on;ftag=692096SIPpTag001;did=f12.1af;ice_caller=strip;ice_callee=strip;aset=50;rtpprx=yes;vsf=d2JoazMwOy0dNzwRaFdCJmp1fnt1Zm9iOThiYUtjaBsoUkZeCC9jcXxte3B1eic1Sm4/CHhBRiE->
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:35.224611
UDP message received [839] bytes :

SIP/2.0 200 OK
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=692096SIPpTag001;vsf=d2JoazMwOy0dNzwRaFdCJmp1fnt1Zm9iOThiYUtjaBsoUkZeCC9jcXxte3B1eic1Sm4/CHhBRiE-;rtpprx=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692096SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51606;rport=51606;branch=z9hG4bK-692096-1-15
From: <sip:testuser1003@incoming-shared-line.scenarios-pbx.test>;tag=692096SIPpTag001
To: <sip:1002@incoming-shared-line.scenarios-pbx.test>;tag=796115D3-6119EDA8000104FA-52CEC700
Call-ID: NGCP%incoming_shared_line%///1-692096@10.20.29.2
CSeq: 3 BYE
Content-Length: 0
P-Asserted-Identity: "1002" <sip:1002@incoming-shared-line.scenarios-pbx.test>


