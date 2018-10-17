FROM node:8-alpine as prebuild
RUN apk add --no-cache ca-certificates \
    make gcc g++ coreutils \
    python python3 python3-dev \
    gzip curl \
    git openssh-client \
    su-exec sudo \
    zsh

ENV RST_UID=472
ENV RST_GID=472

WORKDIR /home/theia

RUN echo "theia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default \
    && chmod 0440 /etc/sudoers.d/default \
    && addgroup -g ${RST_GID} theia \
    && adduser -u ${RST_UID} -G theia -s /bin/sh -D theia \
    && chmod g+rw /home \
    && chown -R theia:theia /home/theia


COPY --chown=theia:theia .bootstrap requirements.txt ./
# COPY --chown=theia:theia theia theia
# COPY --chown=theia:theia .zprezto .zprezto

USER theia

ARG GITHUB_TOKEN
ENV PORT_THEIA=${PORT_THEIA:-8000} \
    PORT=${PORT_DEV:-8080} \
    SHELL=/bin/zsh \
    USE_LOCAL_GIT=true \
    WORKSPACE_PATH=/home/theia/project \
    THEIA=/home/theia/theia \
    VIRTUAL_ENV_DISABLE_PROMPT=yes

RUN python3 -m venv py3env \
    && source py3env/bin/activate \
    && pip install -U -r requirements.txt

RUN git clone https://github.com/madiedinro/theia.git theia \
    && cd theia \
    && rm -rf examples/* \
    && mv ../package ./examples \
    && yarn \
    && cd examples/package \
    && yarn run prepare

RUN cd theia/examples/package \
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

EXPOSE 8080 8000

RUN zsh .bin/init_zprezto.sh
CMD .bin/init_app.sh
