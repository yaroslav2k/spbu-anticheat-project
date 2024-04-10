package ru.spbu.detector.detection;

import ru.spbu.detector.dto.AlgorithmDto;
import ru.spbu.detector.dto.ClusterizationReport;
import ru.spbu.detector.dto.CodeFragment;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Main {
  private static final Logger log = LoggerFactory.getLogger(Main.class);

  public static void main(String[] args) { // FIXME: DRY
    if (args.length == 0 || !Files.exists(Paths.get(args[0]))) {
      throw new IllegalArgumentException("Specify existing folder as first argument");
    }

    List<CodeFragment> fragments = new LinkedList<>();
    var objectMapper = new ObjectMapper();
    var algorithmDTO = new AlgorithmDto("LCS", Collections.emptyMap());

    try {
      for (String source : listSources(args[0])) {
        fragments.addAll(
          objectMapper.readValue(
          new FileInputStream(source),
            new TypeReference<List<CodeFragment>>(){}
          )
        );
      }

      var detectionAlgorithm = DetectionAlgorithm.baseline();
      var clusters = detectionAlgorithm.findClusters(fragments, true);

      String report = objectMapper.writeValueAsString(new ClusterizationReport(algorithmDTO, clusters));

      log.info(report);
    } catch (IOException e) {
      log.error(e.getMessage());
    }
  }

  private static Set<String> listSources(String directory) {
    return Stream.of(new File(directory).listFiles())
      .filter(file -> !file.isDirectory())
      .map(File::getAbsolutePath)
      .collect(Collectors.toSet());
  }
}
