package ru.spbu.detector.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * @param algorithm  Detection algorithm
 * @param assignment Task identifier
 * @param resultPath Webhook URL
 * @param resultKey  S3 result key
 */
public record SubmitRepositoryDto(
        AlgorithmDto algorithm,
        String assignment,
        @JsonProperty("result_path") String resultPath,
        @JsonProperty("result_key") String resultKey
) {
}
