package ru.spbu.detector.mistral.completion;

import com.fasterxml.jackson.annotation.JsonValue;

/**
 * The role of the message.
 */
public enum MessageRole {

    SYSTEM("system"),
    ASSISTANT("assistant"),
    USER("user");

    private final String role;

    MessageRole(String role) {
        this.role = role;
    }

    /**
     * Returns a lowercase string representation of the role. To be used when interacting with the API.
     *
     * @return A lowercase string representation of the role.
     */
    @JsonValue
    public String getRole() {
        return role;
    }
}
