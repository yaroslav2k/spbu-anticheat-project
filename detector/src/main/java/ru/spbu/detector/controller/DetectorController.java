package ru.spbu.detector.controller;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.spbu.detector.detection.DetectorService;
import ru.spbu.detector.dto.CodeFragmentsDto;
import ru.spbu.detector.dto.FragmentIdentifierDto;
import ru.spbu.detector.dto.SubmitRepositoryDto;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping(value = "/detection",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE)
public class DetectorController {
    private final DetectorService detectorService;

    public DetectorController(DetectorService detectorService) {
        this.detectorService = detectorService;
    }

    @PostMapping(value = "/detect-fragments", consumes = MediaType.APPLICATION_JSON_VALUE)
    @Operation(summary = "Кластеризация фрагментов кода на основе переданных токенов")
    public List<Set<FragmentIdentifierDto>> detectClones(@RequestBody CodeFragmentsDto dto) {
        return detectorService.detect(dto);
    }

    @PostMapping(value = "/compare-repositories", consumes = MediaType.APPLICATION_JSON_VALUE)
    @Operation(summary = "Добавить репозиторий в задание для сравнения с другими репозиториями")
    public void submitRepository(@RequestBody SubmitRepositoryDto dto)  {
        detectorService.submitCompareRepositoriesTask(dto);
    }
}
