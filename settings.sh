#!/bin/bash
# FileName: settings.sh
#
# Author: rachpt@126.com
# Version: 2.2v
# Date: 2018-06-17
#
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, egrep, curl
# - cut, cat, mktemp, sort, tail, stat
#
#----------------[main]----------------#
#---use yes to disable all---#
disable_AutoSeed='no'
#---path of transmission-show---#
trans_show="transmission-show"
#
#---path of transmissionreemote---#
trans_remote='transmission-remote'
#
#---torrent file path---#
flexget_path="/home/rachpt/Downloads/tmp"
#
# log path
log_Path="$AUTO_ROOT_PATH/tmp/log"
# lock path
lock_file="$AUTO_ROOT_PATH/tmp/LOCK"
#
#----------------[clean]---------------#
# Watch folder for clean.
# If not set, will clean just finished one's folder.
default_FILE_PATH='/srv/ftp/mp4'
#
# Do not delete for some time after the modification,
# unit seconds, default 2 days(172800 s).
TimeINTERVAL=172800
#
# The minimum allowed disk (G).
DISK_AVAIL_MIN=50
# Over this time, torrent will be deleted (day).
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
ratio_hudbt='6'
cookie_hudbt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---you passkey---#
passkey_hudbt='1234567890987654321123423442'
########################################
#---[whu]---#
enable_whu='yes'
#
default_select_type_whu='415'
default_standard_whu='0'
anonymous_whu='no'
#---ratio of uploaded torrent---#
ratio_whu='10'
cookie_whu='Cookie:c_secure_uid=XXXXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ==; c_session_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#---you passkey---#
passkey_whu='12345678909876543211123456789987'
########################################
#---[npupt]---#
enable_npupt='yes'
#
default_select_type_npupt='401'
default_standard_npupt='7'
anonymous_npupt='no'
#---ratio of uploaded torrent---#
ratio_npupt='6'
cookie_npupt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---you passkey---#
passkey_npupt='12345678909876543211234567887'
########################################
#---[nanyangpt]---#
enable_nanyangpt='yes'
#
default_select_type_nanyangpt='401'
anonymous_nanyangpt='no'
#---ratio of uploaded torrent---#
ratio_nanyangpt='6'
cookie_nanyangpt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---you passkey---#
passkey_nanyangpt='12345678909876543212345654'
########################################
#---[byrbt]---#
enable_byrbt='yes'
#
default_select_type_byrbt='408'
default_second_type_byrbt='1'
anonymous_byrbt='yes'
#---ratio of uploaded torrent---#
ratio_byrbt='8'
cookie_byrbt='Cookie:c_secure_uid=XXXXXX; c_secure_pass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; c_secure_login=bm9wZQ=='
#---you passkey---#
passkey_byrbt='12345678909876543212345654'
########################################
#--------------------------------------#
default_subname='Default Subtitle'
default_imdb_url='tt1234567'
#
#---desc---#
failed_to_get_des='[size=5][color=Magenta][em11] 获取简介失败,稍后编辑。[/color][/size]'
descrCom_simple="[quote]
[b]这是一个自动发布的种子[/b] [i] (又是一个 AUTO)[/i] [em2]
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
