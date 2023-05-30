package ru.spbu.detector.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.Objects;

/**
 * Идентификатор фрагмента кода
 *
 * @param fileName      Имя файла, которому принадлежит фрагмент
 * @param className     Имя класса, которому принадлежит фрагмент
 * @param functionName  Имя функции, которой принадлежит фрагмент
 * @param repositoryURL Ссылка на репозиторий, которому принадлежит фрагмент
 * @param revision      Ревизия
 * @param functionStart Начало функции
 * @param functionEnd   Конец функции
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record FragmentIdentifierDto(
        String fileName,
        String className,
        String functionName,
        String repositoryURL,
        String revision,
        int functionStart,
        int functionEnd
) {
    public static boolean fromSameSubmission(FragmentIdentifierDto left, FragmentIdentifierDto right) {
        return Objects.equals(left.repositoryURL, right.repositoryURL) && Objects.equals(left.revision, right.revision);
    }
}
