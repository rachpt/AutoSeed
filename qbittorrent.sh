#!/bin/bash
# FileName: qbittorrent.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-11-21
#
#--------------------------------------#
qb_login="http://${qb_HOST}:$qb_PORT/api/v2/auth/login"
qb_add="http://${qb_HOST}:$qb_PORT/api/v2/torrents/add"
qb_delete="http://${qb_HOST}:$qb_PORT/api/v2/torrents/delete"
qb_ratio="http://${qb_HOST}:$qb_PORT/api/v2/torrents/setShareLimits"
qb_lists="http://${qb_HOST}:$qb_PORT/api/v2/sync/maindata"
#--------------------------------------#
qbit_webui_cookie() {
    if [ "$(http --ignore-stdin -b GET "http://${qb_HOST}:$qb_PORT" "$qb_Cookie"|grep 'id="username"')" ]; then
        qb_Cookie="Cookie: $(http --ignore-stdin -hf POST "$qb_login" username="$qb_USER" password="$qb_PASSWORD"|sed -En '/set-cookie:/{s/.*(SID=[^;]+).*/\1/i;p;q}')"
        # 更新 qb cookie
        if [ "$qb_Cookie" ]; then
            sed -i "s/^qb_Cookie=*/qb_Cookie=\'$qb_Cookie\'/" "$AUTO_ROOT_PATH/settings.sh" 
        else
            echo 'Failed to get qb cookie!' >> "$debug_log"
        fi
    fi
}
#--------------------------------------#

qb_add_torrent_url() {
    # add url
    http --ignore-stdin -f POST "$qb_add" urls="$torrent2add" root_folder=true \
        savepath="$one_TR_Dir" skip_checking=true "$qb_Cookie"
}
#---------------------------------------#
qb_add_torrent_file() {
    # add file
    http --ignore-stdin -f POST "$qb_add" skip_checking=true root_folder=true \
        name@"${AUTO_ROOT_PATH}/tmp/${t_id}.torrent"  savepath="$one_TR_Dir" \
        "$qb_Cookie"
    #  ----> ok
}

#---------------------------------------#
qb_delete_torrent() {
    # delete
    http --ignore-stdin -f POST "$qb_delete" hashes=aaaaaaaaaaaaa deleteFiles=false  "$qb_Cookie"
}

#---------------------------------------#
qb_set_ratio() {
    # set ratio
    http --ignore-stdin -f POST "$qb_ratio" hashes=aaaaaaaaaaaaaa ratioLimit=99 seedingTimeLimit="$(echo ${MAX_SEED_TIME}*60*60|bc)" "$qb_Cookie"
}
  
qb_get_torrent_info() {
    # get tr lists
    http --ignore-stdin GET "$qb_lists" "$qb_Cookie"
    
    
    
    # from tr name find other info
    http --ignore-stdin --pretty=format GET "$qb_lists" "$qb_Cookie"|grep -A 9 -B 18 "$one_TR_Name"
    
    # form tracker get hash ID
    hash_ID="$(http --ignore-stdin --pretty=format GET "$qb_lists" "$qb_Cookie"|grep -A 9 -B 19 "$one_TR_Name"|grep -EB 15 'magnet:[^,]*tracker\.byr\.cn' |head -1|sed 's/[ ":{]//g;')"
    if [ "${#hash_ID}" -eq 40 ]; then
        # set ratio
        :
    else
        echo 'Failed to get torrent ID' >> "$debug_log"
    fi
}
#---------------------------------------#
qb_get_torrent_completion() {
    qb_complete_and_size="$(http --ignore-stdin --pretty=format GET "$qb_lists" "$qb_Cookie"|grep -B 13 -A 13 "$1"|sed -ne 's/[ ,a-z:"]//g;1p;$p')"
    awk -v a="$(echo "$qb_complete_and_size"|head -1)" -v b="$(echo "$qb_complete_and_size"|tail -1)" 'BEGIN{printf "%d\n",(a/b)*100}'

}
#---------------------------------------#
