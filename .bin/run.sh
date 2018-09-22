#!/bin/bash
cp -nR /home/theia/.bootstrap/.theia "$WORKSPACE_PATH"
chown -R $RST_UID:$RST_GID "$WORKSPACE_PATH/.theia" "$WORKSPACE_PATH/my_images"
su-exec theia:theia yarn theia start /home/theia/project --hostname=0.0.0.0 --port=$PORT_THEIA
