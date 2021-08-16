----------------------------------------------- 2021-08-16 06:46:28.087627
UDP message sent (567 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51603;branch=z9hG4bK-691964-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51603>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 20
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:28.098903
UDP message received [566] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51603;rport=51603;branch=z9hG4bK-691964-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 SUBSCRIBE
Proxy-Authenticate: Digest realm="incoming-shared-line.scenarios-pbx.test", nonce="YRnu0GEZ7aRLiUxxmyymvrHhPJiYusf+"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:28.099000
UDP message sent (490 bytes):

ACK sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51603;rport=51603;branch=z9hG4bK-691964-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 SUBSCRIBE
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:28.100172
UDP message sent (798 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51603;branch=z9hG4bK-691964-1-4
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Proxy-Authorization: Digest username="testuser1002",realm="incoming-shared-line.scenarios-pbx.test",uri="sip:192.168.211.202:5060",nonce="YRnu0GEZ7aRLiUxxmyymvrHhPJiYusf+",response="bc363baaf1696207f4c187414e802b26",algorithm=MD5
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 2 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51603>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 20
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:28.182746
UDP message received [844] bytes :

SIP/2.0 202 Accepted
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51603;rport=51603;branch=z9hG4bK-691964-1-4
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 2 SUBSCRIBE
Event: call-info
Allow-Events: call-info, line-seize
Expires: 20
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353036323b707278726f7574653d31>


----------------------------------------------- 2021-08-16 06:46:28.183652
UDP message received [1043] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51603 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK7c39.ba52242cd37f6e18dc0fd966823c1cc3.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK7c39.a0663941000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 1 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: active
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:28.183722
UDP message sent (541 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK7c39.ba52242cd37f6e18dc0fd966823c1cc3.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK7c39.a0663941000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 NOTIFY
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:33.532763
UDP message received [1219] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51603 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK4c39.d6cb826d31d257f31cfe4b7a2855266e.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK4c39.35d797b0000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 2 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=1;appearance-state=active;appearance-uri="<sip:testuser1003@incoming-shared-line.scenarios-pbx.test>",<sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: active;expires=15
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:33.533445
UDP message sent (545 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK4c39.d6cb826d31d257f31cfe4b7a2855266e.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK4c39.35d797b0000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 2 NOTIFY
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:34.970985
UDP message received [1054] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51603 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5c39.2f66192281b91d5d10d9ec23e6bccdaf.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK5c39.d518e116000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 3 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: active;expires=14
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:34.972773
UDP message sent (545 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK5c39.2f66192281b91d5d10d9ec23e6bccdaf.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK5c39.d518e116000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 3 NOTIFY
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:35.989769
UDP message sent (567 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51603;branch=z9hG4bK-691964-1-14
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51603>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 0
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:36.029846
UDP message received [567] bytes :

SIP/2.0 407 Proxy Authentication Required
Via: SIP/2.0/UDP 10.20.29.2:51603;rport=51603;branch=z9hG4bK-691964-1-14
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 SUBSCRIBE
Proxy-Authenticate: Digest realm="incoming-shared-line.scenarios-pbx.test", nonce="YRnu2GEZ7axtLG/a23NeGq4+S5fc2Q8P"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:36.029951
UDP message sent (502 bytes):

ACK sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51603;rport=51603;branch=z9hG4bK-691964-1-14
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 1 ACK
Contact: <sip:testuser1002@10.20.29.2:51603>
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-08-16 06:46:36.031770
UDP message sent (798 bytes):

SUBSCRIBE sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51603;branch=z9hG4bK-691964-1-18
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Proxy-Authorization: Digest username="testuser1002",realm="incoming-shared-line.scenarios-pbx.test",uri="sip:192.168.211.202:5060",nonce="YRnu2GEZ7axtLG/a23NeGq4+S5fc2Q8P",response="25004f0dfd0ed2684b7be7f1fe815a03",algorithm=MD5
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 2 SUBSCRIBE
Contact: <sip:testuser1002@10.20.29.2:51603>
Allow: INVITE,ACK,CANCEL,BYE,PRACK,INFO,UPDATE,OPTIONS,MESSAGE,NOTIFY,REFER
Max-Forwards: 70
Expires: 0
Event: call-info
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:36.117987
UDP message received [844] bytes :

SIP/2.0 202 Accepted
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51603;rport=51603;branch=z9hG4bK-691964-1-18
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 2 SUBSCRIBE
Event: call-info
Allow-Events: call-info, line-seize
Expires: 0
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a353036323b707278726f7574653d31>


----------------------------------------------- 2021-08-16 06:46:36.118048
UDP message received [1047] bytes :

NOTIFY sip:testuser1002@10.20.29.2:51603 SIP/2.0
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=691964SIPpTag001;ngcplb=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK2c39.ca9ddfc2d95254c92468fc5f2d092054.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK2c39.f39ac8f2000000000000000000000000.0
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
CSeq: 4 NOTIFY
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
Max-Forwards: 69
Content-Length: 0
User-Agent: Sipwise NGCP Proxy 9.X
Call-Info: <sip:incoming-shared-line.scenarios-pbx.test>;appearance-index=*;appearance-state=idle
Event: call-info
Subscription-State: terminated
Contact: <sip:ngcp-lb@192.168.211.202:5060;ngcpct=7369703a3132372e302e302e313a35303632>


----------------------------------------------- 2021-08-16 06:46:36.118096
UDP message sent (541 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.211.202;branch=z9hG4bK2c39.ca9ddfc2d95254c92468fc5f2d092054.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK2c39.f39ac8f2000000000000000000000000.0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=f3067022b00c564156251ba2f28f331f-78550000
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=691964SIPpTag001
Call-ID: NGCP%incoming_shared_line_sub%///1-691964@10.20.29.2
CSeq: 4 NOTIFY
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length: 0


