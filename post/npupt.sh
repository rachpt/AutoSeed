#!/bin/bash
# FileName: post/npupt.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings---------------#
cookie="$cookie_npupt"
passkey="$passkey_npupt"
anonymous="$anonymous_npupt"
#---static---#
postUrl='https://npupt.com/takeupload.php'
edit_postUrl='https://npupt.com/takeedit.php'
site_download_url='https://npupt.com/download.php?id='
#-------------------------------------#
npupt_des="$(echo "$npupt_des"|sed "s/&ratio_in_desc&/$ratio_npupt/g")"
