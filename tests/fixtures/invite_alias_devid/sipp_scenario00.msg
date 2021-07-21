----------------------------------------------- 2021-07-21 10:09:51.690646
UDP message sent (549 bytes):

REGISTER sip:testuser1003@invite-alias-devid.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51613;branch=z9hG4bK-69218-1-0
From: <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>;tag=69218SIPpTag001
To: "TestBria" <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69218@10.20.29.2
CSeq: 1 REGISTER
Contact: "TestBria" <sip:testuser1003@10.20.29.2:6666;ob>;reg-id=1;+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>"
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:51.713740
UDP message received [542] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.29.2:51613;rport=51613;branch=z9hG4bK-69218-1-0
From: <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>;tag=69218SIPpTag001
To: "TestBria" <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_alias_devid%///1-69218@10.20.29.2
CSeq: 1 REGISTER
WWW-Authenticate: Digest realm="invite-alias-devid.scenarios-pbx.test", nonce="YPfXe2D31k8vzYWeebWNm9pzVadizBRx"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:51.714091
UDP message sent (770 bytes):

REGISTER sip:testuser1003@invite-alias-devid.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51613;branch=z9hG4bK-69218-1-3
From: <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>;tag=69218SIPpTag001
To: "TestBria" <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69218@10.20.29.2
CSeq: 2 REGISTER
Authorization: Digest username="testuser1003",realm="invite-alias-devid.scenarios-pbx.test",uri="sip:192.168.2.109:5060",nonce="YPfXe2D31k8vzYWeebWNm9pzVadizBRx",response="ec5f0b8bb54121ff931016a5cb5c1d84",algorithm=MD5
Contact: "TestBria" <sip:testuser1003@10.20.29.2:6666;ob>;reg-id=1;+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>"
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:51.763172
UDP message received [583] bytes :

SIP/2.0 200 OK
Via: SIP/2.0/UDP 10.20.29.2:51613;rport=51613;branch=z9hG4bK-69218-1-3
From: <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>;tag=69218SIPpTag001
To: "TestBria" <sip:testuser1003@invite-alias-devid.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_alias_devid%///1-69218@10.20.29.2
CSeq: 2 REGISTER
Contact: <sip:testuser1003@10.20.29.2:6666;ob>;expires=600;received="sip:10.20.29.2:51613";+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>";reg-id=1
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


