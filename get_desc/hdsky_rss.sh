#!/bin/bash
# FileName: get_desc/hdsky_rss.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------------------------------#
function hds_rss_get_desc()
{
    #---if generated descr---#
    if [ -z "$hds_rss_desc" ];then
        offset_A=3
        offset_B=7
        #---get torrent's name(without dot)---#
        if [ "$new_torrent_name" ]; then
            name=`echo "$new_torrent_name"|sed 's/\./ /g'`
        fi
        #---generate temp files---#
        hds_rss_full=`mktemp "${AUTO_ROOT_PATH}/tmp/hds_rss_full.XXXXXXXX"`
        hds_rss_desc=`mktemp "${AUTO_ROOT_PATH}/tmp/hds_rss_desc.XXXXXXXX"`
        hds_rss_html=`mktemp "${AUTO_ROOT_PATH}/tmp/hds_rss_html.XXXXXXXX"`
    
        #---get item arrar---#
        curl -s --connect-timeout 100 -m 300 "https://hdsky.me/torrentrss.php?rows=50" > "$hds_rss_full"
        j=0
        for i in `grep -n '<item>' "$hds_rss_full"|cut -d: -f1`
        do
            all_item_lists_A[$j]=$i
            j=`expr $j + 1`
        done
        j=0
        for i in `grep -n '</item>' "$hds_rss_full"|cut -d: -f1`
        do
            all_item_lists_B[$j]=$i
            j=`expr $j + 1`
        done
        
        #---get current item---#
        torrent_location_line=`grep -n "$name" "$hds_rss_full"|cut -d: -f1|head -n 1`
        
        if [ -z "$torrent_location_line" ]; then
            name=`echo "$name"|sed "s/DD2 0/DD2.0/g;s/H 26/H.26/g;s/5 1/5.1/g;s/7 1/7.1/g;s/\(.*\)[\. ]mp4/\1/g;s/\(.*\)[\. ]mkv/\1/g"`
            torrent_location_line=`grep -n "$name" "$hds_rss_full"|cut -d: -f1|head -n 1`
        fi
        #---get decsribe---#
        if [ -n "$torrent_location_line" ]; then 
            j=0
            while [ $j -lt 50 ]
            do
                if [ ${torrent_location_line} -ge ${all_item_lists_A[$j]} ] && [ ${torrent_location_line} -le ${all_item_lists_B[$j]} ]; then
                    min_item_line=`expr ${all_item_lists_A[$j]} + $offset_A`
                    max_item_line=`expr ${all_item_lists_B[$j]} - $offset_B`
                    break
                fi
                j=`expr $j + 1`
            done
            # echo "Item:[$torrent_location_line] [$min_item_line, $max_item_line]" >> "$log_Path"
            #---extral item's descr---#
            sed -n "${min_item_line},${max_item_line}p" "$hds_rss_full" > "$hds_rss_desc"
            sed -i "s/<description><\!\[CDATA\[//g; s/\]\]><\/description>//g" "$hds_rss_desc"
            #---filter html code---#
            sed -i "s#onclick=\"[^\"]*\"##g;s#onmouseover=\"[^\"]*\"##g;s#onload=\"[^\"]*;\"##g" "$hds_rss_desc"
            sed -i "s#\"[^\"]*attachments\([^\"]\+\)#\"${source_site_URL}/attachments\1#g;s#src=\"attachments#src=\"${source_site_URL}/attachments#g" "$source_detail_desc"
            #---copy as a duplication---#
            cat "$hds_rss_desc" > "$hds_rss_html"
            source_detail_desc="$hds_rss_desc"
            source_detail_html="$hds_rss_html"
            #---html2bbcode---#
	        source "$AUTO_ROOT_PATH/get_desc/html2bbcode.sh"

        else
            #---use detail func if failed to get item---#
            form_source_site_get_Desc
        fi
        #---clean---#
        rm -f "$hds_rss_full"
	    hds_rss_full=''
	    hds_rss_desc=''
	    hds_rss_html=''
    fi
}

#-------------------------------------#
hds_rss_get_desc

