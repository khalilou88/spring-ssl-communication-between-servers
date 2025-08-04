# SSL Communication Between Spring Boot Servers

This is a Maven multi-module project demonstrating secure SSL communication between two Spring Boot servers. Both servers can initiate communication with each other and respond appropriately.

## Project Structure

```
ssl-communication-parent/
├── pom.xml                 # Parent POM
├── shared/                 # Shared DTOs and utilities
│   ├── pom.xml
│   └── src/main/java/com/example/shared/dto/
│       ├── CommunicationMessage.java
│       └── MessageType.java
├── server-a/               # First Spring Boot server
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/example/servera/
│       │   ├── ServerAApplication.java
│       │   ├── config/SslConfig.java
│       │   ├── controller/CommunicationController.java
│       │   └── service/CommunicationService.java
│       └── resources/
│           ├── application.yml
│           └── keystore/
├── server-b/               # Second Spring Boot server
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/example/serverb/
│       │   ├── ServerBApplication.java
│       │   ├── config/SslConfig.java
│       │   ├── controller/CommunicationController.java
│       │   └── service/CommunicationService.java
│       └── resources/
│           ├── application.yml
│           └── keystore/
└── create-ssl-certs.sh     # SSL certificate generation script
```

## Features

- **Mutual SSL Authentication**: Both servers authenticate each other using certificates
- **Bidirectional Communication**: Either server can initiate communication
- **Automatic Heartbeat**: Servers send periodic heartbeat messages
- **RESTful API**: Clean REST endpoints for communication
- **Comprehensive Logging**: Detailed logging for debugging
- **Health Checks**: Built-in health check endpoints

## Setup Instructions

### 1. Generate SSL Certificates

First, you need to generate SSL certificates for both servers:

```bash
chmod +x create-ssl-certs.sh
./create-ssl-certs.sh
```

This script will:
- Create a Certificate Authority (CA)
- Generate certificates for Server A and Server B
- Create truststores containing all certificates
- Place certificates in the appropriate directories

### 2. Build the Project

```bash
./mvnw clean install
```

### 3. Run the Servers

**Terminal 1 - Server A:**
```bash
./mvnw spring-boot:run -pl server-a
```

**Terminal 2 - Server B:**
```bash
./mvnw spring-boot:run -pl server-b
```

Server A will run on `https://localhost:8081`
Server B will run on `https://localhost:8082`

## Usage

### Health Check

Check if servers are running:

```bash
# Server A
curl -k https://localhost:8081/api/v1/communication/health

# Server B
curl -k https://localhost:8082/api/v1/communication/health
```

### Manual Communication

**Server A to Server B:**
```bash
curl -k -X POST "https://localhost:8081/api/v1/communication/send-to-server-b?message=Hello-from-server-a"
```

**Server B to Server A:**
```bash
curl -k -X POST "https://localhost:8082/api/v1/communication/send-to-server-a?message=Hello-from-server-b"
```

### Direct Message Sending

You can also send messages directly to the receive endpoints:

```bash
# Send to Server A
curl -k -X POST https://localhost:8081/api/v1/communication/receive \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test-123",
    "from": "client",
    "to": "server-a",
    "message": "Direct message to Server A",
    "messageType": "REQUEST",
    "timestamp": "2024-01-01T12:00:00"
  }'
```

## Configuration

### Server Ports
- Server A: `8081` (HTTPS)
- Server B: `8082` (HTTPS)

### SSL Configuration
Both servers are configured with:
- **Mutual Authentication**: `client-auth: need`
- **Protocol**: TLS
- **Certificate Type**: PKCS12

### Application Properties

**Server A (`server-a/src/main/resources/application.yml`):**
- Port: 8081
- Keystore: `server-a-keystore.p12`
- Password: `servera123`

**Server B (`server-b/src/main/resources/application.yml`):**
- Port: 8082
- Keystore: `server-b-keystore.p12`
- Password: `serverb123`

## Communication Flow

1. **Heartbeat Messages**: Servers automatically send heartbeat messages every 30-45 seconds
2. **Request/Response**: When a server receives a message, it automatically responds
3. **Message Types**:
    - `REQUEST`: Initial message from sender
    - `RESPONSE`: Reply to a request
    - `HEARTBEAT`: Periodic health check
    - `NOTIFICATION`: One-way message

## Message Format

```json
{
  "id": "unique-message-id",
  "from": "server-a",
  "to": "server-b", 
  "message": "Hello Server B",
  "messageType": "REQUEST",
  "timestamp": "2024-01-01T12:00:00"
}
```

## Monitoring

Both servers expose actuator endpoints:

```bash
# Health checks
curl -k https://localhost:8081/actuator/health
curl -k https://localhost:8082/actuator/health

# Application info
curl -k https://localhost:8081/actuator/info
curl -k https://localhost:8082/actuator/info
```

## Troubleshooting

### Common Issues

1. **Certificate Errors**: Make sure SSL certificates are generated and placed correctly
2. **Port Conflicts**: Ensure ports 8081 and 8082 are available
3. **SSL Handshake Failures**: Check that truststores contain the correct certificates

### Debug Logging

Both servers have debug logging enabled for SSL and communication components. Check the console output for detailed information about SSL handshakes and message exchanges.

### Testing with curl

When using curl with self-signed certificates, use the `-k` flag to skip certificate verification:

```bash
curl -k https://localhost:8081/api/v1/communication/health
```

## Security Considerations

⚠️ **Important**: This implementation uses self-signed certificates and is intended for development/testing purposes only. For production use:

1. Use certificates from a trusted Certificate Authority
2. Implement proper certificate validation
3. Use strong passwords and secure key management
4. Consider additional security measures like API keys or OAuth

## Development Notes

- Both servers use Spring WebFlux for non-blocking HTTP client communication
- SSL context is manually configured to use custom keystores and truststores
- Scheduled tasks handle automatic heartbeat functionality
- Comprehensive error handling and logging throughout

This setup provides a solid foundation for secure server-to-server communication in a microservices architecture.