# pandocker-base
Yet another Ubuntu 16.04 based Docker image for markdown-html conversion; base image

**latest** branch includes LaTeX environment
**notex** does not include LaTeX environment
```sh
docker run --rm -it -v /$PWD:/workspace k4zuki/pandocker-base:latest
```

- example `Dockerfile`

```
FROM k4zuki/pandocker-base

ENV PANDOC_MISC_VERSION pandocker-0.0.1

WORKDIR /var

RUN git clone --recursive --depth=1 -b pandocker-0.0.1 https://github.com/K4zuki/pandoc_misc.git

WORKDIR /workspace

VOLUME ["/workspace"]

CMD ["bash"]
```
