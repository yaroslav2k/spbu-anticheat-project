# Abstract

The project is intended to build reliable and extendable platform for automatic code clone detection. While the primary
use-cases is considered to be student homework cheating detection, it can be used to automate clone detection of any programs.

## Instalation

Currently the only way to install the system locally is to clone its source code and build required docker images.

The instruction below is tested via Docker Engine (Community) 26.0.0 and Docker Compose plugin 2.25.0.

1. Clone this git repository:

```shell
git clone https://github.com/viralpraxis/spbu-anticheat-project.git
```

2. Enter the repository and build docker images:

```shell
cd spbu-anticheat-project && docker compose build --pull
```

3. Although the system is built with intention of begin language-agnostic, currently each language you would like to process requires it own engine. To build the python engine, one should execute

```shell
docker build -f mutator -t python-mutator:latest .
```

## Running

You can start the entire system by executing

```
docker-compose up --build -d
```

Note that some additional steps to configure some services are quired.

[TODO]

## API

Currenly there are ways of interacting with the system: web UI and RESTful HTTP API.

### HTTP API

[TODO]

### UI API

[TODO]
