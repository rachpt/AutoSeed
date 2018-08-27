#!/bin/bash
# FileName: post/post.sh
#
# Author: rachpt@126.com
# Version: 2.3v
# Date: 2018-08-22
#
#---get desc---#
source "$AUTO_ROOT_PATH/get_desc/desc.sh"
source "$AUTO_ROOT_PATH/post/param.sh"
#-------------------------------------#
upload_torrent()
{
    up_status=1    # judge code
    #---judge to get away from dupe---#
    [ "$postUrl" = "https://whu.pt/takeupload.php" ] && source "$AUTO_ROOT_PATH/post/judge.sh"
    [ "$postUrl" = "https://nanyangpt.com/takeupload.php" ] && source "$AUTO_ROOT_PATH/post/judge.sh"
    #---necessary judge---# 
    if [ "$(egrep '禁止转载|禁转|情色' "$source_detail_desc")" ]; then
        up_status=0  # give up upload
        echo "禁转禁发资源" >> "$log_Path"
    fi
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

        #---byrbt post---#
        elif [ "$postUrl" = "https://bt.byr.cn/takeupload.php" ]; then
            t_id=`http --ignore-stdin -f --print=h POST "$postUrl" 'movie_cname'="$smallDescr_byrbt" 'ename0day'="$dot_name"  'type'="$byrbt_selectType" 'small_descr'="$subname_chs_include" 'url'="$imdbUrl" 'descr'="$byrbt_des" 'type'="$byrbt_selectType" 'second_type'="$second_type_byrbt" 'movie_type'="$movie_type_byrbt" 'movie_country'="$movie_country_byrbt" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id="|grep 'detail'|head -n 1|cut -d '=' -f 2|cut -d '&' -f 1`

            if [ -z "$t_id" ]; then
    	        t_id=`http --ignore-stdin -f POST "$postUrl" movie_cname="$smallDescr_byrbt" ename0day="$dot_name" small_descr="$subname_chs_include" url="$imdbUrl" type="$byrbt_selectType" descr="$byrbt_des" type="$byrbt_selectType" second_type="$second_type_byrbt" movie_type="$movie_type_byrbt" movie_country="$movie_country_byrbt" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
            fi
            
        #---cmct post---#
        elif [ "$postUrl" = "https://hdcmct.org/takeupload.php" ]; then
            t_id=`http --ignore-stdin -f --print=h POST "$postUrl" 'name'="$dot_name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$cmct_des" 'type'="$selectType" 'medium_sel'="$medium_sel_cmct" 'codec_sel'="$codec_sel_cmct" 'standard_sel'="$standardSel" 'source_sel'="$source_sel_cmct" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id=" |grep 'detail'|head -n 1|cut -d '=' -f 2|cut -d '&' -f 1`

            if [ -z "$t_id" ]; then
    	        t_id=`http --ignore-stdin -f POST "$postUrl" name="$dot_name" small_descr="$smallDescr" url="$imdbUrl" descr="$cmct_des" type="$selectType" medium_sel="$medium_sel_cmct" codec_sel="$codec_sel_cmct" standard_sel="$standardSel" source_sel="$source_sel_cmct" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
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
    unset t_id
}
#---------------------------------#
unset_tempfiles()
{
    rm -f "$source_detail_desc" "$source_detail_html"
    unset source_detail_desc source_detail_html
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

if [ "$enable_byrbt" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/byrbt.sh"
    upload_torrent
fi

if [ "$enable_cmct" = 'yes' ]; then
    source "$AUTO_ROOT_PATH/post/cmct.sh"
    upload_torrent
fi
#-------------unset---------------#
unset_tempfiles

