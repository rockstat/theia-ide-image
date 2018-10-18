#!/bin/sh

export JSON_LOGS=0
export NODE_ENV=production
source py3env/bin/activate

git config --global user.email ${EMAIL:-"name@example.com"}
git config --global user.name ${FULLNAME:-"Name Surname"}
cp -nR /home/theia/.theia "$WORKSPACE_PATH"
cd ./theia/examples/package \
    && yarn run start /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA

