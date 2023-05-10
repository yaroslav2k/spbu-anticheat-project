package ru.spbu.detector.detection;

import ru.spbu.detector.dto.AlgorithmDto;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import java.text.MessageFormat;
import java.util.List;
import java.util.Map;
import java.util.Set;

abstract class DetectionAlgorithm {
    private final DetectionAlgorithmParameters parameters;
    private final static String ALGORITHM_NOT_SUPPORTED = "Алгоритм {0} не поддерживается";

    DetectionAlgorithm(DetectionAlgorithmParameters parameters) {
        this.parameters = parameters;
    }

    public static DetectionAlgorithm of(AlgorithmDto algorithmDto) {
        var paramsMap = algorithmDto.params();
        var name = algorithmDto.name();
        switch (name) {
            case "LCS" -> {
                var params = new LCSDetectorParams(paramsMap);
                return new LCSDetector(params);
            }
            default -> throw new IllegalArgumentException(MessageFormat.format(ALGORITHM_NOT_SUPPORTED, name));
        }
    }

    public static DetectionAlgorithm baseline() {
        Map<String, Object> paramsMap = Map.of("threshold", 0.45, "n", 2);
        var params = new LCSDetectorParams(paramsMap);
        return new LCSDetector(params);
    }

    /**
     * @param fragments Фрагменты кода, среди которых необходимо вычленить кластеры
     * @param skipFragmentsSameRepository Не проводить сравнение фрагментов, принадлежащих одному репозиторию
     */
    abstract List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments, boolean skipFragmentsSameRepository);

    public DetectionAlgorithmParameters getParameters() {
        return parameters;
    }
}
