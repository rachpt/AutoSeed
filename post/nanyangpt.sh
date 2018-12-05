#!/bin/bash
# FileName: post/nanyangpt.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-05
#
#-------------settings---------------#
cookie="$cookie_nanyangpt"
passkey="$passkey_nanyangpt"
anonymous="$anonymous_nanyangpt"
#---static---#
postUrl="${post_site[nanyangpt]}/takeupload.php"
editUrl="${post_site[nanyangpt]}/takeedit.php"
downloadUrl="${post_site[nanyangpt]}/download.php?id="
#-------------------------------------#
# 需要的参数
nanyangpt_des="$(echo "$descrCom_simple"|sed "s/&ratio_in_desc&/$ratio_nanyangpt/g")
$(cat "$source_detail_desc")"

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

if [ "$nanyangpt_type" = '401' ]; then
    # 电影 POST
    t_id=$(http --ignore-stdin -f --print=h POST "$postUrl"\
        'name'="$dot_name"\
        'movie_enname'="$dot_name"\
        'small_descr'="$nanyangpt_small_descr"\
        'url'="$imdb_url"\
        'dburl'="$( [ ! "$imdb_url" ] && echo "$douban_url")"\
        'descr'="$nanyangpt_des"\
        'type'="$nanyangpt_selectType"\
        'uplver'="$anonymous_nanyangpt"\
        file@"${torrent_Path}"\
        "$cookie_nanyangpt"|grep 'id='|grep 'detail'|head -1|cut -d '=' -f 2|cut -d '&' -f 1)

    if [ -z "$t_id" ]; then
        # 辅种
        :
        t_id=`http --ignore-stdin -f POST "$postUrl" name="$dot_name" movie_enname="$dot_name" small_descr="$smallDescr" url="$imdbUrl" descr="$nanyangpt_des" type="$nanyangpt_selectType" uplver="$anonymous" file@"$torrent_Path" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
    fi
elif [ "$nanyangpt_type" = '402' ]; then
    # 剧集 POST
    t_id=$(http --ignore-stdin -f --print=h POST "$postUrl"\
        'name'="$dot_name"\
        'series_enname'="$dot_name"\
        'small_descr'="$nanyangpt_small_descr"\
        'url'="$imdb_url"\
        'dburl'="$( [ ! "$imdb_url" ] && echo "$douban_url")"\
        'descr'="$nanyangpt_des"\
        'type'="$nanyangpt_selectType"\
        'uplver'="$anonymous_nanyangpt"\
        file@"${torrent_Path}"\
        "$cookie_nanyangpt"|grep 'id='|grep 'detail'|head -1|cut -d '=' -f 2|cut -d '&' -f 1)

elif [ "$nanyangpt_type" = '406' ]; then
    # 纪录片 POST
    t_id=$(http --ignore-stdin -f --print=h POST "$postUrl"\
        'name'="$dot_name"\
        'doc_enname'="$dot_name"\
        'small_descr'="$nanyangpt_small_descr"\
        'url'="$imdb_url"\
        'dburl'="$( [ ! "$imdb_url" ] && echo "$douban_url")"\
        'descr'="$nanyangpt_des"\
        'type'="$nanyangpt_selectType"\
        'uplver'="$anonymous_nanyangpt"\
        file@"${torrent_Path}"\
        "$cookie_nanyangpt"|grep 'id='|grep 'detail'|head -1|cut -d '=' -f 2|cut -d '&' -f 1)
    :
else
    # 其他 POST
    :
fi

