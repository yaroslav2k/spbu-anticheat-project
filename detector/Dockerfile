FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y --no-install-recommends git build-essential openjdk-17-jdk \
  && rm -rf /var/lib/apt/lists/*

ADD https://github.com/CordyJ/Open-TuringPlus/releases/download/v6.2.1/opentplus-62-linux64.tar.gz /tmp
ADD https://github.com/CordyJ/OpenTxl/releases/download/v11.3.1/opentxl-11.3.1-linux64.tar.gz /tmp

WORKDIR /tmp

RUN tar xvf /tmp/opentplus-62-linux64.tar.gz && cd /tmp/opentplus-62-linux64 && ./InstallTplus.sh && chmod +x /usr/local/bin/tpc
RUN tar xvf /tmp/opentxl-11.3.1-linux64.tar.gz && cd /tmp/opentxl-11.3.1-linux64 && ./InstallTxl.sh && chmod +x /usr/local/bin/txl
RUN git clone https://github.com/CordyJ/Open-NiCad.git && cd Open-NiCad && make && src/installer/InstallNicad.sh
RUN rm -rf /tmp/opentplus-62-linux64 && rm -rf /tmp/opentxl-11.3.1-linux64

WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2 ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

ENTRYPOINT ["java", "-jar", "/workspace/app/target/detector-0.0.1-SNAPSHOT.jar"]
