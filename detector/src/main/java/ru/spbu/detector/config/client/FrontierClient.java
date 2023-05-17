package ru.spbu.detector.config.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import ru.spbu.detector.config.client.configuration.FrontierClientConfiguration;
import ru.spbu.detector.dto.SubmissionStatusDto;

@FeignClient(
        name = "frontier-api",
        url = "${client.frontier.url}",
        configuration = FrontierClientConfiguration.class
)
public interface FrontierClient {
    @PutMapping(value = "/api/submissions/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    void setSubmissionStatus(@PathVariable("id") String id, @RequestBody SubmissionStatusDto status);
}
