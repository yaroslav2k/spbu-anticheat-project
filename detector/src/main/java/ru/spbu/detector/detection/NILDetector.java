package ru.spbu.detector.detection;

import org.apache.commons.lang3.NotImplementedException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import ru.spbu.detector.dto.CodeCloneDto;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.FragmentDto;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;


public class NILDetector extends DetectionAlgorithm {
    private final Logger log = LoggerFactory.getLogger(this.getClass());

    private static final String TESTS_PATH = "./clones/";
    private static final String NIL_JAR_PATH = "./NIL/NIL-all.jar";

    private static final String RESULT_FILE = "result_NIL.csv";

    public NILDetector(DetectionAlgorithmParameters parameters) {
        super(parameters);
    }

    @Override
    List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments, boolean skipFragmentsSameSubmission) {
        cleanNILArtifacts();
        for (int i = 0; i < fragments.size(); i++) {
            List<String> fragment = fragments.get(i).getTokens();
            try (FileWriter fileWriter = new FileWriter(TESTS_PATH + i + ".py")) {
                for (String string : fragment)
                    fileWriter.write(string);
            } catch (IOException e) {
                log.error(String.format("Failed to write file: %s", e.getMessage()));
            }
        }

        runNIL();

        throw new NotImplementedException();
    }

    public void findClustersFromFiles(String file1, String file2) {
        cleanNILArtifacts();
        Path source = Path.of(file1);
        Path dest = Path.of(TESTS_PATH + 1 + ".py");
        try {
            Files.copy(source, dest);
        } catch (IOException e) {
            e.printStackTrace();
        }
        source = Path.of(file2);
        dest = Path.of(TESTS_PATH + 2 + ".py");
        try {
            Files.copy(source, dest);
        } catch (IOException e) {
            e.printStackTrace();
        }
        runNIL();
        deserializeFromCsv("");
    }

    void runNIL() {
        try {
            var parameters = ((NILDetectorParams) getParameters());
            var processBuilder = new ProcessBuilder("java", "-jar", NIL_JAR_PATH, "-l", "python", "-s",  TESTS_PATH, "-p", "1", "-v",  Long.toString(Math.round(parameters.getThreshold() * 100)), "-o", RESULT_FILE);
            log.info(System.getProperty("user.dir"));
            Process process = processBuilder.start();
            process.waitFor();

            if (process.exitValue() > 0) {
                log.error(String.format("Process exited with code %d", process.exitValue()));
            }
        } catch (IOException e) {
            log.error(String.format("Failed to execute `NIL`: %s", e.getMessage()));
            e.printStackTrace();
        } catch (InterruptedException e) {
            log.error(e.getMessage());
            e.printStackTrace();
        }
    }

    void deleteFolder(File folder) {
        File[] files = folder.listFiles();
        if (files != null) { // some JVMs return `null` for empty directories
            for (File f : files) {
                if (f.isDirectory()) {
                    deleteFolder(f);
                } else {
                    if (!f.delete()) {
                        log.error("Failed to delete NIL artifact folder");
                    }
                }
            }
        }
    }

    public void cleanNILArtifacts() {
        File folder = new File(TESTS_PATH);
        deleteFolder(folder);
        File code_blocks = new File("./code_blocks");
        File clone_pairs = new File("./clone_pairs");
        File results = new File("./result_5_10_70.csv");
        if (!code_blocks.delete()) log.info("Failed to delete code_blocks file");
        if (!clone_pairs.delete()) log.info("Failed to delete clone_pairs file");
        if (!results.delete()) log.info("Failed to delete results file");
    }

    Set<CodeCloneDto> deserializeFromCsv(String basePath) {
        Set<CodeCloneDto> codeClones = new HashSet<>();
        String csvFilename = RESULT_FILE;

        try {
            File fcsvFile = Paths.get(basePath, csvFilename).toFile();
            log.debug(String.format("Reading report file %s", fcsvFile.getAbsolutePath()));
            try (BufferedReader br = new BufferedReader(new FileReader(csvFilename))) {
                String line;
                while ((line = br.readLine()) != null) {
                    List<FragmentDto> codeFragments = new ArrayList<>();
                    String[] values = line.split(",");
                    codeFragments.add(new FragmentDto(values[0], Integer.parseInt(values[1]), Integer.parseInt(values[2])));
                    codeFragments.add(new FragmentDto(values[3], Integer.parseInt(values[4]), Integer.parseInt(values[5])));
                    codeClones.add(new CodeCloneDto(100, codeFragments));
                }
            }
            log.info(String.format("[NIL] Found %d clone/s ", codeClones.size()));
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        }
        return codeClones;
    }
}