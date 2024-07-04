#!/bin/sh

# Define paths for certificates
certsPath="$(pwd)"
caKeyPath="$certsPath/ca_key.pem"
caCertPath="$certsPath/ca_certificate.pem"
serverKeyPath="$certsPath/server_key.pem"
serverCertPath="$certsPath/server_certificate.pem"
serverConfigPath="$certsPath/server_cert_config.cnf"

# Generate CA key and certificate
openssl req -new -x509 -days 3650 -keyout $caKeyPath -out $caCertPath -subj "/CN=MyCA" -nodes

# Create OpenSSL configuration file for server certificate
cat > $serverConfigPath <<EOF
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
CN = localhost

[ v3_req ]
keyUsage = keyEncipherment
extendedKeyUsage = serverAuth
EOF

# Generate server key and certificate signing request (CSR) using the configuration file
openssl req -new -newkey rsa:2048 -nodes -keyout $serverKeyPath -out "$certsPath/server.csr" -config $serverConfigPath

# Sign server certificate with CA using the configuration file
openssl x509 -req -days 1825 -in "$certsPath/server.csr" -CA $caCertPath -CAkey $caKeyPath -CAcreateserial -out $serverCertPath -extensions v3_req -extfile $serverConfigPath

# Clean up temporary configuration file
rm -f $serverConfigPath

# Clean up CSR files
rm -f "$certsPath"/*.csr
