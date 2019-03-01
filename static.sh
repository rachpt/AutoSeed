#!/bin/bash
# FileName: static.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-02-28
#
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
#---
user_agent='User-Agent:Mozilla/5.0(X11;Linux x86_64;rv:63.0)Gecko/20100101 Firefox/63.0'
#--------------------------------------#
# 图片上传 API
upload_poster_api_1='https://sm.ms/api/upload'
upload_poster_api_2='https://i.endpot.com/api/upload'
upload_poster_api_3='https://catbox.moe/user/api.php'
byrbt_upload_api='https://bt.byr.cn/ckfinder/core/connector/php/connector.php'
#--------------------------------------#
#---desc---#
failed_to_get_des='[size=6][color=Magenta][em11] 获取简介失败！！！[/color][/size]'
descrCom_simple="[quote] [b]这是一个自动发布的种子[/b] [em2]
[*]所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。
[*]最长保种［${MAX_SEED_TIME}］天，保种分享率［&ratio_in_desc&］，断种恕不补种。
[*]使用 Shell(bash) 脚本实现，开源在：[url=https://github.com/rachpt/AutoSeed]rachpt/AutoSeed[/url][em13]，欢迎star。
[/quote]"
#
( [ "$enable_hudbt" = 'yes' ] || [ "$enable_whu" = 'yes' ] ) && \
descrCom_complex="[quote]
[align=center][span style='inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;'][b]这是一个自动发布的种子[/b] [em57][/span]
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
  <a href=\"https://github.com/rachpt/AutoSeed\">
	<span style=\"inline-block:block;background-color:slateblue;padding:30px;border:dashed silver 1px;border-radius:px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:6em auto;\"><strong>这是一个自动发布的种子</strong> <em> (点不到我^_-)</em> <img alt=\"[em57]\" src=\"https://bt.byr.cn/pic/smilies/57.gif\" /></span></a></span></marquee></marquee></div>
<br /><br /><br />
<span style=\"nline-block:block;background-color:pink;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>所有信息以种子文件名为准，标题、简介信息仅供参考，若发现有误请以［举报］或［留言］的形式通知工作人员审查编辑。</strong> </span><br />
<br />
<span style=\"nline-block:block;background-color:greenyellow;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:100px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>最长保种［${MAX_SEED_TIME}］天，保种分享率［${ratio_byrbt}］，断种恕不补种。</strong> </span><br />
<br />
<span style=\"inline-block:block;background-color:steelblue;padding:10px;border:dashed silver 1px;border-radius:3px;box-shadow: 2px 2px 5px gray;width:110px;overflow-x:hidden;text-overflow:ellipsis;white-space:nowrap;margin:2em auto;\"><strong>使用 Shell(bash) 脚本实现，开源在：<a href=\"https://github.com/rachpt/AutoSeed\">rachpt/AutoSeed</a><img alt=\"[em108]\" src=\"https://bt.byr.cn/pic/smilies/108.gif\" />，欢迎star。</strong> </span><br />
<br />
<br />"
#
#--------------------------------------#
# declare -A 定义关联数组 类似字典键值对
declare -A trackers
declare -A post_site
#
#[[ $enable_hudbt = yes ]] && { trackers[hudbt]='hudbt.hust.edu.cn'
    #post_site[hudbt]='https://hudbt.hust.edu.cn'; }
#[[ $enable_whu = yes ]] && { trackers[whu]='tracker.whupt.net'
    #post_site[whu]='https://whu.pt'; }
#[[ $enable_npupt = yes ]] && { trackers[npupt]='npupt.com'
    #post_site[npupt]='https://npupt.com'; }
#[[ $enable_nanyangpt = yes ]] && { trackers[nanyangpt]='tracker.nanyangpt.com'
    #post_site[nanyangpt]='https://nanyangpt.com'; }
#[[ $enable_byrbt = yes ]] && { trackers[byrbt]='tracker.byr.cn'
    #post_site[byrbt]='https://bt.byr.cn'; }
#[[ $enable_cmct = yes ]] && { trackers[cmct]='tracker.hdcmct.org'
    #post_site[cmct]='https://hdcmct.org'; }
#[[ $enable_tjupt = yes ]] && { trackers[tjupt]='.tjupt.org'
    #post_site[tjupt]='https://tjupt.org'; }
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
trackers[cmct]='tracker.hdcmct.org'
post_site[cmct]='https://hdcmct.org'
trackers[tjupt]='.tjupt.org'
post_site[tjupt]='https://tjupt.org'
#--------------------------------------#
# import functions
source "$ROOT_PATH/qbittorrent.sh"
source "$ROOT_PATH/transmission.sh"
#
#--------------------------------------#
# 普通 图片上传
upload_image_com() {
  unset img_url_com    # clean
  local _file="$1"     # 参数：图片路径
  local _rand_="$(expr $RANDOM % 3)" # choose an api randomly
  up_case_func() {
  case $_rand_ in
    0)
      # endpot.com
      img_url_com="$(http --pretty=format --timeout=25 -bf --ignore-stdin POST \
        --verify=no "$upload_poster_api_2" image@"$_file" "$user_agent"|grep -Eo \
        "\"link\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" ;;
    1)
      # sm.ms
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
        "$upload_poster_api_1" smfile@"$_file" "$user_agent"|grep -Eo \
        "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" ;;
    2)
      # catbox.moe
      img_url_com="$(http --verify=no --timeout=25 --ignore-stdin -bf POST \
      "$upload_poster_api_3" fileToUpload@"$_file" reqtype='fileupload' \
      "$user_agent"|grep -Eio 'http[:/a-z0-9\.]+'|sed 's/\\//g')" ;;
  esac
  }
  up_case_func
  local _count=1
  while [[ ! $img_url_com && $_count -le 3 ]]; do
    [[ $_rand_ -eq 2 ]] && _rand_=0 || _rand_=$(expr $_rand_ + 1)
    up_case_func
    ((_count++))
  done
  unset -f up_case_func
  debug_func "img:com-img-url[$img_url_com]"  #----debug---
}
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
  for _site in  hudbt whu nanyangpt npupt byrbt cmct tjupt; do
    if http --verify=no  --timeout=40 --ignore-stdin GET "${post_site[$_site]}/login.php" \
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

