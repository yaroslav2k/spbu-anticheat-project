package ru.spbu.detector.detection;

import java.util.Map;

public class NICADDetectorParams extends DetectionAlgorithmParameters{
    private final double threshold;
    private final boolean matchCloneClasses;

    public double getThreshold() {
        return this.threshold;
    }

    public boolean matchCloneClasses() {
        return this.matchCloneClasses;
    }

    public NICADDetectorParams(Map<String, Object> params) {
        super();

        this.threshold = (double) params.get("threshold");
        this.matchCloneClasses = (boolean) params.getOrDefault("matchCloneClasses", true);
    }
}
