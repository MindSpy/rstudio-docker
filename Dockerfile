FROM ubuntu:focal as base

LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
      org.opencontainers.image.vendor="Rocker Project" \
      org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

ENV TERM=xterm \
    R_HOME=/usr/local/lib/R \
    CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest \
    CTAN_REPO=https://mirror.ctan.org/systems/texlive/tlnet \
    TZ=Etc/UTC 

ARG R_VERSION

COPY scripts/install_R.sh /rocker_scripts/install_R.sh
COPY certs/* /usr/share/ca-certificates/extra/

ARG PKG_PROXY

RUN set -ex \
  ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
  ; test -n "$PKG_PROXY" && echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
  ; apt-get update -y \
  ; apt-get install -y openssl ca-certificates vim \
  ; c_rehash -v \
  ; mv /usr/share/ca-certificates/extra/openssl.cnf /etc/ssl/ || true \
  ; /rocker_scripts/install_R.sh \
  ; rm $apt_conf || true

COPY scripts /rocker_scripts

RUN set -ex; /rocker_scripts/patch_install_command.sh

FROM base as tidyverse

ARG PKG_PROXY

RUN set -ex \
  ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
  ; test -n "$PKG_PROXY" && echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
  ; /rocker_scripts/install_tidyverse.sh \
  ; rm $apt_conf || true


FROM tidyverse as rstudio

ENV LANG=en_US.UTF-8 \
    S6_VERSION=v2.1.0.2 \
    PANDOC_VERSION=default \
    PATH=/usr/lib/rstudio-server/bin:$PATH \
    DEFAULT_USER=rstudio

ARG RSTUDIO_VERSION

ARG PKG_PROXY

RUN set - ex \
  ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
  ; test -n "$PKG_PROXY" && echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
  ; /rocker_scripts/install_rstudio.sh \
  ; /rocker_scripts/install_pandoc.sh \
  ; rm $apt_conf || true

EXPOSE 8787/tcp

CMD ["/init"]

from tidyverse as shiny

ENV LANG=en_US.UTF-8 \
    S6_VERSION=v2.1.0.2 \
    PATH=/usr/lib/rstudio-server/bin:$PATH \
    DEFAULT_USER=rstudio

ARG SHINY_SERVER_VERSION

ARG PKG_PROXY

RUN set - ex \
  ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
  ; test -n "$PKG_PROXY" && echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
  ; /rocker_scripts/install_shiny_server.sh \
  ; rm $apt_conf || true

EXPOSE 3838/tcp

CMD ["/init"]

FROM rstudio as tex

ENV QUARTO_VERSION=latest \
    PATH=$PATH:/usr/local/texlive/bin/x86_64-linux 

ARG PKG_PROXY

RUN set -ex \
  ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
  ; test -n "$PKG_PROXY" && echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
  ; /rocker_scripts/install_verse.sh \
  ; /rocker_scripts/install_quarto.sh \
  ; rm $apt_conf || true


