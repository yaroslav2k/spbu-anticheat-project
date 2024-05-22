package ru.spbu.detector.dto;

public record FragmentDto(
  String identifier,
  Integer line_start,
  Integer line_end
) {}
