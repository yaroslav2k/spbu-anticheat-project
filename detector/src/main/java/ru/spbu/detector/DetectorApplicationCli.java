package ru.spbu.detector;

import com.fasterxml.jackson.databind.ObjectMapper;
import ru.spbu.detector.detection.CodeFragment;
import ru.spbu.detector.detection.Detector;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.LinkedList;
import java.util.List;

public class DetectorApplicationCli {
    public static void main(String[] args) throws IOException {
        var pathToTokens = Paths.get(args[0]);
        var n = Integer.parseInt(args[1]);
        var threshold = Double.parseDouble(args[2]);

        var mapper = new ObjectMapper();
        var listReader = mapper.readerForListOf(String.class);

        List<CodeFragment> fragments = new LinkedList<>();
        try (var reader = Files.newBufferedReader(Paths.get(args[0]))) {
            String line;
            int id = 0;
            while ((line = reader.readLine()) != null) {
                List<String> tokens = listReader.readValue(line);
                fragments.add(new CodeFragment(id, tokens, n));
                id++;
            }
        }

        var detector = new Detector(threshold);
        var groups = detector.findClusters(fragments);
        var groupId = 1;
        for (var group: groups) {
            var output = mapper.writeValueAsString(group);
            System.out.printf("group %d: %s\n", groupId, output);
            groupId++;
        }
    }
}
