#!/bin/bash
cp -nR $HOME/bootstrap/.theia $HOME/project
chown -R $RST_UID:$RST_GID "$WORKSPACE_PATH/.theia" "$USER_IMAGES_PATH"
su-exec theia:theia yarn theia start /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA

