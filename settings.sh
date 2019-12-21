#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-12-21
#
# Environmental requirements:
# - transmission-[remote,daemon or gtk] or qbittorrent
# - transmission-edit and transmission-show
# - httpie, awk, sed, find, grep,
# - sort, tail, head, stat, python3
# - base64, iconv, mediainfo
#
#---------------[caption]--------------#
# usually, value can set 'yes' or 'no'
# path should use absolutely one and no slash end best
#----------------[main]----------------#
# you can use source to import this file to test each func
[[ ! $ROOT_PATH ]] && \
ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#---use 'yes' to disable all---#
Disable_AutoSeed='no'
# change this value to change delay
Speed=0.6
# set 'yes' allow say thanks 
Allow_Say_Thanks='yes'
# no headers
No_Headers='yes'
# set 'yes', will uselocal python gen while web method failed 
Use_Local_Gen='yes'
#
#---torrent file path---#
flexget_path="/home/rachpt/Downloads/tmp"
#---transmission or qbittorrent---#
fg_client='transmission' # download source torrent
#
# data folder
# for find nfo file in get_desc/info.sh
default_FILE_PATH='/mnt'
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
##===###################################
#---[hudbt]---#
enable_hudbt='yes'
say_thanks_hudbt='yes'
#
client_hudbt='transmission'
anonymous_hudbt='no'
#---ratio of uploaded torrent---#
ratio_hudbt='4'
cookie_hudbt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_hudbt='1234567890987654321123423442'
#####===################################
#---[whu]---#
enable_whu='yes'
say_thanks_whu='yes'
client_whu='transmission'
#
anonymous_whu='yes'
#---ratio of uploaded torrent---#
ratio_whu='4'
cookie_whu='Cookie:c_secure_uid=XXXXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ==; c_session_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#---your passkey---#
passkey_whu='12345678909876543211123456789987'
########===#############################
#---[npupt]---#
enable_npupt='yes'
say_thanks_npupt='yes' # not work
client_npupt='qbittorrent'
#
anonymous_npupt='yes'
#---ratio of uploaded torrent---#
ratio_npupt='4'
cookie_npupt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_npupt='12345678909876543211234567887'
###########===##########################
#---[nanyangpt]---#
enable_nanyangpt='yes'
say_thanks_nanyangpt='yes'
client_nanyangpt='qbittorrent'
#
anonymous_nanyangpt='yes'
#---ratio of uploaded torrent---#
ratio_nanyangpt='4'
cookie_nanyangpt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_nanyangpt='12345678909876543212345654'
##############===#######################
#---[byrbt]---#
enable_byrbt='yes'
say_thanks_byrbt='yes'
client_byrbt='qbittorrent'
#---use 'yes' delete screens img---#
just_poster_byrbt='yes'
anonymous_byrbt='yes'
#---ratio of uploaded torrent---#
ratio_byrbt='4'
cookie_byrbt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_byrbt='12345678909876543212345654'
#################===####################
#---[cmct]---#
enable_cmct='no'
say_thanks_cmct='yes'
client_cmct='qbittorrent'
#
anonymous_cmct='yes'
#---ratio of uploaded torrent---#
ratio_cmct='4'
cookie_cmct='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_cmct='12345678909876543212345654'
#######################===##############
#---[mt]---#
enable_mt='yes'
say_thanks_mt='no'
header_mt='no'
client_mt='qbittorrent'
#---delete screens img---#
#
anonymous_mt='yes'
#---ratio of uploaded torrent---#
ratio_mt='5'
cookie_mt='Cookie:tp=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=='
#---your passkey---#
passkey_mt='12345678909876543212345654'
###########################===##########
#---[tjupt]---#
enable_tjupt='yes'
say_thanks_tjupt='yes'
client_tjupt='qbittorrent'
#---use 'yes' delete screens img---#
just_poster_tjupt='yes'
anonymous_tjupt='yes'
#---ratio of uploaded torrent---#
ratio_tjupt='4'
cookie_tjupt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_tjupt='12345678909876543212345654'
##############################===#######
#---[neu6]---#
enable_neu6='no'
say_thanks_neu6='yes'
client_neu6='qbittorrent'
#---use 'yes' delete screens img---#
just_poster_neu6='yes'
anonymous_tjupt='yes'
#---ratio of uploaded torrent---#
ratio_neu6='4'
cookie_neu6='Cookie: LRpW_2132_saltkey=xxx; LRpW_2132_auth=xxxxxxx'
#---your passkey---#
passkey_neu6='12345678909876543212345654'

#################################===####
#---[tlfbits]---#
enable_tlfbits='no'
say_thanks_tlfbits='no'
client_tlfbits='qbittorrent'
anonymous_tlfbits='yes'
[[ $enable_tlfbits == 'yes' ]] && only_tlfbits='yes'
#---ratio of uploaded torrent---#
ratio_tlfbits='4'
cookie_tlfbits='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---your passkey---#
passkey_tlfbits='12345678909876543212345654'
###################################===##
#------------[transmission]------------#
#---authoriz for transmission---#
tr_HOST='127.0.0.1'
tr_PORT='9091'
tr_USER='tr-username'
tr_PASSWORD='tr-passkey'
#-------------[qbittorrent]------------#
#---authoriz for qbittorrent---#
qb_HOST='http://127.0.0.1'
qb_PORT='8080'
qb_USER='qbit-username'
qb_PASSWORD='qbit-passkey'
qb_Cookie='cookie:SID=xxx'
#----------------[site]----------------#
#---cookie for source site---#
cookie_hds='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
ratio_hds='2'  # just for fg_client='qbittorrent' case
#
cookie_ttg='Cookie:uid=000000; pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; PHPSESSID=xxxxxxxxxxxxxxxxxxxxxxxxx'
ratio_ttg='2'  # just for fg_client='qbittorrent' case
#
cookie_hdc='Cookie:mv_secure_uid=xxxx; mv_secure_pass=xxx;hdchina=xxx;PHPSESSID=xxx;mv_secure_login=bm9wZQ=='
ratio_hdc='2'  # just for fg_client='qbittorrent' case
#
#-----------------[EOF]----------------#

