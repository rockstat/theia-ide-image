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
ADD . .
RUN su-exec theia:theia zsh setupzsh
# building theia
RUN mv latest.package.json package.json && yarn && yarn theia build && rm -rf ./node_modules/electron && yarn cache clean;
# cant set befire
ENV NODE_ENV=production
ENV PORT_THEIA=${PORT_THEIA:-8000}
ENV PORT=${PORT_THEIA:-8000}
# Port for user apps
ENV PORT=8000
ENV JSON_LOGS=0
ENV SHELL /bin/zsh
ENV USE_LOCAL_GIT true

ADD requirements.txt .
RUN pip3 install 'python-language-server[pycodestyle]' \
    && pip3 install 'git+https://github.com/rockstat/band#egg=band' \
    && pip3 install -r requirements.txt
RUN chown -R theia:theia /home/theia  \
    && git config --global user.email ${EMAIL:-"name@example.com"} \
    && git config --global user.name ${USERNAME:-"Name Surname"}}
# readable logs
EXPOSE 8080
CMD /bin/bash -c "su-exec theia:theia ./run.sh"
