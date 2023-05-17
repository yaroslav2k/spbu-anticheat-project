package ru.spbu.detector.dto;

/**
 * @param algorithm Алгоритм кластеризации
 * @param assignment Идентификатор задачи
 * @param repository Имя репозитория
 * @param resultKey Путь по которому нужно положить отчет
 */
public record SubmitRepositoryDto(
    AlgorithmDto algorithm,
    String assignment,
    String repository,
    String resultKey
) { }
