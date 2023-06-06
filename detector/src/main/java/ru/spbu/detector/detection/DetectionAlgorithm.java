package ru.spbu.detector.detection;

import ru.spbu.detector.dto.AlgorithmDto;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import java.text.MessageFormat;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Абстрактный класс инкапсулирующий алгоритм кластеризации
 */
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

    /**
     * Получить baseline алгорит кластеризации
     * @return baseline алгоритм
     */
    public static DetectionAlgorithm baseline() {
        Map<String, Object> paramsMap = Map.of("threshold", 0.45, "n", 2);
        var params = new LCSDetectorParams(paramsMap);
        return new LCSDetector(params);
    }

    /**
     * Провести кластеризацию фрагментов кода
     * @param fragments                   Фрагменты кода, среди которых необходимо вычленить кластеры
     * @param skipFragmentsSameSubmission true - не проводить сравнение фрагментов, принадлежащих одной посылке
     */
    abstract List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments, boolean skipFragmentsSameSubmission);

    /**
     * Получить параметры алгоритма кластеризации
     */
    public DetectionAlgorithmParameters getParameters() {
        return parameters;
    }
}
