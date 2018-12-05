#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-11-21
#
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, egrep, curl
# - cut, cat, mktemp, sort, tail, stat, python3
#
#----------------[main]----------------#
#---use yes to disable all---#
Disable_AutoSeed='no'
# set 'yes' allow say thanks 
Allow_Say_Thanks='yes'
# set 'yes', will use python local,otherwise use web 
USE_Local_Gen='yes'
#
#---torrent file path---#
flexget_path="/home/rachpt/Downloads/tmp"
#
TR_Client='qbittorrent' # qbittorrent or transmission
#----------------[clean]---------------#
# Watch folder for clean.
# If not set, will clean just finished one's folder.
default_FILE_PATH='/mnt/ubuntu/mp4'
#
# Do not delete for some time after the modification,
# unit seconds, default 2 days(172800 s).
TimeINTERVAL=172800
#
# The minimum allowed disk (G).
DISK_AVAIL_MIN=50
# Over this time, torrent will be deleted (unit day).
# It will not delete data.
MAX_SEED_TIME=13
#
#-------------[post site]--------------#
########################################
#---[hudbt]---#
enable_hudbt='yes'
say_thanks_hudbt='yes'
#
default_select_type_hudbt='415'
default_standard_hudbt='3'
anonymous_hudbt='no'
#---ratio of uploaded torrent---#
ratio_hudbt='8'
cookie_hudbt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_hudbt='1234567890987654321123423442'
########################################
#---[whu]---#
enable_whu='yes'
say_thanks_whu='yes'
#
default_select_type_whu='415'
default_standard_whu='0'
anonymous_whu='yes'
#---ratio of uploaded torrent---#
ratio_whu='10'
cookie_whu='Cookie:c_secure_uid=XXXXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ==; c_session_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#---your passkey---#
passkey_whu='12345678909876543211123456789987'
########################################
#---[npupt]---#
enable_npupt='yes'
say_thanks_npupt='yes' # not work
#
default_select_type_npupt='401'
default_standard_npupt='7'
anonymous_npupt='yes'
#---ratio of uploaded torrent---#
ratio_npupt='10'
cookie_npupt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_npupt='12345678909876543211234567887'
########################################
#---[nanyangpt]---#
enable_nanyangpt='yes'
say_thanks_nanyangpt='yes'
#
default_select_type_nanyangpt='401'
anonymous_nanyangpt='yes'
#---ratio of uploaded torrent---#
ratio_nanyangpt='10'
cookie_nanyangpt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_nanyangpt='12345678909876543212345654'
########################################
#---[byrbt]---#
enable_byrbt='yes'
say_thanks_byrbt='yes'
#---use 'yes' delete screens img---#
just_poster_byrbt='yes'
default_select_type_byrbt='408'
default_second_type_byrbt='1'
anonymous_byrbt='yes'
#---ratio of uploaded torrent---#
ratio_byrbt='16'
cookie_byrbt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_byrbt='12345678909876543212345654'
########################################
#---[cmct]---#
enable_cmct='yes'
say_thanks_cmct='yes'
#---delete screens img---#
default_select_type_cmct='501'
default_medium_sel_cmct='6'  # mkv 6, mp4 7.
default_codec_sel_cmct='2' # h264
default_standard_sel_cmct='4' # 720p 4,1080p 2
default_source_sel_cmct='9' # 1 大陆, 2 港台, 3 其他, 10 日韩, 9 欧美.
anonymous_cmct='yes'
#---ratio of uploaded torrent---#
ratio_cmct='16'
cookie_cmct='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_cmct='12345678909876543212345654'
########################################
#---[tjupt]---#
enable_tjupt='yes'
say_thanks_tjupt='yes'
#
default_select_type_tjupt='401' # 401 电影, 411 纪录片
default_subsinfo_tjupt='6' # 其他 ## 字幕
default_source_sel_tjupt='8' # 1 BD, 8 other.
default_team_sel_tjupt='7' # 1 欧美, 7 其他, 2 大陆, 3 日韩, 5 港台.
anonymous_tjupt='yes'
#---ratio of uploaded torrent---#
ratio_tjupt='8'
cookie_tjupt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_tjupt='12345678909876543212345654'
########################################
#------------[transmission]------------#
#---authoriz for transmission---#
tr_HOST='127.0.0.1'
tr_PORT='9091'
tr_USER='username'
tr_PASSWORD='passkey'

qb_HOST='http://127.0.0.1'
qb_PORT='8112'
qb_USER='username'
qb_PASSWORD='passkey'
qb_Cookie='cookie:none'
#----------------[site]----------------#
#---cookie for source site---#
cookie_hds='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#
cookie_ttg='Cookie:uid=000000; pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; PHPSESSID=xxxxxxxxxxxxxxxxxxxxxxxxx'
#
cookie_hdc='Cookie:mv_secure_uid=00000000; mv_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxx; mv_secure_login=bm9wZQ=='
#
cookie_mt='Cookie:uid=000000; pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; PHPSESSID=xxxxxxxxxxxxxxxxxxxxxxxxx'
#------------[donot change]------------#
source "$ROOT_PATH/static.sh"
#-----------------[EOF]----------------#
