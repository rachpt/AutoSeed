#!/bin/bash
# FileName: edit.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-24
#
#------------------------------------#
if [ -z "$log_Path"]; then
    . ./settings.sh
fi
#----------------post----------------#
function edit_post()
{
    http --ignore-stdin -f POST $edit_postUrl 'id'="$t_id"  'name'="$name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'nfoaction'='keep' 'descr'="$des" 'type'="$selectType" 'standard_sel'="$standardSel" 'visible'="1" "$cookie"

}
#------------------------------------#
for edit_look in `egrep -n "small_descr=$default_subname_whu|small_descr=$default_subname_hudbt" $log_Path |awk -F : '{print $1}'`
do
    name=`sed -n "$(expr $edit_look - 1) p" $log_Path|awk -F '=' '{print $2}'`
    new_torrent_name=`echo "$name"|sed 's/ /./g'`
    check_site="`sed -n "$(expr $edit_look + 5) p" $log_Path`"
    t_id=`sed -n "$(expr $edit_look + 6) p" $log_Path|awk -F '[' '{print $2}'|awk -F ']' '{print $1}'`

    if [ "$t_id" ]; then
        . ./hds_desc.sh
        
        if [ "$check_site" = "https://hudbt.hust.edu.cn" ]; then
            . ./hds2hudbt.sh
            edit_post
            sed -i "${edit_look} s#$default_subname#$smallDescr#" "$log_Path"
        elif [ "$check_site" = "https://pt.whu.edu.cn" ]; then
            . ./hds2whu.sh
            edit_post
            sed -i "${edit_look} s#$default_subname#$smallDescr#" "$log_Path"
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

