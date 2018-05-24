#!/bin/bash
# FileName: debug.sh
#
# Author: rachpt@126.com
# Version: 1.2v
# Date: 2018-05-19
#
#------------------------------------#
#---path---#
. ./settings.sh
test1()
{
TR_TORRENT_DIR='/srv/ftp/data'
#---real name of torrent(inclode dot always)---#
TR_TORRENT_NAME='One.on.One.2014.720p.BluRay.DD2.0.x264-HDS'

. ./auto_main.sh
}

test2()
{

. ./settings.sh
new_torrent_name='Friday.the.13th.The.Final.Chapter.1984.BluRay.iPad.720p.AAC.x264-HDSPad'
. ./hds_desc.sh


cat $descr_bbcode
}


test3()
{
new_torrent_name='Narratage.2017.BluRay.iPad.720p.AAC.x264-HDSPad'
. ./hds_desc.sh
}

test3
