package ru.spbu.detector.mistral;

import java.util.List;

import ru.spbu.detector.mistral.builder.MessageListBuilder;
import ru.spbu.detector.mistral.client.MistralClient;
import ru.spbu.detector.mistral.completion.ChatCompletionRequest;
import ru.spbu.detector.mistral.completion.ChatCompletionResponse;
import ru.spbu.detector.mistral.completion.Message;

import com.fasterxml.jackson.core.JsonProcessingException;
import reactor.core.publisher.Mono;

public class Mistral {
    private static final String PROMPT_INITIAL_MESSAGE =
      """
      Compare these two implementations of the same function and answer \
      whether there are signs of copying in these works. Consider the length of the entire text, \
      but do not take into account the names of the functions. On the first line of the answer write Yes or No, then on the next line, \
      if there are signs of copying, write your comment.
      """;

    public static String compareTwo(String prg1, String prg2) {
        MistralClient client = new MistralClient();

        String model = "open-mistral-7b";
        List<Message> messages = new MessageListBuilder()
                .system(PROMPT_INITIAL_MESSAGE)
                .user(prg1 + "/n/n" + prg2)
                .build();

        ChatCompletionRequest request = ChatCompletionRequest.builder()
                .model(model)
                .temperature(0.75)
                .messages(messages)
                .build();

        Mono<ChatCompletionResponse> response;
        try {
            response = client.createChatCompletion(request);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        Message firstChoice = response.block().getChoices().get(0).getMessage();
        return firstChoice.getRole() + ":\n" + firstChoice.getContent() + "\n";
    }

    private Mistral() {}
  }
