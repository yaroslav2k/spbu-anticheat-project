package ru.spbu.detector.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Идентификатор фрагмента кода
 *
 * @param fileName Имя файла, которому принадлежит фрагмент
 * @param className Имя класса, которому принадлежит фрагмент
 * @param functionName Имя функции, которой принадлежит фрагмент
 * @param repositoryURL Ссылка на репозиторий, которому принадлежит фрагмент
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record FragmentIdentifierDto(
        String fileName,
        String className,
        String functionName,
        String repositoryURL
) { }
