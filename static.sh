#!/bin/bash
# FileName: static.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-11-21
#
#--------------------------------------#
#--log path (do not change)---#
log_Path="$ROOT_PATH/tmp/log"
#--log path (do not change)---#
debug_log="$ROOT_PATH/tmp/debug"
#---lock path (do not change)---#
lock_file="$ROOT_PATH/tmp/LOCK"
#
#--------------------------------------#
#
#---path of python3---#
python3='python3'
#--------------------------------------#
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
#--------------------------------------#


#--------------------------------------#
# declare -A  定义关联数组 类似字典 键值对
declare -A trackers
declare -A post_site

[[ $enable_hudbt = 'yes' ]] && { trackers[hudbt]='hudbt.hust.edu.cn'
    post_site[hudbt]='https://hudbt.hust.edu.cn'; }
[[ $enable_whu = 'yes' ]] && { trackers[whu]='tracker.whupt.net'
    post_site[whu]='https://whu.pt'; }
[[ $enable_npupt = 'yes' ]] && { trackers[npupt]='npupt.com'
    post_site[npupt]='https://npupt.com'; }
[[ $enable_nanyangpt = 'yes' ]] && { trackers[nanyangpt]='tracker.nanyangpt.com'
    post_site[nanyangpt]='https://nanyangpt.com'; }
[[ $enable_byrbt = 'yes' ]] && { trackers[byr]='tracker.byr.cn'
    post_site[byrbt]='https://bt.byr.cn'; }
[[ $enable_cmct = 'yes' ]] && { trackers[cmct]='tracker.hdcmct.org'
    post_site[cmct]='https://hdcmct.org'; }
[[ $enable_tjupt = 'yes' ]] && { trackers[tjupt]='pttrackertju.tjupt.org'
    post_site='https://tjupt.org'; }
#--------------------------------------#

#[[ $Allow_Say_Thanks != 'yes' ]] && for tracker in ${!trackers[*]}; do
    #tr_set_commit[$tracker]='init'
#done

if [ "$TR_Client" = 'qbittorrent' ]; then
    source "$ROOT_PATH/qbittorrent.sh"
elif [ "$TR_Client" = 'transmission' ]; then
    source "$ROOT_PATH/transmission.sh"
else
    echo '###### Error!' >> "$debug_log"
fi

#--------------------------------------#
