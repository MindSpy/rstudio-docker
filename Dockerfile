FROM ubuntu:focal as base

LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
      org.opencontainers.image.vendor="Rocker Project" \
      org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

ENV R_VERSION=4.1.2 \
    TERM=xterm \
    R_HOME=/usr/local/lib/R \
    CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest \
    CTAN_REPO=https://mirror.ctan.org/systems/texlive/tlnet \
    TZ=Etc/UTC 

COPY scripts/install_R.sh /rocker_scripts/install_R.sh

ARG PKG_PROXY

RUN if [ -n "$PKG_PROXY" ]  \
  ; then echo "Acquire::http::Proxy \"$PKG_PROXY\";" >> /etc/apt/apt.conf.d/01proxybuild \
  ; fi \
  ; /rocker_scripts/install_R.sh \
  ; rm /etc/apt/apt.conf.d/01proxybuild

COPY scripts /rocker_scripts

RUN /rocker_scripts/patch_install_command.sh

FROM base as rstudio

ENV LANG=en_US.UTF-8 \
    S6_VERSION=v2.1.0.2 \
    RSTUDIO_VERSION=2021.09.1+372 \
    SHINY_SERVER_VERSION=latest \
    QUARTO_VERSION=latest \
    PANDOC_VERSION=default \
    PATH=/usr/lib/rstudio-server/bin:$PATH:/usr/local/texlive/bin/x86_64-linux \
    DEFAULT_USER=rstudio

RUN if [ -n "$PKG_PROXY" ]  \
  ; then echo "Acquire::http::Proxy \"$PKG_PROXY\";" >> /etc/apt/apt.conf.d/01proxybuild \
  ; fi \
  ; /rocker_scripts/install_rstudio.sh \
  ; /rocker_scripts/install_shiny_server.sh \
  ; /rocker_scripts/install_pandoc.sh \
  ; /rocker_scripts/install_tidyverse.sh \
  ; rm /etc/apt/apt.conf.d/01proxybuild

EXPOSE 8787, 3838

CMD ["/init"]

FROM rstudio as tex

RUN if [ -n "$PKG_PROXY" ]  \
  ; then echo "Acquire::http::Proxy \"$PKG_PROXY\";" >> /etc/apt/apt.conf.d/01proxybuild \
  ; fi \
  ; /rocker_scripts/install_verse.sh \
  ; /rocker_scripts/install_quarto.sh \
  ; rm /etc/apt/apt.conf.d/01proxybuild


