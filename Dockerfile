# Python base image for python scripts
FROM python:3.8.6-slim-buster as downloader
ARG VERSION=202112

LABEL container.base.image="python:3.8.6-slim-buster" \
      software.version="${VERSION}" \
      software.website="https://www.sentieon.com/"

# Download the software from the permalink
RUN apt-get update && apt-get install -y wget && \
    mkdir -p /opt/sentieon/ && \
    wget -nv -O - "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-${VERSION}.tar.gz" | \
      tar -zxf - -C /opt/sentieon/

# Build the container
FROM python:3.8.6-slim-buster
ARG VERSION=202010.02

COPY --from=downloader /opt/sentieon/sentieon-genomics-${VERSION} /opt/sentieon/sentieon-genomics-${VERSION}
CMD ["/bin/bash"]

ENV PATH /opt/sentieon/sentieon-genomics-${VERSION}/bin/:$PATH

