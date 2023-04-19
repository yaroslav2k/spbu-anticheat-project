package ru.spbu.detector.detection;

import java.util.ArrayList;
import java.util.List;

public class CodeFragment {
    private List<String> ngrams;
    private int id;

    public CodeFragment(int id, List<String> tokens, int n) {
        ngrams = new ArrayList<>();
        for (int i = 0; i < tokens.size() - n + 1; ++i) {
            ngrams.add(String.join(" ", tokens.subList(i, i  + n)));
        }
        this.id = id;
    }

    public List<String> getNgrams() {
        return ngrams;
    }

    public int getId() {
        return id;
    }
}
