package com.example.serverb.controller;

import com.example.serverb.service.CommunicationService;
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
        logger.info("Server B received message: {}", message);

        // Process the message and create a response
        CommunicationMessage response = new CommunicationMessage(
                UUID.randomUUID().toString(),
                "server-b",
                message.getFrom(),
                "Server B received: " + message.getMessage(),
                MessageType.RESPONSE
        );

        logger.info("Server B responding with: {}", response);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/send-to-server-a")
    public ResponseEntity<String> sendMessageToServerA(@RequestParam("message") String message) {
        logger.info("Server B initiating communication to Server A with message: {}", message);

        try {
            CommunicationMessage response = communicationService.sendMessageToServerA(message);
            logger.info("Server B received response from Server A: {}", response);
            return ResponseEntity.ok("Message sent successfully. Response: " + response.getMessage());
        } catch (Exception e) {
            logger.error("Error communicating with Server A", e);
            return ResponseEntity.internalServerError().body("Failed to communicate with Server A: " + e.getMessage());
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Server B is running");
    }
}