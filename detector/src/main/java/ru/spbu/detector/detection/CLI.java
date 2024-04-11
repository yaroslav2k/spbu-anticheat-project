package ru.spbu.detector.detection;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import ru.spbu.detector.dto.AlgorithmDto;
import ru.spbu.detector.dto.ClusterizationReport;
import ru.spbu.detector.dto.CodeFragment;

@Command(name = "Detector", version = "Detector 1.0.0", mixinStandardHelpOptions = true)
public class CLI implements Runnable {
    private static final Logger log = LoggerFactory.getLogger(CLI.class);

    @Option(names = { "-a", "--algorithm" }, description = "Algorithm to use")
    String algorithm = "LCS";

    @Option(names = { "-d", "--directory" }, required = true, description = "Directory to process")
    String directory;

    public static void main(String[] args) {
      System.exit(new CommandLine(new CLI()).execute(args));
    }

    @Override
    public void run() {
      List<CodeFragment> fragments = new LinkedList<>();
      var objectMapper = new ObjectMapper();
      var algorithmDTO = new AlgorithmDto(algorithm, Collections.emptyMap());

      try {
        for (String source : listSources(directory)) {
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

    private Set<String> listSources(String directory) {
        return Stream.of(new File(directory).listFiles())
            .filter(file -> !file.isDirectory())
            .map(File::getAbsolutePath)
            .collect(Collectors.toSet());
    }
}
