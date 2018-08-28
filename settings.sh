#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 2.3v
# Date: 2018-08-27
#
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, egrep, curl
# - cut, cat, mktemp, sort, tail, stat, python3
#
#----------------[main]----------------#
#---use yes to disable all---#
disable_AutoSeed='no'
#---path of transmission-show---#
trans_show="transmission-show"
#
#---path of transmission-remote---#
trans_remote='transmission-remote'
#
#---path of python3---#
python3='python3'
# set 'yes', will use python local,otherwise use web 
USE_Local_Gen='yes'
#
#---torrent file path---#
flexget_path="/home/rachpt/Downloads/tmp"
#
#--log path (do not change)---#
log_Path="$AUTO_ROOT_PATH/tmp/log"
#---lock path (do not change)---#
lock_file="$AUTO_ROOT_PATH/tmp/LOCK"
#
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
#--------------------------------------#
default_subname='此种需要人工编辑'
default_imdb_url='tt1234567'
#
#---desc---#
failed_to_get_des='[size=6][color=Magenta][em11] 获取简介失败。无人职守！！！ 不喜勿下！ 如果帮助修改，在此非常感谢！[/color][/size]'
descrCom_simple="[quote] [b]这是一个自动发布的种子[/b] [i] (又是一个 AUTO)[/i] [em2]
[*]所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。
[*]最长保种［${MAX_SEED_TIME}］天，保种分享率［&ratio_in_desc&］，断种恕不补种。
[*]使用 Shell 脚本实现，具体见：[url=https://github.com/rachpt/AutoSeed]rachpt/AutoSeed[/url][em13]，Python 版请关注 [url=https://github.com/Rhilip/Pt-Autoseed]Rhilip/Pt-Autoseed[/url]，JS版 [url=https://git.coding.net/Kannnnng/AutoSeed.git]Kannnnng/AutoSeed[/url]。
[/quote]"
#
descrCom_complex="[quote]
[align=center][span style='inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;'][b]这是一个自动发布的种子[/b] [i] (又是一个 AUTO)[/i] [em57][/span]
[/align]



[span style='nline-block:block;background-color:pink;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。[/b] [/span]

[span style='nline-block:block;background-color:greenyellow;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]最长保种［${MAX_SEED_TIME}］天，保种分享率［&ratio_in_desc&］，断种恕不补种。[/b] [/span]

[span style='inline-block:block;background-color:steelblue;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]使用 Shell 脚本实现，具体见：[url=https://github.com/rachpt/AutoSeed]rachpt/AutoSeed[/url][em108]，Python 版请关注 [url=https://github.com/Rhilip/Pt-Autoseed]Rhilip/Pt-Autoseed[/url]，JS版 [url=https://git.coding.net/Kannnnng/AutoSeed.git]Kannnnng/AutoSeed[/url]。[/b] [/span]
[/quote]"
#
descrCom_complex_html="<br />
<div style=\"text-align:center\">
    <marquee behavior=\"alternate\" direction=\"down\" height=\"90\" style=\"border:none\" width=\"960\"><marquee behavior=\"alternate\"><span style=\"font-size:26px;\">
	<span style=\"inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;\"><strong>这是一个自动发布的种子</strong> <em> (又是一个 AUTO)</em> <img alt=\"[em57]\" src=\"https://bt.byr.cn/pic/smilies/57.gif\" /></span></span></marquee></marquee></div>
<br /><br /><br />
<span style=\"nline-block:block;background-color:pink;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。</strong> </span><br />
<br />
<span style=\"nline-block:block;background-color:greenyellow;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>最长保种［${MAX_SEED_TIME}］天，保种分享率［${ratio_byrbt}］，断种恕不补种。</strong> </span><br />
<br />
<span style=\"inline-block:block;background-color:steelblue;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>使用 Shell 脚本实现，具体见：<a href=\"https://github.com/rachpt/AutoSeed\">rachpt/AutoSeed</a><img alt=\"[em108]\" src=\"https://bt.byr.cn/pic/smilies/108.gif\" />，Python 版请关注 <a href=\"https://github.com/Rhilip/Pt-Autoseed\">Rhilip/Pt-Autoseed</a>，JS版 <a href=\"https://git.coding.net/Kannnnng/AutoSeed.git\">Kannnnng/AutoSeed</a>。</strong> </span><br />
<br />
<br />"
#
#------------[transmission]------------#
#---authoriz for transmission---#
HOST='127.0.0.1'
PORT='9091'
USER='username'
PASSWORD='passkey'
#----------------[site]----------------#
#---cookie for source site---#
cookie_hds='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#
cookie_ttg='Cookie:uid=000000; pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; PHPSESSID=xxxxxxxxxxxxxxxxxxxxxxxxx'
#
cookie_hdc='Cookie:mv_secure_uid=00000000; mv_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxx; mv_secure_login=bm9wZQ=='
#-----------------[EOF]----------------#
