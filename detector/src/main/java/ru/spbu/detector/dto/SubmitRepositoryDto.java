package ru.spbu.detector.dto;

/**
 * @param algorithm Алгоритм кластеризации
 * @param assignment Идентификатор задачи
 * @param repository Имя репозитория
 */
public record SubmitRepositoryDto(
    AlgorithmDto algorithm,
    String assignment,
    String repository
    // TODO: Добавить алгоритм
) { }
