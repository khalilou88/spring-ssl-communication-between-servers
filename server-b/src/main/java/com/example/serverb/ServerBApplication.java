package com.example.serverb;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ServerBApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServerBApplication.class, args);
    }
}