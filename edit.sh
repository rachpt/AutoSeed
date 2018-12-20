#!/bin/bash
# FileName: edit.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-08
#
#------------------------------------#
this_mode_is_not_use_now(){
#---main.sh is running?---#
pidof -x main.sh
if [ $? -eq 0 ]; then
    echo '主程序正在运行，稍后重试！'
    exit
fi
#---import settings---#
if [ -z "$log_Path"]; then
    ROOT_PATH="$(dirname "$(readlink -f "$0")")"
    source "$ROOT_PATH/settings.sh"
fi
#----------------post----------------#
function edit_post_normal()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id" 'name'="$no_dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$com_des" 'type'="$selectType" 'standard_sel'="$standardSel" 'anonymous'="`([ "$anonymous" = 'yes' ] && echo 1) || echo 0`" 'visible'="1" "$cookie"
}
function edit_post_npupt()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id" 'name'="$dot_name" 'small_descr'="$smallDescr" 'nfoaction'='keep' 'descr'="$npupt_des" 'type'="$npupt_selectType" 'source_sel'="$npupt_select_source" 'anonymous'="`([ "$anonymous" = 'yes' ] && echo 1) || echo 0`" 'visible'="1" "$cookie"
}
function edit_post_nanyangpt()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id" 'name'="$dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$nanyangpt_des" 'type'="$nanyangpt_selectType" 'anonymous'="`([ "$anonymous" = 'yes' ] && echo 1) || echo 0`" 'visible'="1" 'allow_transfer'='yes' "$cookie"
}
function edit_post_byrbt()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id" 'name'="[$smallDescr_byrbt][$dot_name][$movie_type_byrbt][$movie_country_byrbt]" 'small_descr'="$subname_chs_include" 'url'="$imdbUrl" 'dburl'='' 'nfoaction'='keep' 'descr'="$byrbt_des" 'type'="$byrbt_selectType" 'secocat'="$second_type_byrbt" 'anonymous'="`([ "$anonymous" = 'yes' ] && echo 1) || echo 0`" 'visible'="1" "$cookie"
}
function edit_post_tjupt()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id" 'small_descr'="$( [ "${smallDescr_tjupt#*/}" != "$smallDescr_tjupt" ] && echo "${smallDescr_tjupt#*/} ")$( [ "$subname_chs_include" ] && echo "[$subname_chs_include]")" 'url'="$imdbUrl" 'descr'="$tjupt_des" 'type'="$selectType" 'cname'="${smallDescr_tjupt%%/*}" 'ename'="$dot_name" 'issuedate'="$issuedate_tjupt" 'language'="$language_tjupt" 'format'="$formatratio_tjupt" 'formatradio'="$formatradio_tjupt" 'subsinfo'="$subsinfo_tjupt" 'district'="$district_tjupt" "$country_tjupt"="$country_tjupt" 'source_sel'="$source_sel_tjupt" 'team_sel'="$team_sel_tjupt" 'anonymous'="`([ "$anonymous" = 'yes' ] && echo 1) || echo 0`" 'visible'="1" "$cookie"
}
#------------------------------------#
old_new_torrent_name=''
for edit_loop in `egrep -n "small_descr=$default_subname" "$log_Path" |awk -F ':' '{print $1}'`
do
    posted_name="`sed -n "$(expr $edit_loop - 1) p" "$log_Path"|awk -F '=' '{print $2}'`"
    new_torrent_name="`echo "$posted_name"|sed "s/ /./g;s/\(.*\)\.mp4/\1/g;s/\(.*\)\.mkv/\1/g"`"
    check_site="`sed -n "$(expr $edit_loop + 3) p" "$log_Path"`"        # post site
    source_site_URL="`sed -n "$(expr $edit_loop + 4) p" "$log_Path"`"   # source site
    t_id=`sed -n "$(expr $edit_loop + 5) p" "$log_Path"|awk -F '[' '{print $2}'|awk -F ']' '{print $1}'`

    if [ "$t_id" ]; then
        if [ "$new_torrent_name" != "$old_new_torrent_name" ]; then
            #---clean---#
            rm -f "$source_desc" "$source_html"
            dot_name="$(echo "$new_torrent_name"|sed "s/[ ]\+/./g;s/\(.*\)\.mp4/\1/g;s/\(.*\)\.mkv/\1/g")"
    	      source "$ROOT_PATH/get_desc/desc.sh"
            source "$ROOT_PATH/post/param.sh"
        fi

        echo $imdbUrl
        if [ "$check_site" = "https://hudbt.hust.edu.cn" ]; then
            source "$ROOT_PATH/post/hudbt.sh"
            edit_post_normal
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://whu.pt" ]; then
            source "$ROOT_PATH/post/whu.sh"
            edit_post_normal
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://npupt.com" ]; then
            source "$ROOT_PATH/post/npupt.sh"
            edit_post_npupt
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://nanyangpt.com" ]; then
            source "$ROOT_PATH/post/nanyangpt.sh"
            edit_post_nanyangpt
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://bt.byr.cn" ]; then
            source "$ROOT_PATH/post/byrbt.sh"
            edit_post_byrbt
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://tjupt.org" ]; then
            source "$ROOT_PATH/post/tjupt.sh"
            edit_post_tjupt
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        fi
    fi

    old_new_torrent_name="$new_torrent_name"
done

#------------------------------------#
#---clean---#
rm -f "$source_desc" "$source_html"
}
echo '此模块暂时不使用!'
