package ru.spbu.detector.dto;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.util.List;

public class CodeFragment {
    private List<String> tokens;

    private FragmentIdentifierDto identifier;

    public List<String> getTokens() {
        return tokens;
    }

    public FragmentIdentifierDto getIdentifier() {
        return identifier;
    }

    @JsonIgnore
    public String getFileName() {
        return identifier.getFileName();
    }

    @JsonIgnore
    public String getClassName() {
        return identifier.getClassName();
    }

    @JsonIgnore
    public String getFuncName() {
        return identifier.getFunctionName();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        CodeFragment that = (CodeFragment) o;

        return identifier.equals(that.identifier);
    }

    @Override
    public int hashCode() {
        return identifier.hashCode();
    }
}
