# Summary
Repository created to demonstrate the issue related to connecting without tsl1v.3 support

## Issue
- Even if the configuration contains support for tlsv1.2, the image seems to be not exposing any support for it.
- As a conseqence Windows 10 clients can't connect.
- RabbitMQ 3.13.3 with Erlang 26.2.5.1 is the latest at the date of writing

## Containers
### cert-maker

Creates CA, server cert and client cert in local `certs` folder, if empty. 
Two user certificates are created for the client test.

### rabbitmq

Spins up an instance using the created certificaters. Has two virtual hosts and two users, one assigned to each.
The 'rmq-config\rabbitmq.conf' file is used as configuration, that has these options:

```
ssl_options.versions.1 = tlsv1.2
ssl_options.versions.2 = tlsv1.3
```

### test-container

Runs a client based on an alpine dotnet 8 sdk image. It uses oen of the created certificates to authenticate.
It should show the following in the log:
```
2024-07-04 14:02:16 Using cert file: /certs/generic_user_certificate.pfx
2024-07-04 14:02:17 Connection established: amqps://rabbitmq:5671
```

### nmap

Runs a chyper enumeration on the rabbitmq server.
With the defaulkt configuration, it will have the following log:
```
2024-07-04 14:02:17 Nmap scan report for rabbitmq (172.21.0.2)
2024-07-04 14:02:17 Host is up (0.000063s latency).
2024-07-04 14:02:17 rDNS record for 172.21.0.2: rabbitmq.rmr-tsl-test_test
2024-07-04 14:02:17 
2024-07-04 14:02:17 PORT     STATE SERVICE
2024-07-04 14:02:17 5671/tcp open  amqps
2024-07-04 14:02:17 | ssl-enum-ciphers: 
2024-07-04 14:02:17 |   TLSv1.3: 
2024-07-04 14:02:17 |     ciphers: 
2024-07-04 14:02:17 |       TLS_AKE_WITH_AES_128_CCM_8_SHA256 (ecdh_x25519) - A
2024-07-04 14:02:17 |       TLS_AKE_WITH_AES_128_CCM_SHA256 (ecdh_x25519) - A
2024-07-04 14:02:17 |       TLS_AKE_WITH_AES_128_GCM_SHA256 (ecdh_x25519) - A
2024-07-04 14:02:17 |       TLS_AKE_WITH_AES_256_GCM_SHA384 (ecdh_x25519) - A
2024-07-04 14:02:17 |       TLS_AKE_WITH_CHACHA20_POLY1305_SHA256 (ecdh_x25519) - A
2024-07-04 14:02:17 |     cipher preference: client
2024-07-04 14:02:17 |_  least strength: A 
```
**Note:** There are not TLSv1.2 chypers enumerated! If you run `nmap --script ssl-enum-ciphers -p 443 microsoft.com`, you will see chíypers from both.

## Running the setup
Use Windows 10 with .NET 8 SDK installed for the purposes of this test, with Docker Desktop runnig.
Just fire `docker-compose up`.
After a while all containers complete their respective tasks, and you can examine the logs as described above. 

### Finding 1
There is an alternate configuration based on the description here https://www.rabbitmq.com/docs/ssl#tls-version-support-in-jdk-and-netfile 
Just alter the `docker-compose.yml` to this and rebuild all:
``` 
  rabbitmq:
    ...
    volumes:
      - ./rmq-config/rabbitmq-TLS12.conf:/etc/rabbitmq/rabbitmq.conf:ro
```

**The test will fail, and NMAP won't report any TLS support at all**

### Finding 2
if you change directory into `rmq-tsl-test` amd issue `dotnet run` from the Windows host, you will get error either way.
More precisely:
```
BrokerUnreachableException: None of the specified endpoints were reachable
   AuthenticationException: Authentication failed because the remote party sent a TLS alert: 'InsuffientSecurity'.
      Win32Exception: The message received was unexpected or badly formatted. (System.Net.Security.SslStream.ForceAuthenticationAsync)
```
