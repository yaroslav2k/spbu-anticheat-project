package ru.spbu.detector.detection.util;

import ru.spbu.detector.dto.CodeFragment;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Генератор n-грамм
 */
public class NgramGenerator {
    private final int n;
    private final Map<CodeFragment, List<String>> cache = new HashMap<>();

    /**
     * @param n Размер n-граммы
     */
    public NgramGenerator(int n) {
        this.n = n;
    }

    /**
     * Разбивает фрагмент кода на n-граммы. <br>
     * Внутри происходит кеширование для фрагментов, поэтому повторный вызов вернется сразу.
     * @param fragment Фрагмент кода
     * @return Список n-грамм
     */
    public List<String> getNgrams(CodeFragment fragment) {
        if (cache.containsKey(fragment)) {
            return cache.get(fragment);
        }

        List<String> ngrams = new ArrayList<>();
        var tokens = fragment.getTokens();
        for (int i = 0; i < tokens.size() - n + 1; ++i) {
            ngrams.add(String.join(" ", tokens.subList(i, i  + n)));
        }

        cache.put(fragment, ngrams);
        return ngrams;
    }
}
