package ru.spbu.detector.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * @param algorithm  Алгоритм кластеризации
 * @param assignment Идентификатор задачи
 * @param resultPath Путь по которому нужно отправить хук frontier
 * @param resultKey  Путь по которому нужно положить отчет
 */
public record SubmitRepositoryDto(
        AlgorithmDto algorithm,
        String assignment,
        @JsonProperty("result_path") String resultPath,
        @JsonProperty("result_key") String resultKey
) {
}
