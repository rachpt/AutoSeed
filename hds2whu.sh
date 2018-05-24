#!/bin/bash
# FileName: hds2whu.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-23
#
#-------------settings---------------#
default_name="$default_name_whu"
default_subname="$default_subname_whu"
descrCom="$descrCom"
failed_to_get_des="$failed_to_get_des_whu"
default_standard="$default_standard_whu"
default_select_type="$default_select_type_whu"
default_imdb_url="$default_imdb_url_whu"
cookie="$cookie_whu"
passkey="$passkey_whu"
anonymous="$anonymous_whu"
#---static---#
postUrl='https://pt.whu.edu.cn/takeupload.php'
edit_postUrl='https://pt.whu.edu.cn/takeedit.php'
site_download_url='https://pt.whu.edu.cn/download.php?id='
#-------------------------------------#
. ./hds_desc.sh

#-------------------------------------#
function get_info_whu()
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

    #---ytpe---#
    selectType=''
    if [ "`egrep '国　　家　中国大陆|地　　区　中国' $descr_page`" ]; then
        selectType='401'
    fi
    if [ "`egrep '国　　家　马来西亚|产　　地　日本|地　　区　日本|国　　家　日本|国　　家　韩国|产　　地　韩国|国　　家　印度' $descr_page`" ]; then
        selectType='414'
    fi
    if [ "`egrep '国　　家　中国台湾|国　　家　香港|国　　家　中国香港|地　　区　中国香港' $descr_page`" ]; then
        selectType='413'
    fi
    if [ -z "$selectType" ]; then
        selectType="$default_select_type"
    fi

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
        smallDescr="$name_2 $chs_include"
    else
        if [ "$name_1" ]; then
             smallDescr="$name_1 $chs_include"
        elif [ "$name_2" ]; then
             smallDescr="$name_2 $chs_include"
        else
            smallDescr="$default_subname"
        fi
    fi
       
}
#------#
get_info_whu
