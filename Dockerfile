FROM node:10-alpine3.11 as glibcbuild
ENV LANG=C.UTF-8

# XXX
# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.28-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

FROM glibcbuild

ARG GITHUB_TOKEN
ARG PY_REQUIREMENTS
ENV TINI_VERSION v0.16.1
LABEL band.images.theia.version="0.3.0"




ENV RST_UID 472
ENV RST_GID 472
ENV WORKSPACE_PATH /home/theia/project
ENV BUILD_PATH /home/theia/.build
ENV THEIA /home/theia/.build/theia
ENV LANG C.UTF-8

RUN apk add --no-cache \
    ca-certificates \
    make gcc g++ \
    util-linux pciutils usbutils coreutils binutils findutils grep \
    libffi-dev \
    gzip bzip2 curl nano jq \
    git openssh-client \
    su-exec sudo zsh \
    python

ENV CONDA_VERSION 4.7.12.1
ENV CONDA_MD5 81c773ff87af5cfac79ab862942ab6b3

RUN addgroup -g ${RST_GID} anaconda && \
    adduser -D -u 10151 anaconda -G anaconda && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-$CONDA_VERSION-Linux-x86_64.sh && \
    echo "${CONDA_MD5}  Miniconda3-$CONDA_VERSION-Linux-x86_64.sh" > miniconda.md5 && \
    if [ $(md5sum -c miniconda.md5 | awk '{print $2}') != "OK" ] ; then exit 1; fi && \
    mv Miniconda3-$CONDA_VERSION-Linux-x86_64.sh miniconda.sh && \
    mkdir -p /opt && \
    sh ./miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh miniconda.md5 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    chown -R anaconda:anaconda /opt && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/anaconda/.profile && \
    echo "conda activate base" >> /home/anaconda/.profile && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy


# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
#     && /bin/zsh ~/miniconda.sh -b -p /opt/conda \
#     && rm ~/miniconda.sh \
#     && /opt/conda/bin/conda clean -tipsy \
#     && chmod 0755 /opt/conda/etc/profile.d/conda.sh

# ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
# RUN chmod +x /usr/bin/tini

RUN cat /etc/group

RUN echo "theia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default \
    && chmod 0440 /etc/sudoers.d/default \
    && adduser -u $RST_UID -G anaconda -s /bin/sh -D theia \
    && chmod g+rw /home/theia \
    && mkdir -p ${HOME}/.build ${HOME}/project \
    && chown -R theia:anaconda /opt/conda

WORKDIR /home/theia

USER theia

# ##### ZSH

ENV SHELL=/bin/zsh

COPY --chown=theia:anaconda prezto.tgz init_zprezto ${BUILD_PATH}/
RUN cd ${BUILD_PATH} && \
    tar -zxf prezto.tgz && \
    mv prezto $HOME/.zprezto && \
    zsh ./init_zprezto


# ##### Building theia

ENV NODE_ENV=production

ENV USE_LOCAL_GIT true \
    PORT_THEIA ${PORT_THEIA:-8000} \
    PORT ${PORT_DEV:-8080}

COPY --chown=theia:anaconda package/package.json ./.build

RUN cd ${BUILD_PATH} && yarn --cache-folder ./ycache
RUN cd ${BUILD_PATH} && yarn theia build
RUN rm -rf ./ycache


# ##### Backend / conda

ENV VIRTUAL_ENV_DISABLE_PROMPT=yes

RUN /opt/conda/bin/conda upgrade -y pip && \
    /opt/conda/bin/conda config --add channels conda-forge && \
    /opt/conda/bin/conda clean --all

COPY --chown=theia:anaconda requirements.txt .editorconfig ${BUILD_PATH}/

RUN pip install -U git+https://github.com/rockstat/band@master#egg=band \
    && pip install -U -r ${BUILD_PATH}/requirements.txt

COPY --chown=theia:anaconda init_app ./.build/
COPY --chown=theia:anaconda .theia/settings.json .theia/tasks.json .theia/tasks.json-tmpl ./.build/.theia/

EXPOSE 8080 8000

# ENTRYPOINT [ "/usr/bin/tini", "--" ]

# Band framework params
ENV JSON_LOGS=0

CMD ${BUILD_PATH}/init_app
