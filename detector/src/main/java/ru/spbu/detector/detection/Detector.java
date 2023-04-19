package ru.spbu.detector.detection;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class Detector {
    private Map<String, Set<CodeFragment>> indexMap;
    private double threshold;

    public Detector(double threshold) {
        this.threshold = threshold;
        this.indexMap = new HashMap<>();
    }

    public List<Set<Integer>> findClusters(List<CodeFragment> fragments) {
        // Построение индекс биграмм
        for (var fragment: fragments) {
            for (var ngram: fragment.getNgrams()) {
                if (indexMap.containsKey(ngram)) {
                    indexMap.get(ngram).add(fragment);
                } else {
                    indexMap.put(ngram, new HashSet<>(List.of(fragment)));
                }
            }
        }

        List<Set<Integer>> groups = new LinkedList<>();
        for (var fragment: fragments) {
            // Предварительный отбор слабых кандидатов для b на основе общих биграмм
            Set<CodeFragment> weakClones = new HashSet<>();
            for (var ngram: fragment.getNgrams()) {
                if (indexMap.containsKey(ngram)) {
                    weakClones.addAll(indexMap.get(ngram));
                }
            }
            Set<Integer> g =  new HashSet<>(List.of(fragment.getId()));
            for (var candidate: weakClones) {
                if (isSimilar(fragment, candidate)) {
                    g.add(candidate.getId());
                }
            }
            if (!groups.contains(g)) {
                groups.add(g);
            }
        }
        return groups;
    }

    private boolean isSimilar(CodeFragment b, CodeFragment candidate) {
        var lcsLength = (double) findLCSLength(b, candidate);
        double x = lcsLength / b.getNgrams().size();
        double y = lcsLength / candidate.getNgrams().size();
        return x >= threshold && y >= threshold;
    }

    private int findLCSLength(CodeFragment fragmentOne, CodeFragment fragmentTwo) {
        var ngramsOne = fragmentOne.getNgrams();
        var ngramsTwo = fragmentTwo.getNgrams();

        if (ngramsOne.size() == 0 || ngramsTwo.size() == 0) {
            return 0;
        }

        int[][] lcs = new int[ngramsOne.size() + 1][ngramsTwo.size() + 1];

        for (int i = 0; i < ngramsOne.size() + 1; ++i) {
            for (int j = 0; j < ngramsTwo.size() + 1; ++j) {
                if (i == 0 || j == 0) {
                    lcs[i][j] = 0;
                } else if (Objects.equals(ngramsOne.get(i-1), ngramsTwo.get(j-1))) {
                    lcs[i][j] = lcs[i-1][j-1] + 1;
                } else {
                    lcs[i][j] = Math.max(lcs[i-1][j], lcs[i][j-1]);
                }
            }
        }
        return lcs[ngramsOne.size()][ngramsTwo.size()];
    }
}
