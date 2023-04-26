package ru.spbu.detector.detection;

import org.springframework.stereotype.Component;
import ru.spbu.detector.dto.CodeFragmentsDto;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import java.util.List;
import java.util.Set;

@Component
public class DetectorService {
    public List<Set<FragmentIdentifierDto>> detect(CodeFragmentsDto codeFragmentsDto) {
        var algorithm = DetectionAlgorithm.of(codeFragmentsDto);
        return algorithm.findClusters(codeFragmentsDto.getFragments());
    }
}
