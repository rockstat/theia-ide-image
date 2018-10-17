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
    && chown theia:theia /home/theia

ADD --chown=theia:theia .bootstrap latest.package.json requirements.txt ./


ARG GITHUB_TOKEN
ENV PORT_THEIA=${PORT_THEIA:-8000} \
    PORT=${PORT_DEV:-8080} \
    JSON_LOGS=0 \
    SHELL=/bin/zsh \
    USE_LOCAL_GIT=true \
    WORKSPACE_PATH=/home/theia/project

RUN ls -lh && yarn config set registry=//registry.npmjs.org/
RUN mv latest.package.json package.json \
    && yarn --cache-folder ./ycache \
    && yarn theia build \
    && rm -rf ./node_modules \
    && NODE_ENV=production yarn --production=true \
    && rm -rf ./node_modules/electron \
    && rm -rf ./ycache \
    && yarn cache clean

ENV NODE_ENV=production

RUN pip3 install -U -r requirements.txt
RUN chown -R theia:theia /home/theia  \
    && su-exec theia:theia zsh .bootstrap/bin/setupz.sh

EXPOSE 8080 8000

CMD .bootstrap/bin/run.sh
