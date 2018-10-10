#!/bin/bash
# FileName: get_desc/poster.sh
#
# Author: rachpt@126.com
# Version: 2.4v
# Date: 2018-09-23
#
#-------------------------------------#
#
byrbt_upload_pic_URL='https://bt.byr.cn/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images'

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

    if [ "$enable_tjupt" = 'yes' ]; then
        source_detail_desc2tjupt="${AUTO_ROOT_PATH}/tmp/${dot_name}_desc2tjupt.txt"
        cat "$source_detail_desc" > "$source_detail_desc2tjupt"
    fi
    
    img_counter_bytbt=0
    while true; do
        img_in_desc_url="$(egrep -o "src=[\"\']http[^\'\"]+" "$source_detail_html"|sed "/bt\.byr\.cn/d"|head -n 1|sed "s/src=[\"\']//g")"
        if [ ! "$img_in_desc_url" ]; then
            break # jump out
        elif [ $img_counter_bytbt -gt 24 ]; then
            break # jump out
        fi
        tmp_desc_img_file="$AUTO_ROOT_PATH/tmp/$(echo $RANDOM)-$(echo $RANDOM)-$(echo "${img_in_desc_url##*/}"|sed "s/[uU]nt/no-name/g;s#[^-a-zA-Z0-9.]##g")"
        http --ignore-stdin -dco "$tmp_desc_img_file" "$img_in_desc_url" >/dev/null 2>&1

        byr_upload_img_url="$(http -f POST "$byrbt_upload_pic_URL" upload@"$tmp_desc_img_file" "$cookie_byrbt"|egrep -o "http[-a-zA-Z0-9./:()]+images[-a-zA-Z0-9./:(_ )]+[^\',\"]*" |sed "s/http:/https:/g")"  # byrbt
        [ "$enable_tjupt" = 'yes' ] && [ "$(echo "$img_in_desc_url"|sed "/i\.loli\.net/d")" ] && new_poster_url_sm="$(http --ignore-stdin -f POST 'https://sm.ms/api/upload' smfile@"$tmp_desc_img_file"|egrep -o "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" && sed -i "s#$img_in_desc_url#$new_poster_url_sm#g" "$source_detail_desc2tjupt" && unset new_poster_url_sm # tjupt

        sed -i "s#$img_in_desc_url#$byr_upload_img_url#g" "$source_detail_html" # byrbt
        rm -f "$tmp_desc_img_file"
        img_in_desc_url=''
        tmp_desc_img_file=''
        img_counter_bytbt=`expr $img_counter_bytbt + 1`
    done
}

#-------------------------------------#

deal_with_byrbt_images

#-------------------------------------#
judge_poster_exist_add_new_one()
{
    sed -i "{/<img src=\"[^h]/d}" "$source_detail_html"
    if [ ! "$(head -n 10 "$source_detail_desc"|egrep -i 'jpg|png|gif|webp|jpeg')" ]; then
        sed -i '1,7{/img/d}' "$source_detail_desc"
        sed -i '1,7{/img/d}' "$source_detail_html"
        source "$AUTO_ROOT_PATH/get_desc/generate_desc.sh"
        from_douban_get_desc
        poster_up_to_sm_and_byr
        echo 'poster debug: generated' >> "$log_Path"

        poster_desc_tmp="[img]${new_poster_url}[/img]"
        poster_html_tmp="<img src=\"${new_poster_url_byrbt}\" /><br /><br />"
        sed -i "1 i ${poster_desc_tmp}" "$source_detail_desc"
        sed -i "1 i ${poster_html_tmp}" "$source_detail_html"
        
        poster_desc_tmp=''
        poster_html_tmp=''
    fi
}

#-------------------------------------#
judge_poster_exist_add_new_one
