#!/bin/bash
git config --global user.email ${EMAIL:-"name@example.com"} \
git config --global user.name ${FULLNAME:-"Name Surname"} \
cp -nR /home/theia/.bootstrap/.theia "$WORKSPACE_PATH"
chown -R $RST_UID:$RST_GID "$WORKSPACE_PATH/.theia" "$WORKSPACE_PATH/my_images"
# su-exec theia:theia yarn theia start /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA
su-exec theia:theia node ./src-gen/backend/main.js /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA
