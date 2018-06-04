#!/bin/bash
# FileName: hds_desc.sh
#
# Author: rachpt@126.com
# Version: 1.6v
# Date: 2018-05-29
#
#-------------------------------------#
function get_descr()
{
    #---if generated descr---#
    if [ -z "$descr_page" ];then
        offset_A=3
        offset_B=7
        #---get torrent's name(without dot)---#
        if [ "$new_torrent_name" ]; then
            name=`echo "$new_torrent_name"|sed 's/\./ /g'`
        else
            name="$default_name"
        fi
        #---generate temp files---#
        html_page=`mktemp    /tmp/html_page.XXXXXXXXXX`
        descr_page=`mktemp   /tmp/descr_page.XXXXXXXXXX`
        descr_bbcode=`mktemp /tmp/descr_bbcode.XXXXXXXXXX`
        #---get item arrar---#
        curl -s --connect-timeout 100 -m 300 "https://hdsky.me/torrentrss.php?rows=50" > "$html_page"
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
            sed -n "${min_item_line},${max_item_line}p" "$html_page" > "$descr_page"
            sed -i "s/<description><\!\[CDATA\[//g; s/\]\]><\/description>//g" "$descr_page"
        else
            source "$AUTO_ROOT_PATH/hds_detail.sh"   # use detail page if failed to get item
        fi
        #---log---#
        cat "$descr_page" >> "$AUTO_ROOT_PATH/items.html"
        if [ -s "$descr_page" ]; then
            echo "已经生成 page" >> $log_Path
            imdbUrl=`egrep tt[0-9]{7} "$descr_page" |awk -F '//' '{print $2}'|head -n 1|awk -F '/' '{print $3}'`
        else
            echo "生成 page 失败!" >> $log_Path
        fi
        #---bbcode---#
	    /usr/local/bin/html2bbcode "$descr_page" "$descr_bbcode"
        sleep 1
        wait
	    if [ ! -s "$descr_bbcode" ]; then
            cat "$descr_page"|html2bbcode "$descr_bbcode"
            sleep 1
        fi
        #---log---#
        if [ -s "$descr_bbcode" ]; then
            echo "已经生成 bbcode" >> $log_Path
            #---filter bbdcode---#
            sed -i 's/$'"/`echo ?`/" "$descr_bbcode"
            sed -i 'N;s/^?\n?/\n/g' "$descr_bbcode"
            sed -i 'N;s/?\n?$//g' "$descr_bbcode"
            sed -i 's/?$//' "$descr_bbcode"

            if [ -n "$(grep '引用' $descr_bbcode)" ]; then
                sed -i 's#\引用#[quote]#g;s#\[/font\]#[/font][/quote]\n#g' "$descr_bbcode"
            else
                sed -i 's#\[font=.*\]#[quote][font=monospace]#g;s#\[/font\]#[/font][/quote]\n#g' "$descr_bbcode"
            fi
            sed -i 's/^[\t ]*\[img/\[img/' "$descr_bbcode"
        else
            echo "生成 bbcode 失败!" >> $log_Path
            #---use webpage transform---#
            http -f POST 'https://www.garyshood.com/htmltobb/' html="`cat $descr_page`" > "$descr_bbcode"
            wait
            sleep 1
            if [ -s "$descr_bbcode" ]; then
                echo "通过web生成 bbcode" >> $log_Path
                web_page_head=`grep -n '<textarea' "$descr_bbcode"|awk -F : '{print $1}'`
                web_page_foot=`grep -n '</textarea>' "$descr_bbcode"|awk -F : '{print $1}'`
                sed -n -i "${web_page_head},${web_page_foot}p" "$descr_bbcode"
                sed -i "s/<textarea.*>//; s%</textarea>%%; s/引用/[quote]/; s%Information: \[/b\]%Information: [/b][font=monospace]%; s%@HDSPad%@HDSPad[/font][/quote]%" "$descr_bbcode"
            else
                echo "通过web生成bbcode失败!" >> $log_Path
            fi    
        fi

    fi
    
    #---get subtitle---#
    if [ -n "`grep 'CH[ST]' $descr_page`" ]; then
        chs_include='[中文字幕]'
    else
        chs_include=''
    fi
    
    name_1=`grep "译　　名" $descr_page |sed 's/.译[　]*名[　]*//;s/<br \/>//;s/\n//;s/\r//'`
    name_2=`grep "片　　名" $descr_page |sed 's/.片[　]*名[　]*//;s/<br \/>//;s/\n//;s/\r//'`
}

#-------------------------------------#
get_descr
