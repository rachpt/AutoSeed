#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 1.6v
# Date: 2018-06-04
#
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, grep, curl
# - cut, cat, mktemp, html2bbcode 
#
#----------------[main]----------------#
# Set it also in auto_man.sh and edit.sh
AUTO_ROOT_PATH='/home/rachpt/shell/auto'
#---Use yes to disable all---#
disable_AutoSeed='no'
#---path of transmission-show---#
trans_show="transmission-show"

#---path of transmissionreemote---#
trans_remote='transmission-remote'

#---path of html2bbcode---#
h2b='/usr/local/bin/html2bbcode'

flexget_path="/home/rachpt/tmp"

# log path
log_Path="$AUTO_ROOT_PATH/log"
# lock path
lock_file="$AUTO_ROOT_PATH/lock"
#----------------[post]----------------#

#---[hudbt]---#
enable_hds2hudbt='yes'

default_name_hudbt="Default Title"
default_subname_hudbt="Default Subtitle"
failed_to_get_des_hudbt='[size=5][color=Magenta]获取简介失败[/color][/size]         [em11]'
default_imdb_url_hudbt='tt1234567'
default_select_type_hudbt='415'
default_standard_hudbt='3'
anonymous_hudbt='no'
#---ratio of uploaded torrent---#
ratio_hudbt='10'

cookie_hudbt='Cookie:c_secure_uid=xxxxxx; c_secure_pass=xxxxxxxxxxx; c_secure_login=xxxxxx'
#---you passkey---#
passkey_hudbt='12345678900987654321'

#---[whu]---#
enable_hds2whu='yes'

default_name_whu="Default Title"
default_subname_whu="Default Subtitle"
failed_to_get_des_whu='[size=5][color=Magenta]获取简介失败[/color][/size]         [em11]'
default_imdb_url_whu='tt1234567'
default_select_type_whu='415'
default_standard_whu='0'
anonymous_whu='no'
#---ratio of uploaded torrent---#
ratio_whu='10'

cookie_whu='Cookie:c_secure_uid=xxxxxxx; c_secure_pass=xxxxxxxxxx; c_secure_login=xxxxxxx; c_session_id=xxxxxxxxxxxx'
#---you passkey---#
passkey_whu='1234567890987654323'

#-------#

descrCom="[quote]
[align=center][span style='inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;'][b]这是一个自动发布的种子[/b] [i] (又是一个 AUTO)[/i] [em57][/span]
[/align]



[span style='nline-block:block;background-color:pink;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。[/b] [/span]

[span style='nline-block:block;background-color:greenyellow;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]保种12-20天（目前实行保种分享率[$ratio_whu]），断种恕不补种。[/b] [/span]

[span style='inline-block:block;background-color:steelblue;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]使用 Shell 脚本实现，具体见：[url=https://github.com/rachpt/AutoSeed]rachpt/AutoSeed[/url][em108]，Python 版请关注 [url=https://github.com/Rhilip/Pt-Autoseed]Rhilip/Pt-Autoseed[/url]。[/b] [/span]
[/quote]"

#----------------[add]----------------#
#---authoriz for transmission---#
HOST='127.0.0.1'
PORT='9091'
USER='user'
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

#----------------[hds]----------------#
#---get torrent's detail page---#
cookie_hds='c_secure_uid=xxxxxx; c_secure_pass=xxxxxxxxxx; c_secure_login=xxxxxx'
#----------------[EOF]----------------#
