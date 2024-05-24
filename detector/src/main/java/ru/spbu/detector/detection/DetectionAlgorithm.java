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
    private static final String ALGORITHM_NOT_SUPPORTED = "Algorithm {0} is not supported";

    private final DetectionAlgorithmParameters parameters;

    DetectionAlgorithm(DetectionAlgorithmParameters parameters) {
        this.parameters = parameters;
    }

    public static DetectionAlgorithm of(AlgorithmDto algorithmDto) {
        var paramsMap = algorithmDto.params();
        var name = algorithmDto.name();

        if (name.equals("lcs-baseline")) {
            return new LCSDetector(new LCSDetectorParams(paramsMap));
        } else if (name.equals("nicad")) {
            return new NICADDetector(new NICADDetectorParams(paramsMap));
        }
        else {
            throw new IllegalArgumentException(MessageFormat.format(ALGORITHM_NOT_SUPPORTED, name));
        }
    }

    /**
     * Get baseline clusterization algorithm
     * @return baseline algorithm
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

    public String getName() {
        throw new UnsupportedOperationException("Not implemented :-)");
    }
}
