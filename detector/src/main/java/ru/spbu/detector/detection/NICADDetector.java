package ru.spbu.detector.detection;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.FragmentIdentifierDto;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

public class NICADDetector extends DetectionAlgorithm {

    private final Logger log = LoggerFactory.getLogger(this.getClass());
    private final String NICAD_PATH = "src/main/resources/Open-NiCad/";

    private final String TESTS_PATH = "src/main/resources/Open-NiCad/tests/examples/clones/";

    private final String NICAD_CLONES =  "nicadclones/clones/";
    private final String BLIND_CLONES = NICAD_CLONES + "clones_files-blind-clones/clones_files-blind-clones-0.30-classes.xml";


    public NICADDetector(DetectionAlgorithmParameters parameters) {
        super(parameters);
    }

    @Override
    List<Set<FragmentIdentifierDto>> findClusters(List<CodeFragment> fragments, boolean skipFragmentsSameSubmission) {
        cleanNicadclones();
        for (int i = 0; i < fragments.size(); i++) {
            List<String> fragment = fragments.get(i).getTokens();
            try (FileWriter fileWriter = new FileWriter(  TESTS_PATH + i + ".py")) {
                for (String string : fragment)
                    fileWriter.write(string);
            } catch (IOException e) {
                log.error("Ошибка при записи в файл: " + e.getMessage());
            }
        }
        runNicad();
        List<Set<Integer>> list = deserializeFromXml();
        List<Set<FragmentIdentifierDto>> result = new LinkedList<>();
        for (Set<Integer> sets : list) {
            Set<FragmentIdentifierDto> g = new java.util.HashSet<>(List.of());
            for (int i : sets) {
                g.add(fragments.get(i).getIdentifier());
            }
            result.add(g);
        }
        return result;
    }

    public void findClustersFromFiles(String file1, String file2) {
        cleanNicadclones();
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
        runNicad();
        deserializeFromXml();
    }

    void runNicad() {
        try {
            Runtime.getRuntime().exec(NICAD_PATH + "bin/nicad files py " + TESTS_PATH).waitFor();
        } catch (IOException e) {
            log.error("Ошибка при запуске NiCad: " + e.getMessage());
        } catch (InterruptedException e) {
            log.error(e.getMessage());
            e.printStackTrace();
        }
    }

    void deleteFolder(File folder) {
        File[] files = folder.listFiles();
        if(files!=null) { //some JVMs return null for empty dirs
            for(File f: files) {
                if(f.isDirectory()) {
                    deleteFolder(f);
                } else {
                    f.delete();
                }
            }
        }
    }

    public void cleanNicadclones() {
        File folder = new File(TESTS_PATH);
        deleteFolder(folder);
        folder = new File(NICAD_CLONES);
        deleteFolder(folder);
    }

    List<Set<Integer>> deserializeFromXml() {
        List<Set<Integer>> groups = new LinkedList<>();
        try {
            File fXmlFile = new File(BLIND_CLONES);
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(fXmlFile);
            doc.getDocumentElement().normalize();

            NodeList CloneClasses = doc.getElementsByTagName("class");
            for (int i = 0; i < CloneClasses.getLength(); i++) {
                Node nNode = CloneClasses.item(i);

                if (nNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element eElement = (Element) nNode;
                    int similarity = Integer.parseInt(eElement.getAttribute("similarity"));
                    if (similarity < ((NICADDetectorParams) getParameters()).getThreshold())
                        continue;
                    log.info("found clone:");
                    log.info("Similarity: " + similarity);
                    NodeList Sources = ((Element) nNode).getElementsByTagName("source");
                    Set<Integer> g = new java.util.HashSet<>(List.of());
                    for (int j = 0; j < Sources.getLength(); j++) {
                        String filePath = ((Element) Sources.item(j)).getAttribute("file");
                        log.info(filePath);
                        int fileNum = Integer.parseInt(Path.of(filePath).getFileName().toString().replaceFirst("[.][^.]+$", ""));
                        g.add(fileNum);
                    }
                    if (!groups.contains(g)) {
                        groups.add(g);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return groups;
    }
}
