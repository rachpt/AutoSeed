#!/bin/bash
# FileName: auto_post.sh
#
# Author: rachpt@126.com
# Version: 1.4v
# Date: 2018-05-21
#
#-------------settings---------------#

torrentPath="${flexget_path}${new_torrent_name}.torrent"

#-------------------------------------#
#---paramter up_status code---#
function upload_torrent()
{
    #---log---#
    echo "+++++++++++[post data]+++++++++++" >> $logoPath
    echo -e name="$name" "\n" small_descr="$smallDescr" "\n" url="$imdbUrl" "\n" type=$selectType "\n" standard_sel=$standardSel "\n" uplver="$anonymous"  >> $logoPath
    #---post---#
    t_id=''
    if [ "$up_status" = "1" ]; then
        t_id=`http --ignore-stdin -f --print=h POST $postUrl 'name'="$name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$des" 'type'="$selectType" 'standard_sel'="$standardSel" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id=" |head -n 1|cut -d '=' -f 2|cut -d '&' -f 1` 

        echo t_id: [$t_id] >> $logoPath
        # http --ignore-stdin -f POST "$postUrl" 'name'="$name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$des" 'type'="$selectType" 'standard_sel'="$standardSel" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie"  2> "${AUTO_ROOT_PATH}/http.log"
        if [ -z "$t_id" ]; then
    	    t_id=`http --ignore-stdin -f POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="$des" type="$selectType" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
    	    echo reget t_id:  [$t_id] >> $logoPath
        fi
        #---check again---#
        if [ -z "$t_id" ]; then
    	    t_id=`http --ignore-stdin -f POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="$des" type="$selectType" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
    	    echo reget t_id:  [$t_id] >> $logoPath
        fi
    	#---next step---#
        if [ -z "$t_id" ]; then
            echo "++++++++++[failed to get tID]++++++++++" >> $logoPath
        else
            #---add torrent---#
            download_url="${site_download_url}${t_id}"
            . ./auto_add.sh
        fi
    fi
}

function finish()
{
	echo "++++++++++[deleted tmp]++++++++++" >> $logoPath
    rm -f $html_page $descr_page $descr_bbcode 
}

#----------call function-----------#

if [ "$enable_hds2hudbt" = 'yes' ]; then
    . ./hds2hudbt.sh
    upload_torrent

fi
if [ "$enable_hds2whu" = 'yes' ]; then
    . ./hds2whu.sh
    upload_torrent

fi
#---clean---#
. ./auto_clean.sh
#--------------exit----------------#
finish
# trap finish EXIT
