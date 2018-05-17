#!/bin/bash
# FileName: auto_add.sh
#
# Author: rachpt@126.com
# Version: 1.0v
# Date: 2018-05-17

#-------------settings---------------#
#---transmissionreemote---#
trans_remote='transmission-remote'

ratio='10'

HOST='127.0.0.1'
PORT='9090'
USER='admin'
PASSWORD='password'
trorrent2add="$1"

function add_torrent()
{

    $trans_remote ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "$torrent2add" -w "$TR_TORRENT_DIR" -sr "$ratio" -s --trash-torrent


}


#-------------call function---------------#

if [ "$1" ]; then
    add_torrent

    . ./auto_clean.sh
fi
