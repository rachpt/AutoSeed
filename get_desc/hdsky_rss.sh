#!/bin/bash
# FileName: get_desc/hdsky_rss.sh
#
# Author: rachpt@126.com
# Version: 2.4.2v
# Date: 2018-10-23
#
#-------------------------------------#
function hds_rss_get_desc() {
    #---if generated descr---#
    if [ ! -s "$source_detail_desc" ];then
        offset_A=3
        offset_B=7
        #---get torrent's name(without dot)---#
        if [ "$new_torrent_name" ]; then
            name=`echo "$new_torrent_name"|sed 's/\./ /g'`
        fi

        #---get item arrar---#
        curl -s --connect-timeout 100 -m 300 "https://hdsky.me/torrentrss.php?rows=50" > "$source_detail_full"
        j=0
        for i in `grep -n '<item>' "$source_detail_full"|cut -d: -f1`
        do
            all_item_lists_A[$j]=$i
            j=`expr $j + 1`
        done
        j=0
        for i in `grep -n '</item>' "$source_detail_full"|cut -d: -f1`
        do
            all_item_lists_B[$j]=$i
            j=`expr $j + 1`
        done

        #---get current item---#
        torrent_location_line=`grep -n "$name" "$source_detail_full"|cut -d: -f1|head -1`

        if [ -z "$torrent_location_line" ]; then
            name=`echo "$name"|sed "s/DD2 0/DD2.0/g;s/H 26/H.26/g;s/5 1/5.1/g;s/7 1/7.1/g;s/\(.*\)[\. ]mp4/\1/g;s/\(.*\)[\. ]mkv/\1/g"`
            torrent_location_line=`grep -n "$name" "$source_detail_full"|cut -d: -f1|head -1`
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

            #---extral item's descr---#
            sed -n "${min_item_line},${max_item_line}p" "$source_detail_full" > "$source_detail_desc"
            sed -i "s/<description><\!\[CDATA\[//g; s/\]\]><\/description>//g" "$source_detail_desc"
            #---filter html code---#
            sed -i "s#onclick=\"[^\"]*\"##g;s#onmouseover=\"[^\"]*\"##g;s#onload=\"[^\"]*;\"##g;s#onclick=\"[^\"]*[)]*\"##g" "$source_detail_desc"
            sed -i "s#\"[^\"]*attachments\([^\"]\+\)#\"${source_site_URL}/attachments\1#g;s#src=\"attachments#src=\"${source_site_URL}/attachments#g" "$source_detail_desc"

            sed -i "/doubanio\.com/d" "$source_detail_desc"  # this img link cannot use
            #---imdb url---#
            imdbUrl="$(grep -o 'tt[0-9]\{7\}' "$source_detail_desc"|head -1)"
            #---copy as a duplication---#
            [ "$enable_byrbt" = 'yes' ] && cat "$source_detail_desc" > "$source_detail_html"

            #---html2bbcode---#
            source "$AUTO_ROOT_PATH/get_desc/html2bbcode.sh"
	        
	        #---clean---#
            rm -f "$source_detail_full"
        else
            #---use detail func if failed to get item---#
            form_source_site_get_Desc
        fi
    fi
}

#-------------------------------------#
hds_rss_get_desc

