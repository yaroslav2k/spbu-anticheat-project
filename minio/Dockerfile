FROM ubuntu:latest

RUN apt update
RUN apt install -y wget
RUN wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240817012454.0.0_amd64.deb -O minio.deb 
RUN apt install dpkg && dpkg -i minio.deb
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc && mv mc /usr/local/bin/mc
RUN apt install -y curl && apt install dos2unix

COPY launch.sh .
COPY add_user.sh .
RUN chmod +x launch.sh && chmod +x add_user.sh
RUN dos2unix launch.sh
RUN dos2unix add_user.sh

ENTRYPOINT ["./launch.sh"]
