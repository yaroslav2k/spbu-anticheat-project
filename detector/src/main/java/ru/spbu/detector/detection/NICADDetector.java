package ru.spbu.detector.detection;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;

import org.apache.commons.lang3.NotImplementedException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import ru.spbu.detector.dto.CodeCloneDto;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.FragmentDto;
import ru.spbu.detector.dto.FragmentIdentifierDto;

public class NICADDetector extends DetectionAlgorithm {
    private final Logger log = LoggerFactory.getLogger(this.getClass());

    private static final String TESTS_PATH = "src/main/resources/Open-NiCad/tests/examples/clones/";

    private static final String NICAD_CLONES = "nicadclones/data/";
    private static final String BLIND_CLONES = NICAD_CLONES
            + "data_files-blind-clones/data_files-blind-clones-0.30.xml";
    private static final String BLIND_CLONES_CLASSES = NICAD_CLONES
           + "data_files-blind-clones/data_files-blind-clones-0.30-classes.xml";

    public NICADDetector(DetectionAlgorithmParameters parameters) {
        super(parameters);
    }

    @Override
    List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments, boolean skipFragmentsSameSubmission) {
        cleanNicadArtifacts();
        for (int i = 0; i < fragments.size(); i++) {
            List<String> fragment = fragments.get(i).getTokens();
            try (FileWriter fileWriter = new FileWriter(TESTS_PATH + i + ".py")) {
                for (String string : fragment)
                    fileWriter.write(string);
            } catch (IOException e) {
                log.error(String.format("Failed to write file: %s", e.getMessage()));
            }
        }

        runNicad(TESTS_PATH);

        throw new NotImplementedException();
    }

    public Set<CodeCloneDto> findClustersFromDirectory(Path directoryPath) {
        cleanNicadArtifacts();

        runNicad(directoryPath.toString());

        return deserializeFromXml(directoryPath.toString());
    }

    public void findClustersFromFiles(String file1, String file2) {
        cleanNicadArtifacts();
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
        runNicad(TESTS_PATH);
        deserializeFromXml("");
    }

    void runNicad(String directoryPath) {
        try {
            var processBuilder = new ProcessBuilder(
                    Arrays.asList("/usr/local/bin/nicad", "files", "py", directoryPath + "/data"));
            processBuilder.directory(Paths.get(directoryPath).toFile());
            Process process = processBuilder.start();
            process.waitFor();

            if (process.exitValue() > 0) {
                log.error(String.format("Process exited with code %d", process.exitValue()));
            }
        } catch (IOException e) {
            log.error(String.format("Failed to execute `NiCad`: %s", e.getMessage()));
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
                        log.error("Failed to delete nicad artifact folder");
                    }
                }
            }
        }
    }

    public void cleanNicadArtifacts() {
        File folder = new File(TESTS_PATH);
        deleteFolder(folder);
        folder = new File(NICAD_CLONES);
        deleteFolder(folder);
    }

    Set<CodeCloneDto> deserializeFromXml(String basePath) {
        Set<CodeCloneDto> codeClones = new HashSet<>();
        var parameters = ((NICADDetectorParams) getParameters());
        var threshold = parameters.getThreshold() * 100;
        var matchCloneClasses = parameters.matchCloneClasses();

        String xmlFilename = matchCloneClasses ? BLIND_CLONES_CLASSES : BLIND_CLONES;

        try {
            File fXmlFile = Paths.get(basePath, xmlFilename).toFile();
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            dbFactory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(fXmlFile);
            doc.getDocumentElement().normalize();

            String topLevelKey = matchCloneClasses ? "class" : "clone";
            NodeList serializedClones = doc.getElementsByTagName(topLevelKey);
            for (int i = 0; i < serializedClones.getLength(); i++) {
                if (serializedClones.item(i).getNodeType() != Node.ELEMENT_NODE) {
                    continue;
                }

                Element serializedCloneElement = (Element) serializedClones.item(i);
                int similarity = Integer.parseInt(serializedCloneElement.getAttribute("similarity"));

                if (similarity < threshold) {
                    continue;
                } else {
                    log.info(String.format("[NiCad] Found clone with similarity: %d", similarity));
                }

                List<FragmentDto> codeFragments = new ArrayList<>();
                NodeList serializedFragments = serializedCloneElement.getElementsByTagName("source");

                for (int j = 0; j < serializedFragments.getLength(); j++) {
                    Element serializedFragmentElement = (Element) serializedFragments.item(j);

                    codeFragments.add(new FragmentDto(serializedFragmentElement.getAttribute("file"),
                            Integer.parseInt(serializedFragmentElement.getAttribute("startline")),
                            Integer.parseInt(serializedFragmentElement.getAttribute("endline"))));

                }

                codeClones.add(new CodeCloneDto(similarity, codeFragments));
            }
        } catch (Exception e) {
            e.printStackTrace();

            throw new RuntimeException(e.getMessage());
        }
        return codeClones;
    }
}
