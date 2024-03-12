package ru.spbu.detector;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class DetectorApplication {

    public static void main(String[] args) {
        SpringApplication.run(DetectorApplication.class, args);
    }
}
