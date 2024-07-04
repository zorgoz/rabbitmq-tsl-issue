#!/bin/sh

# Define paths for certificates
certsPath="$(pwd)"
caKeyPath="$certsPath/ca_key.pem"
caCertPath="$certsPath/ca_certificate.pem"
clientConfigPath="$certsPath/client_cert_config.cnf"
genericUserKeyPath="$certsPath/generic_user_key.pem"
genericUserCertPath="$certsPath/generic_user_certificate.pem"
genericUserPfxPath="$certsPath/generic_user_certificate.pfx"
secureUserKeyPath="$certsPath/secure_user_key.pem"
secureUserCertPath="$certsPath/secure_user_certificate.pem"
secureUserPfxPath="$certsPath/secure_user_certificate.pfx"

# Create OpenSSL configuration file for client certificates
cat > $clientConfigPath <<EOF
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
CN = client

[ v3_req ]
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
EOF

# Generate generic_user key and certificate signing request (CSR) using the configuration file
openssl req -new -newkey rsa:2048 -nodes -keyout $genericUserKeyPath -out "$certsPath/generic_user.csr" -subj "/CN=generic_user" -config $clientConfigPath

# Sign generic_user certificate with CA using the configuration file
openssl x509 -req -days 1825 -in "$certsPath/generic_user.csr" -CA $caCertPath -CAkey $caKeyPath -CAcreateserial -out $genericUserCertPath -extensions v3_req -extfile $clientConfigPath

# Convert generic_user certificate and key to PFX format
openssl pkcs12 -export -out $genericUserPfxPath -inkey $genericUserKeyPath -in $genericUserCertPath -certfile $caCertPath -passout pass:

# Generate secure_user key and certificate signing request (CSR) using the configuration file
openssl req -new -newkey rsa:2048 -nodes -keyout $secureUserKeyPath -out "$certsPath/secure_user.csr" -subj "/CN=secure_user" -config $clientConfigPath

# Sign secure_user certificate with CA using the configuration file
openssl x509 -req -days 1825 -in "$certsPath/secure_user.csr" -CA $caCertPath -CAkey $caKeyPath -CAcreateserial -out $secureUserCertPath -extensions v3_req -extfile $clientConfigPath

# Convert secure_user certificate and key to PFX format
openssl pkcs12 -export -out $secureUserPfxPath -inkey $secureUserKeyPath -in $secureUserCertPath -certfile $caCertPath -passout pass:

# Clean up
rm -f $clientConfigPath
rm -f "$certsPath"/*.csr

echo "Certificates and keys generated and saved to $certsPath"
