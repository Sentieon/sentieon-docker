# Python base image for tnhapfilter and other python scripts
FROM python:2.7.16-slim-stretch as downloader
ARG VERSION=201808.07

LABEL container.base.image="python:2.7.16-slim-stretch" \
      software.version="${VERSION}" \
      software.website="https://www.sentieon.com/"

# Download the software from the permalink
RUN apt-get update && apt-get install -y wget && \
    mkdir -p /opt/sentieon/ && \
    wget -nv -O - "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-${VERSION}.tar.gz" | \
      tar -zxf - -C /opt/sentieon/

# Build the container
FROM python:2.7.16-slim-stretch
ARG VERSION=201808.07

COPY --from=downloader /opt/sentieon/sentieon-genomics-${VERSION} /opt/sentieon/sentieon-genomics-${VERSION}
CMD ["/bin/bash"]

ENV PATH /opt/sentieon/sentieon-genomics-${VERSION}/bin/:$PATH

