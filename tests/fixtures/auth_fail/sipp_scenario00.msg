----------------------------------------------- 2021-07-12 11:47:35.854097
UDP message sent (404 bytes):

REGISTER sip:testuser1003@auth-fail.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-29092-1-0
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 1 REGISTER
Contact: <sip:testuser1003@10.20.29.2:51602>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.862022
UDP message received [483] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.29.2:51602;rport=51602;branch=z9hG4bK-29092-1-0
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 1 REGISTER
WWW-Authenticate: Digest realm="auth-fail.scenarios.test", nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.868422
UDP message sent (612 bytes):

REGISTER sip:testuser1003@auth-fail.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-29092-1-3
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 2 REGISTER
Authorization: Digest username="testuser1003",realm="auth-fail.scenarios.test",uri="sip:192.168.2.121:5060",nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf",response="5a694615df518a21232659b1ae37b73d",algorithm=MD5
Contact: <sip:testuser1003@10.20.29.2:51602>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.874829
UDP message received [483] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.29.2:51602;rport=51602;branch=z9hG4bK-29092-1-3
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 2 REGISTER
WWW-Authenticate: Digest realm="auth-fail.scenarios.test", nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.882794
UDP message sent (612 bytes):

REGISTER sip:testuser1003@auth-fail.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-29092-1-6
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 3 REGISTER
Authorization: Digest username="testuser1003",realm="auth-fail.scenarios.test",uri="sip:192.168.2.121:5060",nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf",response="5a694615df518a21232659b1ae37b73d",algorithm=MD5
Contact: <sip:testuser1003@10.20.29.2:51602>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.890672
UDP message received [483] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.29.2:51602;rport=51602;branch=z9hG4bK-29092-1-6
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 3 REGISTER
WWW-Authenticate: Digest realm="auth-fail.scenarios.test", nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.890805
UDP message sent (612 bytes):

REGISTER sip:testuser1003@auth-fail.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-29092-1-9
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 4 REGISTER
Authorization: Digest username="testuser1003",realm="auth-fail.scenarios.test",uri="sip:192.168.2.121:5060",nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf",response="5a694615df518a21232659b1ae37b73d",algorithm=MD5
Contact: <sip:testuser1003@10.20.29.2:51602>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.902452
UDP message received [483] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.29.2:51602;rport=51602;branch=z9hG4bK-29092-1-9
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 4 REGISTER
WWW-Authenticate: Digest realm="auth-fail.scenarios.test", nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.902720
UDP message sent (613 bytes):

REGISTER sip:testuser1003@auth-fail.scenarios.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-29092-1-12
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 5 REGISTER
Authorization: Digest username="testuser1003",realm="auth-fail.scenarios.test",uri="sip:192.168.2.121:5060",nonce="YOwQ42DsD7evuVhxpdWTJe37BDP8EKRf",response="5a694615df518a21232659b1ae37b73d",algorithm=MD5
Contact: <sip:testuser1003@10.20.29.2:51602>
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-12 11:47:35.902845
UDP message received [383] bytes :

SIP/2.0 403 Try again later
Via: SIP/2.0/UDP 10.20.29.2:51602;branch=z9hG4bK-29092-1-12;rport=51602
From: <sip:testuser1003@auth-fail.scenarios.test>;tag=29092SIPpTag001
To: <sip:testuser1003@auth-fail.scenarios.test>;tag=0bfe5d278ccafe7e169db3d564176051.e6880ed6
Call-ID: NGCP%auth_fail%///1-29092@10.20.29.2
CSeq: 5 REGISTER
Server: Sipwise NGCP LB 9.X
Content-Length: 0


