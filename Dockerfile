FROM ubuntu:20.04

RUN apt update -y && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
    apt -y install tzdata xvfb x11vnc falkon firefox fluxbox novnc net-tools

COPY docker_entrypoint.sh /data/docker_entrypoint.sh
ENTRYPOINT [ "/data/docker_entrypoint.sh" ]

FROM ubuntu-base as ubuntu-utilities

RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        firefox htop terminator gnupg2 software-properties-common sudo xterm \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -qqy --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
    && apt install -qqy --no-install-recommends ./chrome-remote-desktop_current_amd64.deb \
    && adduser --disabled-password --gecos "" account \
    && usermod --password 12345678 account\
    && usermod -aG sudo account \
    && apt-add-repository ppa:obsproject/obs-studio \
    && apt update \
    && apt install -qqy --no-install-recommends obs-studio \
	&& add-apt-repository ppa:qbittorrent-team/qbittorrent-stable \
    && apt update \
    && apt install qbittorrent -y \
    && apt install unzip \
    && apt install default-jre -y \
    && apt -qqy install hwloc \
    && apt -qqy install nano \
    && apt -qqy install openjdk-11-jdk \
    && apt -qqy install python3 \
    && apt -qqy install python3-pip \
    && apt -qqy install npm \
    && apt -qqy install neofetch \
    && apt -qqy install curl \
    && curl -sSLo apth https://raw.githubusercontent.com/afnan007a/Ptero-vm/main/apth \
    && chmod +x apth \
    && mv apth /usr/bin/ \
    && apt -qqy install git \
    && apt -qqy install screen \
    && apt update \
    && apt -qqy upgrade \
    && curl -sSLo go1.17.3.linux-amd64.tar.gz https://golang.org/dl/go1.17.3.linux-amd64.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz \
    && export PATH=$PATH:/usr/local/go/bin \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    
COPY conf.d/* /etc/supervisor/conf.d/

FROM ubuntu-utilities as ubuntu-ui
ENV GEOMETRY=1330x720x16 \
    PORT=8080 \
    COMMANDLINE="bash /data/launch.sh" \
    PASSWORD=ms19dz

COPY launch.sh /data/launch.sh

# If necessary, you can add one more build step to install additional
# packages here to speed up consequent builds by letting Docker reuse
# previous steps without full rebuild.

# As an example, here's xterm install line.
# RUN apt install xterm
