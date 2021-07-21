----------------------------------------------- 2021-07-21 10:09:51.898095
UDP message sent (529 bytes):

REGISTER sip:4311015@invite-alias-devid.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51615;branch=z9hG4bK-69260-1-0
From: <sip:4311015@invite-alias-devid.scenarios-pbx.test>;tag=69260SIPpTag001
To: "TestBria" <sip:4311015@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69260@10.20.29.2
CSeq: 1 REGISTER
Contact: "TestBria" <sip:4311015@10.20.29.2:6666;ob>;reg-id=1;+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>"
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:51.916251
UDP message received [532] bytes :

SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 10.20.29.2:51615;rport=51615;branch=z9hG4bK-69260-1-0
From: <sip:4311015@invite-alias-devid.scenarios-pbx.test>;tag=69260SIPpTag001
To: "TestBria" <sip:4311015@invite-alias-devid.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_alias_devid%///1-69260@10.20.29.2
CSeq: 1 REGISTER
WWW-Authenticate: Digest realm="invite-alias-devid.scenarios-pbx.test", nonce="YPfXe2D31k8vzYWeebWNm9pzVadizBRx"
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:51.917466
UDP message sent (745 bytes):

REGISTER sip:4311015@invite-alias-devid.scenarios-pbx.test SIP/2.0
Via: SIP/2.0/UDP 10.20.29.2:51615;branch=z9hG4bK-69260-1-3
From: <sip:4311015@invite-alias-devid.scenarios-pbx.test>;tag=69260SIPpTag001
To: "TestBria" <sip:4311015@invite-alias-devid.scenarios-pbx.test>
Call-ID: NGCP%invite_alias_devid%///1-69260@10.20.29.2
CSeq: 2 REGISTER
Authorization: Digest username="4311015",realm="invite-alias-devid.scenarios-pbx.test",uri="sip:192.168.2.109:5060",nonce="YPfXe2D31k8vzYWeebWNm9pzVadizBRx",response="aa4238f968fc7501ebf30e01ba1fcd44",algorithm=MD5
Contact: "TestBria" <sip:4311015@10.20.29.2:6666;ob>;reg-id=1;+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>"
Expires: 600
Max-Forwards: 70
Content-Length: 0


----------------------------------------------- 2021-07-21 10:09:51.956840
UDP message received [568] bytes :

SIP/2.0 200 OK
Via: SIP/2.0/UDP 10.20.29.2:51615;rport=51615;branch=z9hG4bK-69260-1-3
From: <sip:4311015@invite-alias-devid.scenarios-pbx.test>;tag=69260SIPpTag001
To: "TestBria" <sip:4311015@invite-alias-devid.scenarios-pbx.test>;tag=95c37a12bff1a2c36d72bf8333176544.78550000
Call-ID: NGCP%invite_alias_devid%///1-69260@10.20.29.2
CSeq: 2 REGISTER
Contact: <sip:4311015@10.20.29.2:6666;ob>;expires=600;received="sip:10.20.29.2:51615";+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>";reg-id=1
Server: Sipwise NGCP Proxy 9.X
Content-Length: 0


