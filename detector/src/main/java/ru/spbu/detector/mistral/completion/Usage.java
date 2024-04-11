package ru.spbu.detector.mistral.completion;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Usage {

    /**
     * The number of tokens used for the prompt ("input tokens").
     *
     * @return the number of tokens used for the prompt
     */
    @JsonProperty("prompt_tokens")
    private int promptTokens;

    /**
     * The total number of tokens used (prompt tokens + completion tokens).
     *
     * @return the total number of tokens used
     */
    @JsonProperty("total_tokens")
    private int totalTokens;

    /**
     * The number of tokens used for the completion ("output tokens").
     *
     * @return the number of tokens used for the completion
     */
    @JsonProperty("completion_tokens")
    private int completionTokens;

}
