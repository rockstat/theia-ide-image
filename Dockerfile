FROM node:8-alpine as prebuild

ARG GITHUB_TOKEN

ENV RST_UID=472 \ 
    RST_GID=472 \
    WORKSPACE_PATH=/home/theia/project \
    BUILD_PATH=/home/theia/.build \
    THEIA=/home/theia/.build/theia \
    PYENV=.py3env

RUN apk add --no-cache ca-certificates \
    make gcc g++ coreutils \
    python python3 python3-dev \
    gzip curl \
    git openssh-client \
    su-exec sudo \
    zsh

WORKDIR /home/theia

RUN echo "theia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default \
    && chmod 0440 /etc/sudoers.d/default \
    && addgroup -g ${RST_GID} theia \
    && adduser -u ${RST_UID} -G theia -s /bin/sh -D theia \
    && chmod g+rw /home/theia \
    && mkdir -p ${HOME}/.build ${HOME}/project  \
    && chown -R theia:theia /home/theia

USER theia

ENV PORT_THEIA=${PORT_THEIA:-8000} \
    PORT=${PORT_DEV:-8080} \
    SHELL=/bin/zsh \
    USE_LOCAL_GIT=true \
    VIRTUAL_ENV_DISABLE_PROMPT=yes

COPY --chown=theia:theia requirements.txt init_zprezto ${BUILD_PATH}/

RUN git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto \ 
    && ${BUILD_PATH}/init_zprezto 

ARG PY_REQUIREMENTS
RUN echo "${PY_REQUIREMENTS:-none}" \
    && python3 -m venv $PYENV  \
    && source $PYENV/bin/activate \
    && pip install -U pip \
    && pip install -U -r ${BUILD_PATH}/requirements.txt

COPY --chown=theia:theia package .build/package
RUN cd ${BUILD_PATH} \
    && git clone https://github.com/madiedinro/theia.git theia \
    && cd theia \
    && rm -rf examples/* \
    && mv ${BUILD_PATH}/package ./examples \
    && yarn

RUN cd ${BUILD_PATH}/theia/examples/package \
    && yarn run clean \
    && yarn theia build

# RUN mv latest.package.json package.json \
#     && yarn --cache-folder ./ycache \
#     && yarn theia build \
#     && rm -rf ./node_modules \
#     && NODE_ENV=production yarn --production=true \
#     && rm -rf ./node_modules/electron \
#     && rm -rf ./ycache \
#     && yarn cache clean

# RUN chown -R theia:theia /home/theia \
#     && su-exec theia:theia zsh .bin/init_zprezto.sh

COPY --chown=theia:theia init_app .build/
COPY --chown=theia:theia .theia .build/.theia

EXPOSE 8080 8000

CMD ${BUILD_PATH}/init_app
