#!/bin/sh
user=frsyuki
echo "cd /home/groups/m/ms/msgpack/htdocs
put index.html
put index/speedtest.png index/speedtest.png
exit" | sftp -b - $user,msgpack@web.sourceforge.net

