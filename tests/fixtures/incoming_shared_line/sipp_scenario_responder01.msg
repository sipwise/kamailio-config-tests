----------------------------------------------- 2021-08-16 06:46:28.103325
UDP message sent (567 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51605;branch=z9hG4bK-691980-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51605>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 20
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:28.129843
UDP message received [566] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51605;rport=51605;branch=z9hG4bK-691980-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 SUBSCRIBE
Proxy-Authenticate: Digest realm="incoming-shared-line.scenarios-pbx.test", nonce="YRnu0GEZ7aRLiUxxmyymvrHhPJiYusf+"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:28.129939
UDP message sent (490 bytes):

ACK sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51605;rport=51605;branch=z9hG4bK-691980-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 SUBSCRIBE
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:28.131157
UDP message sent (798 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51605;branch=z9hG4bK-691980-1-4
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Proxy-Authorization: Digest username="testuser1002",realm="incoming-shared-line.scenarios-pbx.test",uri="sip:192.168.211.202:5060",nonce="YRnu0GEZ7aRLiUxxmyymvrHhPJiYusf+",response="bc363baaf1696207f4c187414e802b26",algorithm=MD5
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 2 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51605>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 20
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:28.218567
UDP message received [844] bytes :

SIP/2.0 202 Accepted
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51605;rport=51605;branch=z9hG4bK-691980-1-4
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 2 SUBSCRIBE
Event: call-info
Allow-Events: call-info, line-seize
Expires: 20
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353036323b707278726f7574653d31>


----------------------------------------------- 2021-08-16 06:46:28.218640
UDP message received [1043] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51605 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKddf1.02ead20ff1996175891b5a999a23274c.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKddf1.84a418e3000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 1 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: active
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:28.218701
UDP message sent (541 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKddf1.02ead20ff1996175891b5a999a23274c.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKddf1.84a418e3000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 NOTIFY
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:33.529575
UDP message received [1219] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51605 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKadf1.1f87cc84e45aa8696f4e0735024eb167.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKadf1.4773c527000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 2 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1;appearance-state=active;appearance-uri="<sip:testuser1003@incoming-shared-line.scenarios-pbx.test>",<sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: active;expires=15
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:33.530009
UDP message sent (545 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKadf1.1f87cc84e45aa8696f4e0735024eb167.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKadf1.4773c527000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 2 NOTIFY
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:34.971080
UDP message received [1054] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51605 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKbdf1.31a141fc817917e018e5b269947b46d2.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKbdf1.ccce0d11000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 3 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: active;expires=14
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:34.972588
UDP message sent (545 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bKbdf1.31a141fc817917e018e5b269947b46d2.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKbdf1.ccce0d11000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 3 NOTIFY
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:35.989425
UDP message sent (567 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51605;branch=z9hG4bK-691980-1-14
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51605>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 0
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:36.053388
UDP message received [567] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51605;rport=51605;branch=z9hG4bK-691980-1-14
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 SUBSCRIBE
Proxy-Authenticate: Digest realm="incoming-shared-line.scenarios-pbx.test", nonce="YRnu2GEZ7axtLG/a23NeGq4+S5fc2Q8P"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:36.053474
UDP message sent (506 bytes):

ACK sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51605;rport=51605;branch=z9hG4bK-691980-1-14
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 1 ACK
Contact: <sip:testuser1002@10.20.29.2:51605>
Max-Forwards: 70
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:36.055336
UDP message sent (798 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51605;branch=z9hG4bK-691980-1-18
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Proxy-Authorization: Digest username="testuser1002",realm="incoming-shared-line.scenarios-pbx.test",uri="sip:192.168.211.202:5060",nonce="YRnu2GEZ7axtLG/a23NeGq4+S5fc2Q8P",response="25004f0dfd0ed2684b7be7f1fe815a03",algorithm=MD5
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 2 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51605>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 0
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:36.108071
UDP message received [844] bytes :

SIP/2.0 202 Accepted
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51605;rport=51605;branch=z9hG4bK-691980-1-18
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 2 SUBSCRIBE
Event: call-info
Allow-Events: call-info, line-seize
Expires: 0
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353036323b707278726f7574653d31>


----------------------------------------------- 2021-08-16 06:46:36.111258
UDP message received [1047] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51605 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691980SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK8df1.7ddee26e9e4806bdd5ec35c1871dd4bf.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK8df1.88ca9554000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 4 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: terminated
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:36.111325
UDP message sent (541 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK8df1.7ddee26e9e4806bdd5ec35c1871dd4bf.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK8df1.88ca9554000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691980SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691980@10.20.29.2
CSeq: 4 NOTIFY
Contact: <sip:10.20.29.2:51605;transport=UDP>
Content-Length: 0


