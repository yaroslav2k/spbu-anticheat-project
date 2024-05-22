package ru.spbu.detector.mistral.completion;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * A message in a conversation. A message contains the role of the message, and the content of the message.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Message {

    /**
     * The role of the message.
     * Currently, there are 3 roles: user, assistant, and system.
     *
     * @param role The role of the message.
     * @return The role of the message.
     */
    @NotNull
    private MessageRole role;

    /**
     * The content of the message.
     *
     * @param content The content of the message.
     * @return The content of the message.
     */
    @NotNull
    private String content;

    /**
     * Unimplemented. Don't use.
     */
    @JsonProperty("tool_calls")
    private List<String> toolCalls;

    public Message(MessageRole role, String content) {
        this.role = role;
        this.content = content;
    }
}

