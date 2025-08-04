package com.example.servera.controller;

import com.example.servera.service.CommunicationService;
import com.example.shared.dto.CommunicationMessage;
import com.example.shared.dto.MessageType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/communication")
public class CommunicationController {

    private static final Logger logger = LoggerFactory.getLogger(CommunicationController.class);

    @Autowired
    private CommunicationService communicationService;

    @PostMapping("/receive")
    public ResponseEntity<CommunicationMessage> receiveMessage(@Valid @RequestBody CommunicationMessage message) {
        logger.info("Server A received message: {}", message);

        // Process the message and create a response
        CommunicationMessage response = new CommunicationMessage(
                UUID.randomUUID().toString(),
                "server-a",
                message.getFrom(),
                "Server A received: " + message.getMessage(),
                MessageType.RESPONSE
        );

        logger.info("Server A responding with: {}", response);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/send-to-server-b")
    public ResponseEntity<String> sendMessageToServerB(@RequestParam("message") String message) {
        logger.info("Server A initiating communication to Server B with message: {}", message);

        try {
            CommunicationMessage response = communicationService.sendMessageToServerB(message);
            logger.info("Server A received response from Server B: {}", response);
            return ResponseEntity.ok("Message sent successfully. Response: " + response.getMessage());
        } catch (Exception e) {
            logger.error("Error communicating with Server B", e);
            return ResponseEntity.internalServerError().body("Failed to communicate with Server B: " + e.getMessage());
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Server A is running");
    }
}