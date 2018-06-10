#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings---------------#
torrentPath="${flexget_path}/${new_torrent_name}.torrent"
#---get desc---#
source "$AUTO_ROOT_PATH/get_desc/detail_page.sh"
source "$AUTO_ROOT_PATH/post/param.sh"
#-------------------------------------#
function upload_torrent()
{
    up_status=1    # judge code
    #---judge to get away from dupe---#
    source "$AUTO_ROOT_PATH/post/judge.sh"
    t_id=''        # set t_id to none
    #---post---#
    if [ "$up_status" = "1" ]; then
        #---log---#
        echo "+++++++++++[post data]+++++++++++" >> "$log_Path"
        echo -e "name=${dot_name}\nsmall_descr=${smallDescr}\nimdburl=${imdbUrl}\nuplver=${anonymous}\n${postUrl%/*}\n${source_site_URL}" >> "$log_Path"
        #---npupt post---#
        if [ "$postUrl" = "https://npupt.com/takeupload.php" ]; then
            #---base64 encode---#
            des_enc="`echo "$npupt_des"|base64`"
            name_enc="`echo "$dot_name"|base64`"
            sub_title_enc="`echo "$smallDescr"|base64`"
            #---post data---#
            t_id=`http --ignore-stdin -f --print=h POST "$postUrl" 'name'="$name_enc" 'small_descr'="$sub_title_enc" 'descr'="$des_enc" 'type'="$npupt_selectType" 'source_sel'="$npupt_select_source" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id=" |grep 'detail'|head -n 1|cut -d '=' -f 2|cut -d '&' -f 1` 
        
            if [ -z "$t_id" ]; then
    	        t_id=`http --ignore-stdin -f POST "$postUrl" name="$name_enc" small_descr="$sub_title_enc" descr="$des_enc" type="$npupt_selectType" source_sel="$npupt_select_source" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
            fi

        #---nanyangpt post---#
        elif [ "$postUrl" = "https://nanyangpt.com/takeupload.php" ]; then
            t_id=`http --ignore-stdin -f --print=h POST "$postUrl" 'name'="$dot_name" 'movie_enname'="$dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$nanyangpt_des" 'type'="$nanyangpt_selectType" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id="|grep 'detail'|head -n 1|cut -d '=' -f 2|cut -d '&' -f 1` 
            
            if [ -z "$t_id" ]; then
    	        t_id=`http --ignore-stdin -f POST "$postUrl" name="$dot_name" movie_enname="$dot_name" small_descr="$smallDescr" url="$imdbUrl" descr="$nanyangpt_des" type="$nanyangpt_selectType" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
            fi

        #---momel moduel post, hudbt & whu---#
        else
            t_id=`http --ignore-stdin -f --print=h POST "$postUrl" 'name'="$no_dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$com_des" 'type'="$selectType" 'standard_sel'="$standardSel" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id=" |grep 'detail'|head -n 1|cut -d '=' -f 2|cut -d '&' -f 1` 
        
            if [ -z "$t_id" ]; then
    	        t_id=`http --ignore-stdin -f POST "$postUrl" name="$no_dot_name" small_descr="$smallDescr" url="$imdbUrl" descr="$com_des" type="$selectType" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
            fi

        fi
    	#---if get t_id then add it to tr---#
        if [ -z "$t_id" ]; then
            echo "++++++[failed to get tID]++++++++" >> "$log_Path"
        else
            echo t_id: [$t_id] >> "$log_Path"
            #---add torrent---#
            download_url="${site_download_url}${t_id}"
            source "$AUTO_ROOT_PATH/post/add.sh"
        fi
    fi
    t_id=''
}
#---------------------------------#
function unset_tempfiles()
{
    rm -f "$hds_rss_desc" "$hds_rss_html" "$source_detail_page" "$source_detail_desc"
    hds_rss_html=''
    hds_rss_desc=''
    source_detail_desc=''
    source_detail_page=''
    source_site_URL=''
    echo "++++++++++[deleted tmp]++++++++++" >> "$log_Path"
}

#----------call function-----------#
if [ "$enable_hudbt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/hudbt.sh"
    upload_torrent
fi

if [ "$enable_whu" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/whu.sh"
    upload_torrent
fi

if [ "$enable_npupt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/npupt.sh"
    upload_torrent
fi

if [ "$enable_nanyangpt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/nanyangpt.sh"
    upload_torrent
fi

#-------------unset---------------#
unset_tempfiles

