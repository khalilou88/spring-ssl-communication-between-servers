package com.example.serverb.service;

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

    @Value("${server.a.url}")
    private String serverAUrl;

    public CommunicationMessage sendMessageToServerA(String message) {
        CommunicationMessage request = new CommunicationMessage(
                UUID.randomUUID().toString(),
                "server-b",
                "server-a",
                message,
                MessageType.REQUEST
        );

        logger.info("Sending message to Server A: {}", request);

        try {
            CommunicationMessage response = webClient
                    .post()
                    .uri(serverAUrl + "/api/v1/communication/receive")
                    .body(Mono.just(request), CommunicationMessage.class)
                    .retrieve()
                    .bodyToMono(CommunicationMessage.class)
                    .timeout(Duration.ofSeconds(10))
                    .block();

            logger.info("Received response from Server A: {}", response);
            return response;
        } catch (Exception e) {
            logger.error("Error sending message to Server A", e);
            throw new RuntimeException("Failed to communicate with Server A", e);
        }
    }

    @Scheduled(fixedRate = 45000) // Send heartbeat every 45 seconds (offset from Server A)
    public void sendHeartbeat() {
        try {
            CommunicationMessage heartbeat = new CommunicationMessage(
                    UUID.randomUUID().toString(),
                    "server-b",
                    "server-a",
                    "Heartbeat from Server B",
                    MessageType.HEARTBEAT
            );

            logger.debug("Sending heartbeat to Server A");
            sendMessageToServerA("Heartbeat from Server B");
        } catch (Exception e) {
            logger.warn("Failed to send heartbeat to Server A: {}", e.getMessage());
        }
    }
}