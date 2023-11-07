FROM debian:12
MAINTAINER "Nikita Voronchev <n.voronchev@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        dumb-init \
        gosu \
        fonts-lato \
        texlive-base \
        texlive-latex-base \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-fonts-extra \
        texlive-science \
    && rm -rf /var/cache/apt/archives/*

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        texlive-plain-generic \
    && rm -rf /var/cache/apt/archives/*

RUN --mount=type=bind,target=/tmp/host-context \
    sim_texmf_dir="$(kpsewhich -var-value TEXMFLOCAL)/tex/latex/simple-invoice" ; \
    mkdir -p "${sim_texmf_dir}" && \
    cp -t "${sim_texmf_dir}" /tmp/host-context/src/simple-invoice.cls && \
    mktexlsr --verbose && \
    kpsewhich simple-invoice.cls || { echo "ERROR: LaTeX class file hasn't been installed properly"; exit 1; }

COPY make/invoice /

ARG INVOICE_MOUNT
ENV INVOICE_MOUNT=${INVOICE_MOUNT}

COPY make/docker/entrypoint.sh /
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
