#!/bin/bash
# FileName: hds_desc.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-24
#
#-------------------------------------#
function get_descr()
{
    #---if generated descr---#
    if [ -z "$descr_bbcode" ];then
        offset_A=3
        offset_B=7
        #---get torrent's name(without dot)---#
        if [ "$new_torrent_name" ]; then
            name=`echo "$new_torrent_name"|sed 's/\./ /g'`
        else
            name="$default_name"
        fi
        #---get item arrar---#
        html_page=`mktemp /tmp/RssTempPage.XXXXXXXXXX`
        descr_page=`mktemp /tmp/TorrentDescr.XXXXXXXXXX`
        descr_bbcode=`mktemp /tmp/BBCode.XXXXXXXXXX`

        curl -s --connect-timeout 100 -m 300 "https://hdsky.me/torrentrss.php?rows=50" > $html_page
        j=0
        for i in `grep -n '<item>' $html_page|cut -d: -f1`
        do
            all_item_lists_A[$j]=$i
            j=`expr $j + 1`
        done
        j=0
        for i in `grep -n '</item>' $html_page|cut -d: -f1`
        do
            all_item_lists_B[$j]=$i
            j=`expr $j + 1`
        done
        
        #---get current item---#
        
        torrent_location_line=`grep -n "$name" $html_page|cut -d: -f1|head -n 1`
        
        if [ -z "$torrent_location_line" ]; then
            name=`echo "$name"|sed 's/DD2 0/DD2.0/g;s/H 26/H.26/g;s/5 1/5.1/g;s/7 1/7.1/g'`
            torrent_location_line=`grep -n "$name" $html_page|cut -d: -f1|head -n 1`
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
            echo "Item:[$torrent_location_line] [$min_item_line, $max_item_line]" >> $log_Path
            #---extral item's descr---#
            sed -n "${min_item_line},${max_item_line} p" $html_page > $descr_page
            sed -i "s/<description><\!\[CDATA\[//g; s/\]\]><\/description>//g" $descr_page
        else
            . ./hds_detail.sh   # use detail page
        fi      

        $h2b $descr_page $descr_bbcode

        #---filter bbdcode---#
        sed -i 's/$'"/`echo ?`/" $descr_bbcode 
        sed -i 'N;s/^?\n?/\n/g' $descr_bbcode 
        sed -i 'N;s/?\n?$//g' $descr_bbcode
        sed -i 's/?$//' $descr_bbcode

        if [ -n "$(grep '引用' $descr_bbcode)" ]; then
            sed -i 's#\引用#[quote]#g;s#\[/font\]#[/font][/quote]\n#g' $descr_bbcode
        else
            sed -i 's#\[font=.*\]#[quote][font=monospace]#g;s#\[/font\]#[/font][/quote]\n#g' $descr_bbcode
        fi
        sed -i 's/^[\t ]*\[img/\[img/' $descr_bbcode
        
    fi
    
    imdbUrl=`egrep tt[0-9]{7} "$descr_page" |awk -F '//' '{print $2}'|head -n 1|awk -F '/' '{print $3}'`

    #---get subtitle---#
    if [ "`grep 'CH[ST]' $descr_page`" ]; then
        chs_include='[中文字幕]'
    else
        chs_include=''
    fi
    
    name_1=`grep "译　　名" $descr_page |sed 's/.译[　]*名[　]*//;s/<br \/>//'`
    name_2=`grep "片　　名" $descr_page |sed 's/.片[　]*名[　]*//;s/<br \/>//'`
}

#-------------------------------------#
get_descr
