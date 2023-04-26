package ru.spbu.detector.detection.util;

import ru.spbu.detector.dto.CodeFragment;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NgramGenerator {
    private final int n;
    private final Map<String, List<String>> cache = new HashMap<>();

    public NgramGenerator(int n) {
        this.n = n;
    }
    public List<String> getNgrams(CodeFragment fragment) {
        var key = MessageFormat.format(
                "{0}{1}{2}{3}{4}{5}",
                fragment.getFileName().length(), fragment.getFileName(),
                fragment.getClassName().length(), fragment.getClassName(),
                fragment.getFuncName().length(), fragment.getFuncName());
        if (cache.containsKey(key)) {
            return cache.get(key);
        }

        List<String> ngrams = new ArrayList<>();
        var tokens = fragment.getTokens();
        for (int i = 0; i < tokens.size() - n + 1; ++i) {
            ngrams.add(String.join(" ", tokens.subList(i, i  + n)));
        }

        cache.put(key, ngrams);
        return ngrams;
    }
}
