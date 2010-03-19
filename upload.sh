#!/bin/sh
user=frsyuki
echo "cd /home/groups/m/ms/msgpack/htdocs
put index.html
exit" | sftp -b - $user,msgpack@web.sourceforge.net

