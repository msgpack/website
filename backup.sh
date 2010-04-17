#!/bin/sh
user=frsyuki
mkdir -p backup-current/msgpack
mkdir -p backup
rsync -e ssh -vr $user,msgpack@web.sourceforge.net:/home/groups/m/ms/msgpack/ backup-current/msgpack
if $? -ne 0;then
	exit 1;
fi
pdumpfs backup-current/msgpack backup

