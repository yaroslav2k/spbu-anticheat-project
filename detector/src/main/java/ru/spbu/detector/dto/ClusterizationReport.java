package ru.spbu.detector.dto;

import java.util.List;
import java.util.Set;

/**
 * Дто представляет отчет кластеризации
 *
 * @param metadata Метаданные алгоритма
 * @param clusters Найденные кластеры
 */
public record ClusterizationReport(
        AlgorithmDto metadata,
        List<Set<FragmentIdentifierDto>> clusters
) { }
