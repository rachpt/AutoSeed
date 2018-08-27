#!/bin/bash
# FileName: post/cmct.sh
#
# Author: rachpt@126.com
# Version: 2.3v
# Date: 2018-07-28
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
