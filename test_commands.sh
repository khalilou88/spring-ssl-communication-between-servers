#!/bin/bash

# Test script for SSL communication with client certificates
# Run this after generating certificates and starting both servers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Testing SSL Communication Between Servers${NC}"
echo -e "${YELLOW}Make sure both servers are running before executing these tests${NC}"
echo ""

# Check if certificate files exist
if [[ ! -f "client-cert.pem" || ! -f "client-key.pem" || ! -f "ca-cert.pem" ]]; then
    echo -e "${RED}Error: Certificate files not found!${NC}"
    echo -e "${YELLOW}Please run create-ssl-certs-fixed.sh first to generate certificates.${NC}"
    exit 1
fi

echo -e "${BLUE}1. Testing Server A Health Check...${NC}"
curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem \
     https://localhost:8081/api/v1/communication/health
echo -e "\n"

echo -e "${BLUE}2. Testing Server B Health Check...${NC}"
curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem \
     https://localhost:8082/api/v1/communication/health
echo -e "\n"

echo -e "${BLUE}3. Sending message from Server A to Server B...${NC}"
curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem \
     -X POST "https://localhost:8081/api/v1/communication/send-to-server-b?message=Hello-from-server-a"
echo -e "\n"

echo -e "${BLUE}4. Sending message from Server B to Server A...${NC}"
curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem \
     -X POST "https://localhost:8082/api/v1/communication/send-to-server-a?message=Hello-from-server-b"
echo -e "\n"

echo -e "${BLUE}5. Sending direct message to Server A receive endpoint...${NC}"
curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem \
     -X POST https://localhost:8081/api/v1/communication/receive \
     -H "Content-Type: application/json" \
     -d '{
       "id": "test-123",
       "from": "curl-client",
       "to": "server-a",
       "message": "Direct message from curl",
       "messageType": "REQUEST",
       "timestamp": "2024-01-01T12:00:00"
     }'
echo -e "\n"

echo -e "${BLUE}6. Sending direct message to Server B receive endpoint...${NC}"
curl --cert client-cert.pem --key client-key.pem --cacert ca-cert.pem \
     -X POST https://localhost:8082/api/v1/communication/receive \
     -H "Content-Type: application/json" \
     -d '{
       "id": "test-456",
       "from": "curl-client",
       "to": "server-b",
       "message": "Direct message from curl",
       "messageType": "REQUEST",
       "timestamp": "2024-01-01T12:00:00"
     }'
echo -e "\n"

echo -e "${GREEN}All tests completed!${NC}"
echo -e "${YELLOW}Check the server logs to see the communication in action.${NC}"