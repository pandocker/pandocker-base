ARG ubuntu_version="22.04"
ARG pandoc_version="2.19"
ARG nexe_version="4.0.0-beta.19"

FROM ubuntu:${ubuntu_version} AS tool-getter

RUN apt-get -y update && \
    apt-get -y install wget curl unzip make
ENV PLANTUML_VERSION 1.2022.6
ENV PLANTUML_DOWNLOAD_URL https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar
RUN curl -fsSL "${PLANTUML_DOWNLOAD_URL}" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

RUN wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip && \
    unzip -e v0.4.zip && ls

RUN wget -c https://github.com/adobe-fonts/source-han-sans/releases/download/2.004R/SourceHanSansHWJ.zip && \
      mkdir SourceHanSansJ && \
      unzip SourceHanSansHWJ.zip -d SourceHanSansJ

FROM lansible/nexe:${nexe_version} as wavedrom
WORKDIR /root
RUN apk add --update --no-cache \
    make \
    g++ \
    jpeg-dev \
    cairo-dev \
    giflib-dev \
    pango-dev \
    python3

RUN npm i canvas --build-from-source && \
    npm i wavedrom-cli && \
    nexe --build -i ./node_modules/wavedrom-cli/wavedrom-cli.js -o wavedrom-cli

FROM pandoc/latex:${pandoc_version}-ubuntu

#COPY src/sourcecodepro/*.ttf /usr/share/fonts/
#COPY src/sourcesanspro/*.ttf /usr/share/fonts/

COPY --from=tool-getter /usr/local/bin/ /usr/local/bin/
COPY --from=tool-getter /SourceHanSansJ/ /usr/share/fonts/SourceHanSansJ/
COPY --from=tool-getter /BXptool-0.4/ /opt/texlive/texdir/texmf-dist/tex/latex/BXptool/
COPY --from=wavedrom /root/wavedrom-cli /usr/local/bin/

RUN apt-get -y update && \
    apt-get -y install wget curl unzip nano make lua5.3 luarocks lua-penlight libyaml-dev liblua5.3-dev
RUN apt-get -y --no-install-recommends install librsvg2-bin git && \
    apt-get -y --no-install-recommends install graphviz default-jre-headless && \
    apt-get -y --no-install-recommends install python3-pip \
      python3-setuptools python3-setuptools-scm python3-setuptools-git \
      python3-yaml \
      python3-six \
      python3-cairosvg
RUN apt-get -y install --no-install-recommends xzdec lmodern fonts-ricty-diminished fonts-noto-cjk-extra && \
    apt-get -y clean
RUN luarocks install lyaml
RUN luarocks install lunajson
RUN luarocks install lua-cjson 2.1.0-1
RUN git clone https://github.com/geoffleyland/lua-csv.git && cd lua-csv && luarocks-5.3 make rockspecs/csv-1-1.rockspec

ENV LANG C.UTF-8

RUN pip3 install -U pantable csv2table \
    pandoc-imagine \
    svgutils \
    pandocker-lua-filters \
    docx-coreprop-writer && \
    fc-cache -fv

RUN curl -L -O http://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh && sh update-tlmgr-latest.sh
RUN tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet
RUN tlmgr update --self && fc-cache -fv && tlmgr install \
    ascmac \
    background \
    bxjscls \
    ctex \
    environ \
    everypage \
    fancybox \
    haranoaji \
    haranoaji-extra \
    ifoddpage \
    lastpage \
    mdframed \
    needspace \
    realscripts\
    tcolorbox \
    trimspaces \
    xhfill \
    xltxtra \
    zref \
    zxjafont \
    zxjatype && mktexlsr

RUN mkdir -p /workdir && \
    cd /workdir

WORKDIR /workdir

VOLUME ["/workdir"]

ENTRYPOINT [""]
CMD ["bash"]
