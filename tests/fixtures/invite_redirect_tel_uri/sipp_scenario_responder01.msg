----------------------------------------------- 2021-07-05 18:05:31.436441
UDP message received [1670] bytes :

INVITE sip:testuser1002@10.20.30.1:52635;cause=302 SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;did=e82.e2f1>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.ec6553e1ad578512fc6a44a1bf056a20.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.7ae42c07adc509182ee36f867ff88d09.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKG8rLJapY;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>
CSeq: 10 INVITE
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
Max-Forwards: 69
P-Asserted-Identity: <sip:4311129@invite-redirect-tel-uri.scenarios.test>
Diversion: <sip:+4311130@invite-redirect-tel-uri.scenarios.test>;privacy=off;counter=1
History-Info: <sip:testuser1001@invite-redirect-tel-uri.scenarios.test:5060;user=phone?Reason=SIP%3bcause%3d302>;index=1
History-Info: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test:5060;user=phone;cause=302>;index=1.1
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 31512 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:31513
a=ptime:50
a=direction:both

----------------------------------------------- 2021-07-05 18:05:31.548769
UDP message sent (558 bytes):

SIP/2.0 100 Trying
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.ec6553e1ad578512fc6a44a1bf056a20.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.7ae42c07adc509182ee36f867ff88d09.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKG8rLJapY;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>;user=phone
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
CSeq: 10 INVITE
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:31.550168
UDP message sent (615 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.ec6553e1ad578512fc6a44a1bf056a20.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.7ae42c07adc509182ee36f867ff88d09.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKG8rLJapY;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>;tag=65425SIPpTag011
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
CSeq: 10 INVITE
Contact: <sip:10.20.30.1:52635;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:32.056630
UDP message sent (1108 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.ec6553e1ad578512fc6a44a1bf056a20.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.7ae42c07adc509182ee36f867ff88d09.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKG8rLJapY;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>;tag=65425SIPpTag011
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
CSeq: 10 INVITE
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;did=e82.e2f1>
Contact: <sip:10.20.30.1:52635;transport=UDP>
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.30.1
s=-
c=IN IP4 10.20.30.1
t=0 0
m=audio 46083 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-05 18:05:32.618617
UDP message received [1041] bytes :

ACK sip:10.20.30.1:52635;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKca9b.dc25baea3a62cf0ced02f5cfc9a7ab6a.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKca9b.b213844a5a541e06971186ca81f8ce59.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKXLpXEanH;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>;tag=65425SIPpTag011
CSeq: 10 ACK
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-07-05 18:05:34.045208
UDP message received [1029] bytes :

BYE sip:10.20.30.1:52635;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=4763A163-60E32DCB0002874A-9B7C7700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKda9b.c12395e5b61ad9b4626f6cc655868382.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKda9b.9d544f1e365d8cc5462a5fee442bf7c6.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bK4M5Fpa4G;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>;tag=65425SIPpTag011
CSeq: 11 BYE
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
Max-Forwards: 68
P-Asserted-Identity: <sip:4311129@invite-redirect-tel-uri.scenarios.test>
Content-Length: 0


----------------------------------------------- 2021-07-05 18:05:34.046472
UDP message sent (611 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bKda9b.c12395e5b61ad9b4626f6cc655868382.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKda9b.9d544f1e365d8cc5462a5fee442bf7c6.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bK4M5Fpa4G;rport=5080
From: <sip:4311129@invite-redirect-tel-uri.scenarios.test>;tag=4763A163-60E32DCB0002874A-9B7C7700
To: <sip:testuser1002@invite-redirect-tel-uri.scenarios.test>;tag=65425SIPpTag011
Call-ID: NGCP%invite_redirect_tel_uri%///1-65445@10.20.30.1_b2b-1
CSeq: 11 BYE
Contact: <sip:10.20.30.1:52635;transport=UDP>
Content-Length:     0


