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
        return identifier.fileName();
    }

    @JsonIgnore
    public String getClassName() {
        return identifier.className();
    }

    @JsonIgnore
    public String getFuncName() {
        return identifier.functionName();
    }

    @JsonIgnore
    public String getRepository() {
        return identifier.repository();
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
