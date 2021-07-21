----------------------------------------------- 2021-07-21 12:54:08.902961
UDP message received [1207] bytes :

INVITE sip:4318881003@172.30.1.2:52603;transport=udp SIP/2.0
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;did=fe5.6e42>
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bKf858.adf6bb0114f7dd356e0c532d6b575027.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKf858.dd527662d6d0b89a14528a77e331b74c.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKdPMVPaaz;rport=5080
From: <sip:004321001@incoming-peer.scenarios-lnp.test>;tag=7FEAFA60-60F7FCD0000D4994-C8D5F700
To: <sip:4318881003@172.30.1.2>
CSeq: 1929 INVITE
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2_pbx-1
Max-Forwards: 69
P-Asserted-Identity: <sip:004321001@127.0.2.1>
Content-Type: application/sdp
Content-Length: 176
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a35303830>

v=0
o=user1 53655765 2353687637 IN IP4 192.168.2.109
s=-
c=IN IP4 192.168.2.109
t=0 0
m=audio 30464 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=sendrecv
a=rtcp:30465
a=ptime:50

----------------------------------------------- 2021-07-21 12:54:08.903637
UDP message sent (575 bytes):

SIP/2.0 180 Ringing
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bKf858.adf6bb0114f7dd356e0c532d6b575027.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKf858.dd527662d6d0b89a14528a77e331b74c.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKdPMVPaaz;rport=5080
From: <sip:004321001@incoming-peer.scenarios-lnp.test>;tag=7FEAFA60-60F7FCD0000D4994-C8D5F700
To: <sip:4318881003@172.30.1.2>;tag=128664SIPpTag011
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2_pbx-1
CSeq: 1929 INVITE
Contact: <sip:172.30.1.2:52603;transport=UDP>
Content-Length: 0


----------------------------------------------- 2021-07-21 12:54:09.414261
UDP message sent (1008 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bKf858.adf6bb0114f7dd356e0c532d6b575027.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKf858.dd527662d6d0b89a14528a77e331b74c.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKdPMVPaaz;rport=5080
From: <sip:004321001@incoming-peer.scenarios-lnp.test>;tag=7FEAFA60-60F7FCD0000D4994-C8D5F700
To: <sip:4318881003@172.30.1.2>;tag=128664SIPpTag011
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2_pbx-1
CSeq: 1929 INVITE
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>, <sip:127.0.0.1;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>, <sip:127.0.0.1:5062;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;did=fe5.6e42>
Contact: <sip:172.30.1.2:52603;transport=UDP>
Content-Type: application/sdp
Content-Length:   144

v=0
o=user1 53655765 2353687637 IN IP4 172.30.1.2
s=-
c=IN IP4 172.30.1.2
t=0 0
m=audio 46006 RTP/AVP 8
a=rtpmap:8 PCMA/8000
a=ptime:50

----------------------------------------------- 2021-07-21 12:54:09.665452
UDP message received [941] bytes :

ACK sip:172.30.1.2:52603;transport=UDP SIP/2.0
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700>
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bKf858.389617254dff6530e5c56eb09c7a710b.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bKf858.8c94fff99c8582f8d211c71e4c3203e8.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKFXaFsa~5;rport=5080
From: <sip:004321001@incoming-peer.scenarios-lnp.test>;tag=7FEAFA60-60F7FCD0000D4994-C8D5F700
To: <sip:4318881003@172.30.1.2>;tag=128664SIPpTag011
CSeq: 1929 ACK
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2_pbx-1
Max-Forwards: 68
Content-Length: 0
Contact: <sip:ngcp-lb@192.168.2.109:5060;ngcpct=7369703a3132372e302e302e313a35303830>


----------------------------------------------- 2021-07-21 12:54:11.262049
UDP message received [902] bytes :

BYE sip:172.30.1.2:52603;transport=UDP SIP/2.0
Record-Route: <sip:192.168.2.109;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>
Record-Route: <sip:127.0.0.1;r2=on;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700;ngcplb=yes>
Record-Route: <sip:127.0.0.1:5062;lr=on;ftag=7FEAFA60-60F7FCD0000D4994-C8D5F700>
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK7668.9d54088116df98930959e62b8c631880.0
Via: SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK7668.9c7423a55ca91fc961dba3fb6793f63f.0
Via: SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKSYQKgazX;rport=5080
From: <sip:004321001@incoming-peer.scenarios-lnp.test>;tag=7FEAFA60-60F7FCD0000D4994-C8D5F700
To: <sip:4318881003@172.30.1.2>;tag=128664SIPpTag011
CSeq: 1930 BYE
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2_pbx-1
Max-Forwards: 68
P-Asserted-Identity: <sip:004321001@127.0.2.1>
Content-Length: 0


----------------------------------------------- 2021-07-21 12:54:11.262202
UDP message sent (571 bytes):

SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.2.109;branch=z9hG4bK7668.9d54088116df98930959e62b8c631880.0, SIP/2.0/UDP 127.0.0.1:5062;rport=5062;branch=z9hG4bK7668.9c7423a55ca91fc961dba3fb6793f63f.0, SIP/2.0/UDP 127.0.0.1:5080;received=127.0.0.1;branch=z9hG4bKSYQKgazX;rport=5080
From: <sip:004321001@incoming-peer.scenarios-lnp.test>;tag=7FEAFA60-60F7FCD0000D4994-C8D5F700
To: <sip:4318881003@172.30.1.2>;tag=128664SIPpTag011
Call-ID: NGCP%incoming_peer%///1-128684@172.30.1.2_pbx-1
CSeq: 1930 BYE
Contact: <sip:172.30.1.2:52603;transport=UDP>
Content-Length:     0


