#!/bin/bash
# FileName: auto_main.sh
#
# Author: rachpt@126.com
# Version: 1.0v
# Date: 2018-05-17
# Environmental requirements:
# - transmission-[show,remote,daemon or gtk]
# - httpie, head, awk, sed, find, grep, curl
# - cut, cat, mktemp, html2bbcode 
#----------------设置------------------#
trans_show="transmission-show"

#---include "/" end---#
flexget_path="/home/rc/Downloads/tmp/"

#moveTotPath="/home/rc/Downloads/finish/"
#logoPath="/home/rc/Downloads/finish/info"

#----------------日志函数---------------#
#function printLogo {
	#echo "=================================" >> $logoPath
	#echo "匹配成功"  >> $logoPath
	#echo "下载到了："$TR_TORRENT_DIR >> $logoPath
	#echo "种子编号："$TR_TORRENT_ID >> $logoPath
	#echo -e "于："$TR_TIME_LOCALTIME " \c" >> $logoPath
	#echo "完成对："$TR_TORRENT_NAME" 的移动！" >> $logoPath
#}

#----------rename torrent file-----------#
function rename_torrent()
{
    IFS_OLD=$IFS
    IFS=$'\n'
    
    for i in $(find $flexget_path -iname *.torrent* |awk -F "/" '{print $NF}')
    do  
    	new_torrent_name=`$trans_show "$i" |awk 'BEGIN{FS=":"} /Name/{print $2}' |head -n 1`
        if [ "$i" != "$new_torrent_name" ]; then
            mv "${flexget_path}${i}" "${flexget_path}${new_torrent_name}"
        fi

    	if [ "$new_torrent_name" = "$TR_TORRENT_NAME" ]
        then
            IFS=$IFS_OLD
            up_status=1
            . ./auto_uplaod.sh "$new_torrent_name" "$up_status"
        fi
    done

    IFS=$IFS_OLD
}
#----------------start---------------#

if [ "$(find $flexget_path -iname *.torrent*)" ]; then
    rename_torrent
fi


