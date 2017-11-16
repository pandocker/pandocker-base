# pandocker-base
Yet another Ubuntu 16.04 based Docker image for markdown-html/tex/pdf conversion; base image

```sh
docker run --rm -it -v /$PWD:/workspace k4zuki/pandocker-base
```

- example `Dockerfile`
```
FROM k4zuki pandocker-base

RUN cd /workspace && \
    git clone --recursive --depth=1 -b pandocker-0.0.1 https://github.com/K4zuki/pandoc_misc.git && \
    mkdir -p /workspace/pandocker && \
    cd /workspace/pandocker

WORKDIR /workspace/pandocker

VOLUME ["/workspace/pandocker"]

CMD ["bash"]
```
