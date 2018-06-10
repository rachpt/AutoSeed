#!/bin/bash
# FileName: post/hudbt.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings---------------#
cookie="$cookie_hudbt"
passkey="$passkey_hudbt"
anonymous="$anonymous_hudbt"
#---static---#
postUrl='https://hudbt.hust.edu.cn/takeupload.php'
edit_postUrl='https://hudbt.hust.edu.cn/takeedit.php'
site_download_url='https://hudbt.hust.edu.cn/download.php?id='
#-------------------------------------#
selectType="$hudbt_selectType"
standardSel="$hudbt_standardSel"
com_des="$(echo "$complex_des"|sed "s/&ratio_in_desc&/$ratio_hudbt/g")"
