----------------------------------------------- 2021-07-05 18:08:30.957826
UDP message sent (400 bytes):

REGISTER sip:testuser1003@invite-callforward.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:51652;branch=z9hG4bK-70263-1-0
From: <sip:testuser1003@invite-callforward.scenarios.test>;tag=70263SIPpTag001
To: <sip:testuser1003@invite-callforward.scenarios.test>
Call-ID: NGCP%register%///1-70263@10.20.30.1
CSeq: 1 REGISTER
Contact: <sip:testuser1003@10.20.30.1:51652>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-05 18:08:31.040076
UDP message received [479] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.30.1:51652;rport=51652;branch=z9hG4bK-70263-1-0
From: <sip:testuser1003@invite-callforward.scenarios.test>;tag=70263SIPpTag001
To: <sip:testuser1003@invite-callforward.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%register%///1-70263@10.20.30.1
CSeq: 1 REGISTER
WWW-Authenticate: Digest realm="invite-callforward.scenarios.test", nonce="YOMvq2DjLn/NHP53+e8jHZxrkjA933pD"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-05 18:08:31.040570
UDP message sent (607 bytes):

REGISTER sip:testuser1003@invite-callforward.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.30.1:51652;branch=z9hG4bK-70263-1-3
From: <sip:testuser1003@invite-callforward.scenarios.test>;tag=70263SIPpTag001
To: <sip:testuser1003@invite-callforward.scenarios.test>
Call-ID: NGCP%register%///1-70263@10.20.30.1
CSeq: 2 REGISTER
Authorization: Digest username="testuser1003",realm="invite-callforward.scenarios.test",uri="sip:192.168.1.152:5060",nonce="YOMvq2DjLn/NHP53+e8jHZxrkjA933pD",response="dab2606a154300beba3e1e251e665be7",algorithm=MD5
Contact: <sip:testuser1003@10.20.30.1:51652>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-05 18:08:31.273159
UDP message received [459] bytes :

SIP/2.0 200 OK
Via: SIP/2.0/UDP 10.20.30.1:51652;rport=51652;branch=z9hG4bK-70263-1-3
From: <sip:testuser1003@invite-callforward.scenarios.test>;tag=70263SIPpTag001
To: <sip:testuser1003@invite-callforward.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%register%///1-70263@10.20.30.1
CSeq: 2 REGISTER
Contact: <sip:testuser1003@10.20.30.1:51652>;expires=600;received="sip:10.20.30.1:51652"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


