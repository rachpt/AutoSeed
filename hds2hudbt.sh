#!/bin/bash
# FileName: hds2hudbt.sh
#
# Author: rachpt@126.com
# Version: 1.4v
# Date: 2018-05-21
#
#-------------settings---------------#
default_name="$default_name_hudbt"
default_subname="$default_subname_hudbt"
descrCom="$descrCom"
failed_to_get_des="$failed_to_get_des_hudbt"
default_standard="$default_standard_hudbt"
default_select_type="$default_select_type_hudbt"
cookie="$cookie_hudbt"
passkey="$passkey_hudbt"
ratio="$ratio_hudbt"
anonymous="$anonymous_hudbt"
#---static---#
postUrl='https://hudbt.hust.edu.cn/takeupload.php'
site_download_url='https://hudbt.hust.edu.cn/download.php?id='
#-------------------------------------#
. ./hds_desc.sh

#-------------------------------------#
function get_type_std()
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
}

get_type_std