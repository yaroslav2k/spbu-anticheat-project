package ru.spbu.detector.mistral.completion;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;

/**
 * Represents a choice in a chat completion. A choice contains the message that was generated and the reason for the completion to finish.
 */
@Getter
public class Choice {

    /**
     * The index of the choice. Starts at 0.
     *
     * @return the index of the choice
     */
    private int index;

    /**
     * The message that was generated.
     *
     * @return the message that was generated
     */
    private Message message;

    /**
     * Reason for the completion to finish.
     *
     * @return the reason for the completion to finish
     */
    @JsonProperty("finish_reason")
    private String finishReason;

    @JsonProperty("logprobs")
    private String logProbs;

}
