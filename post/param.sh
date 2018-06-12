#!/bin/bash
# FileName: post/param.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings---------------#

#-------------------------------------#
function from_desc_get_prarm()
{
    #---name---#
    no_dot_name=`echo "$new_torrent_name"|sed 's/\./ /g'|sed 's/DD2 0/DD2.0/;s/H 26/H.26/;s/5 1/5.1/;s/7 1/7.1/'`
    dot_name=`echo "$new_torrent_name"|sed 's/[ ]\+/./g'`
    #---get torrent's type---#
    
    #---hudbt & whu---#
    if [ "`egrep '[国地][　 ]+[家区][　 ]+中国大陆|[国地][　 ]+[家区][　 ]+中国' "$source_detail_desc"`" ]; then
        whu_selectType='401'
        hudbt_selectType='401'
    elif [ "`egrep '[国地][　 ]+[家区][　 ]+马来西亚|产[　 ]+地[　 ]+日本|[国地][　 ]+[家区][　 ]+日本|[国地][　 ]+[家区][　 ]+韩国|产[　 ]+地[　 ]+韩国|[国地][　 ]+[家区][　 ]+印度|[国地][　 ]+[家区][　 ]+泰国|[国地][　 ]+[家区][　 ]+伊朗' "$source_detail_desc"`" ]; then
        whu_selectType='414'
        hudbt_selectType='414'
    elif [ "`egrep '[国地][　 ]+[家区][　 ]+中国台湾|[国地][　 ]+[家区][　 ]+台湾|[国地][　 ]+[家区][　 ]+香港|[国地][　 ]+[家区][　 ]+中国香港|[国地][　 ]+[家区][　 ]+澳门' "$source_detail_desc"`" ]; then
        whu_selectType='413'
        hudbt_selectType='413'
    fi
    if [ -z "$whu_selectType" ]; then
        whu_selectType="$default_select_type_whu"
    fi
    
    #---hudbt & whu ipad---#
    case "$new_torrent_name" in
        *[Ii][Pp][Aa][Dd]*)
            hudbt_selectType='430' 
            whu_standardSel='9'
            case "$new_torrent_name" in
                *720[Pp]*)
                    hudbt_standardSel='3' ;;
               	*1080[Pp]*)
                   	hudbt_standardSel='1' ;;
               	*)
               	    hudbt_standardSel="$default_standard_hudbt" ;;
            esac
            ;;
        *)
            if [ -z "$hudbt_selectType" ]; then
                hudbt_selectType="$default_select_type_hudbt"
            fi
            case "$new_torrent_name" in
                *720[Pp]*)
                    hudbt_standardSel='3'
               	    whu_standardSel='3'
               	    ;;
               	*1080[Pp]*)
                   	hudbt_standardSel='1'
               	    whu_standardSel='1'
               	    ;;
               	*)
               	    hudbt_standardSel="$default_standard_hudbt"
               	    whu_standardSel="$default_standard_whu"
               	    ;;
            esac
            ;;
    esac
	#---纪录片---#
	if [ "`egrep '类[　 ]+别[　 ]+纪录片' "$source_detail_desc"`" ]; then
        nanyangpt_selectType='406'
        npupt_selectType='404'
        hudbt_selectType='404'
        whu_selectType='404'
        # other site
    else
        nanyangpt_selectType="$default_select_type_nanyangpt"
        npupt_selectType="$default_select_type_npupt"
    fi
    
    #---npupt source---#
    if [ "`egrep '[国地][　 ]+[家区][　 ]+大陆|[国地][　 ]+[家区][　 ]+中国|[国地][　 ]+[家区][　 ]+台湾|[国地][　 ]+[家区][　 ]+香港' "$source_detail_desc"`" ]; then
        npupt_select_source='6'
    elif [ "`egrep '产[　 ]+地[　 ]+日本|[国地][　 ]+[家区][　 ]+日本|[国地][　 ]+[家区][　 ]+韩国|产[　 ]+地[　 ]+韩国' "$source_detail_desc"`" ]; then
        npupt_select_source='4'
    fi
    if [ -z "$select_source" ]; then
        npupt_select_source="$default_standard_npupt" #7
    fi

    #---imdb---#
    if [ -z "$imdbUrl" ]; then
        imdbUrl="$default_imdb_url"
    fi

    #---subtitle---#
    if [ "`egrep '[　 ]+中国大陆' $source_detail_desc`" ]; then
        smallDescr="`echo "$subname_2"` $subname_chs_include"
    else
        if [ "$subname_1" ]; then
             smallDescr="`echo "$subname_1"` $subname_chs_include"
        elif [ "$subname_2" ]; then
             smallDescr="`echo "$subname_2"` $subname_chs_include"
        else
            smallDescr="$default_subname"
        fi
    fi

    #---join desc---#
    if [ -s "$source_detail_desc" ]; then
        simple_des="${descrCom_simple}
        `cat "$source_detail_desc"`"
        
        complex_des="${descrCom_complex}
        `cat "$source_detail_desc"`"

    else
        simple_des="${descrCom_simple}
        $failed_to_get_des"
        
        complex_des="${descrCom_complex}
        $failed_to_get_des"
    fi 
        nanyangpt_des="$simple_des"
        npupt_des="$simple_des"    
#        hudbt_des="$complex_des"
#        whu_des="$complex_des"       
}
#-------------------------------#
from_desc_get_prarm
