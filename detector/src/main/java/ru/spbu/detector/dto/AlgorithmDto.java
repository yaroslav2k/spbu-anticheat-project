package ru.spbu.detector.dto;

import java.util.Map;

/**
 * Detection algorithm DTO.
 * @param name   Algorithm name
 * @param params Algorithm parameters
 */
public record AlgorithmDto(
        String name,
        Map<String, Object> params
) {}
