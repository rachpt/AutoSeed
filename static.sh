#!/bin/bash
# FileName: static.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2020-01-09
#
# This file defines constants and functions
#--------------------------------------#
export LANGUAGE=en_US
source "$ROOT_PATH/test.sh"
#--log path (do not change)---#
log_Path="$ROOT_PATH/tmp/log"
#--log path (do not change)---#
debug_Log="$ROOT_PATH/tmp/debug"
#---lock path (do not change)---#
lock_File="$ROOT_PATH/tmp/LOCK"
#---queue path (do not change)---#
queue="$ROOT_PATH/tmp/queue"
quene_lock="$ROOT_PATH/tmp/queue-lock"
#---for qbit (do not change)---#
qb_rt_queue="$ROOT_PATH/tmp/qb-ratio-queue"
#
#--------------------------------------#
#---path of transmission-show---#
tr_show='transmission-show'
tr_edit='transmission-edit'
tr_remote='transmission-remote'
#---path of python3---#
python3='python3'
#---path of mediainfo---#
mediainfo='mediainfo'
#---path of ffmpeg---#
ffmpeg='ffmpeg'
#---path of mtn---#
mtn='mtn'
#---path of dottorrent---#
dottorrent='dottorrent' # example /home/rachpt/.local/bin/dottorrent
#---
user_agent='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:69.0) Gecko/20100101 Firefox/69.0'
#--------------------------------------#
# 豆瓣 api
db_api_1='https://api.rhilip.info/tool/movieinfo/gen'
db_api_2='https://api.nas.ink/infogen'
#--------------------------------------#
# 图片上传 API
upload_poster_api_0='https://sm.ms/api/v2/upload?inajax=1'
upload_poster_api_1='https://i.endpot.com/api/upload'
upload_poster_api_2='https://catbox.moe/user/api.php'
upload_poster_api_3='https://apis.yum6.cn/api/5bd44dc94bcfc' #https://wiki.yum6.cn
upload_poster_api_4='https://pic.xiaojianjian.net/webtools/picbed/upload.htm'
upload_poster_api_5='http://upload.ouliu.net/'
upload_poster_api_6='https://ooxx.ooo/upload'
upload_poster_api_7='https://imgchr.com' # 路过图床，20/h 限制
upload_poster_api_8='https://whoimg.com' # 无名图床
upload_poster_api_9='https://upload.cc'
upload_poster_api_10='https://imgbb.com'
upload_poster_api_11='http://myjd.jd.com/afs/common/upload.action' # 京东图床
byrbt_upload_api='https://bt.byr.cn/ckfinder/core/connector/php/connector.php'
#-------------desc headers-------------#
failed_to_get_des='[size=6][color=Magenta][em11] 获取简介失败！！！[/color][/size]'
set_desc_headers() {
descrCom_simple="[quote] [b]这是一个自动发布的种子[/b] [em2]
[*]所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。
[*]最长保种［${MAX_SEED_TIME}］天，保种分享率［&ratio_in_desc&］，断种恕不补种。
[*]使用 Shell(bash) 脚本实现，开源在：[url=https://github.com/rachpt/AutoSeed]rachpt/AutoSeed[/url][em13]，欢迎star。
[/quote]"
#
( [ "$enable_hudbt" = 'yes' ] || [ "$enable_whu" = 'yes' ] ) && \
descrCom_complex="[quote]
[align=center][span style='inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;'][b][color=White]这是一个自动发布的种子[/color][/b] [em57][/span]
[/align]



[span style='nline-block:block;background-color:pink;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。[/b] [/span]

[span style='nline-block:block;background-color:greenyellow;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]最长保种［${MAX_SEED_TIME}］天，保种分享率［&ratio_in_desc&］，断种恕不补种。[/b] [/span]

[span style='inline-block:block;background-color:steelblue;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;'][b]使用 Shell(bash) 脚本实现，开源在：[url=https://github.com/rachpt/AutoSeed]rachpt/AutoSeed[/url][em108]，欢迎star。[/b] [/span]
[/quote]"
#
[ "$enable_byrbt" = 'yes' ] && \
descrCom_complex_html="<br />
<div style=\"text-align:center\">
  <marquee behavior=\"alternate\" direction=\"down\" height=\"90\" style=\"border:none\" width=\"960\"><marquee behavior=\"alternate\"><span style=\"font-size:26px;\">
  <a href=\"https://github.com/rachpt/AutoSeed\" target=\"_blank\">
	<span style=\"inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;\"><strong>这是一个自动发布的种子</strong> <em> (点不到我^_-)</em> <img alt=\"[em57]\" src=\"https://bt.byr.cn/pic/smilies/57.gif\" /></span></a></span></marquee></marquee></div>
<br /><br /><br />
<span style=\"nline-block:block;background-color:pink;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。</strong> </span><br />
<br />
<span style=\"nline-block:block;background-color:greenyellow;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>最长保种［${MAX_SEED_TIME}］天，保种分享率［${ratio_byrbt}］，断种恕不补种。</strong> </span><br />
<br />
<span style=\"inline-block:block;background-color:steelblue;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>使用 Shell(bash) 脚本实现，开源在：<a href=\"https://github.com/rachpt/AutoSeed\">rachpt/AutoSeed</a><img alt=\"[em108]\" src=\"https://bt.byr.cn/pic/smilies/108.gif\" />，欢迎star。</strong> </span><br />
<br />
<br />"
}
#
#--------------------------------------#
# declare -A 定义关联数组 类似字典键值对
declare -A trackers
declare -A post_site
#
trackers[hudbt]='hudbt.hust.edu.cn'
post_site[hudbt]='https://hudbt.hust.edu.cn'
trackers[whu]='tracker.whupt.net'
post_site[whu]='https://whu.pt'
trackers[npupt]='npupt.com'
post_site[npupt]='https://npupt.com'
trackers[nanyangpt]='tracker.nanyangpt.com'
post_site[nanyangpt]='https://nanyangpt.com'
trackers[byrbt]='tracker.byr.cn'
post_site[byrbt]='https://bt.byr.cn'
trackers[cmct]='on.springsunday.net'
post_site[cmct]='https://springsunday.net'
trackers[tjupt]='.tjupt.org'
post_site[tjupt]='https://tjupt.org'
trackers[tlfbits]='pt.eastgame.org'
post_site[tlfbits]='https://pt.eastgame.org'
#--------------------------------------#
# source tracker url
post_site[ttg]='https://totheglory.im'
trackers[ttg]='tracker.totheglory.im'
post_site[hdc]='https://hdchina.org'
trackers[hdc]='tracker.hdchina.org'
post_site[hds]='https://hdsky.me'
trackers[hds]='tracker.hdsky.me'
post_site[mt]='https://pt.m-team.cc'
trackers[mt]='tracker.m-team.cc'
#--------------------------------------#
# import functions
source "$ROOT_PATH/qbittorrent.sh"
source "$ROOT_PATH/transmission.sh"
#
#--------------------------------------#
# set client mode
unset _site use_qbt use_trs # clean
for _site in hudbt whu nanyangpt npupt byrbt mt cmct tjupt; do
  [[ "$(eval echo '$'enable_$_site)" = yes ]] && \
    case $(eval echo '$'client_$_site) in
      qbittorrent)
          use_qbt='yes' ;;
      transmission)
          use_trs='yes' ;;
    esac
done
case "$fg_client" in
  qbittorrent)
      use_qbt='yes' ;;
  transmission)
      use_trs='yes' ;;
