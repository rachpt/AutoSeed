#!/bin/bash
# FileName: post/byrbt.sh
#
# Author: rachpt@126.com
# Version: 2.3v
# Date: 2018-08-23
#
#-------------settings---------------#
cookie="$cookie_byrbt"
passkey="$passkey_byrbt"
anonymous="$anonymous_byrbt"
#---static---#
postUrl='https://bt.byr.cn/takeupload.php'
edit_postUrl='https://bt.byr.cn/takeedit.php'
site_download_url='https://bt.byr.cn/download.php?id='
#-------------------------------------#


if [ -s "$source_detail_html" ]; then
    byrbt_des="$descrCom_complex_html
    $(cat "$source_detail_html")"
else
    byrbt_des="$descrCom_complex_html
    <br /><br /><br /><strong><span style=\"font-size:30px;\">获取简介失败。无人职守！！！ 不喜勿下！ 如果帮助修改，在此非常感谢！</span></strong><br /><br />"
fi

movie_type_byrbt="$(egrep "[类分][　 ]*[别类型]" "$source_detail_desc"|head -n 1|sed "s/.*[类分][　 ]*[别类型][ 　]*//g;s/[ ]*//g;s/[\n\r]*//g")"
movie_country_byrbt="$(egrep "[国地产][　 ]*[家区地]" "$source_detail_desc"|head -n 1|sed "s/.*[国地产][　 ]*[家区地][ 　]*//g;s/,/\//g;;s/[ ]*//g;s/[\n\r]*//g")"

