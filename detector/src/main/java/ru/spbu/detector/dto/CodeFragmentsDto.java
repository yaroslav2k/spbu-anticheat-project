package ru.spbu.detector.dto;

import java.util.List;
import java.util.Map;

public class CodeFragmentsDto {
    private String algorithm;
    private Map<String, Object> params;
    private List<CodeFragment> fragments;

    public String getAlgorithm() {
        return algorithm;
    }

    public Map<String, Object> getParams() {
        return params;
    }

    public List<CodeFragment> getFragments() {
        return fragments;
    }
}
