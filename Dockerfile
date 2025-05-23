FROM debian:stable-20250520-slim AS downloader

ARG SENTIEON_VERSION
RUN test -n "$SENTIEON_VERSION"

LABEL container.base.image="debian:stable-20250520-slim" \
      software.version="${SENTIEON_VERSION}" \
      software.website="https://www.sentieon.com/"

# Download the software from the permalink
RUN apt-get update && apt-get install -y curl && \
    mkdir -p /opt/sentieon/ && \
    curl -L "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-${SENTIEON_VERSION}.tar.gz" | \
      tar -zxf - -C /opt/sentieon/

# Build gnuplot
RUN apt-get update && apt-get install -y curl make gcc gzip libgd-dev libcairo2-dev libpango1.0-dev && \
  curl -L "https://downloads.sourceforge.net/project/gnuplot/gnuplot/6.0.2/gnuplot-6.0.2.tar.gz" | \
  tar -zxf - && \
  cd gnuplot-6.0.2 && \
  ./configure && \
  make install

# Build the container
FROM debian:stable-20250520-slim
ARG SENTIEON_VERSION
ENV SENTIEON_VERSION=$SENTIEON_VERSION

COPY --from=downloader /opt/sentieon/sentieon-genomics-${SENTIEON_VERSION} /opt/sentieon/sentieon-genomics-${SENTIEON_VERSION}
COPY --from=downloader /usr/local/bin/gnuplot /usr/local/bin/gnuplot
COPY --from=downloader /usr/local/libexec/gnuplot/6.0/gnuplot_x11 /usr/local/libexec/gnuplot/6.0/gnuplot_x11
COPY --from=downloader /usr/local/share/gnuplot/6.0 /usr/local/share/gnuplot/6.0
CMD ["/bin/bash"]

# Install jemalloc as the recommended memory allocation tool, see https://support.sentieon.com/appnotes/jemalloc/
# Install procps for process monitoring
RUN apt-get update && apt-get install -y \
    libjemalloc2 \
    procps \
    libgd-dev \
    libcairo2-dev \
    libpango1.0-dev \
    locales \
  && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && echo "LANG=en_US.UTF-8" | tee /etc/default/locale \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV LC_ALL=en_US.UTF-8
ENV SENTIEON_INSTALL_DIR=/opt/sentieon/sentieon-genomics-$SENTIEON_VERSION
ENV PATH $SENTIEON_INSTALL_DIR/bin/:$PATH
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# A default jemalloc configuration that should work well for most use-cases, see http://jemalloc.net/jemalloc.3.html
ENV MALLOC_CONF=metadata_thp:auto,background_thread:true,dirty_decay_ms:30000,muzzy_decay_ms:30000
