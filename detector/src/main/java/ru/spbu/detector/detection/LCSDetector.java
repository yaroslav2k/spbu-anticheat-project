package ru.spbu.detector.detection;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ru.spbu.detector.detection.util.NgramGenerator;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

class LCSDetector extends DetectionAlgorithm {
    private final Logger log = LoggerFactory.getLogger(this.getClass());
    private final Map<String, Set<CodeFragment>> indexMap = new HashMap<>();
    private final NgramGenerator ngramGenerator;

    LCSDetector(LCSDetectorParams params) {
        super(params);
        ngramGenerator = new NgramGenerator(params.getN());
    }

    public List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments, boolean skipFragmentsSameRepository) {
        log.info("Started clusterization");

        // Построение индекса биграмм
        for (var fragment: fragments) {
            for (var ngram: ngramGenerator.getNgrams(fragment)) {
                if (indexMap.containsKey(ngram)) {
                    indexMap.get(ngram).add(fragment);
                } else {
                    indexMap.put(ngram, new HashSet<>(List.of(fragment)));
                }
            }
        }

        List<Set<FragmentIdentifierDto>> groups = new LinkedList<>();
        for (var fragment: fragments) {
            // Предварительный отбор слабых кандидатов для b на основе общих биграмм
            Set<CodeFragment> weakClones = new HashSet<>();
            for (var ngram: ngramGenerator.getNgrams(fragment)) {
                if (indexMap.containsKey(ngram)) {
                    weakClones.addAll(indexMap.get(ngram));
                }
            }
            Set<FragmentIdentifierDto> g =  new HashSet<>(List.of(fragment.getIdentifier()));
            for (var candidate: weakClones) {
                boolean shouldCompare = !skipFragmentsSameRepository || !Objects.equals(fragment.getRepository(), candidate.getRepository());
                if (shouldCompare && isSimilar(fragment, candidate)) {
                    g.add(candidate.getIdentifier());
                }
            }
            if (!groups.contains(g)) {
                groups.add(g);
            }
        }

        groups.removeIf(group -> group.size() == 1);

        log.info("Finished clusterization");
        return groups;
    }

    private boolean isSimilar(CodeFragment b, CodeFragment candidate) {
        var lcsLength = (double) findLCSLength(b, candidate);
        var threshold = ((LCSDetectorParams) getParameters()).getThreshold();

        double x = lcsLength / ngramGenerator.getNgrams(b).size();
        double y = lcsLength / ngramGenerator.getNgrams(candidate).size();
        log.debug("{\"fragment_identifiers\": [{}, {}], \"lcs_length\": {}, \"similarity\": {}}",
                b.getIdentifier(), candidate.getIdentifier(), (int)lcsLength, Math.min(x, y));
        return x >= threshold && y >= threshold;
    }

    private int findLCSLength(CodeFragment fragmentOne, CodeFragment fragmentTwo) {
        var ngramsOne = ngramGenerator.getNgrams(fragmentOne);
        var ngramsTwo = ngramGenerator.getNgrams(fragmentTwo);

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
