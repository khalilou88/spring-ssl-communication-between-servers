package com.example.servera.service;

import com.example.shared.dto.CommunicationMessage;
import com.example.shared.dto.MessageType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.UUID;

@Service
public class CommunicationService {

    private static final Logger logger = LoggerFactory.getLogger(CommunicationService.class);

    @Autowired
    private WebClient webClient;

    @Value("${server.b.url}")
    private String serverBUrl;

    public CommunicationMessage sendMessageToServerB(String message) {
        CommunicationMessage request = new CommunicationMessage(
                UUID.randomUUID().toString(),
                "server-a",
                "server-b",
                message,
                MessageType.REQUEST
        );

        logger.info("Sending message to Server B: {}", request);

        try {
            CommunicationMessage response = webClient
                    .post()
                    .uri(serverBUrl + "/api/v1/communication/receive")
                    .body(Mono.just(request), CommunicationMessage.class)
                    .retrieve()
                    .bodyToMono(CommunicationMessage.class)
                    .timeout(Duration.ofSeconds(10))
                    .block();

            logger.info("Received response from Server B: {}", response);
            return response;
        } catch (Exception e) {
            logger.error("Error sending message to Server B", e);
            throw new RuntimeException("Failed to communicate with Server B", e);
        }
    }

    @Scheduled(fixedRate = 30000) // Send heartbeat every 30 seconds
    public void sendHeartbeat() {
        try {
            CommunicationMessage heartbeat = new CommunicationMessage(
                    UUID.randomUUID().toString(),
                    "server-a",
                    "server-b",
                    "Heartbeat from Server A",
                    MessageType.HEARTBEAT
            );

            logger.debug("Sending heartbeat to Server B");
            sendMessageToServerB("Heartbeat from Server A");
        } catch (Exception e) {
            logger.warn("Failed to send heartbeat to Server B: {}", e.getMessage());
        }
    }
}