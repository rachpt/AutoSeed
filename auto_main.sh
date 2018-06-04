#!/bin/bash
# FileName: auto_main.sh
#
# Author: rachpt@126.com
# Version: 1.6v
# Date: 2018-06-04
#
#-----------import settings-------------#
AUTO_ROOT_PATH='/home/rachpt/shell/auto'
cd "$AUTO_ROOT_PATH"
source /etc/profile
source ~/.bashrc
source ~/.profile

source "$AUTO_ROOT_PATH/settings.sh"

#----------------lock func--------------#
function is_locked()
{
    if [ -f "$lock_file" ]; then
        exit
    fi
}

function create_lock()
{
    touch "$lock_file"
}

function remove_lock()
{
    rm -f "$lock_file"
}
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
    create_lock  # lock file
    IFS_OLD=$IFS
    IFS=$'\n'    
    #---loop for torrent in flexget path ---#
    for i in $(find $flexget_path -iname "*.torrent*" |awk -F "/" '{print $NF}')
    do  
    	new_torrent_name=`$trans_show "${flexget_path}/$i"|grep Name|head -n 1|sed 's/Name: //'`
        if [ "$i" != "${new_torrent_name}.torrent" ]; then
            mv "${flexget_path}/${i}" "${flexget_path}/${new_torrent_name}.torrent"
        fi
        source "$AUTO_ROOT_PATH/get_tr.sh"            # get TR_NAME 
    	if [ "$new_torrent_name" = "$TR_TORRENT_NAME" ]
        then
            IFS=$IFS_OLD
            echo -e "\n+++++++++++++[start]+++++++++++++" >> $log_Path

            up_status=1          # judge code
            echo "[`date '+%Y-%m-%d %H:%M:%S'`] 准备发布 [$TR_TORRENT_NAME]" >> $log_Path
            source "$AUTO_ROOT_PATH/auto_post.sh"
            rm -f "$torrentPath" # delete uploaded torrent
            
            #---clean---#
            source "$AUTO_ROOT_PATH/auto_clean.sh"
            #---re edit descr---#
            #. "$AUTO_ROOT_PATH/edit.sh"
            
            printLogo              # end
            TR_TORRENT_NAME=''   # next torrent
        fi
    done
    IFS=$IFS_OLD
}
#-------------start function------------#

if [ "$disable_AutoSeed" = "yes" ]; then
    exit
fi
#---start check---#
if [ "$(find $flexget_path -iname '*.torrent*')" ]; then
    is_locked
    rename_torrent
    remove_lock
fi
