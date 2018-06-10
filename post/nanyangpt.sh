#!/bin/bash
# FileName: post/nanyangpt.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings---------------#
cookie="$cookie_nanyangpt"
passkey="$passkey_nanyangpt"
anonymous="$anonymous_nanyangpt"
#---static---#
postUrl='https://nanyangpt.com/takeupload.php'
edit_postUrl='https://nanyangpt.com/takeedit.php'
site_download_url='https://nanyangpt.com/download.php?id='
#-------------------------------------#
nanyangpt_des="$(echo "$nanyangpt_des"|sed "s/&ratio_in_desc&/$ratio_nanyangpt/g")"
