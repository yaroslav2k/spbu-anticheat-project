package ru.spbu.detector.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class NicadConfig {
    @Value("${detector.nicad.executable-path}")
    public String executablePath;
}
