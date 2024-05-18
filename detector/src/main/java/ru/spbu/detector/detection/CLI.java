package ru.spbu.detector.detection;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import ru.spbu.detector.dto.AlgorithmDto;
import ru.spbu.detector.dto.ClusterizationReport;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.mistral.Mistral;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(name = "Detector", version = "Detector 1.0.0", mixinStandardHelpOptions = true)
public class CLI implements Runnable {
    private static final Logger log = LoggerFactory.getLogger(CLI.class);
    private enum Algorithm { LCS, MISTRAL, NICAD }

    @Option(names = { "-a", "--algorithm" }, description = "Algorithm to use (one of ${COMPLETION-CANDIDATES})")
    Algorithm algorithm = Algorithm.LCS;

    @Parameters(arity = "1..*", description = "Source data to process")
    String[] sources;

    public static void main(String[] args) {
      System.exit(new CommandLine(new CLI()).execute(args));
    }

    @Override
    public void run() {
      switch (algorithm) {
        case LCS:
          processLCS();
          break;
        case MISTRAL:
          processMistral();
          break;
      case NICAD:
          processNicad();
          break;

      }
    }

    private void processLCS() {
      List<CodeFragment> fragments = new LinkedList<>();
      var objectMapper = new ObjectMapper();
      var algorithmDTO = new AlgorithmDto(algorithm.name(), Collections.emptyMap());

      try {
        for (String source : listSources(sources[0])) {
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

    private void processMistral() {
      String content1;
      String content2;
      Path path1 = Path.of(sources[0]);
      Path path2 = Path.of(sources[1]);

      try {
        content1 = Files.readString(path1);
        content2 = Files.readString(path2);

        log.info(Mistral.compareTwo(content1, content2));
      } catch (IOException e) {
        log.error(e.getMessage());

        System.exit(1);
      }
    }

    private void processNicad() {
        Map<String, Object> paramsMap = Map.of("threshold", 0.45);
        NICADDetector nicad = new NICADDetector(new NICADDetectorParams(paramsMap));
        try {
            nicad.findClustersFromFiles(sources[0], sources[1]);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private Set<String> listSources(String directory) {
        return Stream.of(new File(directory).listFiles())
            .filter(file -> !file.isDirectory())
            .map(File::getAbsolutePath)
            .collect(Collectors.toSet());
    }
}
