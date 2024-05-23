package ru.spbu.detector.dto;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;


/**
 * Detection algorithm DTO.
 * @param name   Algorithm name
 * @param params Algorithm parameters
 */
public record CloneDetectionTaskDto(
  @NotNull AlgorithmDto algorithm,
  @NotNull Map<String, Object> params,
  @NotNull String revision,
  @NotNull @JsonProperty("result_path") String resultPath,
  @NotNull @JsonProperty("result_key") String resultKey,
  @NotNull @NotEmpty @JsonProperty("resources") String[] resources
) {}

