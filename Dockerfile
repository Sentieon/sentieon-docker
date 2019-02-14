# Python base image for plotting
FROM python:2.7.14-slim-jessie as downloader
ARG VERSION=201808.03

LABEL container.base.image="python:2.7.14-jessie" \
      software.version="${VERSION}" \
      software.website="https://www.sentieon.com/"

# Download the software from the permalink
RUN apt-get update && apt-get install -y wget && \
    mkdir -p /opt/sentieon/ && \
    wget -nv -O - "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-${VERSION}.tar.gz" | \
      tar -zxf - -C /opt/sentieon/

# Build the container
FROM python:2.7.14-slim-jessie
ARG VERSION=201808.03

COPY --from=downloader /opt/sentieon/sentieon-genomics-${VERSION} /opt/sentieon/sentieon-genomics-${VERSION}
CMD ["/bin/bash"]

ENV PATH /opt/sentieon/sentieon-genomics-${VERSION}/bin/:$PATH

