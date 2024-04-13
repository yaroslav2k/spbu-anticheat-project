package ru.spbu.detector.mistral.client;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.lang.NonNull;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.ResponseExtractor;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import ru.spbu.detector.mistral.builder.MessageListBuilder;
import ru.spbu.detector.mistral.completion.ChatCompletionRequest;
import ru.spbu.detector.mistral.completion.ChatCompletionResponse;
import ru.spbu.detector.mistral.completion.Message;
import ru.spbu.detector.mistral.completion.MessageRole;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;

@Getter
public class MistralClient {

    private static final String API_URL = "https://api.mistral.ai/v1";
    private static final String API_KEY_VAR = "MISTRAL_API_KEY";
    private final String apiKey;
    private final ObjectMapper objectMapper;

    public MistralClient() {
        this.apiKey = System.getenv(API_KEY_VAR);
        this.objectMapper = buildObjectMapper();
    }

    public Mono<ChatCompletionResponse> createChatCompletion(@NonNull ChatCompletionRequest request) throws JsonProcessingException {
        String requestJson =objectMapper.writeValueAsString(request);
        String endpoint = "/chat/completions";

        WebClient client = WebClient.builder().baseUrl(API_URL + endpoint).defaultHeaders(httpHeaders -> {
            httpHeaders.set("Content-Type", "application/json");
            httpHeaders.set("Accept", "application/json");
            httpHeaders.set("Authorization", "Bearer " + getApiKey());
        }).build();
        Mono<ChatCompletionResponse> responseMono = client.post().bodyValue(requestJson).exchangeToMono(_response -> {
            return _response.bodyToMono(ChatCompletionResponse.class);
        });

        return responseMono;
    }

    private ObjectMapper buildObjectMapper() {
        ObjectMapper mapper = new ObjectMapper();

        mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        return mapper;
    }
}