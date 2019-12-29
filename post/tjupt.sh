#!/bin/bash
# FileName: post/tjupt.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2018-12-09
#
#-------------settings---------------#
cookie="$cookie_tjupt"
passkey="$passkey_tjupt"
anonymous="$anonymous_tjupt"
ratio_set=$ratio_tjupt
to_client="$client_tjupt"
#---static---#
postUrl="${post_site[tjupt]}/takeupload.php"
editUrl="${post_site[tjupt]}/takeedit.php"
downloadUrl="${post_site[tjupt]}/download.php?id="
#-------------------------------------#
gen_tjupt_parameter() {

if [ -s "$source_desc2tjupt" ]; then
tjupt_des="${descrCom_simple/&ratio_in_desc&/$ratio_tjupt}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d;/&extra_comment&/d' "$source_desc2tjupt")"
else
tjupt_des="${descrCom_simple/&ratio_in_desc&/$ratio_tjupt}
$failed_to_get_des"
fi

#-------------------------------------#
# 类型
if [ "$documentary" = 'yes' ]; then
    # 纪录片
    tjupt_type='411'
elif [ "$is_ipad" = 'yes' ]; then
    tjupt_type='412'
else
    if [ "$serials" = 'yes' ]; then
        # 剧集
        tjupt_type='402'
    else
        # 电影
        tjupt_type='401'
    fi
fi
# 年份
tjupt_year="$(echo "$dot_name"|grep -Eo '[12][089][0-9]{2}'|sed '/1080/d'|tail -1)"
[ ! "$tjupt_year" ] && tjupt_year=2018  # 默认年份

# 电影格式
if [ "$is_1080p" = 'yes' ]; then
    jutpt_stardand='1080p'
elif [ "$is_720p" = 'yes' ]; then
    jutpt_stardand='720p'
else
    jutpt_stardand='none'
fi

if [ "$chs_included" ]; then
    tjupt_subsinfo=2
else
    tjupt_subsinfo=6
fi

#-------------------------------------#
# 来源
if [ "$is_bd" = 'yes' ]; then
    tjupt_source='1'
elif [ "$is_hdtv" = 'yes' ]; then
    tjupt_source='4'
elif [ "$is_webdl" = 'yes' ]; then
    tjupt_source='7'
else
    tjupt_source='8'
fi

#-------------------------------------#
# 地区
case "$region" in
  *中国大陆*)
      tjupt_team='2' ;;
  *香港*|*台湾*|*澳门*)
      tjupt_team='5' ;;
  *日本*|*韩国*)
      tjupt_team='3' ;;
  *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*)
      tjupt_team='1' ;;
  *)
      tjupt_team='7' ;;
esac
}
#-------------------------------------#
tjupt_post_func() {
    gen_tjupt_parameter
    #---post data---#
t_id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
    'small_descr'="$chs_included"\
    'url'="$imdb_url"\
    'descr'="$tjupt_des"\
    'type'="$tjupt_type"\
    'cname'="$chinese_title"\
    'ename'="$dot_name"\
    'issuedate'="$tjupt_year"\
    'language'="$language"\
    'format'="$jutpt_stardand"\
    'formatratio'="$jutpt_stardand"\
    'subsinfo'="$tjupt_subsinfo"\
    'district'="$region"\
    'specificcat'="$region"\
    'source_sel'="$tjupt_source"\
    'team_sel'="$tjupt_team"\
    'uplver'="$anonymous_tjupt"\
    file@"${torrent_Path}"\
    "$cookie_tjupt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
fi
}

#-------------------------------------#
