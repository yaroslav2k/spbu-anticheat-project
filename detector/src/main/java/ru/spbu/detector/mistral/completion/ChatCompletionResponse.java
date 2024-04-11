package ru.spbu.detector.mistral.completion;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.util.List;

/**
 * The ChatCompletionResponse class represents a response from the Mistral API when creating a chat completion.
 * Most of these fields are undocumented.
 */
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class ChatCompletionResponse {

    /**
     * Unique identifier for this response.
     *
     * @return the id of the response.
     */
    private String id;

    /**
     * Undocumented, seems to be the type of the response.
     */
    private String object;

    /**
     * The time the chat completion was created in seconds since the epoch.
     *
     * @return the time the chat completion was created.
     */
    private long created;

    /**
     * The model used to generate the completion.
     *
     * @return the model used to generate the completion.
     */
    private String model;

    /**
     * The generated completions.
     *
     * @return the generated completions.
     */
    private List<Choice> choices;

    /**
     * The tokens used to generate the completion.
     *
     * @return the amount of tokens used to generate the completion.
     */
    private Usage usage;

}
