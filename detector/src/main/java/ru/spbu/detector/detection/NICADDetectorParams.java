package ru.spbu.detector.detection;

import java.util.Map;

public class NICADDetectorParams extends DetectionAlgorithmParameters{
    private final double threshold;

    public double getThreshold() {
        return threshold;
    }

    public NICADDetectorParams(Map<String, Object> params) {
        super();
        threshold = (double) params.get("threshold");
    }
}
