#!/bin/bash
# FileName: hds2whu.sh
#
# Author: rachpt@126.com
# Version: 1.4v
# Date: 2018-05-21
#
#-------------settings---------------#
default_name="$default_name_whu"
default_subname="$default_subname_whu"
descrCom="$descrCom"
failed_to_get_des="$failed_to_get_des_whu"
default_standard="$default_standard_whu"
default_select_type="$default_select_type_whu"
cookie="$cookie_whu"
passkey="$passkey_whu"
ratio="$ratio_whu"
anonymous="$anonymous_whu"
#---static---#
postUrl='https://pt.whu.edu.cn/takeupload.php'
site_download_url='https://pt.whu.edu.cn/download.php?id='
#-------------------------------------#
. ./hds_desc.sh

#-------------------------------------#
function get_type_std()
{
    #---get torrent's standard---#
    case "$name" in
        *iPad*)
            standardSel='9' ;;
        *ipad*)
            standardSel='9' ;;
        *)
            case "$name" in
		        *720p*)
		            standardSel='3' ;;
		        *1080p*)
		            standardSel='1' ;;
		        *)
		            standardSel="$default_standard"  ;;
		    esac
    esac
}
#------#
selectType="$default_select_type"
get_type_std