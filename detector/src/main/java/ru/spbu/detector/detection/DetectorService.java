package ru.spbu.detector.detection;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import ru.spbu.detector.client.FrontierClient;
import ru.spbu.detector.dto.ClusterizationReport;
import ru.spbu.detector.dto.CodeFragment;
import ru.spbu.detector.dto.CodeFragmentsDto;
import ru.spbu.detector.dto.FragmentIdentifierDto;
import ru.spbu.detector.dto.SubmissionStatusDto;
import ru.spbu.detector.dto.SubmitRepositoryDto;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Component
public class DetectorService {
    private final Logger log = LoggerFactory.getLogger(this.getClass());

    @Value("${detector.s3.bucket-name}")
    private String bucketName;
    private final S3Client s3Client;
    private final FrontierClient frontierClient;

    private final ExecutorService detectorThreadPool = Executors.newFixedThreadPool(10);

    public DetectorService(S3Client s3Client, FrontierClient frontierClient) {
        this.s3Client = s3Client;
        this.frontierClient = frontierClient;
    }

    public List<Set<FragmentIdentifierDto>> detect(CodeFragmentsDto codeFragmentsDto) {
        var algorithm = DetectionAlgorithm.baseline();
        return algorithm.findClusters(codeFragmentsDto.getFragments(), false);
    }

    public void submitCompareRepositoriesTask(SubmitRepositoryDto dto) {
        detectorThreadPool.submit(() -> {
            var trackingId = UUID.randomUUID().toString();
            MDC.put("trackingId", trackingId);
            try {
                compareRepositories(dto);
            } catch (Exception e) {
                log.error(e.getMessage());
            }
        });
        log.info("Submitted task: {}", dto.assignment());
    }

    private void compareRepositories(SubmitRepositoryDto dto) throws JsonProcessingException {
        var listReq = ListObjectsV2Request.builder()
                .bucket(bucketName)
                .prefix(dto.assignment())
                .build();

        var listRes = s3Client.listObjectsV2Paginator(listReq);
        var objectMapper = new ObjectMapper();
        List<CodeFragment> fragments = new LinkedList<>();
        listRes.contents().stream()
                .forEach(content -> {
                    var getObjectRequest = GetObjectRequest.builder()
                            .bucket(bucketName)
                            .key(content.key())
                            .build();
                    var resp = s3Client.getObject(getObjectRequest);
                    try {
                        var tfragments = objectMapper.readValue(resp, new TypeReference<List<CodeFragment>>(){});
                        fragments.addAll(tfragments);
                    } catch (IOException e) {
                        log.error(e.getMessage());
                    }
                });

        var algorithm = DetectionAlgorithm.of(dto.algorithm());
        var clusters = algorithm.findClusters(fragments, true);

        String report = objectMapper.writeValueAsString(new ClusterizationReport(dto.algorithm(), clusters));

        var objectRequest = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(dto.resultKey())
                .build();

        s3Client.putObject(objectRequest, RequestBody.fromString(report, StandardCharsets.UTF_8));
        frontierClient.setSubmissionStatus(dto.resultPath(), SubmissionStatusDto.COMPLETED);
    }
}
