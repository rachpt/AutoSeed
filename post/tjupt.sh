#!/bin/bash
# FileName: post/tjupt.sh
#
# Author: rachpt@126.com
# Version: 2.3v
# Date: 2018-08-28
#
#-------------settings---------------#
cookie="$cookie_tjupt"
passkey="$passkey_tjupt"
anonymous="$anonymous_tjupt"
#---static---#
postUrl='https://tjupt.org/takeupload.php'
edit_postUrl='https://tjupt.org/takeedit.php'
site_download_url='https://tjupt.org/download.php?id='
#-------------------------------------#
selectType="$tjupt_selectType"
[ ! "$team_sel_tjupt" ] && team_sel_tjupt="$default_team_sel_tjupt"
[ ! "$subsinfo_tjupt" ] && subsinfo_tjupt="$default_subsinfo_tjupt"
tjupt_des="$(echo "$simple_des"|sed "s/&ratio_in_desc&/$ratio_tjupt/g")"

smallDescr_tjupt="$smallDescr_byrbt"

#---tjupt date---#
issuedate_tjupt="$(echo "$dot_name"|egrep -o '[12][089][0-9]{2}'|sed '/1080/d'|tail -n 1)"
#---tjupt format ratio---#
formatratio_tjupt="$(echo "$dot_name"|egrep -io '720p|1080p')"
#---tjupt source sel---#
if [ "$(echo "$dot_name"|egrep -i 'blu[-]*ray|bdrip')" ]; then
    source_sel_tjupt='1'
elif [ "$(echo "$dot_name"|egrep -i 'hdtv')" ]; then
    source_sel_tjupt='4'
elif [ "$(echo "$dot_name"|egrep -i 'web[-]*dl')" ]; then
    source_sel_tjupt='7'
else
    source_sel_tjupt="$default_source_sel_tjupt"
fi
#---tjupt language---#
language_tjupt="$(egrep "[语][　 ]*[言]" "$source_detail_desc"|head -n 1|sed "s/.*[语][　 ]*[言][ 　]*//g;s/[ ]*//g;s/[\n\r]*//g")"

district_tjupt="$movie_country_byrbt"
#---country---#
if [ "$(echo "$district_tjupt"|grep '香港')" ]; then
    country_tjupt='香港'
elif [ "$(echo "$district_tjupt"|grep '台湾')" ]; then
    country_tjupt='台湾'
elif [ "$(echo "$district_tjupt"|egrep '中国|大陆')" ]; then
    country_tjupt='大陆'
elif [ "$(echo "$district_tjupt"|grep '日本')" ]; then
    country_tjupt='日本'
elif [ "$(echo "$district_tjupt"|grep '韩国')" ]; then
    country_tjupt='韩国'
elif [ "$(echo "$district_tjupt"|grep '美国')" ]; then
    country_tjupt='美国'
elif [ "$(echo "$district_tjupt"|grep '英国')" ]; then
    country_tjupt='英国'
elif [ "$(echo "$district_tjupt"|grep '法国')" ]; then
    country_tjupt='法国'
elif [ "$(echo "$district_tjupt"|grep '德国')" ]; then
    country_tjupt='德国'
elif [ "$(echo "$district_tjupt"|grep '澳大利亚')" ]; then
    country_tjupt='澳大利亚'
elif [ "$(echo "$district_tjupt"|grep '墨西哥')" ]; then
    country_tjupt='北美'
elif [ "$(echo "$district_tjupt"|grep '加拿大')" ]; then
    country_tjupt='北美'
else
    country_tjupt='其他'
fi

