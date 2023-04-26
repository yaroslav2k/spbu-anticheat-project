package ru.spbu.detector.detection;

import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.CodeFragmentsDto;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import java.text.MessageFormat;
import java.util.List;
import java.util.Set;

abstract class DetectionAlgorithm {
    private final DetectionAlgorithmParameters parameters;
    private final static String ALGORITHM_NOT_SUPPORTED = "Алгоритм {0} не поддерживается";

    DetectionAlgorithm(DetectionAlgorithmParameters parameters) {
        this.parameters = parameters;
    }

    public static DetectionAlgorithm of(CodeFragmentsDto codeFragmentsDto) {
        var paramsMap = codeFragmentsDto.getParams();
        var algorithm = codeFragmentsDto.getAlgorithm();
        switch (algorithm) {
            case "LCS" -> {
                var params = new LCSDetectorParams(paramsMap);
                return new LCSDetector(params);
            }
            default -> throw new IllegalArgumentException(MessageFormat.format(ALGORITHM_NOT_SUPPORTED, algorithm));
        }
    }

    abstract List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments);

    public DetectionAlgorithmParameters getParameters() {
        return parameters;
    }
}
