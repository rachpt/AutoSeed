#!/bin/bash
# FileName: post/whu.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings---------------#
cookie="$cookie_whu"
passkey="$passkey_whu"
anonymous="$anonymous_whu"
#---static---#
postUrl='https://pt.whu.edu.cn/takeupload.php'
edit_postUrl='https://pt.whu.edu.cn/takeedit.php'
site_download_url='https://pt.whu.edu.cn/download.php?id='
#-------------------------------------#
selectType="$whu_selectType"
standardSel="$whu_standardSel"
com_des="$(echo "$complex_des"|sed "s/&ratio_in_desc&/$ratio_whu/g")"
