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

delete_screenshots_img()
{
    sed -i "/<a.*><img.*>.*<\/a>/d" "$source_detail_html" # small img
    sed -i "/截图赏析/d; /alt=\"screens.jpg\"/d; /www.stonestudio2015.com\/stonestudio\/created.png/d; /hds_logo.png/d" "$source_detail_html" # hds
    sed -i "/.More.Screens/d;/.Comparisons/d;/Source.*WiKi/d;/WiKi.*Source/d" "$source_detail_html" # ttg
    
    sed -i "/[Hh][Dd][Cc]hina.*vs.*[Ss]ource/d;/[Ss]ource.*vs.*[Hh][Dd][Cc]hina/d" "$source_detail_html" # hdc
    #---imdb and douban
    sed -i "s#<a.*href=\"http://www.imdb.com/title/.*\"><a.*href=\"http://www.imdb.com/title/.*\">\(http://www.imdb.com/title/tt[0-9]\{7\}6386132[/]\)</a></a>#\1#g" "$source_detail_html"
    sed -i "s#<a.*href=\"http[s]*://movie.douban.com/subject/.*\"><a.*href=\"http[s]*://movie.douban.com/subject/.*\">\(http[s]*://movie.douban.com/subject/.*\)</a></a>#\1#g" "$source_detail_html"
    sed -i "s#<a.*href=\"http://www.imdb.com/title/.*\">\(http://www.imdb.com/title/tt[0-9]\{7\}6386132[/]\)</a>#\1#g" "$source_detail_html"
    sed -i "s#<a.*href=\"http[s]*://movie.douban.com/subject/.*\">\(http[s]*://movie.douban.com/subject/.*\)</a>#\1#g" "$source_detail_html"
}

deal_with_byrbt_images()
{
    [ "$just_poster_byrbt" = "yes" ] && delete_screenshots_img # delete small images
    
    img_counter_bytbt=0
    while true; do
        img_in_desc_url="$(egrep -o "src=[\"\']http[^\'\"]+" "$source_detail_html"|sed "/bt\.byr\.cn/d"|head -n 1|sed "s/src=[\"\']//g")"
        if [ ! "$img_in_desc_url" ]; then
            break # jump out
        elif [ $img_counter_bytbt -gt 6 ]; then
            break # jump out
        fi
        tmp_desc_img_file="$AUTO_ROOT_PATH/tmp/`echo $RANDOM`-`echo $RANDOM`-`echo "${img_in_desc_url##*/}"|sed "s#[^-a-zA-Z0-9.]##g"`"
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
    `cat "$source_detail_html"` <br /><br /><br /><fieldset>
    <br />""`if [ $source_t_id ]; then
        echo '<span style="font-size:20px;">本种简介来自： '${source_site_URL}/details.php?id=${source_t_id}'</span>'
    else
        echo '<span style="font-size:20px;">本种简介来自： '${source_site_URL}'</span>'
    fi`<br /></fieldset><br /><br />"
else
    byrbt_des="$descrCom_complex_html
    <br /><br /><br /><strong><span style=\"font-size:30px;\">获取简介失败。无人职守！！！ 不喜勿下！ 如果帮助修改，在此非常感谢！</span></strong><br /><br />"
fi

movie_type_byrbt="$(egrep "[类分][　 ]*[别类型]" "$source_detail_desc"|sed "s/.*[类分][　 ]*[别类型][ 　]*//g;s/[ ]*//g;s/[\n\r]*//g")"
movie_country_byrbt="$(egrep "[国地产][　 ]*[家区地]" "$source_detail_desc"|sed "s/.*[国地产][　 ]*[家区地][ 　]*//g;s/,/\//g;;s/[ ]*//g;s/[\n\r]*//g")"

