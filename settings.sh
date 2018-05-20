#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 1.4v
# Date: 2018-05-21
#
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, grep, curl
# - cut, cat, mktemp, html2bbcode 
#
#----------------[main]----------------#
#---path of transmission-show---#
trans_show="transmission-show"

#---path of transmissionreemote---#
trans_remote='transmission-remote'

#---path of html2bbcode---#
h2b='/usr/local/bin/html2bbcode'
#---include "/" end---#
AUTO_ROOT_PATH='/home/rachpt/shell/dev'
#---flexget_path need slash(/) end---#
flexget_path="/home/rachpt/Downloads/tmp/"

#moveTotPath="/home/rc/Downloads/finish/"
logoPath="/home/rachpt/shell/dev/log"

#----------------[post]----------------#

#---[hudbt]---#
enable_hds2hudbt='yes'

default_name_hudbt="Default Title"
default_subname_hudbt="Default Subtitle"
failed_to_get_des_hudbt='[size=5][color=Magenta]获取简介失败[/color][/size]         [em11]'
default_imdb_url_hudbt='tt1234567'
default_select_type_hudbt='415'
default_standard_hudbt='3'
anonymous_hudbt='yes'
#---ratio of uploaded torrent---#
ratio_hudbt='10'

cookie_hudbt='Cookie:c_secure_uid=xxxxxx; c_secure_pass=xxxxxxx; c_secure_login=bm9wZQ=='
#---you passkey---#
passkey_hudbt='123456789969f82b673b01fc8b77'

#---[whu]---#
enable_hds2whu='yes'

default_name_whu="Default Title"
default_subname_whu="Default Subtitle"
failed_to_get_des_whu='[size=5][color=Magenta]获取简介失败[/color][/size]         [em11]'
default_imdb_url_whu='tt1234567'
default_select_type_whu='415'
default_standard_whu='0'
anonymous_whu='yes'
#---ratio of uploaded torrent---#
ratio_whu='10'

cookie_whu='Cookie:c_secure_uid=xxxxxx; c_secure_pass=xxxxxxx; c_secure_login=bm9wZQ==; c_session_id=xxxxxxxx'
#---you passkey---#
passkey_whu='123456789969f82b673b01fc8e3'

#-------#

descrCom="[quote]
[b]这是一个自动发布的种子[/b]
[ul]
[li]所有信息以所发种子信息(文件名)为准，所有标题、简介信息均仅供参考，若发现有误请以[举报]或[留言]的形式通知工作人员审查和编辑。
[*]保种12-20天，断种恕不补种。
[*] Shell 脚本实现，具体见：[url=https://github.com/rachpt/AutoSeed]GitHub AutoSeed[/url]
[/li][/ul]
[/quote]"

#----------------[add]----------------#
#---authoriz for transmission---#
HOST='127.0.0.1'
PORT='9091'
USER='username'
PASSWORD='password'

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
