#!/bin/bash
# FileName: post/cmct.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-10-23
#
#-------------settings---------------#
cookie="$cookie_cmct"
passkey="$passkey_cmct"
anonymous="$anonymous_cmct"
#---static---#
postUrl='https://hdcmct.org/takeupload.php'
edit_postUrl='https://hdcmct.org/takeedit.php'
site_download_url='https://hdcmct.org/download.php?id='
#-------------------------------------#
selectType="$cmct_selectType"
cmct_des="$(echo "${cmct_des}"|sed "s/&ratio_in_desc&/${ratio_cmct}/g")"
codec_sel_cmct="$default_codec_sel_cmct"

#-------------------------------------#
if [ "$dot_name" = ".*HDSPad*" ]; then
    medium_sel_cmct='7'
else
    medium_sel_cmct="$default_medium_sel_cmct"
fi

if [ ! "$source_sel_cmct" ]; then
    source_sel_cmct="$default_source_sel_cmct"
fi

if [ "$dot_name" = ".*720p*" ]; then
    standardSel='4'
elif [ "$dot_name" = ".*1080p*" ]; then
    standardSel='2'
else
    standardSel="$default_standard_sel_cmct"
fi


t_id=$(http --ignore-stdin -f --print=h POST "$postUrl"\
    'name'="$dot_name"\
    'small_descr'="$smallDescr"\
    'url'="$imdbUrl"\
    'descr'="$cmct_des"\
    'type'="$selectType"\
    'medium_sel'="$medium_sel_cmct"\
    'codec_sel'="$codec_sel_cmct"\
    'standard_sel'="$standardSel"\
    'source_sel'="$source_sel_cmct"\
    'uplver'="$anonymous"\
    file@"${torrentPath}"\
    "$cookie"|grep 'id='|grep 'detail'|head -1|cut -d '=' -f 2|cut -d '&' -f 1)

if [ -z "$t_id" ]; then
    t_id=`http --ignore-stdin -f POST "$postUrl" name="$dot_name" small_descr="$smallDescr" url="$imdbUrl" descr="$cmct_des" type="$selectType" medium_sel="$medium_sel_cmct" codec_sel="$codec_sel_cmct" standard_sel="$standardSel" source_sel="$source_sel_cmct" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
fi

