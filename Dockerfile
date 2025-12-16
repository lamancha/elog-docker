FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

# build
RUN apt update \
    && apt install -y \
        imagemagick \
        ckeditor \
        build-essential \
        cmake \
        curl \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN curl -LO https://elog.psi.ch/elog/download/tar/elog-3.1.5-1.tar.gz \
    && tar xvzf elog-3.1.5-1.tar.gz 

WORKDIR /tmp/elog-3.1.5-1
RUN make

#final image
FROM ubuntu:24.04

RUN apt update \
    && apt install -y \
        imagemagick \
        ckeditor \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app \
    && mkdir -p /data \
    && mkdir -p /config

COPY --from=builder /tmp/elog-3.1.5-1/* /app/

# elog config
COPY --from=builder /tmp/elog-3.1.5-1/elogd.cfg.example /config/elogd.cfg
RUN useradd -U -G www-data -r elog \
    && chown -R elog:elog /app \
    && chown -R elog:elog /data \
    && chown -R elog:elog /config

EXPOSE 8080

##USER 751
#CMD ["elogd", "-p", "8080", "-c", "/etc/elog/elog.conf"]
