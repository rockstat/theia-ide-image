FROM node:8-alpine as prebuild
RUN apk add --no-cache ca-certificates \
        make gcc g++ coreutils \
        python py2-pip python3 python3-dev \
        nano gzip curl \
        bash zsh git openssh-client \
        su-exec sudo 

# Theia user
WORKDIR /home/theia
RUN echo "theia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default \
    && chmod 0440 /etc/sudoers.d/default \
    && addgroup -g 473 theia \
    && adduser -u 473 -G theia -s /bin/bash -D theia \
    && chmod g+rw /home \
    && chown theia:theia /home/theia
# setup zsh
COPY setupzsh .    
COPY latest.package.json ./package.json
RUN su-exec theia:theia zsh setupzsh
# building theia
RUN yarn && yarn theia build && rm -rf ./node_modules/electron && yarn cache clean;
# cant set befire
ENV NODE_ENV production
# cache buster
ARG RELEASE=master
# FROM prebuild
# ENV SHELL /bin/bash
ENV SHELL /bin/zsh
ENV USE_LOCAL_GIT true

RUN echo "VERSION $RELEASE" && pip3 install 'python-language-server[pycodestyle]' \
    && pip3 install 'git+https://github.com/rockstat/band#egg=band' \
    && pip3 install -r requirements.txt

RUN chown -R theia:theia /home/theia  \
    && git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name"

EXPOSE 3000
CMD ["su-exec", "theia:theia", "yarn", "theia", "start", "/home/theia/project", "--hostname=0.0.0.0", "--port=8000" ]
