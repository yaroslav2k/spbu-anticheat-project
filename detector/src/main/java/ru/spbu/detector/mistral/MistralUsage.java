package ru.spbu.detector.mistral;

import com.fasterxml.jackson.core.JsonProcessingException;
import reactor.core.publisher.Mono;
import ru.spbu.detector.mistral.builder.MessageListBuilder;
import ru.spbu.detector.mistral.completion.ChatCompletionRequest;
import ru.spbu.detector.mistral.completion.ChatCompletionResponse;
import ru.spbu.detector.mistral.completion.Message;

import java.util.List;

public class MistralUsage {
    public static void main(String[] arg) {
        MistralClient client = new MistralClient();

        String program1 = "def print_numbers():\n" +
                "    number = 1\n" +
                "    while number <= 10:\n" +
                "        print(number)\n" +
                "        number += 1" ;
        String program2 = "def print_numbers():\n" +
                "    num = 1\n" +
                "    while num <= 10:\n" +
                "        print(num)\n" +
                "        num += 1";

        String model = "open-mistral-7b";
        List<Message> messages = new MessageListBuilder()
                .system("Сравни эти две реализации одной функции и ответь, есть ли признаки копирования в этих работах. Учитвай длину всего текста, но не учитывай названия функций. На первой строке ответа напиши Да или Нет, далее, на следующей строке, если присутствуют признаки копирования, напиши свой комментарий")
                .user(program1 + "/n/n" + program2)
                .build();

        ChatCompletionRequest request = ChatCompletionRequest.builder()
                .model(model)
                .temperature(0.75)
                .messages(messages)
                .build();

        Mono<ChatCompletionResponse> response = null;
        try {
            response = client.createChatCompletion(request);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        Message firstChoice = response.block().getChoices().get(0).getMessage();
        System.out.println(firstChoice.getRole() + ":\n" + firstChoice.getContent() + "\n");
    }
}
