#!/bin/bash
# FileName: post/add.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-09
#
#-------------settings----------------#

torrent2add="${download_url}&passkey=${passkey}"

#-------------functions---------------#
function set_ratio()
{
    for oneTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'|sed 's/\*//g'|sort -nr`
    do
	    oneTorrent=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep Name|awk '{print $2}'`
	    
	    set_commit_hust=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'hudbt.hust.edu.cn'`
	    set_commit_whu=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'whupt'`
	    set_commit_npupt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'npupt.com'`
	    set_commit_nanyangpt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.nanyangpt.com'`
	    #---add new site's seed ratio here---#
	    #set_commit_new=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.new.com'
	    	    
        if [ "$TR_TORRENT_NAME" = "$oneTorrent" ]; then
        
            if [ -n "$set_commit_hust" ]; then
		        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_hudbt
                break
            elif [ -n "$set_commit_whu" ]; then
		        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_whu
                break
            elif [ -n "$set_commit_npupt" ]; then
		        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_npupt
                break
            elif [ -n "$set_commit_nanyangpt" ]; then
	    	    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_nanyangpt
	    	    break
	    	#---add new site's seed ratio here---#
	    	#elif [ -n "$set_commit_new" ]; then
	    	#   "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_new
	    	#   break
            fi
        fi
    done
}

#------------add torrent--------------#
function add_torrent_to_TR()
{
    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "$torrent2add" -w "$TR_TORRENT_DIR"
    #---set seed ratio---#
    set_ratio
    echo "+++++++++++++[added]+++++++++++++" >> "$log_Path"
}
#-----------call function-------------#
if [ "$torrent2add" ]; then
    add_torrent_to_TR
fi
