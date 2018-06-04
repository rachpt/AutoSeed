#!/bin/bash
# FileName: hds2hudbt.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-23
#
#-------------settings---------------#
default_name="$default_name_hudbt"
default_subname="$default_subname_hudbt"
descrCom="$descrCom"
failed_to_get_des="$failed_to_get_des_hudbt"
default_standard="$default_standard_hudbt"
default_select_type="$default_select_type_hudbt"
default_imdb_url="$default_imdb_url_hudbt"
cookie="$cookie_hudbt"
passkey="$passkey_hudbt"
anonymous="$anonymous_hudbt"
#---static---#
postUrl='https://hudbt.hust.edu.cn/takeupload.php'
edit_postUrl='https://hudbt.hust.edu.cn/takeedit.php'
site_download_url='https://hudbt.hust.edu.cn/download.php?id='
#-------------------------------------#
source "$AUTO_ROOT_PATH/hds_desc.sh"

#-------------------------------------#
function get_info_hudbt()
{
	#---get torrent's type---#
    case "$name" in
        *iPad*)
            selectType='430' ;;
        *ipad*)
            selectType='430' ;;
        *)
            selectType="$default_select_type"  ;;
    esac
    
    #---get torrent's standard---#
    case "$name" in
        *720p*)
            standardSel='3' ;;
        *1080p*)
            standardSel='1' ;;
        *)
            standardSel="$default_standard"  ;;
    esac
    
    #---imdb---#
    if [ -z "$imdbUrl" ]; then
        imdbUrl="$default_imdb_url"
    fi
        
    #---join descr---#
    if [ -s "$descr_bbcode" ]; then
        des="${descrCom}
        `cat $descr_bbcode`"
    else
        des="${descrCom}
        ${failed_to_get_des}"
    fi

    #---subtitle---#
    if [ "`grep '　中国大陆' $descr_page`" ]; then
        smallDescr="`echo $name_2` $chs_include"
    else
        if [ "$name_1" ]; then
            smallDescr="`echo $name_1` $chs_include"
        elif [ "$name_2" ]; then
            smallDescr="`echo $name_2` $chs_include"
        else
            smallDescr="$default_subname"
        fi
    fi
}
#-------------------------------------#
get_info_hudbt
