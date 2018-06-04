#!/bin/bash
# FileName: edit.sh
#
# Author: rachpt@126.com
# Version: 1.6v
# Date: 2018-06-04
#
#------------------------------------#
AUTO_ROOT_PATH='/home/rachpt/shell/auto'
source /etc/profile
source ~/.bashrc
source ~/.profile

if [ -z "$log_Path"]; then
    source "$AUTO_ROOT_PATH/settings.sh"
fi
#----------------post----------------#
function edit_post()
{
    http --ignore-stdin -f POST $edit_postUrl 'id'="$t_id"  'name'="$name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$des" 'type'="$selectType" 'standard_sel'="$standardSel" 'visible'="1" "$cookie"

}
#------------------------------------#
for edit_loop in `egrep -n "small_descr=$default_subname_whu|small_descr=$default_subname_hudbt" $log_Path |awk -F : '{print $1}'`
do
    name=`sed -n "$(expr $edit_loop - 1) p" $log_Path|awk -F '=' '{print $2}'`
    new_torrent_name=`echo "$name"|sed 's/ /./g'`
    check_site="`sed -n "$(expr $edit_loop + 5) p" $log_Path`"
    t_id=`sed -n "$(expr $edit_loop + 6) p" $log_Path|awk -F '[' '{print $2}'|awk -F ']' '{print $1}'`

    if [ "$t_id" ]; then
        source "$AUTO_ROOT_PATH/hds_desc.sh"
        echo $imdbUrl 
        if [ "$check_site" = "https://hudbt.hust.edu.cn" ]; then
            source "$AUTO_ROOT_PATH/hds2hudbt.sh"
            edit_post
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://pt.whu.edu.cn" ]; then
            source "$AUTO_ROOT_PATH/hds2whu.sh"
            edit_post
            echo "$default_subname" "$smallDescr"
            sed -i "${edit_loop}s#$default_subname#$smallDescr#" "$log_Path"
        fi 
    fi
    
    #---clean---#    
    rm -f $html_page $descr_page $descr_bbcode 
    descr_bbcode=''
    descr_page=''
    html_page=''
    new_torrent_name=''
done

#------------------------------------#

