#!/bin/bash
# FileName: auto_main.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-24
#
#-----------import settings-------------#

cd "$AUTO_ROOT_PATH"

. ./settings.sh

#----------------log func---------------#
function printLogo {
	echo "+++++++++++++++++++++++++++++++++"   >> $log_Path
	echo -e "[`date '+%Y-%m-%d %H:%M:%S'`] \c" >> $log_Path
	echo "发布了：[$TR_TORRENT_NAME]"          >> $log_Path
	echo "++++++++++++++[end]++++++++++++++"   >> $log_Path
}

#----------rename torrent file-----------#
function rename_torrent()
{
    IFS_OLD=$IFS
    IFS=$'\n'    
    #---loop for torrent in flexget path ---#
    for i in $(find $flexget_path -iname "*.torrent*" |awk -F "/" '{print $NF}')
    do  
    	new_torrent_name=`$trans_show "${flexget_path}$i"|grep Name|head -n 1|sed 's/Name: //'`
        if [ "$i" != "${new_torrent_name}.torrent" ]; then
            mv "${flexget_path}${i}" "${flexget_path}${new_torrent_name}.torrent"
        fi
        . ./get_tr.sh            # get TR_NAME 
    	if [ "$new_torrent_name" = "$TR_TORRENT_NAME" ]
        then
            IFS=$IFS_OLD
            echo -e "\n+++++++++++++[start]+++++++++++++" >> $log_Path

            up_status=1          # judge code
            echo "[`date '+%Y-%m-%d %H:%M:%S'`] 准备发布 [$TR_TORRENT_NAME]" >> $log_Path
            . ./auto_post.sh
            rm -f "$torrentPath" # delete uploaded torrent
            
            #---clean---#
            . ./auto_clean.sh
            #---re edit descr---#
            . ./edit.sh
            
            printLogo            # end
            TR_TORRENT_NAME=''   # next torrent
        fi
    done
    IFS=$IFS_OLD
}
#-------------start function------------#

if [ "$(find $flexget_path -iname '*.torrent*')" ]; then
    rename_torrent
fi
