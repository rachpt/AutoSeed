#!/bin/bash
# FileName: qbittorrent.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-05
#
#--------------------------------------#
qb_login="${qb_HOST}:$qb_PORT/api/v2/auth/login"
qb_add="${qb_HOST}:$qb_PORT/api/v2/torrents/add"
qb_delete="${qb_HOST}:$qb_PORT/api/v2/torrents/delete"
qb_ratio="${qb_HOST}:$qb_PORT/api/v2/torrents/setShareLimits"
qb_lists="${qb_HOST}:$qb_PORT/api/v2/sync/maindata"
#--------------------------------------#
qbit_webui_cookie() {
    if [ "$(http --ignore-stdin -b GET "${qb_HOST}:$qb_PORT" "$qb_Cookie"|grep 'id="username"')" ]; then
        qb_Cookie="cookie:$(http --ignore-stdin -hf POST "$qb_login" username="$qb_USER" password="$qb_PASSWORD"|sed -En '/set-cookie:/{s/.*(SID=[^;]+).*/\1/i;p;q}')"
        # 更新 qb cookie
        if [ "$qb_Cookie" ]; then
            sed -i "s/^qb_Cookie=.*/qb_Cookie=\'$qb_Cookie\'/" "$ROOT_PATH/settings.sh" 
        else
            echo 'Failed to get qb cookie!' >> "$debug_log"
        fi
    fi
}
#--------------------------------------#

qb_add_torrent_url() {
    qbit_webui_cookie
    # add url
    http --ignore-stdin -f POST "$qb_add" urls="$torrent2add" root_folder=true savepath="$one_TR_Dir" skip_checking=true "$qb_Cookie"
}
#---------------------------------------#
qb_add_torrent_file() {
    qbit_webui_cookie
    $tr_edit -r 'http://' 'https://' "${ROOT_PATH}/tmp/${t_id}.torrent"
    # add file
    http --ignore-stdin -f POST "$qb_add" skip_checking=true root_folder=true name@"${ROOT_PATH}/tmp/${t_id}.torrent"  savepath="$one_TR_Dir" "$qb_Cookie"
    #  ----> ok
}

#---------------------------------------#
qb_delete_torrent() {
    qbit_webui_cookie
    # delete
    http --ignore-stdin -f POST "$qb_delete" hashes=$torrent_hash deleteFiles=false  "$qb_Cookie"
}

#---------------------------------------#
qb_set_ratio() {
    qbit_webui_cookie
    # from tr name find other info
    local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" "$qb_Cookie"|sed -Ee '1,/"torrents": \{/d;/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'|grep -B18 -A13 'name":'|sed -Ee '/".{40}"/{s/"//g};/"completed":/{s/"//g};/"magnet_uri":/{s/"//g};/"name":/{s/"//g};/"save_path":/{s/"//g};/"size":/{s/"//g};'|sed '/"/d')" 

    while true; do
        # get torrent hash
        torrent_hash="$(echo "$data"|grep -B4 'name.*'"$one_TR_Name"|head -1|grep -Eo '[0-9a-zA-Z]{40}')"
        [ ! "$torrent_hash" ] && break

        tracker_one="$(echo "$data"|grep -B1 'name.*'"$one_TR_Name"|tail -1|grep 'tracker')"
        if [ "$(echo "$tracker_one"|grep "$add_sites_tracker")" ];then
            if [ "${#torrent_hash}" -eq 40 ]; then
                # set ratio
                [[ $ratio_set ]] && \
                http --ignore-stdin -f POST "$qb_ratio" hashes="$torrent_hash" \
                ratioLimit=$ratio_set seedingTimeLimit="$(echo ${MAX_SEED_TIME}*60*60|bc)" "$qb_Cookie"
            else
                echo 'Failed to get torrent ID' >> "$debug_log"
            fi
        else
            # delete the first name matched
            data="$(echo "$data"|sed "0,/name.*$one_TR_Name/{//d}")"
        fi
    done
}
  
#---------------------------------------#
qb_get_torrent_completion() {
    qbit_webui_cookie
    # need a parameter
    local data="$(http --ignore-stdin --pretty=format GET "$qb_lists" "$qb_Cookie"|sed -Ee '1,/"torrents": \{/d;/^[ ]*[},]+$/d;s/^[ ]+//;s/[ ]+[{]+//;s/[},]+//g'|grep -B18 -A13 'name":'|sed -Ee '/".{40}"/{s/"//g};/"completed":/{s/"//g};/"magnet_uri":/{s/"//g};/"name":/{s/"//g};/"save_path":/{s/"//g};/"size":/{s/"//g};'|sed '/"/d')" 
    # match no more than one!
    local compl_one="$(echo "$data"|grep -B2 'name.*'"$1"|head -1|grep -Eo '[0-9]{4,}')"
    local size_one="$(echo "$data"|grep -A2'name.*'"$1"|tail -1|grep -Eo '[0-9]{4,}')"
    # return completed precent
    awk -v a="$compl_one" -v b="$size_one" 'BEGIN{printf "%d\n",(a/b)*100}'
}
#---------------------------------------#
