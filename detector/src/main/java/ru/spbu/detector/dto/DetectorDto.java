package ru.spbu.detector.dto;

import java.util.List;

public class DetectorDto {
    private double threshold;
    private double n;
    private List<List<String>> fragments;

    public double getThreshold() {
        return threshold;
    }

    public void setThreshold(double threshold) {
        this.threshold = threshold;
    }

    public double getN() {
        return n;
    }

    public void setN(double n) {
        this.n = n;
    }

    public List<List<String>> getFragments() {
        return fragments;
    }

    public void setFragments(List<List<String>> fragments) {
        this.fragments = fragments;
    }
}
