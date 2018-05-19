#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 1.2v
# Date: 2018-05-19
#
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, grep, curl
# - cut, cat, mktemp, html2bbcode 
#
#----------------[main]----------------#
#---path of transmission-show---#
trans_show="transmission-show"

#---include "/" end---#
flexget_path="/home/rachpt/downloads/tmp/"

#moveTotPath="/home/rc/Downloads/finish/"
logoPath="/home/rachpt/shell/auto/log"

#----------------[post]----------------#
#---path of html2bbcode---#
h2b='html2bbcode'

default_name="Default Title"

default_subname="Default Subtitle"

postUrl='https://hudbt.hust.edu.cn/takeupload.php'

descrCom="[quote]
[b]这是一个自动发布的种子[/b]
[ul]
[li]所有信息以所发种子信息(文件名)为准，所有标题、简介信息均仅供参考，若发现有误请以[举报]或[留言]的形式通知工作人员审查和编辑。
[*]保种12-20天，断种恕不补种。
[*] Shell 脚本实现，具体见：[url=https://github.com/rachpt/AutoSeed]GitHub AutoSeed[/url]
[/li][/ul]
[/quote]"

default_imdb_url='tt1234567'

#---default type---#
default_select_type='415'

default_standard='3'
#---anonymous upload---#
anonymous='yes'

#---cookie of forwarding site---#
cookie="Cookie:c_secure_uid=xxxxxx; c_secure_pass=xxxxxxx; c_secure_login=xxxxxx"

#----------------[add]----------------#
#---path of transmissionreemote---#
trans_remote='transmission-remote'
#---ratio of uploaded torrent---#
ratio='10'
#---authoriz for transmission---#
HOST='127.0.0.1'
PORT='9090'
USER='rach'
PASSWORD='0511416752'
#---you passkey, for add torrent---#
passkey='123456789012345678902134567'

#----------------[clean]----------------#
# Watch folder for clean.
# If not set, will clean just finished folder.
default_FILE_PATH='/srv/ftp/mp4'

# Do not delete for some time after the modification,
# unit seconds, default 2 days(172800 s).
TimeINTERVAL=172800

# The minimum allowed disk (G)
DISK_AVAIL_MIN=50

#----------------[EOF]----------------#
