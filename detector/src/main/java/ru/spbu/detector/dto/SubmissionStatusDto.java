package ru.spbu.detector.dto;

import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * Статус обработки посылки задания (assignment)
 */
@JsonFormat(shape = JsonFormat.Shape.OBJECT)
public enum SubmissionStatusDto {
    COMPLETED("completed");

    private final String status;

    SubmissionStatusDto(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }
}
