#!/bin/bash

# SSL Certificate Generation Script for Server A and Server B
# This script creates self-signed certificates for development/testing purposes

# Create directories for keystores
mkdir -p server-a/src/main/resources/keystore
mkdir -p server-b/src/main/resources/keystore

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating SSL certificates for Server A and Server B...${NC}"

# Generate CA certificate (Certificate Authority)
echo -e "${YELLOW}1. Creating Certificate Authority (CA)...${NC}"
keytool -genkeypair -alias ca \
    -keyalg RSA -keysize 2048 -validity 365 \
    -dname "CN=LocalCA, OU=Development, O=Example Corp, L=City, S=State, C=US" \
    -keystore ca-keystore.p12 -storetype PKCS12 \
    -storepass capass123 -keypass capass123

# Export CA certificate
keytool -exportcert -alias ca \
    -keystore ca-keystore.p12 -storetype PKCS12 -storepass capass123 \
    -file ca-cert.crt

# Generate Server A certificate
echo -e "${YELLOW}2. Creating Server A certificate...${NC}"
keytool -genkeypair -alias server-a \
    -keyalg RSA -keysize 2048 -validity 365 \
    -dname "CN=localhost, OU=Server-A, O=Example Corp, L=City, S=State, C=US" \
    -keystore server-a-keystore.p12 -storetype PKCS12 \
    -storepass servera123 -keypass servera123 \
    -ext SAN=dns:localhost,ip:127.0.0.1

# Generate certificate signing request for Server A
keytool -certreq -alias server-a \
    -keystore server-a-keystore.p12 -storetype PKCS12 -storepass servera123 \
    -file server-a.csr

# Sign Server A certificate with CA
keytool -gencert -alias ca \
    -keystore ca-keystore.p12 -storetype PKCS12 -storepass capass123 \
    -infile server-a.csr -outfile server-a.crt \
    -validity 365 -ext SAN=dns:localhost,ip:127.0.0.1

# Import CA certificate to Server A keystore
keytool -importcert -alias ca \
    -keystore server-a-keystore.p12 -storetype PKCS12 -storepass servera123 \
    -file ca-cert.crt -noprompt

# Import signed certificate to Server A keystore
keytool -importcert -alias server-a \
    -keystore server-a-keystore.p12 -storetype PKCS12 -storepass servera123 \
    -file server-a.crt -noprompt

# Generate Server B certificate
echo -e "${YELLOW}3. Creating Server B certificate...${NC}"
keytool -genkeypair -alias server-b \
    -keyalg RSA -keysize 2048 -validity 365 \
    -dname "CN=localhost, OU=Server-B, O=Example Corp, L=City, S=State, C=US" \
    -keystore server-b-keystore.p12 -storetype PKCS12 \
    -storepass serverb123 -keypass serverb123 \
    -ext SAN=dns:localhost,ip:127.0.0.1

# Generate certificate signing request for Server B
keytool -certreq -alias server-b \
    -keystore server-b-keystore.p12 -storetype PKCS12 -storepass serverb123 \
    -file server-b.csr

# Sign Server B certificate with CA
keytool -gencert -alias ca \
    -keystore ca-keystore.p12 -storetype PKCS12 -storepass capass123 \
    -infile server-b.csr -outfile server-b.crt \
    -validity 365 -ext SAN=dns:localhost,ip:127.0.0.1

# Import CA certificate to Server B keystore
keytool -importcert -alias ca \
    -keystore server-b-keystore.p12 -storetype PKCS12 -storepass serverb123 \
    -file ca-cert.crt -noprompt

# Import signed certificate to Server B keystore
keytool -importcert -alias server-b \
    -keystore server-b-keystore.p12 -storetype PKCS12 -storepass serverb123 \
    -file server-b.crt -noprompt

# Create truststore with both server certificates
echo -e "${YELLOW}4. Creating truststore...${NC}"
keytool -importcert -alias ca \
    -keystore truststore.p12 -storetype PKCS12 -storepass truststore123 \
    -file ca-cert.crt -noprompt

keytool -importcert -alias server-a \
    -keystore truststore.p12 -storetype PKCS12 -storepass truststore123 \
    -file server-a.crt -noprompt

keytool -importcert -alias server-b \
    -keystore truststore.p12 -storetype PKCS12 -storepass truststore123 \
    -file server-b.crt -noprompt

# Copy certificates to appropriate locations
echo -e "${YELLOW}5. Copying certificates to server directories...${NC}"
cp server-a-keystore.p12 server-a/src/main/resources/keystore/
cp truststore.p12 server-a/src/main/resources/keystore/
cp server-b-keystore.p12 server-b/src/main/resources/keystore/
cp truststore.p12 server-b/src/main/resources/keystore/

# Clean up temporary files
echo -e "${YELLOW}6. Cleaning up temporary files...${NC}"
rm -f *.csr *.crt ca-keystore.p12 server-a-keystore.p12 server-b-keystore.p12 truststore.p12

echo -e "${GREEN}SSL certificates created successfully!${NC}"
echo -e "${GREEN}Certificates have been placed in the appropriate server directories.${NC}"
echo ""
echo -e "${YELLOW}Certificate Information:${NC}"
echo "- Server A runs on: https://localhost:8081"
echo "- Server B runs on: https://localhost:8082"
echo "- Keystore passwords: servera123 (Server A), serverb123 (Server B)"
echo "- Truststore password: truststore123"
echo ""
echo -e "${RED}Note: These are self-signed certificates for development only!${NC}"
