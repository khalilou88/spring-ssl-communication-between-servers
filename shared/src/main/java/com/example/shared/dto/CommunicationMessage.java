package com.example.shared.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public class CommunicationMessage {

    @JsonProperty("id")
    @NotBlank
    private String id;

    @JsonProperty("from")
    @NotBlank
    private String from;

    @JsonProperty("to")
    @NotBlank
    private String to;

    @JsonProperty("message")
    @NotBlank
    private String message;

    @JsonProperty("timestamp")
    @NotNull
    private LocalDateTime timestamp;

    @JsonProperty("messageType")
    @NotNull
    private MessageType messageType;

    public CommunicationMessage() {
    }

    public CommunicationMessage(String id, String from, String to, String message, MessageType messageType) {
        this.id = id;
        this.from = from;
        this.to = to;
        this.message = message;
        this.messageType = messageType;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public MessageType getMessageType() {
        return messageType;
    }

    public void setMessageType(MessageType messageType) {
        this.messageType = messageType;
    }

    @Override
    public String toString() {
        return "CommunicationMessage{" +
                "id='" + id + '\'' +
                ", from='" + from + '\'' +
                ", to='" + to + '\'' +
                ", message='" + message + '\'' +
                ", timestamp=" + timestamp +
                ", messageType=" + messageType +
                '}';
    }
}