package ru.spbu.detector.detection;

import java.util.Map;


public class NILDetectorParams extends DetectionAlgorithmParameters{
    private final double threshold;

    public double getThreshold() {
        return this.threshold;
    }


    public NILDetectorParams(Map<String, Object> params) {
        super();
        this.threshold = (double) params.get("threshold");
    }
}
