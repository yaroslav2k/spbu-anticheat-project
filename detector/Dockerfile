FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y --no-install-recommends git build-essential openjdk-17-jdk \
  && rm -rf /var/lib/apt/lists/* && echo $JAVA_HOME

ADD https://github.com/CordyJ/Open-TuringPlus/releases/download/v6.2.1/opentplus-62-linux64.tar.gz /tmp
ADD https://github.com/CordyJ/OpenTxl/releases/download/v11.3.1/opentxl-11.3.1-linux64.tar.gz /tmp

WORKDIR /tmp

RUN tar xvf /tmp/opentplus-62-linux64.tar.gz && cd /tmp/opentplus-62-linux64 && ./InstallTplus.sh
RUN tar xvf /tmp/opentxl-11.3.1-linux64.tar.gz && cd /tmp/opentxl-11.3.1-linux64 && ./InstallTxl.sh
RUN git clone https://github.com/CordyJ/Open-NiCad.git && cd Open-NiCad && make && src/installer/InstallNicad.sh
RUN rm -rf /tmp/opentplus-62-linux64 && rm -rf /tmp/opentxl-11.3.1-linux64

COPY NIL/build.gradle.kts build.gradle.kts 
RUN git clone https://github.com/kusumotolab/NIL && rm NIL/build.gradle.kts && cp build.gradle.kts NIL/build.gradle.kts && cd NIL && \
  ./gradlew ShadowJar && mkdir /lib/nil && cp build/libs/NIL-all.jar /lib/nil/NIL-all.jar

WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
COPY NIL/nil /bin/nil


RUN    --mount=type=cache,target=/root/.m2 apt-get update && apt-get install dos2unix && dos2unix mvnw && ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

ENTRYPOINT ["java", "-jar", "/workspace/app/target/detector-0.0.1-SNAPSHOT.jar"]

