#!/bin/bash
# FileName: get_desc/screens.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-10-23
#
#-------------------------------------#
#

delete_screenshots_img() {
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

deal_with_byrbt_images() {
    [ "$enable_byrbt" = 'yes' ] && [ "$just_poster_byrbt" = "yes" ] && delete_screenshots_img # delete small images
    
    # 遍历 html 简介中的非 byr 图片
    local img_counter_bytbt=0
    while true; do
        # 获取不包含 byrbt 域名的图片链接
        img_in_desc_url="$(egrep -io "src=[\"\']http[^\'\"]+" "$source_detail_html"|sed "/bt\.byr\.cn/d"|head -1|sed "s/src=[\"\']//ig")"
        # 跳出循环条件
        if [ ! "$img_in_desc_url" ]; then
            break # jump out
        elif [ $img_counter_bytbt -gt 24 ]; then
            break # jump out
        fi
        # 临时图片路径，使用时间作为文件名的一部分
        local tmp_desc_img_file="$AUTO_ROOT_PATH/tmp/$(echo "autoseed-pic-$(date +%s%N)$(echo "${img_in_desc_url##*/}"|sed -r 's/.*(\.[jpgb][pnim]e?[gfp]).*/\1/i')")"
        http --ignore-stdin -dco "$tmp_desc_img_file" "$img_in_desc_url" >/dev/null 2>&1
        # 图片上传至 byrbt
        local byr_upload_img_url="$(http -b -f POST "$upload_poster_api_byrbt" upload@"$tmp_desc_img_file" "$cookie_byrbt"|awk -F ',' '{print $2}'|sed -r "s#.*https?://#https://#;s/'[ ]*$//")"  # byrbt
        # 替换简介中的图片链接
        sed -i "s#$img_in_desc_url#$byr_upload_img_url#g" "$source_detail_html" # byrbt
        rm -f "$tmp_desc_img_file"
        unset img_in_desc_url   tmp_desc_img_file
        ((img_counter_bytbt++)) # C 形式的增1
    done
}

#-------------------------------------#

