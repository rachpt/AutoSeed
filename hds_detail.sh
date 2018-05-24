#!/bin/bash
# FileName: hds_detail.sh
#
# Author: rachpt@126.com
# Version: 1.5v
# Date: 2018-05-23
#
#-------------------------------------#
hds_html_page=`mktemp /tmp/HDS.detail.XXXXXXXXXX`

hds_t_id=`http "https://hdsky.me/torrents.php?search=$new_torrent_name" "Cookie:$cookie_hds"|grep 'href="details.php?id='|head -n 1|awk -F 'id=' '{print $2}'|awk -F '&amp' '{print $1}'`

if [ -n "$hds_t_id" ]; then
    http "https://hdsky.me/details.php?id=${hds_t_id}" "Cookie:$cookie_hds" > ${hds_html_page}

    start_line_html=`grep -n '</tr></table></td></tr>' "$hds_html_page" |head -n 1|awk -F : '{print $1}'`
    end_line_html=`grep -n '</div></td></tr>$' "$hds_html_page" |head -n 1|awk -F : '{print $1}'`
    
    sed -n "`expr ${start_line_html} + 1`,${end_line_html} p" $hds_html_page|sed 's#.*lt="ad" /></a></div>##' > $descr_page

else
    echo failed to get hds t_id $hds_t_id >> $log_Path
fi

rm -f $hds_html_page

