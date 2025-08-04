#!/bin/bash

# SSL Certificate Generation Script for Server A and Server B
# This script creates proper certificates for mutual SSL authentication with fixed CA

# Create directories for keystores
mkdir -p server-a/src/main/resources/keystore
mkdir -p server-b/src/main/resources/keystore

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating SSL certificates for Server A and Server B...${NC}"

# Clean up any existing certificates
rm -f *.p12 *.crt *.csr *.pem

# Step 1: Create Certificate Authority (CA) with proper extensions using OpenSSL
echo -e "${YELLOW}1. Creating Certificate Authority (CA) with proper extensions...${NC}"

# Generate CA private key
openssl genrsa -out ca-key.pem 2048

# Create CA certificate with proper extensions
openssl req -new -x509 -key ca-key.pem -out ca-cert.pem -days 3650 \
    -subj "/C=US/ST=State/L=City/O=Example/OU=Development/CN=Local-CA" \
    -extensions v3_ca \
    -config <(cat <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca

[req_distinguished_name]

[v3_ca]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF
)

# Convert CA key and cert to PKCS12 for keytool compatibility
openssl pkcs12 -export -out ca.p12 -inkey ca-key.pem -in ca-cert.pem -name ca -passout pass:changeit

echo -e "${GREEN}✓ CA certificate created with proper extensions${NC}"

# Step 2: Create Server A certificate
echo -e "${YELLOW}2. Creating Server A certificate...${NC}"
keytool -genkeypair \
    -alias server-a \
    -keyalg RSA \
    -keysize 2048 \
    -validity 365 \
    -dname "CN=localhost, OU=Server-A, O=Example, L=City, S=State, C=US" \
    -keystore server-a.p12 \
    -storetype PKCS12 \
    -storepass servera123 \
    -keypass servera123 \
    -ext "SAN=dns:localhost,dns:server-a,ip:127.0.0.1"

# Create CSR for Server A
keytool -certreq \
    -alias server-a \
    -keystore server-a.p12 \
    -storepass servera123 \
    -file server-a.csr

# Sign Server A certificate with CA using OpenSSL
openssl x509 -req -in server-a.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial \
    -out server-a.crt -days 365 \
    -extensions v3_req \
    -extfile <(cat <<EOF
[v3_req]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment,dataEncipherment,digitalSignature
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = DNS:localhost,DNS:server-a,IP:127.0.0.1
EOF
)

# Import CA cert into Server A keystore
keytool -importcert \
    -alias ca \
    -keystore server-a.p12 \
    -storepass servera123 \
    -file ca-cert.pem \
    -noprompt

# Import signed Server A cert back into its keystore
keytool -importcert \
    -alias server-a \
    -keystore server-a.p12 \
    -storepass servera123 \
    -file server-a.crt \
    -noprompt

# Step 3: Create Server B certificate
echo -e "${YELLOW}3. Creating Server B certificate...${NC}"
keytool -genkeypair \
    -alias server-b \
    -keyalg RSA \
    -keysize 2048 \
    -validity 365 \
    -dname "CN=localhost, OU=Server-B, O=Example, L=City, S=State, C=US" \
    -keystore server-b.p12 \
    -storetype PKCS12 \
    -storepass serverb123 \
    -keypass serverb123 \
    -ext "SAN=dns:localhost,dns:server-b,ip:127.0.0.1"

# Create CSR for Server B
keytool -certreq \
    -alias server-b \
    -keystore server-b.p12 \
    -storepass serverb123 \
    -file server-b.csr

# Sign Server B certificate with CA using OpenSSL
openssl x509 -req -in server-b.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial \
    -out server-b.crt -days 365 \
    -extensions v3_req \
    -extfile <(cat <<EOF
[v3_req]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment,dataEncipherment,digitalSignature
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = DNS:localhost,DNS:server-b,IP:127.0.0.1
EOF
)

# Import CA cert into Server B keystore
keytool -importcert \
    -alias ca \
    -keystore server-b.p12 \
    -storepass serverb123 \
    -file ca-cert.pem \
    -noprompt

