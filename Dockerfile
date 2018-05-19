FROM node:8-alpine as prebuild
RUN apk add --no-cache ca-certificates \
        make gcc g++ coreutils \
        python py2-pip python3 python3-dev \
        nano gzip curl \
        bash zsh git openssh-client \
        su-exec sudo 
RUN pip install -U pip && pip3 install -U pip \
    && pip3 install 'git+https://github.com/bcb/jsonrpcclient.git@master#egg=jsonrpcclient' \
    && pip3 install 'python-language-server[pycodestyle]' \
    && pip3 install 'git+https://github.com/rockstat/band#egg=band'
ARG version=latest

WORKDIR /home/theia
# or: addgroup theia && \  -G theia
RUN adduser -s /bin/bash -D theia && \
    chmod g+rw /home \
    && chown theia:theia /home/theia \
    && echo "theia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default; \
    chmod 0440 /etc/sudoers.d/default
COPY setupzsh .    
COPY $version.package.json ./package.json
RUN su-exec theia:theia zsh setupzsh
RUN yarn
RUN yarn theia build
RUN    rm -rf ./node_modules/electron && \
    yarn cache clean;

ENV NODE_ENV production
FROM prebuild
ENV SHELL /bin/bash
ENV USE_LOCAL_GIT true
WORKDIR /home/theia
COPY --chown=theia:theia --from=prebuild /home/theia /home/theia
RUN git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name"
EXPOSE 3000
# USER theia
ENV SHELL /bin/zsh
CMD ["su-exec", "theia:theia", "yarn", "theia", "start", "/home/theia/project", "--hostname=0.0.0.0", "--port=8000" ]