esac
unset _site # clean
#--------------------------------------#
# 普通 图片上传
upload_image_com() {
  unset img_url_com    # clean
  local _file="$1"     # 参数：图片路径
  local _rand_=$((RANDOM % 12)) # choose an api randomly
  up_case_func() {
  case $_rand_ in
    0)
      # https://sm.ms
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
        "$upload_poster_api_0" smfile@"$_file" "$user_agent"|grep -Eo \
        "\"url\".{0,4}\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" ;;
    1)
      # https://i.endpot.com
      img_url_com="$(http --pretty=format --timeout=25 --ignore-stdin -bf POST \
        --verify=no "$upload_poster_api_1" image@"$_file" "$user_agent"|grep -Eo \
        "\"link\".{0,4}\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" ;;
    2)
      # https://catbox.moe
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
      "$upload_poster_api_2" fileToUpload@"$_file" reqtype='fileupload' \
      "$user_agent"|grep -Eio 'http[:/a-z0-9\.]+'|sed 's/\\//g')" ;;
    3)
      # sina 图床，YoungxjApis
      # 更多请看: https://www.youngxj.cn/565.html
      local _tok='f07b711396f9a05bc7129c4507fb65c5'
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
      "$upload_poster_api_3" "token==$_tok" file@"$_file" "$user_agent"| \
      grep -Eio 'https?:[/\\a-z0-9\.]+'|sed 's/\\//g;s/cdn.sinaimg.cn.52ecy.cn/tva1.sinaimg.cn/')" ;;
    4)
      # sina 图床, 小贱贱api: https://pic.xiaojianjian.net
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
        "$upload_poster_api_4" file@"$_file" "$user_agent"|grep -Eio \
        'https?:[/\\a-z0-9\.]+'|sed 's/\\//g;s/http:/http:/')" ;;
      # https 外链被封？
    5)
      # http://upload.ouliu.net
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
      "$upload_poster_api_5" ifile@"$_file" "$user_agent"|grep 'id="codedirect"'| \
      grep -Eio 'https?:[/\\a-z0-9\.]+'|sed 's/\\//g;s/http:/https:/'|head -1)" ;;
    66)
      # https://ooxx.ooo # 下线，2019-04-25
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
      "$upload_poster_api_6" files[]@"$_file" "$user_agent"|grep -Eio '[0-9a-z/\.]+')"
      [[ $img_url_com ]] && img_url_com="https://i.ooxx.ooo/$img_url_com" ;;
    7)
      # https://imgchr.com 路过图床
      unset _data _sessid _tok2; local _data _sessid _tok2
      _data="$(http -v "$upload_poster_api_7" "$user_agent"|grep -Ei 'auth_token|Set-Cookie')"
      _sessid="$(echo "$_data"|grep -Eio 'PHPSESSID=[0-9a-z]+'|head -1)"
      _tok2="$(echo "$_data"|grep -i 'auth_token'|head -1|grep -Eio '[0-9a-z]{30,}')"
      # 恶心...
      [[ $_tok2 && $_sessid ]] && \
      img_url_com="$(http --pretty=format --verify=no --timeout=25 --ignore-stdin \
      -bf POST "${upload_poster_api_7}/json" source@"$_file" auth_token="$_tok2" \
      nsfw=0 timestamp=`date +%s`${RANDOM: -3} action='upload' type='file' "cookie:$_sessid" \
      "$user_agent"|grep -i '"image":'|grep -Eio 'https?:[/\\a-z0-9\.]+')" ;;
    8)
      # https://whoimg.com 无名图床
      unset _data _sessid _tok2; local _data _sessid _tok2
      _data="$(http -v "$upload_poster_api_8" "$user_agent"|grep -Ei 'auth_token|Set-Cookie')"
      _sessid="$(echo "$_data"|grep -Eio 'PHPSESSID=[0-9a-z]+'|head -1)"
      _tok2="$(echo "$_data"|grep -i 'auth_token'|head -1|grep -Eio '[0-9a-z]{30,}')"
      # 恶心...
      [[ $_tok2 && $_sessid ]] && \
      img_url_com="$(http --pretty=format --verify=no --timeout=25 --ignore-stdin \
      -bf POST "${upload_poster_api_8}/json" source@"$_file" auth_token="$_tok2" \
      nsfw=0 timestamp=`date +%s`${RANDOM: -3} action='upload' type='file' "cookie:$_sessid" \
      "$user_agent"|grep -i '"image":'|grep -Eio 'https?:[/\\a-z0-9\.]+')" ;;
    9)
      # https://upload.cc
      img_url_com="$(http --pretty=format --verify=no --timeout=25 -Ibf POST \
      "${upload_poster_api_9}/image_upload" uploaded_file[]@"$_file" "$user_agent"| \
      grep '"url":'|grep -Eio '[0-9a-z/\.]{14,}')"
      [[ $img_url_com ]] && img_url_com="${upload_poster_api_9}/${img_url_com}" ;;
    10)
      # 京东
      img_url_com="$(http --pretty=format --verify=no --timeout=25 -Ibf POST \
      "${upload_poster_api_11}" filedata@"$_file" op='applyUpload' "$user_agent"| \
      grep 'optDescription'|grep -io 'jfs[^"]*')"
      [[ $img_url_com ]] && img_url_com="https://img30.360buyimg.com/myjd/$img_url_com" ;;

  esac
  }
  up_case_func
  # 遍历所有 api 直到上传图片成功
  local _count=1
  while [[ ! $img_url_com && $_count -le 11 ]]; do
    [[ $_rand_ -eq 11 ]] && _rand_=0 || _rand_=$((_rand_ + 1))
    up_case_func
    ((_count++))
  done
  unset -f up_case_func
  debug_func "img:com-img-url[$img_url_com][$_rand_][$_count]"  #----debug---
}
#--------------------------------------#
# byr 图片上传
upload_image_byrbt() {
  unset img_url_byr  # clean
  local _file="$1"   # 参数：图片路径
  img_url_byr="$(http --verify=no --ignore-stdin --timeout=40 -bf POST \
    "$byrbt_upload_api" command==QuickUpload type==Images upload@"$_file" \
    "$user_agent" "$cookie_byrbt"|grep -Eio "https?://[^\'\"]+"|sed "s/http:/https:/g")"

  #----debug---
  [[ $img_url_byr ]] || debug_func "$byrbt_up_api command==QuickUpload type==Images upload@$_file $user_agent $cookie_byrbt"
  debug_func "img:byr-img-url[$img_url_byr]"  #----debug---
}
#
#-------------------------------------#
# test tracker is down?
is_tracker_down() {
  local _site
  for _site in  hudbt whu nanyangpt npupt byrbt mt cmct tjupt tlfbits; do
    [[ "$(eval echo '$'enable_$_site)" = yes ]] && \
    if http --verify=no --timeout=40 --ignore-stdin GET "${post_site[$_site]}/login.php" \
    "$(eval echo '$'"cookie_$_site")" "$user_agent" &> /dev/null; then
      debug_func "static-[$_site is OK]"  #----debug---
    else
      case $? in
        2|3|4)
            : ;;
        5|6)
          eval "enable_$_site"='no'
          debug_func "static-[$_site is Down !!!]"  #----debug---
          ;;
        *)
          debug_func "static-[$_site http error!!]"  #----debug---
          ;;
      esac
    fi
  done
  unset _site
}
#-------------------------------------#
count(){ [[ -f $1 ]] && printf '%s' "$#"|| printf 0; }
Listf(){ local i;for i in "${1%/}/"*"$2";do [[ -f $i ]] && printf '%s\n' "$i";done; }
#-------------------------------------#
get_torrents_name() {
  [[ -f $1 ]] && $tr_show "$1"|grep -m1 '^Name:'|sed 's/Name:[ ]*//' || \
    debug_func "get-tr-name:[$1]not a file"
}
#-------------------------------------#

