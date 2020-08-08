FROM pandoc/ubuntu-latex:2.10

RUN apt-get -y update && \
    apt-get -y install wget curl unzip nano make gpp lua5.3 luarocks lua-penlight liblua5.3-dev
RUN apt-get -y --no-install-recommends install librsvg2-bin git && \
    apt-get -y --no-install-recommends install graphviz default-jre-headless && \
    apt-get -y --no-install-recommends install python3-pip \
      python3-setuptools python3-setuptools-scm python3-setuptools-git \
      python3-yaml \
      python3-six \
      python3-cairosvg
RUN apt-get -y install --no-install-recommends xzdec lmodern fonts-ricty-diminished && \
    apt-get -y clean
RUN luarocks install lyaml
RUN luarocks install lunajson
RUN luarocks install lua-cjson 2.1.0-1
RUN luarocks install csv

ENV PLANTUML_VERSION 1.2020.15
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download

RUN curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

RUN wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip && \
    unzip -e v0.4.zip && \
    mkdir -p /opt/texlive/texmf-local/tex/latex/BXptool/ && \
    cp -r BXptool-0.4/* /opt/texlive/texmf-local/tex/latex/BXptool/

ENV LANG C.UTF-8

RUN pip3 install -U pantable csv2table \
    pandoc-imagine \
    svgutils \
    wavedrom && \
    mktexlsr && \
    fc-cache -fv

RUN tlmgr update --self && fc-cache -fv && tlmgr install \
    ascmac \
    bxjscls \
    ctex \
    environ \
    haranoaji \
    haranoaji-extra \
    ifoddpage \
    lastpage \
    mdframed \
    needspace \
    tcolorbox \
    trimspaces \
    xhfill \
    zref \
    zxjafont \
    zxjatype && mktexlsr

RUN mkdir -p /workdir && \
    cd /workdir

WORKDIR /workdir

VOLUME ["/workdir"]

ENTRYPOINT [""]
CMD ["bash"]
