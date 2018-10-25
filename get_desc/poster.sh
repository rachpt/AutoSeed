#!/bin/bash
# FileName: get_desc/poster.sh
#
# Author: rachpt@126.com
# Version: 2.4.2v
# Date: 2018-09-23
#
#-------------------------------------#
#
byrbt_upload_pic_URL='https://bt.byr.cn/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images'

delete_screenshots_img() {
    local desc_delete_screens="$1"
    sed -i "/<a.*><img.*>.*<\/a>/d" "$desc_delete_screens" # small img
    sed -i "/截图赏析/d; /alt=\"screens.jpg\"/d; /www.stonestudio2015.com\/stonestudio\/created.png/d; /hds_logo.png/d" "$desc_delete_screens" # hds
    sed -i "/.More.Screens/d;/.Comparisons/d;/Source.*WiKi/d;/WiKi.*Source/d" "$desc_delete_screens" # ttg

    sed -i "/[Hh][Dd][Cc]hina.*vs.*[Ss]ource/d;/[Ss]ource.*vs.*[Hh][Dd][Cc]hina/d" "$desc_delete_screens" # hdc
    #---imdb and douban
    sed -i "s#<a.*href=\"http://www.imdb.com/title/.*\"><a.*href=\"http://www.imdb.com/title/.*\">\(http://www.imdb.com/title/tt[0-9]\{7\}6386132[/]\)</a></a>#\1#g" "$desc_delete_screens"
    sed -i "s#<a.*href=\"http[s]*://movie.douban.com/subject/.*\"><a.*href=\"http[s]*://movie.douban.com/subject/.*\">\(http[s]*://movie.douban.com/subject/.*\)</a></a>#\1#g" "$desc_delete_screens"
    sed -i "s#<a.*href=\"http://www.imdb.com/title/.*\">\(http://www.imdb.com/title/tt[0-9]\{7\}6386132[/]\)</a>#\1#g" "$desc_delete_screens"
    sed -i "s#<a.*href=\"http[s]*://movie.douban.com/subject/.*\">\(http[s]*://movie.douban.com/subject/.*\)</a>#\1#g" "$desc_delete_screens"
}

deal_with_desc_screens() {
    # delete small images
    [ "$just_poster_byrbt" = "yes" ] && delete_screenshots_img "$source_detail_html"
    # tjupt
    if [ "$enable_tjupt" = 'yes' ]; then
        source_detail_desc2tjupt="${AUTO_ROOT_PATH}/tmp/${dot_name}_desc2tjupt.txt"
        cp "$source_detail_desc" "$source_detail_desc2tjupt"
        [ "$just_poster_tjupt" = "yes" ] && delete_screenshots_img "$source_detail_desc2tjupt"
    fi

    local img_counter_reupload=0
    while true; do
        if [ "$enable_byrbt" = 'yes' ]; then
            local img_in_desc_url="$(egrep -o "src=[\"\']http[^\'\"]+" "$source_detail_html"|sed "/bt\.byr\.cn/d"|head -1|sed "s/src=[\"\']//g")"
        elif [ "$enable_tjupt" = 'yes' ]; then
            local img_in_desc_url="$(egrep -o "src=[\"\']http[^\'\"]+" "$source_detail_html"|sed "/i\.loli\.net/d"|head -1|sed "s/src=[\"\']//g")"
        fi
        if [ ! "$img_in_desc_url" ]; then
            break # jump out
        elif [ $img_counter_reupload -gt 24 ]; then
            break # jump out
        fi
        local tmp_desc_img_file="$AUTO_ROOT_PATH/tmp/$(echo "autoseed-pic-$(date +%s%N)$(echo "${img_in_desc_url##*/}"|sed -r 's/title//ig;s/.*(\.[jpgb][pnim]e?[gfp]).*/\1/i')")"
        http --ignore-stdin -dco "$tmp_desc_img_file" "$img_in_desc_url" >/dev/null 2>&1
        # byrbt
        [ "$enable_byrbt" = 'yes' ] && byr_upload_img_url="$(http -f POST "$byrbt_upload_pic_URL" upload@"$tmp_desc_img_file" "$cookie_byrbt"|egrep -o "http[-a-zA-Z0-9./:()]+images[-a-zA-Z0-9./:(_ )]+[^\',\"]*" |sed "s/http:/https:/g")" && sed -i "s#$img_in_desc_url#$byr_upload_img_url#g" "$source_detail_html" && unset byr_upload_img_url
        # tjupt
        [ "$enable_tjupt" = 'yes' ] && [ ! "$(echo "$img_in_desc_url"|grep "i\.loli\.net")" ] && new_poster_url_sm="$(http --ignore-stdin -f POST 'https://sm.ms/api/upload' smfile@"$tmp_desc_img_file"|egrep -o "\"url\":\"[^\"]+\""|awk -F "\"" '{print $4}'|sed 's/\\//g')" && sed -i "s#$img_in_desc_url#$new_poster_url_sm#g" "$source_detail_desc2tjupt" && unset new_poster_url_sm 

        rm -f "$tmp_desc_img_file"
        unset img_in_desc_url  tmp_desc_img_file
        ((img_counter_reupload++)) # C 形式的增1
    done
    # tjupt images
    [ "$enable_tjupt" = 'yes' ] && sed -i '/jpg\|png\|jpeg\|gif\|webp/ {/i\.loli\.net/!d}' "$source_detail_desc2tjupt"
}

#-------------------------------------#

deal_with_desc_screens

#-------------------------------------#
judge_poster_exist_add_new_one() {
    sed -i "{/<img src=\"[^h]/d}" "$source_detail_html"
    if [ ! "$(head -n 10 "$source_detail_desc"|egrep -i 'jpg|png|gif|webp|jpeg')" ]; then
        sed -i '1,7{/img/d}' "$source_detail_desc"
        sed -i '1,7{/img/d}' "$source_detail_html"
        source "$AUTO_ROOT_PATH/get_desc/generate_desc.sh"
        from_douban_get_desc
        poster_up_to_sm_and_byr
        echo 'poster debug: generated' >> "$log_Path"

        local poster_desc_tmp="[img]${new_poster_url}[/img]"
        local poster_html_tmp="<img src=\"${new_poster_url_byrbt}\" /><br /><br />"
        sed -i "1 i ${poster_desc_tmp}" "$source_detail_desc"
        sed -i "1 i ${poster_html_tmp}" "$source_detail_html"
    fi
}

#-------------------------------------#
judge_poster_exist_add_new_one

