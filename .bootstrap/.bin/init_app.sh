#!/bin/sh

export JSON_LOGS=0
export NODE_ENV=production

source py3env/bin/activate

git config --global user.email ${EMAIL:-"name@example.com"}
git config --global user.name ${FULLNAME:-"Name Surname"}
cp -nR /home/theia/.bootstrap/.theia "$WORKSPACE_PATH"
chown -R $RST_UID:$RST_GID "$WORKSPACE_PATH/.theia" "$WORKSPACE_PATH/my_images"
cd ./theia/examples/package
# su-exec theia:theia node ./theia/examples/package/src-gen/backend/main.js /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA
yarn run start /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA
