#!/bin/bash
cp -nR /home/theia/bootstrap/.theia "$WORKSPACE_PATH"
chown -R $RST_UID:$RST_GID "$WORKSPACE_PATH/.theia" "$USER_IMAGES_PATH"
su-exec theia:theia yarn theia start /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA

