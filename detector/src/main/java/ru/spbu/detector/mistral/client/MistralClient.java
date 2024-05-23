package ru.spbu.detector.mistral.client;

import ru.spbu.detector.mistral.completion.ChatCompletionRequest;
import ru.spbu.detector.mistral.completion.ChatCompletionResponse;

import org.springframework.lang.NonNull;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Getter;

import reactor.core.publisher.Mono;

@Getter
public class MistralClient {
    private static final String DEFAULT_API_URL = "https://api.mistral.ai/v1";
    private static final String API_KEY_VAR = "MISTRAL_API_KEY";
    private static final String API_URL_VAR = "MISTRAL_API_URL";

    private final String apiKey;
    private final String apiURL;
    private final ObjectMapper objectMapper;

    public MistralClient() {
        this.apiKey = System.getenv(API_KEY_VAR);
        this.apiURL = System.getenv(API_URL_VAR) != null ? System.getenv(API_URL_VAR) : DEFAULT_API_URL;
        this.objectMapper = buildObjectMapper();

        if (this.apiKey == null) {
          throw new RuntimeException(String.format("Missing `%s` variable", API_KEY_VAR));
        }
    }

    public Mono<ChatCompletionResponse> createChatCompletion(@NonNull ChatCompletionRequest request) throws JsonProcessingException {
        String requestJson = objectMapper.writeValueAsString(request);
        String endpoint = "/chat/completions";

        WebClient client = WebClient.builder().baseUrl(this.apiURL + endpoint).defaultHeaders(httpHeaders -> {
            httpHeaders.set("Content-Type", "application/json");
            httpHeaders.set("Accept", "application/json");
            httpHeaders.set("Authorization", "Bearer " + getApiKey());
        }).build();
        return client.post().bodyValue(requestJson).exchangeToMono(response -> {
            return response.bodyToMono(ChatCompletionResponse.class);
        });
    }

    private ObjectMapper buildObjectMapper() {
        ObjectMapper mapper = new ObjectMapper();

        mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        return mapper;
    }
}
