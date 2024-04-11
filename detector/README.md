# Detector service

Detector service is responsible for running clone detection algorithms.

### Usage

You can either run it as a Spring application or via CLI:

```shell
java -cp target/detector-*.jar -Dloader.main=ru.spbu.detector.detection.CLI org.springframework.boot.loader.PropertiesLauncher --help
```

Make sure you have a JAR in `target` folder (you can generate one via `mvn package`).
