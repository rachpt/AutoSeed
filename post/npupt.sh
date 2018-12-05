#!/bin/bash
# FileName: post/npupt.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-05
#
#-------------settings---------------#
cookie="$cookie_npupt"
passkey="$passkey_npupt"
anonymous="$anonymous_npupt"
#---static---#
postUrl="${post_site[npupt]}/takeupload.php"
editUrl="${post_site[npupt]}/takeedit.php"
downloadUrl="${post_site[npupt]}/download.php?id="
#-------------------------------------#
# 需要的参数
npupt_des="$(echo "$descrCom_simple"|sed "s/&ratio_in_desc&/$ratio_npupt/g")
$(cat "$source_detail_desc")"




#---base64 encode---#
des_enc="$(echo "$npupt_des"|base64)"
name_enc="$(echo "$dot_name"|base64)"
sub_title_enc="$(echo "$smallDescr"|base64)"
#---post data---#
t_id=$(http --ignore-stdin -f --print=h POST "$postUrl"\
    'name'="$name_enc"\
    'small_descr'="$sub_title_enc"\
    'descr'="$des_enc"\
    'type'="$npupt_selectType"\
    'source_sel'="$npupt_select_source"\
    'uplver'="$anonymous_npupt"\
    file@"${torrent_Path}"\
    "$cookie_npupt"|grep 'id='|grep 'detail'|head -1|cut -d '=' -f 2|cut -d '&' -f 1)

if [ -z "$t_id" ]; then
    t_id=`http --ignore-stdin -f POST "$postUrl" name="$name_enc" small_descr="$sub_title_enc" descr="$des_enc" type="$npupt_selectType" source_sel="$npupt_select_source" uplver="$anonymous" file@"$torrent_Path" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
fi
