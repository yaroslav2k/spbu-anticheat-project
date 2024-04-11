package ru.spbu.detector.mistral.completion;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
/**
 * The response format of a completion request.
 */
public class ResponseFormat {

    /**
     * The type of the response format. Currently, can either be TEXT or JSON.
     *
     * @param type The type of the response format.
     * @return The type of the response format.
     */
    @NotNull
    private ResponseFormats type = ResponseFormats.TEXT;

}
