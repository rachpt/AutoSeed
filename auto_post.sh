#!/bin/bash
# FileName: auto_post.sh
#
# Author: rachpt@126.com
# Version: 1.2v
# Date: 2018-05-19
#
#-------------settings---------------#

torrentPath="${flexget_path}${new_torrent_name}.torrent"

#-------------------------------------#
#---paramter torrent's dot connected name---#
function get_descr()
{
    offset_A=3
    offset_B=7
    #---get torrent's name(without dot)---#
    if [ "$new_torrent_name" ]; then
        name=`echo "$new_torrent_name"|sed 's/\./ /g'`
    else
        name="$default_name"
    fi
    
    #---get torrent's type---#
    case "$name" in
        *iPad*)
            selectType='430' ;;
        *ipad*)
            selectType='430' ;;
        *)
            selectType="$default_select_type"  ;;
    esac
    
    #---get torrent's standard---#
    case "$name" in
        *720p*)
            standardSel='3' ;;
        *1080p*)
            standardSel='1' ;;
        *)
            standardSel="$default_standard"  ;;
    esac 
    
    #---get item arrar---#
    html_page=`mktemp /tmp/RssTempPage.XXXXXXXXXX`
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
    #echo step 3 "${all_item_lists_A[@]}">> $logoPath
    #---get current item---#
    
    torrent_location_line=`grep -n "$name" $html_page|cut -d: -f1|head -n 1`
    j=0
    while [ $j -lt 50 ]
    do
        if [ $torrent_location_line -ge "${all_item_lists_A[$j]}" ] && [ $torrent_location_line -le "${all_item_lists_B[$j]}" ]; then
            min_item_line=${all_item_lists_A[$j]}
            max_item_line=${all_item_lists_B[$j]}
            break
        fi
        #echo in it $j >> $logoPath
        j=`expr $j + 1`
    done
    echo $torrent_location_line == $j step 4 $min_item_line $max_item_line >> $logoPath
    #---extral item's descr---#

    descr_page=`mktemp /tmp/TorrentDescr.XXXXXXXXXX`
    descr_bbcode=`mktemp /tmp/BBCode.XXXXXXXXXX`
    sed -n "`expr $min_item_line + $offset_A`, `expr $max_item_line - $offset_B` p" $html_page > $descr_page
    sleep 1

    sed -i "s/<description><\!\[CDATA\[//g; s/\]\]><\/description>//g" $descr_page
    "$h2b" $descr_page $descr_bbcode
    sleep 1

    imdbUrl=`grep tt[0-9][0-9][0-9][0-9][0-9][0-9][0-9] $descr_page |awk 'BEGIN{FS="//"} {print $2}'|head -n 1|awk 'BEGIN{FS="/"}{print $3}'`
    if [ -z "$imdbUrl" ]; then
	    imdbUrl="$default_imdb_url"
    fi
    
    #---filter bbdcode---#

    sed -i 's/$'"/`echo ?`/" $descr_bbcode 
    sed -i 'N;s/^?\n?/\n/g' $descr_bbcode 
    sed -i 'N;s/?\n?$//g' $descr_bbcode
    sed -i 's/?$//' $descr_bbcode
    sleep 1
    if [ -n "$(grep '引用' $descr_bbcode)" ]; then
        sed -i 's#\引用#[quote]#g;s#\[/font\]#[/font][/quote]\n#g' $descr_bbcode
    else
        sed -i 's#\[font=.*\]#[quote][font=monospace]#g;s#\[/font\]#[/font][/quote]\n#g' $descr_bbcode
    fi
    sed -i 's/^[\t ]*\[img/\[img/' $descr_bbcode

    #---get subtitle---#
    name_1=`grep "译　　名" $descr_bbcode |sed 's/.译　　名[　]*//'`
    name_2=`grep "片　　名" $descr_bbcode |sed 's/.片　　名[　]*//'`
    if [ "$name_1" ]; then
        smallDescr="$name_1"
    elif [ "$name_2" ]; then
        smallDescr="$name_2"
    else
        smallDescr="$default_subname"
    fi
    
    #---join descr---#
    des="${descrCom}
    `cat $descr_bbcode`"
    
    #---log---#
    echo "+++++++++++[post data]+++++++++++" >> $logoPath
    echo -e name="$name" "\n" small_descr="$smallDescr" "\n" url="$imdbUrl" "\n" type=$selectType "\n" standard_sel=$standardSel "\n" uplver="$anonymous"  >> $logoPath

}

#-------------------------------------#
#---paramter up_status code---#
function upload_torrent()
{
    if [ "$up_status" = "1" ]; then
        t_id=`http -f -h POST $postUrl 'name'="$name" 'small_descr'="$smallDescr" 'url'="$imdbUrl" 'descr'="$des" 'type'="$selectType" 'standard_sel'="$standardSel" 'uplver'="$anonymous" file@"${torrentPath}" "$cookie" | grep "id=" |head -n 1|cut -d '=' -f 2|cut -d '&' -f 1` 

        echo t_id: [$t_id] >> $logoPath
    
        if [ -z "$t_id" ]; then
    	    t_id=`http -f POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="$des" type="430" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
    	    echo reget t_id:  [$t_id] >> $logoPath
        fi
        
        if [ -z "$t_id" ]; then
    	    t_id=`http -f POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="$des" type="430" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|head -n 1|cut -d = -f 5|cut -d '&' -f 1`
    	    echo reget t_id:  [$t_id] >> $logoPath
        fi
    	
    	download_url="https://hudbt.hust.edu.cn/download.php?id=$t_id"
    
    fi
}

function finish()
{
	echo "+++++++++++[delet tmp]+++++++++++" >> $logoPath
    rm -rf $html_page $descr_page $descr_bbcode 
}

#----------call function-----------#

get_descr

upload_torrent

if [ -n "${t_id}" ]; then
    . ./auto_add.sh
    rm -f $torrentPath # delete uploaded torrent
else
    echo "++++++++++[failed to get tID]++++++++++" >> $logoPath
fi

#--------------exit----------------#
trap finish EXIT
