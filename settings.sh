#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-10
#
# Environmental requirements:
# - transmission-[remote,daemon or gtk] or qbittorrent
# - transmission-edit and transmission-show
# - httpie, head, awk, sed, find, grep,
# - cut, cat, sort, tail, stat, python3
# - base64, iconv, mediainfo
#
#----------------[main]----------------#
#---use 'yes' to disable all---#
Disable_AutoSeed='no'
Speed=0.6
# set 'yes' allow say thanks 
Allow_Say_Thanks='yes'
# set 'yes', will uselocal python gen while web method failed 
Use_Local_Gen='yes'
#
#---torrent file path---#
flexget_path="/home/rachpt/Downloads/tmp"
#---transmission or qbittorrent---#
fg_client='transmission'
#
# data folder.
# for find nfo file and clean.
default_FILE_PATH='/mnt/'
#
#----------------[clean]---------------#
# Do not delete for some time after the modification,
# unit seconds, default 2 days(172800 s).
TimeINTERVAL=172800
#
# The minimum allowed disk (G).
DISK_AVAIL_MIN=20
# Over this time, torrent will be deleted (unit day).
# It will NOT delete data.
MAX_SEED_TIME=10
#
#-------------[post site]--------------#
########################################
#---[hudbt]---#
enable_hudbt='yes'
say_thanks_hudbt='yes'
#
client_hudbt='transmission'
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
client_whu='transmission'
#
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
client_npupt='qbittorrent'
#
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
client_nanyangpt='qbittorrent'
#
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
client_byrbt='qbittorrent'
#---use 'yes' delete screens img---#
just_poster_byrbt='yes'
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
client_cmct='qbittorrent'
#
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
client_tjupt='qbittorrent'
#---use 'yes' delete screens img---#
just_poster_tjupt='yes'
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
qb_PORT='8080'
qb_USER='username'
qb_PASSWORD='passkey'
qb_Cookie='cookie:SID=xxx'
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
