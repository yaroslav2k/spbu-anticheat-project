package ru.spbu.detector.config.client.configuration;

import feign.RequestInterceptor;
import org.apache.http.HttpHeaders;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;

public class FrontierClientConfiguration {

    @Value("${client.frontier.auth-token}")
    private String frontierToken;

    @Bean
    public RequestInterceptor frontierRequestInterceptor() {
        return requestTemplate -> {
            requestTemplate.header(HttpHeaders.AUTHORIZATION, "Bearer " + frontierToken);
        };
    }
}
