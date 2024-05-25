package ru.spbu.detector.dto;

import java.util.Set;

import com.fasterxml.jackson.annotation.JsonProperty;

public record CloneDetectionResultDto(
  @JsonProperty("algorithm") AlgorithmDto algorithm,
  @JsonProperty("result") Set<CodeCloneDto> codeClones
) {}
