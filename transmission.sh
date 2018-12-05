#!/bin/bash
# FileName: transmission.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-11-21
#
#---------------------------------------#
#
#---path of transmission-remote---#
tr_remote="transmission-remote ${tr_HOST}:${tr_PORT} \
    --auth ${tr_USER}:${tr_PASSWORD}"

#---------------------------------------#

function tr_set_ratio() {
    for Tr_ID in $( $tr_remote -l|sed -En 's/^[ ]*([0-9]+).*/\1/gp'|sort -nr)
    do
	    name_in_tr=$($tr_remote -t $Tr_ID -i|awk -F 'Name: ' '/Name/{print $2}')
      if [ "$one_TR_Name" = "$name_in_tr" ]; then
          for tracker in ${!trackers[*]}; do
              [ "$($trans_remote -t $Tr_ID -i|grep "$trackers[$tracker]")" ] && \
                $tr_remote -t $Tr_ID -sr "$(eval echo '$'"ratio_$tracker")"
                # say thanks
                [[ $Allow_Say_Thanks != 'yes' ]] && \
                [[ "$(eval echo '$'"say_thanks_$tracker")" = 'yes' ]] && \
                http --ignore-stdin -f POST "${post_site[$tracker]}/thanks.php" \
                    id="$t_id" "$(eval echo '$'"cookie_$tracker")" && break
          done
      fi
    done
}

#------------add torrent--------------#
function tr_add_torrent_file()
{
    $tr_edit -r 'http://' 'https://' "${ROOT_PATH}/tmp/${t_id}.torrent"

    $tr_remote --add "${ROOT_PATH}/tmp/${t_id}.torrent" -w "$one_TR_Dir"
    #---set seed ratio---#
    tr_set_ratio
}

#------------add torrent--------------#
function tr_add_torrent_url()
{
    $tr_remote --add "$torrent2add" -w "$one_TR_Dir"
    #---set seed ratio---#
    tr_set_ratio
}

#---------------------------------------#

