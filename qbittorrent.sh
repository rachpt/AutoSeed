#!/bin/bash
# FileName: qbittorrent.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-01-20
#
#--------------------------------------#
qbit_webui_cookie() {
    if [ "$(http -b GET "http://${qb_HOST}:$qb_PORT" "$qb_Cookie"|grep 'id="username"')" ]; then
        qb_Cookie="Cookie: $(http -hf POST "http://${qb_HOST}:$qb_PORT/api/v2/auth/login" username="$qb_USER" password="$qb_PASSWORD"|sed -En '/set-cookie:/{s/.*(SID=[^;]+).*/\1/i;p;q}')"
        # 更新 qb cookie
        if [ "$qb_Cookie" ]; then
            sed -i "s/^qb_Cookie=*/qb_Cookie=\'$qb_Cookie\'/" "$AUTO_ROOT_PATH/settings.sh" 
        else
            echo 'Failed to get qb cookie!' >> "$debug_log"
        fi
    fi
}
#--------------------------------------#

qb_add_torrent() {

    # add url
    http -f POST 'http://127.0.0.1:8080/api/v2/torrents/add' urls="$bt1"  savepath='/srv/tmp/' skip_checking=true root_folder=true "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"
    # add file
    http -f POST 'http://127.0.0.1:8080/api/v2/torrents/add' name@"$tmp_tr_path"  savepath='/srv/tmp/' skip_checking=true root_folder=true "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"
    #  ----> ok

    # delete
    http -f POST 'http://127.0.0.1:8080/api/v2/torrents/delete' hashes=aaaaaaaaaaaaaa36586182d645835fc23d557e1 deleteFiles=false  "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"
    
    # set ratio
    http -f POST 'http://127.0.0.1:8080/api/v2/torrents/setShareLimits' hashes=aaaaaaaaaaaaaa36586182d645835fc23d557e1 ratioLimit=99 seedingTimeLimit=6643646  "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"
    
    
    
    # get tr lists
    http GET 'http://127.0.0.1:8080/api/v2/sync/maindata?jopru' "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"
    
    
    
    # from tr name find other info
    http --pretty=format GET 'http://127.0.0.1:8080/api/v2/sync/maindata' "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"|grep -A 9 -B 18 '60分钟企业经营战略：10倍速商业经典.CHM'
    
    # form tracker get hash ID
    hash_ID="$(http --pretty=format GET 'http://127.0.0.1:8080/api/v2/sync/maindata' "Cookie: SID=fJrHLOTy6RacX8yZTaaaaaaaaaaaaaa"|grep -A 9 -B 19 '60分钟企业经营战略：10倍速商业经典.CHM'|grep -EB 15 'magnet:[^,]*tracker\.byr\.cn' |head -1|sed 's/[ ":{]//g;')"
    if [ "${#hash_ID}" -eq 40 ]; then
        # set ratio
        :
    else
        echo 'Failed to get torrent ID' >> "$debug_log"
    fi

}
