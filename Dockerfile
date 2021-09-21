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
    rm -rf /usr/src/*
    
    ### Dependencies
RUN set -ex && \
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
    rm -rf /root/.cache /root/.subversion
# Add coreutils
RUN apk add --no-cache --update coreutils && rm -rf /var/cache/apk/* && \
    \
### Add timezone
    cp -R /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone



##Specify the user with UID
USER 1001

ENTRYPOINT ["bash"]

STOPSIGNAL SIGQUIT

CMD ["bash"]
