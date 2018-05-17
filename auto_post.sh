#!/bin/bash
# FileName: auto_post.sh
#
# Author: rachpt@126.com
# Version: 1.0v
# Date: 2018-05-17

#-------------settings---------------#
h2b='html2bbcode'

torrentPath="${flexget_path}$1"

#---watch dir(full, like:/home/down/)---#
watch_dir='/home/rc/Downloads/hudbt/'

name="Default Title"

smallDescr="Default subtitle"

postUrl='https://hudbt.hust.edu.cn/takeupload.php'

descrCom="[quote]
[b]这是一个自动发布的种子[/b]
[ul]
[li]所有信息以所发种子信息(文件名)为准，所有标题、简介信息均仅供参考，若发现有误请以[举报]或[留言]的形式通知工作人员审查和编辑。
[*]保种12-20天，断种恕不补种。
[*] Shell 脚本实现，具体见：[url=https://github.com/rachpt/AutoSeed]GitHub AutoSeed[/url]
[/li][/ul]
[/quote]\n\n[hr /]"

imdbUrl=''

#---default type---#
selectType=430

standardSel=3

anonymous='yes'

#---cookie of forwarding site---#
cookie='----string-----'

#-------------------------------------#

#---paramter torrent's dot connected name---#
function get_descr()
{
    offset_A=3
    offset_B=7
    #---get torrent's name(without dot)---#
    if [ "$1" ]; then
        name=`sed 's/\./ /g' "${1%./}"`
    else
        name="Failed to get Title"
    fi

    #---get item arrar---#
    html_page=`mktemp /tmp/rssTempPage.XXXXXXXXXX`
    j=0
    for i in `grep -n \<item\> $html_page|cut -d: -f1`
    do
        all_item_lists_A[j]=$i
        j=`expr $j + 1`
    done
    j=0
    for i in `grep -n \</item\> $html_page|cut -d: -f1`
    do
        all_item_lists_B[j]=$i
        j=`expr $j + 1`
    done

    #---get current item---#
    
    torrent_location_line=`grep -n "$name" $html_page|cut -d: -f1`
    j=0
    while [ $j lt 50 ]
    do
        if [ $torrent_location_line -ge $all_item_lists_A[$j] ] && [ $torrent_location_line -le $all_item_lists_B[$j] ]; then
            min_item_line=$all_item_lists_A[$j]
            max_item_line=$all_item_lists_B[$j]
            break
        fi
    done

    #---extral item's descr---#

    descr_page=`mktemp /tmp/torrentDescr.XXXXXXXXXX`
    descr_bbcode=`mktemp /tmp/BBCode.XXXXXXXXXX``
    sed -n "$(expr $min_item_line + $offset_A),$(expr $max_item_line - $offset_B)p" $html_page > $descr_page
    sed -i "s/<description><\!\[CDATA\[//g; s/\]\]><\/description>//g" $descr_page
    "$h2b" $descr_page $descr_bbcode


    imdbUrl=`grep tt[0-9][0-9][0-9][0-9][0-9][0-9][0-9] $descr_page |awk 'BEGIN{FS="//"} {print $2}'|head -n 1|awk 'BEGIN{FS="/"}{print $3}'`
    
    #---filter bbdcode---#

    sed -i 's/$'"/`echo ?`/" $descr_bbcode 
    sed -i 'N;s/^?\n?/\n/g' $descr_bbcode 
    sed -i 'N;s/?\n?$//g' $descr_bbcode
    sed -i 's/?$//' $descr_bbcode
    sed -i 's#\[font=.*\]#\n[quote]#g;s#\[/font\]#[/quote]\n\n#g' $descr_bbcode
    sed -i 's/^[\t ]*\[img/\[img/' $descr_bbcode

    #---get subtitle---#
    name_1=`grep "译　　名" $descr_bbcode |sed 's/.译　　名[　]*//'`
    name_2=`grep "片　　名" $descr_bbcode |sed 's/.片　　名[　]*//'`
    if [ "$name_1" ]; then
        smallDescr="$name_1"
    elif [ "$name_2" ]; then
        smallDescr="$name_2"
    fi

}


#-------------------------------------#
#---paramter up_status code---#
function upload_torrent()
{
    if [ "$1" = "1" ]; then
        t_id=`http -fh POST $postUrl name="$name" small_descr="$smallDescr" url="$imdbUrl" descr="${descrCom}$(cat $descr_bbcode)" type=$selectType standard_sel=$standardSel uplver="$anonymous" file@$torrentPath "$cookie" | grep id= |cut -d = -f 2|cut -d & -f 1` 
    
    
        if [ -z "$t_id" ]; then
    	    t_id=`http -f POST $postUrl name="test" small_descr="something" descr="1111111" type="430" uplver="$anonymous" file@"$torrentPath" "$cookie"|grep hit=1|cut -d = -f 5|cut -d '&' -f 1`
        fi
    
    	download_url='https://hudbt.hust.edu.cn/download.php?id='$t_id
    
    	http -d $download_url -o "${watch_dir}${t_id}.torrent" "$cookie" 
    fi
}

function finish()
{
    rm -rf $html_page $descr_page $descr_bbcode 
}


#----------call function-----------#

get_descr "$1"

upload_torrent "$2"

if [ -f "${watch_dir}${t_id}.torrent" ]; then
    . ./auto_add.sh "${watch_dir}${t_id}.torrent"
fi

#--------------exit----------------#
trap finish EXIT
