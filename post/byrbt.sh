#!/bin/bash
# FileName: post/byrbt.sh
#
# Author: rachpt@126.com
# Version: 2.2v
# Date: 2018-06-17
#
#-------------settings---------------#
cookie="$cookie_byrbt"
passkey="$passkey_byrbt"
anonymous="$anonymous_byrbt"
#---static---#
postUrl='https://bt.byr.cn/takeupload.php'
edit_postUrl='https://bt.byr.cn/takeedit.php'
site_download_url='https://bt.byr.cn/download.php?id='
upload_pic_URL='https://bt.byr.cn/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images'
#-------------------------------------#

deal_with_byrbt_images()
{
    img_counter_bytbt=0
    while true; do
        img_in_desc_url="$(egrep -o "src=[\"\']http[^\'\"]+" "$source_detail_html"|sed "/bt\.byr\.cn/d"|head -n 1|sed "s/src=[\"\']//g")"
        if [ ! "$img_in_desc_url" ]; then
            break # jump out
        elif [ $img_counter_bytbt -gt 40 ]; then
            break # jump out
        fi
        tmp_desc_img_file="$AUTO_ROOT_PATH/tmp/${img_in_desc_url##*/}"
        http --ignore-stdin -dco "$tmp_desc_img_file" "$img_in_desc_url" >/dev/null 2>&1

        byr_upload_img_url="$(http -f POST "$upload_pic_URL" upload@"$tmp_desc_img_file" "$cookie_byrbt"|egrep -o "http[-a-zA-Z0-9./:()]+images[-a-zA-Z0-9./:(_ )]+[^''\"]*" |sed "s/http:/https:/g")"  # byrbt
        sed -i "s#$img_in_desc_url#$byr_upload_img_url#g" "$source_detail_html" # byrbt
        rm -f "$tmp_desc_img_file"
        img_in_desc_url=''
        tmp_desc_img_file=''
        img_counter_bytbt=`expr $img_counter_bytbt + 1`
    done

}

#-------------------------------------#

deal_with_byrbt_images

if [ -s "$source_detail_html" ]; then
    byrbt_des="$descrCom_complex_html
    `cat "$source_detail_html"`"
else
    byrbt_des="$descrCom_complex_html
    <br /><br /><br /><strong>获取简介失败, 稍后编辑。</strong><br /><br />"
fi

movie_type_byrbt="$(egrep "[类分][　 ]*[别类]" "$source_detail_desc"|sed "s/.*[类分][　 ]*[别类][ 　]*//g;s/[ ]*//g;s/[\n\r]*//g")"
movie_country_byrbt="$(egrep "[国地产][　 ]*[家区地]" "$source_detail_desc"|sed "s/.*[国地产][　 ]*[家区地][ 　]*//g;s/,/\//g;;s/[ ]*//g;s/[\n\r]*//g")"

