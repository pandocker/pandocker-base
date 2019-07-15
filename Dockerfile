FROM ubuntu:18.04 AS common-base

RUN apt-get -y update && \
    apt-get -y install wget curl unzip nano make gpp lua5.3
RUN apt-get -y --no-install-recommends install librsvg2-bin git && \
    apt-get -y --no-install-recommends install graphviz default-jre-headless && \
    apt-get -y --no-install-recommends install python3-pip python3-setuptools \
      python3-yaml \
      python3-six \
      python3-cairosvg
RUN apt-get -y install --no-install-recommends texlive-xetex xzdec lmodern fonts-noto-cjk fonts-noto-mono \
    texlive-generic-recommended texlive-lang-japanese texlive-science && \
    apt-get -y clean

FROM common-base AS luarocks-builder
ENV LUAROCKS_VERSION 3.1.3
ENV LUAROCKS_ARCHIVE luarocks-$LUAROCKS_VERSION.tar.gz
ENV LUAROCKS_DOWNLOAD_URL https://luarocks.org/releases/$LUAROCKS_ARCHIVE

RUN apt install -y liblua5.3-dev
RUN wget $LUAROCKS_DOWNLOAD_URL && tar zxf $LUAROCKS_ARCHIVE && \
    cd luarocks-$LUAROCKS_VERSION && \
    ./configure && make && make install
RUN luarocks install lua-yaml
RUN luarocks install lunajson
RUN luarocks install penlight
RUN luarocks install csv
# /usr/local/bin/luarocks
# /usr/local/bin/luarocks-admin
# /usr/local/etc/luarocks/config-5.3.lua
# /usr/local/share/lua/5.3/*

FROM common-base AS wget-curl
ENV PLANTUML_VERSION 1.2018.12
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download

RUN curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/bin/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/bin/plantuml.jar -Djava.awt.headless=true \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml
# /usr/local/bin/plantuml*

ENV PANDOC_REPO https://github.com/jgm/pandoc
ENV PANDOC_VERSION 2.7.3
ENV PANDOC_DEB pandoc-$PANDOC_VERSION-1-amd64.deb
ENV PANDOC_DOWNLOAD_URL $PANDOC_REPO/releases/download/$PANDOC_VERSION/$PANDOC_DEB
ENV PANDOC_ROOT /usr/local/pandoc
RUN wget -c $PANDOC_DOWNLOAD_URL
# /$PANDOC_DEB

ENV CROSSREF_REPO https://github.com/lierdakil/pandoc-crossref
ENV CROSSREF_VERSION v0.3.4.1
ENV CROSSREF_ARCHIVE linux-pandoc_2_7_2.tar.gz
ENV CROSSREF_DOWNLOAD_URL $CROSSREF_REPO/releases/download/$CROSSREF_VERSION/$CROSSREF_ARCHIVE
RUN wget -c $CROSSREF_DOWNLOAD_URL && \
      tar zxf $CROSSREF_ARCHIVE && \
      cp pandoc-crossref /usr/local/bin/
# /usr/local/bin/

RUN wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip && \
    unzip -e v0.4.zip
# /BXptool-0.4/* /usr/share/texlive/texmf-dist/tex/latex/BXptool/

#RUN wget -c https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansJ.zip && \
#      unzip -e SourceHanSansJ.zip
# /SourceHanSansJ/SourceHanSans-*.otf /usr/local/share/fonts/

FROM common-base AS base-builder
ENV PANDOC_VERSION 2.7.3
ENV PANDOC_DEB pandoc-$PANDOC_VERSION-1-amd64.deb

COPY --from=luarocks-builder /usr/local/bin/ /usr/local/bin/
COPY --from=luarocks-builder /usr/local/etc/luarocks/config-5.3.lua /usr/local/etc/luarocks/config-5.3.lua
COPY --from=luarocks-builder /usr/local/share/lua/5.3/ /usr/local/share/lua/5.3/
COPY --from=wget-curl /usr/local/bin/ /usr/local/bin/
COPY --from=wget-curl /BXptool-0.4/ /usr/share/texlive/texmf-dist/tex/latex/BXptool/
#COPY --from=wget-curl /SourceHanSansJ/ /usr/local/share/fonts/
COPY --from=wget-curl /$PANDOC_DEB /tmp/$PANDOC_DEB

ENV LANG C.UTF-8

RUN pip3 install -U setuptools pantable csv2table \
    setuptools_scm \
    pandoc-imagine \
    svgutils \
    wavedrom && \
    apt install /tmp/$PANDOC_DEB && \
    mktexlsr && \
    fc-cache -fv

RUN mkdir -p /workdir && \
    cd /workdir

WORKDIR /workdir

VOLUME ["/workdir"]

CMD ["bash"]
