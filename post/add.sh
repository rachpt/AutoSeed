#!/bin/bash
# FileName: post/add.sh
#
# Author: rachpt@126.com
# Version: 2.4.2v
# Date: 2018-10-25
#
#-------------settings----------------#

torrent2add="${download_url}&passkey=${passkey}"

#-------------functions---------------#
function set_ratio() {
    for oneTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'|sed 's/\*//g'|sort -nr`
    do
	    local oneTorrent=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'Name'|head -1|sed 's/Name: //'`
  
	    local set_commit_hudbt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'hudbt.hust.edu.cn'`
	    local set_commit_whu=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'whupt'`
	    local set_commit_npupt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'npupt.com'`
	    local set_commit_nanyangpt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.nanyangpt.com'`
	    local set_commit_byrbt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.byr.cn'`
	    local set_commit_cmct=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.hdcmct.org'`
	    local set_commit_tjupt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tjupt.org'`
	    #---add new site's seed ratio here---#
	    #set_commit_new=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.new.com'
	    	    
        if [ "$TR_TORRENT_NAME" = "$oneTorrent" ]; then
        
            if [ -n "$set_commit_hudbt" ]; then
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_hudbt
                [[ $Allow_Say_Thanks = 'yes' && $say_thanks_hudbt = 'yes' ]] && http --ignore-stdin -f POST "https://hudbt.hust.edu.cn/thanks.php" id="$t_id" "$cookie" &> /dev/null
                break
            elif [ -n "$set_commit_whu" ]; then
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_whu
                [[ $Allow_Say_Thanks = 'yes' && $say_thanks_whu = 'yes' ]] && http --ignore-stdin -f POST "https://whu.pt/thanks.php" id="$t_id" "$cookie" &> /dev/null
                break
            elif [ -n "$set_commit_npupt" ]; then
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_npupt
                #http --ignore-stdin -f POST "https://npupt.com/thanks.php" id="$t_id" "$cookie" # not work!
                break
            elif [ -n "$set_commit_nanyangpt" ]; then
                sleep 1
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_nanyangpt
                sleep 4
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_nanyangpt
                [[ $Allow_Say_Thanks = 'yes' && $say_thanks_nanyangpt = 'yes' ]] && http --ignore-stdin -f POST "https://nanyangpt.com/thanks.php" id="$t_id" "$cookie" &> /dev/null
                break
            elif [ -n "$set_commit_byrbt" ]; then
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_byrbt
                http --ignore-stdin GET "https://bt.byr.cn/retriver.php?id=${t_id}&type=2&siteid=2" "$cookie"
                [[ $Allow_Say_Thanks = 'yes' && $say_thanks_byrbt = 'yes' ]] && http --ignore-stdin -f POST "https://bt.byr.cn/thanks.php" id="$t_id" "$cookie" &> /dev/null
                break
            elif [ -n "$set_commit_cmct" ]; then
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_cmct
                [[ $Allow_Say_Thanks = 'yes' && $say_thanks_cmct = 'yes' ]] && http --ignore-stdin -f POST "https://hdcmct.org/thanks.php" id="$t_id" "$cookie" &> /dev/null
                break	            
            elif [ -n "$set_commit_tjupt" ]; then
                "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_tjupt
                [[ $Allow_Say_Thanks = 'yes' && $say_thanks_tjupt = 'yes' ]] && http --ignore-stdin -f POST "https://tjupt.org/thanks.php" id="$t_id" "$cookie" &> /dev/null
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
function add_torrent_special_for_whupt() {
    http --ignore-stdin -d "$torrent2add" -o "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent" &> /dev/null
    transmission-edit -r 'http://' 'https://' "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent" &> /dev/null

    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent" -w "$TR_TORRENT_DIR"
    rm -f "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent"
}

#-----------call function-------------#
if [ "$TR_TORRENT_DIR" ]; then
    if [ "$postUrl" = 'https://whu.pt/takeupload.php' ]; then
        add_torrent_special_for_whupt
    else
        #---add torrent---#
        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "$torrent2add" -w "$TR_TORRENT_DIR"
    fi
    #---set seed ratio---#
    set_ratio
    echo "+++++++++++++[added]+++++++++++++" >> "$log_Path"
else
    echo "没有找到本地文件！" >> "$log_Path"
fi
#-------------------------------------#
