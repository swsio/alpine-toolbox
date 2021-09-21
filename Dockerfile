FROM quay.io/swsmirror/alpine:3.14
LABEL maintainer="Florian Froehlich (florian.froehlich@sws.de)"

### Set Environment Variables
ENV MSSQL_VERSION=17.5.2.1-1 \
    TIMEZONE=Europe/Berlin

### Add core utils
RUN apk update && \
        apk upgrade && \
        apk add \
            iputils \
            bash \
            pcre \
            libssl1.1 && \
     apk add -t .base-rundeps \
            bash \
            busybox-extras \
            curl \
            grep \
            less \
            logrotate \
            nano \
            sudo \
            htop \
            tzdata \
            vim \
            tar \
            && \
    rm -rf /var/cache/apk/* && \
    rm -rf /etc/logrotate.d/acpid && \
    rm -rf /root/.cache /root/.subversion && \
    \
    ## Quiet down sudo
    echo "Set disable_coredump false" > /etc/sudo.conf && \
    \
### Clean up
    rm -rf /usr/src/*&& \
    \
    ### Dependencies
    set -ex && \
    apk update && \
    apk upgrade && \
    apk add -t .db-backup-build-deps \
               build-base \
               bzip2-dev \
               git \
               libarchive-dev \
               xz-dev \
               && \
    \
    apk add --no-cache -t .db-backup-run-deps \
      	       bzip2 \
               libarchive \
               libressl \
               pigz \
               xz \
               zstd \
               && \
    rm -rf /var/cache/apk/* && \
    rm -rf /etc/logrotate.d/acpid && \
    rm -rf /root/.cache /root/.subversion && \
    cd /usr/src && \
    \
    mkdir -p /usr/src/pbzip2 && \
    curl -sSL https://launchpad.net/pbzip2/1.1/1.1.13/+download/pbzip2-1.1.13.tar.gz | tar xvfz - --strip=1 -C /usr/src/pbzip2 && \
    cd /usr/src/pbzip2 && \
    make && \
    make install && \
    mkdir -p /usr/src/pixz && \
    curl -sSL https://github.com/vasi/pixz/releases/download/v1.0.7/pixz-1.0.7.tar.xz | tar xvfJ - --strip 1 -C /usr/src/pixz && \
    cd /usr/src/pixz && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        && \
     make && \
     make install && \
     \
### Cleanup
    apk del .db-backup-build-deps && \
    rm -rf /usr/src/* && \
    rm -rf /tmp/* /var/cache/apk/* && \
# Add coreutils
    apk add --no-cache --update coreutils && rm -rf /var/cache/apk/* && \
    \
### Add timezone
    cp -R /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone

### Add s3cmd
RUN apk add --no-cache python2 && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache && \
    pip install python-dateutil python-magic && \
    S3CMD_CURRENT_VERSION=`curl -fs https://api.github.com/repos/s3tools/s3cmd/releases/latest | grep tag_name | sed -E 's/.*"v?([0-9\.]+).*/\1/g'` \
    && mkdir -p /opt \
    && wget https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_CURRENT_VERSION}/s3cmd-${S3CMD_CURRENT_VERSION}.zip \
    && unzip s3cmd-${S3CMD_CURRENT_VERSION}.zip -d /opt/ \
    && ln -s $(find /opt/ -name s3cmd) /usr/bin/s3cmd \
    && ls /usr/bin/s3cmd \
    && \
    rm -rf /var/cache/apk/* && \
    rm -rf /etc/logrotate.d/acpid && \
    rm -rf /root/.cache /root/.subversion


##Specify the user with UID
USER 1001

ENTRYPOINT ["bash"]

STOPSIGNAL SIGQUIT

CMD ["bash"]
