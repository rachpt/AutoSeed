#!/bin/bash
# FileName: edit.sh
#
# Author: rachpt@126.com
# Version: 2.1v
# Date: 2018-06-15
#
#------------------------------------#
if [ -z "$log_Path"]; then
    AUTO_ROOT_PATH="$(dirname "$(readlink -f "$0")")"
    source "$AUTO_ROOT_PATH/settings.sh"
fi
#----------------post----------------#
function edit_post_normal()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id"  'name'="$no_dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$complex_des" 'type'="$selectType" 'standard_sel'="$standardSel" 'visible'="1" "$cookie"
}
function edit_post_npupt()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id"  'name'="$dot_name" 'small_descr'="$smallDescr" 'nfoaction'='keep' 'descr'="$npupt_des" 'type'="$npupt_selectType" 'source_sel'="$npupt_select_source" 'visible'="1" "$cookie"
}
function edit_post_nanyangpt()
{
    http --ignore-stdin -f POST "$edit_postUrl" 'id'="$t_id"  'name'="$dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$nanyangpt_des" 'type'="$nanyangpt_selectType" 'visible'="1" "$cookie"
}

#------------------------------------#
for edit_loop in `egrep -n "small_descr=$default_subname" "$log_Path" |awk -F ':' '{print $1}'`
do
    posted_name="`sed -n "$(expr $edit_loop - 1) p" "$log_Path"|awk -F '=' '{print $2}'`"
    new_torrent_name="`echo "$posted_name"|sed 's/ /./g'`"
    check_site="`sed -n "$(expr $edit_loop + 3) p" "$log_Path"`"        # post site
    source_site_URL="`sed -n "$(expr $edit_loop + 4) p" "$log_Path"`"   # source site
    t_id=`sed -n "$(expr $edit_loop + 5) p" "$log_Path"|awk -F '[' '{print $2}'|awk -F ']' '{print $1}'`

    if [ "$t_id" ]; then
    	source "$AUTO_ROOT_PATH/get_desc/detail_page.sh"
	    source "$AUTO_ROOT_PATH/post/param.sh"

        echo $imdbUrl
        if [ "$check_site" = "https://hudbt.hust.edu.cn" ]; then
            source "$AUTO_ROOT_PATH/post/hudbt.sh"
            echo "$edit_postUrl" 'id'="$t_id"  'name'="$no_dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$complex_des" 'type'="$selectType" 'standard_sel'="$standardSel" 'visible'="1" "$cookie"
            edit_post_normal
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://pt.whu.edu.cn" ]; then
            source "$AUTO_ROOT_PATH/post/whu.sh"
            edit_post_normal
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://npupt.com" ]; then
            source "$AUTO_ROOT_PATH/post/npupt.sh"
            edit_post_npupt
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://nanyangpt.com" ]; then
            source "$AUTO_ROOT_PATH/post/nanyangpt.sh"
            edit_post_nanyangpt
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        fi 
    fi
    
    #---clean---#    
    rm -f "$hds_rss_desc" "$hds_rss_html" "$source_detail_page" "$source_detail_desc"
    new_torrent_name=''
    source_site_URL=''
    source_detail_desc=''
    source_detail_page=''
done

#------------------------------------#

