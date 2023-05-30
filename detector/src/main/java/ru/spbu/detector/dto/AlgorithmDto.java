package ru.spbu.detector.dto;

import java.util.Map;

/**
 * ДТО инкапсулирующая описание алгоритма детектции
 * @param name   Название алгоритма
 * @param params Параметры алгоритма
 */
public record AlgorithmDto(
        String name,
        Map<String, Object> params
) { }
