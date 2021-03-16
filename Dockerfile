FROM alpine:latest

RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    curl \
    ffmpeg \
    vlc

RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust

# Download the powershell '.tar.gz' archive
RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz

# Download xTeVe
RUN wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip -O temp.zip; unzip temp.zip -d /usr/bin/; rm temp.zip

# Create the target folder where powershell will be placed
RUN mkdir -p /opt/microsoft/powershell/7

# Expand powershell to the target folder
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

# Set execute permissions
RUN chmod +x /opt/microsoft/powershell/7/pwsh

# Create the symbolic link that points to pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Volumes
VOLUME /config
VOLUME /guide2go
VOLUME /root/.xteve
VOLUME /tmp/xteve
VOLUME /etc/periodic/daily

# Set executable permissions
RUN chmod +x /entrypoint.sh
RUN chmod +x /cronjob.sh
RUN chmod +x /usr/bin/xteve

# Add powershell script to root
ADD cronjob.ps1 /

# Expose Port
EXPOSE 34400

# Entrypoint
ENTRYPOINT ["/usr/bin/xteve -port=34400 -config=/root/.xteve/"]
