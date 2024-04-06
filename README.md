# Abstract

The project is intended to build reliable and extendable platform for automatic code clone detection. While the primary
use-cases is considered to be student homework cheating detection, it can be used to automate clone detection of any programs.

## Installation

### Prerequisites

The instructions below were on tested on Ubuntu 22.04 with the following packages installed:

- Docker Engine (Community) 26.0.0 with compose plugin (2.25.0)

Make sure you have docker installed, other versions are highly likely to work too.

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

4. Now you should configure credentials for each service.

Start with creating VCS-ignored dotenv files:

```shell
cp .{postgresql,s3,}.env.sample .{postgresql,s3,}.env
```

(optional) change Minio root credentials in `.s3.env`
(optional)

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
