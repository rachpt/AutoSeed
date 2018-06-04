#!/bin/bash
# FileName: auto_post.sh
#
# Author: rachpt@126.com
# Version: 1.6v
# Date: 2018-06-04
#
#-------------settings---------------#

torrentPath="${flexget_path}/${new_torrent_name}.torrent"

#-------------------------------------#
#---paramter up_status code---#
function upload_torrent()
{
    #---log---#
    echo "+++++++++++[post data]+++++++++++" >> $log_Path
    echo -e "name=${name}\nsmall_descr=${smallDescr}\nurl=${imdbUrl}\ntype=${selectType}\nstandard_sel=${standardSel}\nuplver=${anonymous}\n${postUrl%/*}" >> $log_Path

    #---post---#
    t_id=''
    if [ "$up_status" = "1" ]; then
        t_id=`http --ignore-stdin -f --print=h POST $postUrl 'name'="$name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$des" 'type'="$selectType" 'standard_sel'="$standardSel" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id=" |head -n 1|cut -d '=' -f 2|cut -d '&' -f 1` 
        
        if [ -z "$t_id" ]; then
    	    t_id=`http --ignore-stdin -f POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="$des" type="$selectType" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
        fi
        #---check again---#
        if [ -z "$t_id" ]; then
    	    t_id=`http --ignore-stdin -f POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="$des" type="$selectType" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
        fi
    	#---next step---#
        if [ -z "$t_id" ]; then
            echo "++++++[failed to get tID]++++++++" >> $log_Path
        else
            echo t_id: [$t_id] >> $log_Path
            #---add torrent---#
            download_url="${site_download_url}${t_id}"
            source "$AUTO_ROOT_PATH/auto_add.sh"
        fi
    fi
}
#---------------------------------#
function finish()
{
    echo "++++++++++[deleted tmp]++++++++++" >> $log_Path
    rm -f $html_page $descr_page $descr_bbcode 
    descr_bbcode=''
    descr_page=''
    html_page=''
}

#----------call function-----------#

if [ "$enable_hds2hudbt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/hds2hudbt.sh"
    upload_torrent
fi

if [ "$enable_hds2whu" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/hds2whu.sh"
    upload_torrent
fi

#--------------exit----------------#
finish
# trap finish EXIT