# Import signed Server B cert back into its keystore
keytool -importcert \
    -alias server-b \
    -keystore server-b.p12 \
    -storepass serverb123 \
    -file server-b.crt \
    -noprompt

# Step 4: Create truststore with CA certificate
echo -e "${YELLOW}4. Creating truststore...${NC}"
keytool -importcert \
    -alias ca \
    -keystore truststore.p12 \
    -storetype PKCS12 \
    -storepass truststore123 \
    -file ca-cert.pem \
    -noprompt

# Also add both server certificates to truststore for mutual auth
keytool -importcert \
    -alias server-a \
    -keystore truststore.p12 \
    -storepass truststore123 \
    -file server-a.crt \
    -noprompt

keytool -importcert \
    -alias server-b \
    -keystore truststore.p12 \
    -storepass truststore123 \
    -file server-b.crt \
    -noprompt

# Step 5: Create client certificate for curl testing
echo -e "${YELLOW}5. Creating client certificate for curl testing...${NC}"

# Generate client private key
openssl genrsa -out client-key.pem 2048

# Create client certificate request
openssl req -new -key client-key.pem -out client.csr \
    -subj "/C=US/ST=State/L=City/O=Example/OU=Client/CN=test-client"

# Sign client certificate with CA
openssl x509 -req -in client.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial \
    -out client-cert.pem -days 365 \
    -extensions v3_req \
    -extfile <(cat <<EOF
[v3_req]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment,dataEncipherment,digitalSignature
extendedKeyUsage = clientAuth
EOF
)

# Create client PKCS12 for keytool compatibility
openssl pkcs12 -export -out client.p12 -inkey client-key.pem -in client-cert.pem -name client -passout pass:client123

# Add client certificate to truststore (so servers can verify the client)
keytool -importcert \
    -alias client \
    -keystore truststore.p12 \
    -storepass truststore123 \
    -file client-cert.pem \
    -noprompt

# Step 6: Verify CA certificate has proper extensions
echo -e "${YELLOW}6. Verifying CA certificate extensions...${NC}"
openssl x509 -in ca-cert.pem -text -noout | grep -A 10 "X509v3 extensions"

# Step 7: Copy keystores to the correct locations
echo -e "${YELLOW}7. Copying keystores to server directories...${NC}"
cp server-a.p12 server-a/src/main/resources/keystore/server-a-keystore.p12
cp truststore.p12 server-a/src/main/resources/keystore/truststore.p12
cp server-b.p12 server-b/src/main/resources/keystore/server-b-keystore.p12
cp truststore.p12 server-b/src/main/resources/keystore/truststore.p12

# Step 8: Clean up temporary files
echo -e "${YELLOW}8. Cleaning up temporary files...${NC}"
rm -f *.csr *.p12 *.crt ca-key.pem *.srl

echo -e "${GREEN}SSL certificates created successfully with proper CA extensions!${NC}"
echo -e "${GREEN}Client certificates for curl have been created in PEM format.${NC}"
echo ""
echo -e "${YELLOW}Files created for curl testing:${NC}"
echo -e "  ${GREEN}✓ client-cert.pem${NC} - Client certificate"
echo -e "  ${GREEN}✓ client-key.pem${NC}  - Client private key"
echo -e "  ${GREEN}✓ ca-cert.pem${NC}     - CA certificate with proper extensions"
echo ""
echo -e "${YELLOW}Now you can test with curl using client certificates:${NC}"
echo ""
echo -e "${GREEN}# Test Server A health:${NC}"
echo "curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem https://localhost:8081/api/v1/communication/health"
echo ""
echo -e "${GREEN}# Test Server B health:${NC}"
echo "curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem https://localhost:8082/api/v1/communication/health"
echo ""
echo -e "${GREEN}# Send message from Server A to Server B:${NC}"
echo 'curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem -X POST "https://localhost:8081/api/v1/communication/send-to-server-b?message=Hello"'
echo ""
echo -e "${GREEN}# Send message from Server B to Server A:${NC}"
echo 'curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem -X POST "https://localhost:8082/api/v1/communication/send-to-server-a?message=Hello"'
echo ""
echo -e "${GREEN}The CA certificate now has proper extensions and should work with curl!${NC}"