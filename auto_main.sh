#!/bin/bash
# FileName: auto_main.sh
#
# Author: rachpt@126.com
# Version: 1.2v
# Date: 2018-05-19
#
#-----------import settings-------------#

. ./settings.sh

#----------------log func---------------#
function printLogo {
	echo "+++++++++++++++++++++++++++++++++"   >> $logoPath
	echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] \c" >> $logoPath
	echo "发布了：[$TR_TORRENT_NAME]"          >> $logoPath
	echo "================================="    >> $logoPath
}

#----------rename torrent file-----------#
function rename_torrent()
{
IFS_OLD=$IFS
    IFS=$'\n'
    
    for i in $(find $flexget_path -iname "*.torrent*" |awk -F "/" '{print $NF}')
    do  
    	new_torrent_name=`$trans_show "${flexget_path}$i" |awk 'BEGIN{FS=": "} /Name/{print $2}' |head -n 1`
        if [ "$i" != "${new_torrent_name}.torrent" ]; then
            mv "${flexget_path}${i}" "${flexget_path}${new_torrent_name}.torrent"
        fi

    	if [ "$new_torrent_name" = "$TR_TORRENT_NAME" ]
        then
            IFS=$IFS_OLD
            up_status=1
	    	echo "[`date '+%Y-%m-%d %H:%M:%S'`] 准备发布 [$TR_TORRENT_NAME]" >> $logoPath
            . ./auto_post.sh
	        printLogo          # end
        fi
    done

    IFS=$IFS_OLD
}
#-------------start function------------#

if [ "$(find $flexget_path -iname "*.torrent*")" ]; then
    echo "+++++++++++++[start]+++++++++++++" >> $logoPath
    rename_torrent
fi


