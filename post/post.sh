#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2019-01-10
#
#---------------------------------------#
# 将简介以及种子以post方式发布
#---------------------------------------#
# import functions
source "$ROOT_PATH/get_desc/desc.sh"    # get source site
source "$ROOT_PATH/post/parameter.sh"
source "$ROOT_PATH/post/judge.sh"
#---------------------------------------#
judge_before_upload() {
    up_status='yes'    # judge code
    #---judge to get away from dupe---#
    [ "$postUrl" = "${post_site[whu]}/takeupload.php" ] && \
        judge_torrent_func # $ROOT_PATH/post/judge.sh
    [ "$postUrl" = "${post_site[nanyangpt]}/takeupload.php" ] && \
        judge_torrent_func # $ROOT_PATH/post/judge.sh
    #---necessary judge---# 
    if [ "$(grep -E '禁止转载|禁转|独占资源|情色' "$source_desc")" ]; then
        up_status='no'  # give up upload
        echo "禁转禁发资源"                      >> "$log_Path"
    fi

    my_dupe_rules     # 导入自定义规则
    unset t_id        # set t_id to none
    #---post---#
    if [[ $up_status = yes ]]; then
        #---log---#
        echo "-----------[post data]-----------" >> "$log_Path"
        echo -e "name=${dot_name}\
            \nsmall_descr=${chinese_title}\
            \nimdburl=${imdb_url}\
            \nuplver=${anonymous}\
            \n${postUrl%/*}\
            \n${source_site_URL}"                >> "$log_Path"
    fi
}

add_t_id_2_client() {        
    #---if get t_id then add it to tr---#
    [[ $up_status = yes ]] && if [[ -z $t_id ]]; then
        echo "======[failed to get tID]========" >> "$log_Path"
    else
        echo t_id: [$t_id]                       >> "$log_Path"
        #---add torrent---#
        torrent2add="${downloadUrl}${t_id}&passkey=${passkey}"
        source "$ROOT_PATH/post/add.sh"
    fi
    unset t_id
}
#---------------------------------------#
unset_tempfiles() {
    [ ! "$test_func_probe" ] && \
    rm -f "$source_desc" "$source_html" "$source_desc2tjupt"
    unset source_desc source_html source_desc2tjupt
    unset douban_poster_url source_site_URL source_t_id imdb_url
    echo "----------[deleted tmp]----------"     >> "$log_Path"
}

#-----import and call functions---------#

from_desc_get_param  # $ROOT_PATH/post/parameter.sh

if [ "$enable_hudbt" = 'yes' ]; then
    source "$ROOT_PATH/post/hudbt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && hudbt_post_func
    add_t_id_2_client
fi

if [ "$enable_whu" = 'yes' ]; then
    source "$ROOT_PATH/post/whu.sh"
    judge_before_upload
    [[ $up_status = yes ]] && whu_post_func
    add_t_id_2_client
fi

if [ "$enable_npupt" = 'yes' ]; then
    source "$ROOT_PATH/post/npupt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && npupt_post_func
    add_t_id_2_client
fi

if [ "$enable_nanyangpt" = 'yes' ]; then
    source "$ROOT_PATH/post/nanyangpt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && nanyangpt_post_func
    add_t_id_2_client
fi

if [ "$enable_byrbt" = 'yes' ]; then
    source "$ROOT_PATH/post/byrbt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && byrbt_post_func
    add_t_id_2_client
fi

if [ "$enable_cmct" = 'yes' ]; then
    source "$ROOT_PATH/post/cmct.sh"
    judge_before_upload
    [[ $up_status = yes ]] && cmct_post_func
    add_t_id_2_client
fi

if [ "$enable_tjupt" = 'yes' ]; then
    source "$ROOT_PATH/post/tjupt.sh"
    judge_before_upload
    [[ $up_status = yes ]] && tjupt_post_func
    add_t_id_2_client
fi
#---------------unset-------------------#

unset_tempfiles

#---------------------------------------#
