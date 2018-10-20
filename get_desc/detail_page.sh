#!/bin/bash
# FileName: get_desc/detail_page.sh
#
# Author: rachpt@126.com
# Version: 2.4v
# Date: 2018-10-20
#
#-------------------------------------#
get_source_site()
{
    tracker_source_infos=`"$trans_show" "$torrentPath" |grep -A 5 'TRACKERS'`

    if [ "`echo $tracker_source_infos|grep -i 'hdsky'`" ]; then
        source_site_URL='https://hdsky.me'
        cookie_source_site="$cookie_hds"
        echo "got source_site" >> "$log_Path"
    elif [ "`echo $tracker_source_infos|grep -i 'totheglory'`" ]; then
        source_site_URL='https://totheglory.im'
        cookie_source_site="$cookie_ttg"
        echo "got source_site" >> "$log_Path"
    elif [ "`echo $tracker_source_infos|grep -i 'hdchina'`" ]; then
        source_site_URL='https://hdchina.org'
        cookie_source_site="$cookie_hdc"
        echo "got source_site" >> "$log_Path"
    elif [ "`echo $tracker_source_infos|grep -i 'tp.m-team.cc'`" ]; then
        source_site_URL='https://tp.m-team.cc'
        cookie_source_site="$cookie_mt"
        echo "got source_site" >> "$log_Path"
    elif [ "`echo $tracker_source_infos|grep -i 'hdcmct.org'`" ]; then
        source_site_URL='https://hdcmct.org'
        cookie_source_site="$cookie_cmct"
        echo "got source_site" >> "$log_Path"
    #elif [ "`echo $tracker_source_infos|grep -i 'new'`" ]; then
    #    source_site_URL='https://new.tracker.com'
    fi
}
set_source_site_cookie()
{
    if [ "$source_site_URL" = "https://hdsky.me" ]; then
        cookie_source_site="$cookie_hds"
    elif [ "$source_site_URL" = "https://totheglory.im" ]; then
        cookie_source_site="$cookie_ttg"
    elif [ "$source_site_URL" = "https://hdchina.org" ]; then
        cookie_source_site="$cookie_hdc"
    elif [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
        cookie_source_site="$cookie_mt"
    elif [ "$source_site_URL" = "https://hdcmct.org" ]; then
        cookie_source_site="$cookie_cmct"
    fi
}

#-------------------------------------#
form_source_site_get_tID()
{
    if [ "$source_site_URL" = "https://totheglory.im" ]; then
        source_site_search_URL="${source_site_URL}/browse.php?c=M&search_field=$(echo "${dot_name}"|sed -r "s/\.[a-z4]{2,4}$//i")"
    else
        source_site_search_URL="${source_site_URL}/torrents.php?search=$(echo "${dot_name}"|sed -r "s/\.[a-z4]{2,4}$//i")"
    fi

    source_t_id=`http "$source_site_search_URL" "$cookie_source_site"| grep 'hit=1'|grep 'id='|head -n 1|awk -F '?id=' '{print $2}'|awk -F '&' '{print $1}'`

    #---deal with wrong year---#
    if [ ! "$source_t_id" ]; then
        source_site_search_URL="$(echo "$source_site_search_URL"|sed "s/[12][015-9][0-9][0-9]//g")"
        source_t_id=`http "$source_site_search_URL" "$cookie_source_site"| grep 'hit=1'|grep 'id='|head -n 1|awk -F '?id=' '{print $2}'|awk -F '&' '{print $1}'`
    fi
}

#-------------------------------------#
get_original_subname()
{
    if [ "$source_site_URL" = "https://totheglory.im" ]; then
        original_subname_info="$(grep 'h1.*\[.*\]' "$source_detail_full"|head -n 1|sed "s#.*\[\(.*\)</h1>#\1#g")"
        if [ "$original_subname_info" ]; then
            original_subname="$(echo "$original_subname_info"|sed "s#\[\(.*\)\]#\1#g;s#[ ]\+##g")"
            original_other_info="$(echo "$original_subname_info"|sed "s#.*\]\(.*\)#\1#g;s#\*##g")"
        fi
    elif [ "$source_site_URL" = "https://hdchina.org" ]; then
        original_subname_info="$(grep 'h3' "$source_detail_full"|head -n 1|sed "s#<[/]*h3>##g")"
        if [ "$original_subname_info" ]; then
            original_subname="$(echo "$original_subname_info"|sed "s#\*.*##g;s#\[.*##g;s#[导主]演.*##g;s#[ ]\+##g;s#|.*##g")"
            original_other_info="$(echo "$original_subname_info"|sed "s#[^ ]\+##;s#[^*[|]\+[\*\[|]##;s#[*[|]##g;s#\]##g;s#.*\([导主]演.*\)#\1#g")"
        fi

    else
        original_subname_info="$(egrep '副标题|Small Description|副標題' "$source_detail_full"|head -n 1|sed "s#.*left\">##g;s#<.*>##g;s#[ ]\+##g")"
        if [ "$original_subname_info" ]; then
            original_subname="$(echo "$original_subname_info"|sed "s#\[.*\]##g;s#[ ]\+##g;s#【.*】##g;s#[导主]演.*##g;s#[ ]\+##g;s#|.*##g")"
            original_other_info="$(echo "$original_subname_info"|sed "s#.*\[\(.*\)\].*#\1#g;s#.*【\(.*\)】.*#\1#g;s#.*\([导主]演.*\)#\1#g"|sed "s%\][ ]*\[% %g")"
        fi
    fi
}

#-------------------------------------#
form_source_site_get_Desc()
{
    form_source_site_get_tID

    if [ -n "${source_t_id}" ]; then
        http --ignore-stdin GET "${source_site_URL}/details.php?id=${source_t_id}" "$cookie_source_site" > "$source_detail_full"
    fi

    if [ -s "$source_detail_full" ]; then
        get_original_subname
        source_start_line_html=`egrep -n '>[ ]?简介<|>简述<|>[ ]?簡介<|>[ ]?Description<|>説明<|>설명<' "$source_detail_full" |head -n 1|awk -F ':' '{print $1}'`
        if [ "$source_site_URL" = "https://totheglory.im" ] || [ "$source_site_URL" = "https://tp.m-team.cc" ]; then
            source_end_line_html=`grep -n '</div></td></tr>' "$source_detail_full" |head -n 1|awk -F ':' '{print $1}'`
        elif [ "$source_site_URL" = "https://hdcmct.org" ]; then
            source_start_line_html=`expr $source_start_line_html + 1` # delete notice
            source_end_line_html=`grep -n '</div></td></tr>' "$source_detail_full" |head -n 2|tail -n 1|awk -F ':' '{print $1}'`
            source_end_line_html=`expr $source_end_line_html - 1` # delete notice
        else
            source_end_line_html=`grep -n '</div></td></tr>' "$source_detail_full" |head -n 2|tail -n 1|awk -F ':' '{print $1}'`
        fi

        if [ "$source_site_URL" = "https://hdsky.me" ]; then
            sed -n "`expr ${source_start_line_html} + 1`,${source_end_line_html}p" "$source_detail_full" > "$source_detail_desc"
        else
            sed -n "${source_start_line_html},${source_end_line_html}p" "$source_detail_full" > "$source_detail_desc"
        fi
        #---hdsky---#
        sed -i 's#.*lt="ad" /></a></div>##' "$source_detail_desc"
        sed -i 's#^[ \t	]\+<img#<img#g' "$source_detail_desc"
        #---ttg---#
        sed -i "/\/pic\/ico/d" "$source_detail_desc"
        sed -i "s/.*align=left><div id='kt_d'>//g" "$source_detail_desc"
        #---hdc---#
        sed -i "s/.*kdescr'>//g;" "$source_detail_desc"

        #---hdc poster---#
        if [ "$source_site_URL" = "https://hdchina.org" ]; then
            source_hdc_poster_img=`grep 'poster_box' "$source_detail_full"|sed "s/.*img[^>]\+src=\"\([^\"]\+\)\".*/\1/g"`
            if [ ! "`grep "$source_hdc_poster_img" "$source_detail_desc"`" ]; then
                sed -i "1i <img src=\"$source_hdc_poster_img\" /><br /><br /><br />\n\n" "$source_detail_desc"
            fi
            sed -i "s/.*id='kdescr'>//g;s/onclick=\"Previewurl([^)]*)[;]*\"//g;s/onload=\"Scale([^)]*)[;]*\"//g;s/onmouseover=\"[^\"]*;\"//g" "$source_detail_desc"
            sed -i "s#onclick=\"Previewurl.*/><br />#/><br />#g" "$source_detail_desc"
            sed -i "/本资源仅限会员测试带宽之用，严禁用于商业用途！/d; /对用于商业用途所产生的法律责任，由使用者自负！/d" "$source_detail_desc"
        fi
        #---filter html code---#
        sed -i "s#\"[^\"]*attachments\([^\"]\+\)#\"${source_site_URL}/attachments\1#g;s#src=\"attachments#src=\"${source_site_URL}/attachments#g" "$source_detail_desc"
        sed -i "s#onmouseover=\"[^\"]*[;]*\"##g" "$source_detail_desc"
        sed -i "s#onload=\"[^\"]*[;]*\"##g" "$source_detail_desc"
        sed -i "s#onclick=\"[^\"]*[;)]*\"##g" "$source_detail_desc"
        
        sed -i "/doubanio\.com/d" "$source_detail_desc"
        #---copy as a duplication---#
        cat "$source_detail_desc" > "$source_detail_html"

        imdbUrl="$(grep -o 'tt[0-9]\{7\}' "$source_detail_full"|head -n 1)"
        doubanUrl="$(grep -o 'http[s]*://movie\.douban\.com/subject/[0-9]\{8\}[/]*' "$source_detail_full"|head -n 1)"

        #---html2bbcode---#
	      source "$AUTO_ROOT_PATH/get_desc/html2bbcode.sh"

    fi
    rm -f "$source_detail_full"
}

#-------------------------------------#
detail_main_func()
{
    #---define temp file name---#
    source_detail_full="${AUTO_ROOT_PATH}/tmp/${dot_name}_full.txt"

    #---get description---#
    if [ "$source_site_URL" = "https://hdsky.me" ]; then
        #---use rss page first---#
        source "$AUTO_ROOT_PATH/get_desc/hdsky_rss.sh"
    else
        #---mormal method---#
        form_source_site_get_Desc
    fi
}

#-------------------------------------#

