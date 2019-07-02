# Sentieon-Docker

Example Dockerfiles for use with the Sentieon software

## Requirements

Sentieon's Dockerfiles use [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) and therfore require Docker 17.05 or later.

## Example Usage

Build a container image for a specific version of the Sentieon tools:

```bash
git clone https://github.com/Sentieon/sentieon-docker.git
cd sentieon-docker
docker build --build-arg VERSION=201808.07 .
# ...
# Successfully built a1575042a0a6
```

Run the created container interactively:

```
docker run --rm -it a1575042a0a6 /bin/bash
```

## More information

For additional help with Docker, please see the [Docker documentation](https://docs.docker.com). For additional help with the Sentieon tools, please visit the Sentieon [support page](https://www.sentieon.com/support/).

