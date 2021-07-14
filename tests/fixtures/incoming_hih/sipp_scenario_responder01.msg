----------------------------------------------- 2021-07-15 18:07:56.121117
UDP message received [1602] bytes :

INVITE sip:testuser1002@10.20.29.2:51603;cause=302 SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;did=54.46f>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK467f.0f93f15a9f0fd946ceb67be665d40e96.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK467f.2bae458c4adab3696bf3c8b719279a54.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKrxc~warC;rport=5080
From: <sip:004321001@incoming-hih.scenarios.test>;tag=429E5A36-60F05D5C000060E1-E96AC700
To: <sip:testuser1002@incoming-hih.scenarios.test>
CSeq: 10 INVITE
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2_b2b-1
Max-Forwards: 69
History-Info: <sip:+4313012026@incoming-hih.scenarios.test;user=phone?privacy=history>;index=1
History-Info: <sip:+4311001@incoming-hih.scenarios.test;user=phone;cause=302?privacy=id>;index=1.1
History-Info: <sip:+4311000@incoming-hih.scenarios.test:5060;user=phone;cause=302>;index=1.1.1
P-Asserted-Identity: <sip:004321001@incoming-hih.scenarios.test>
Content-Type: application/sdp
Content-Length: 194
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.1.152
s=-
c=IN IP4 192.168.1.152
t=0 0
m=audio 30136 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30137
a=ptime:50
a=direction:both

----------------------------------------------- 2021-07-15 18:07:56.121512
UDP message sent (586 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK467f.0f93f15a9f0fd946ceb67be665d40e96.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK467f.2bae458c4adab3696bf3c8b719279a54.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKrxc~warC;rport=5080
From: <sip:004321001@incoming-hih.scenarios.test>;tag=429E5A36-60F05D5C000060E1-E96AC700
To: <sip:testuser1002@incoming-hih.scenarios.test>;tag=445932SIPpTag011
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2_b2b-1
CSeq: 10 INVITE
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-15 18:07:56.635454
UDP message sent (1077 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK467f.0f93f15a9f0fd946ceb67be665d40e96.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK467f.2bae458c4adab3696bf3c8b719279a54.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKrxc~warC;rport=5080
From: <sip:004321001@incoming-hih.scenarios.test>;tag=429E5A36-60F05D5C000060E1-E96AC700
To: <sip:testuser1002@incoming-hih.scenarios.test>;tag=445932SIPpTag011
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2_b2b-1
CSeq: 10 INVITE
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>, <sip:127.0.0.1;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>, <sip:127.0.0.1:5062;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;did=54.46f>
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 10.20.29.2
s=-
c=IN IP4 10.20.29.2
t=0 0
m=audio 45006 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-15 18:07:57.190124
UDP message received [1012] bytes :

ACK sip:10.20.29.2:51603;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK467f.d686a83f8f593d099bf370a05d5401fd.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK467f.290ecd974b940cb69561e51783d97e63.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKikhEvaYG;rport=5080
From: <sip:004321001@incoming-hih.scenarios.test>;tag=429E5A36-60F05D5C000060E1-E96AC700
To: <sip:testuser1002@incoming-hih.scenarios.test>;tag=445932SIPpTag011
CSeq: 10 ACK
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2_b2b-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.1.152:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-07-15 18:07:58.786292
UDP message received [991] bytes :

BYE sip:10.20.29.2:51603;transport=UDP SIP/2.0
Record-Route: <sip:192.168.1.152;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700;ngcplb=yes;socket=sip:192.168.1.152:5060>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=429E5A36-60F05D5C000060E1-E96AC700>
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK567f.f0abce14d389c1e60e149ff153fef7fc.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK567f.8a85f33f024324b9038056f3e50757ba.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKtTK.6a~2;rport=5080
From: <sip:004321001@incoming-hih.scenarios.test>;tag=429E5A36-60F05D5C000060E1-E96AC700
To: <sip:testuser1002@incoming-hih.scenarios.test>;tag=445932SIPpTag011
CSeq: 11 BYE
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2_b2b-1
Max-Forwards: 68
P-Asserted-Identity: <sip:004321001@incoming-hih.scenarios.test>
Content-Length: 0


----------------------------------------------- 2021-07-15 18:07:58.786634
UDP message sent (582 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.1.152;branch=z9hG4bK567f.f0abce14d389c1e60e149ff153fef7fc.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK567f.8a85f33f024324b9038056f3e50757ba.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKtTK.6a~2;rport=5080
From: <sip:004321001@incoming-hih.scenarios.test>;tag=429E5A36-60F05D5C000060E1-E96AC700
To: <sip:testuser1002@incoming-hih.scenarios.test>;tag=445932SIPpTag011
Call-ID: NGCP%incoming_hih%///1-445952@172.30.1.2_b2b-1
CSeq: 11 BYE
Contact: <sip:10.20.29.2:51603;transport=UDP>
Content-Length:     0


