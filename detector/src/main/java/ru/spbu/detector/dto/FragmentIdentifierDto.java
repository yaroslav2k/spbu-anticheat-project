package ru.spbu.detector.dto;

public record FragmentIdentifierDto(
        String fileName,
        String className,
        String functionName,
        String repository
) { }
