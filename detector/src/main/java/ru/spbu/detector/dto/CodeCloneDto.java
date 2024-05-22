package ru.spbu.detector.dto;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

public record CodeCloneDto(
  Integer similarity,
  @JsonProperty("code_fragments") List<FragmentDto> codeFragments
) {}
