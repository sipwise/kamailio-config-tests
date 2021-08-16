----------------------------------------------- 2021-08-16 06:46:28.670214
UDP message sent (437 bytes):

OPTIONS sip:testuser1002@incoming-shared-line.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-692067-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692067SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>
Call-ID: NGCP%incoming_shared_line_opt%///1-692067@10.20.29.2
CSeq: 1 OPTIONS
Contact: <sip:testuser1002@10.20.29.2:51602>
Content-Length:     0


----------------------------------------------- 2021-08-16 06:46:28.712562
UDP message received [660] bytes :

SIP/2.0 200 Alive
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=692067SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Record-Route: <sip:192.168.211.202;r2=on;lr=on;ftag=692067SIPpTag001;ngcplb=yes;nat=yes;socket=udp:192.168.211.202:5060>
Via: SIP/2.0/UDP 10.20.29.2:51602;rport=51602;branch=z9hG4bK-692067-1-0
From: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=692067SIPpTag001
To: <sip:testuser1002@incoming-shared-line.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%incoming_shared_line_opt%///1-692067@10.20.29.2
CSeq: 1 OPTIONS
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


