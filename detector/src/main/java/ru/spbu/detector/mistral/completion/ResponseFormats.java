package ru.spbu.detector.mistral.completion;

import com.fasterxml.jackson.annotation.JsonValue;

/**
 * The response formats supported by mistral.
 */
public enum ResponseFormats {

    TEXT("text"),
    JSON("json_object");

    private final String format;

    ResponseFormats(String format) {
        this.format = format;
    }

    /**
     * Returns a lowercase string representation of the format. To be used when interacting with the API.
     *
     * @return Lowercase string representation of the format.
     */
    @JsonValue
    public String getFormat() {
        return format;
    }
}
