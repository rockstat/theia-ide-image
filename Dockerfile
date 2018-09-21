FROM node:8-alpine as prebuild
RUN apk add --no-cache ca-certificates \
        make gcc g++ coreutils \
        python py2-pip python3 python3-dev \
        nano gzip curl \
        bash zsh git openssh-client \
        su-exec sudo 

ENV RST_UID=765
ENV RST_GID=765


WORKDIR /home/theia
RUN echo "theia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default \
    && chmod 0440 /etc/sudoers.d/default \
    && addgroup -g ${RST_GID} theia \
    && adduser -u ${RST_UID} -G theia -s /bin/bash -D theia \
    && chmod g+rw /home \
    && chown theia:theia /home/theia

ADD --chown=theia:theia . .

RUN yarn config set registry=//registry.npmjs.org/:_authToken=${GITHUB_ACCESS_TOKEN:-""}
RUN mv latest.package.json package.json \
    && yarn \
    && yarn theia build \
    && rm -rf ./node_modules/electron \
    && yarn cache clean;

ENV PORT_THEIA=${PORT_THEIA:-8000} \
    PORT=${PORT_DEV:-8080} \
    JSON_LOGS=0 \
    SHELL=/bin/zsh \
    USE_LOCAL_GIT=true \
    NODE_ENV=production

RUN pip3 install -U -r requirements.txt
RUN chown -R theia:theia /home/theia  \
    && git config --global user.email ${EMAIL:-"name@example.com"} \
    && git config --global user.name ${USERNAME:-"Name Surname"}} \
    && su-exec theia:theia zsh .bin/setupz.sh

EXPOSE 8080 8000

CMD /home/theia/.bin/run.sh
