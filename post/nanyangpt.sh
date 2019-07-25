#!/bin/bash
# FileName: post/nanyangpt.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2018-12-05
#
#-------------settings---------------#
cookie="$cookie_nanyangpt"
passkey="$passkey_nanyangpt"
anonymous="$anonymous_nanyangpt"
ratio_set=$ratio_nanyangpt
to_client="$client_nanyangpt"
#---static---#
postUrl="${post_site[nanyangpt]}/takeupload.php"
editUrl="${post_site[nanyangpt]}/takeedit.php"
downloadUrl="${post_site[nanyangpt]}/download.php?id="
#-------------------------------------#
# 需要的参数
gen_nanyangpt_parameter() {

if [[ -s "$source_desc" ]]; then
nanyangpt_des="${descrCom_simple//&ratio_in_desc&/$ratio_nanyangpt}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
else
nanyangpt_des="${descrCom_simple//&ratio_in_desc&/$ratio_nanyangpt}
$failed_to_get_des"
fi

if [ "$documentary" = 'yes' ]; then
    # 纪录片
    nanyangpt_type='406'
else
    if [ "$serials" = 'yes' ]; then
        # 剧集
        nanyangpt_type='402'
    else
        # 电影
        nanyangpt_type='401'
    fi
fi

    # 副标题
    nanyangpt_small_descr="$chinese_title $chs_included"
}
#-------------------------------------#
# file -> 种子文件(*)
# type -> 类型(*) ，name  -> 主标题(0day 不要点*)
# [movie_enname | series_enname |doc_enname]，small_descr -> 副标题
# url  -> imdb链接，dburl -> 豆瓣链接(没有 imdb 才使用)
# nfo  -> nfo 文件，descr -> 简介(*)
# uplver -> 匿名上传('yes')，prohibit_transfer -> 禁转('yes')
#---类型---#
# 401  电影
# 402  剧集
# 403  动漫
# 404  综艺
# 405  体育
# 406  纪录
# 407  音乐
# 408  学习
# 409  软件
# 410  游戏
# 411  其它

#-------------------------------------#
nanyangpt_post_func() {
    gen_nanyangpt_parameter
    #---post data---#
if [[ "$nanyangpt_type" == '401' ]]; then
  # 电影 POST
  t_id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
    'name'="$dot_name"\
    'movie_enname'="$dot_name"\
    'small_descr'="$nanyangpt_small_descr"\
    'url'="$imdb_url"\
    'dburl'="$([[ ! "$imdb_url" ]] && echo "$douban_url" || echo 'none')"\
    'descr'="$nanyangpt_des"\
    'type'="$nanyangpt_type"\
    'uplver'="$anonymous_nanyangpt"\
    file@"${torrent_Path}"\
    "$cookie_nanyangpt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

  if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
  fi
elif [[ "$nanyangpt_type" == '402' ]]; then
  # 剧集 POST
  t_id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
    'name'="$dot_name"\
    'series_enname'="$dot_name"\
    'small_descr'="$nanyangpt_small_descr"\
    'url'="$imdb_url"\
    'dburl'="$([[ ! "$imdb_url" ]] && echo "$douban_url" || echo 'none')"\
    'descr'="$nanyangpt_des"\
    'type'="$nanyangpt_type"\
    'uplver'="$anonymous_nanyangpt"\
    file@"${torrent_Path}"\
    "$cookie_nanyangpt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

  if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
  fi

elif [[ "$nanyangpt_type" == '406' ]]; then
  # 纪录片 POST
  t_id="$(http --verify=no --ignore-stdin -f --print=h POST "$postUrl"\
    'name'="$dot_name"\
    'doc_enname'="$dot_name"\
    'small_descr'="$nanyangpt_small_descr"\
    'url'="$imdb_url"\
    'dburl'="$([[ ! "$imdb_url" ]] && echo "$douban_url" || echo 'none')"\
    'descr'="$nanyangpt_des"\
    'type'="$nanyangpt_type"\
    'uplver'="$anonymous_nanyangpt"\
    file@"${torrent_Path}"\
    "$cookie_nanyangpt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

  if [[ -z "$t_id" ]]; then
    # 辅种
    reseed_torrent
  fi
else
    # 其他 POST
    :
fi
}

#-------------------------------------#

