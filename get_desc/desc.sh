#!/bin/bash
# FileName: get_desc/desc.sh
#
# Author: rachpt@126.com
# Version: 2.3v
# Date: 2018-08-27
#
#-------------------------------------#
#
source_detail_desc="${AUTO_ROOT_PATH}/tmp/${dot_name}_desc.txt"
source_detail_html="${AUTO_ROOT_PATH}/tmp/${dot_name}_html.txt"
# import functions
source "$AUTO_ROOT_PATH/get_desc/detail_page.sh"

#---to log and edit.sh---#
if [ -z "$source_site_URL" ]; then
    get_source_site          # get_desc/detail_page.sh
else
    set_source_site_cookie   # get_desc/detail_page.sh
fi

#---if not exist desc file---#
if [ ! -s "$source_detail_desc" ]; then
    detail_main_func         # get_desc/detail_page.sh
    
    subname_tmp_1="$(grep "译[　 ]*名" "$source_detail_desc" |sed "s/.*译[　 ]*名[　 ]*//;s/\n//g;s/\r//g;s/[ ]*//g")"
    subname_tmp_2="$(grep "片[　 ]*名" "$source_detail_desc" |sed "s/.*片[　 ]*名[　 ]*//;s/\n//g;s/\r//g;s/[ ]*//g")"
    
    if [ ! "$subname_tmp_1" ] && [ ! "$subname_tmp_2" ]; then
        source "$AUTO_ROOT_PATH/get_desc/generate_desc.sh"
        generate_main_func    # get_desc/generate_desc.sh"
    else
        #---add site info---#
        source_detail_desc_tmp="$(cat "$source_detail_desc")
        $(if [ $source_t_id ]; then
            echo -e "\n[quote][b]本种简介来自：[/b] ${source_site_URL}/details.php?id=${source_t_id}[/quote]"
        else
            echo -e "\n[quote][b]本种简介来自：[/b] ${source_site_URL}[/quote]"
        fi
        )"
        source_detail_html_tmp="$(cat "$source_detail_html")
        $(echo -e "\n<br /><br /><br /><fieldset><br />\n")
        $(if [ $source_t_id ]; then
            echo '<span style="font-size:20px;">本种简介来自： '${source_site_URL}/details.php?id=${source_t_id}'</span>'
        else
            echo '<span style="font-size:20px;">本种简介来自： '${source_site_URL}'</span>'
        fi
        )$(echo -e "\n<br /></fieldset><br /><br />\n")"
    
        echo "$source_detail_desc_tmp" > "$source_detail_desc"
        echo "$source_detail_html_tmp" > "$source_detail_html"
        unset source_detail_desc_tmp    source_detail_html_tmp
        #---
    fi
    echo "$subname_tmp_1 $subname_tmp_2"

    unset subname_tmp_1 subname_tmp_2
    
    unset avoid_infinite_loops  chs_name_douban  desc_json_info
    unset tmp_poster_file  new_poster_url  new_poster_url_byrbt
fi

#---poster---#
sed -i "1 {s/^[ \t]*//g}" "$source_detail_desc"
source "$AUTO_ROOT_PATH/get_desc/poster.sh"
cat "$source_detail_html"
