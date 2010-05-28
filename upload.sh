#!/bin/sh
user=frsyuki
files="index index.html"
rsync -e ssh -vr $files $user,msgpack@web.sourceforge.net:/home/groups/m/ms/msgpack/htdocs/
