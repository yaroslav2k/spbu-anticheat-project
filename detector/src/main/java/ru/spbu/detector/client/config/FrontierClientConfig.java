package ru.spbu.detector.client.config;

import feign.RequestInterceptor;
import org.springframework.http.HttpHeaders;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;

public class FrontierClientConfig {

    @Value("${client.frontier.auth-token}")
    private String frontierToken;

    @Bean
    public RequestInterceptor frontierRequestInterceptor() {
        return requestTemplate -> {
            requestTemplate.header(HttpHeaders.AUTHORIZATION, "Bearer " + frontierToken);
        };
    }
}
