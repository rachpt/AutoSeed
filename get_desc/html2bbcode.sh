#!/bin/bash
# FileName: get_desc/html2bbcode.sh
#
# Author: rachpt@126.com
# Version: 2.0v
# Date: 2018-06-10
#
#-------------------------------------#
sed -i "s#<strong>#[b]#g;s#</strong>#[/b]#g" "$source_detail_desc"
sed -i "s#<span[^>]*>##g;s#</span>##g;s#<p[^>]*>##g;s#</p>##g;s#<tr[^>]*>##g;s#</tr>##g;s#<td[^>]*>##g;s#</td>##g" "$source_detail_desc"
sed -i "s#<div[^>]*>##g;s#</div>##g" "$source_detail_desc"
sed -i "s#<u>#[u]#g;s#</u>#[/u]#g;s#<p[^>]\*>##g;s#</p>##g;" "$source_detail_desc"  # ttg

#---color & size---#
sed -i "s#<font color=\"\([^\"]\+\)\">\([^<]\+\)</font>#[color=\1]\2[/color]#g" "$source_detail_desc"

sed -i "s#\(font size=.*\)</font>#\1[/size]#g" "$source_detail_desc"

sed -i "s#<font size=\"\([^\"]\+\)\"[^>]*>#[size=\1]#g" "$source_detail_desc"
#sed -i "s#<font color=\"\([^\"]\+\)\"[^>]*>#[color=\1]#g" "$source_detail_desc"

#---br---#
sed -i "s/<br \/>//g;s/<br\/>//g;s/<br>//g;s/&nbsp;/ /g" "$source_detail_desc"

#---font face---#
sed -i "s/<font face=\"[cC]ourier [nN]ew\">/[font=monospace]/g;s/<font face=\"monospace\">/[font=monospace]/g;s/<\/font>/[\/font]/g" "$source_detail_desc"

#---table---#
sed -i "s#<table[^>]\+>#[quote]#g;s#</table>#[/quote]\n#g;" "$source_detail_desc"

#---img---#
sed -i "s#<img[^>]\+src=\"\(.[^\"]\+\)\"[^>]*>#[img]\1[/img]#g" "$source_detail_desc"
sed -i "s#\(.*\)attachments\(.*\)#\1${source_site_URL}/attachments\2#g" "$source_detail_desc"

#---a---#
sed -i "s#</a>#[/url]#g;s#<a[^>]\+href=\"\(.[^\"]\+\)\"[^>]*>#[url=\1]#g" "$source_detail_desc"

#---hdsky & hdchina---#
sed -i "s#<legend>[^>]\+引用[^>]\+</legend>##g;s#fieldset#quote#g" "$source_detail_desc"

#---others---#
sed -i "s#<#[#g;s#>#]#g" "$source_detail_desc"

#---double url---#
sed -i "s#\[url=[^\]]\+/\]\[url=\(.*\)\[/url\]\[/url\]#[url=\1[/url]#g" "$source_detail_desc"

#---get subname---#
if [ -n "`grep "CH[ST]" "$source_detail_desc"`" ]; then
    subname_chs_include='中文字幕'
else
    subname_chs_include=''
fi
    
subname_1=`grep "译　　名" "$source_detail_desc" |sed 's/.*译[　 ]*名[　 ]*//;s/<br \/>//g;s/\n//g;s/\r//g'`
subname_2=`grep "片　　名" "$source_detail_desc" |sed 's/.*片[　 ]*名[　 ]*//;s/<br \/>//g;s/\n//g;s/\r//g'`

if [ -z "$imdbUrl" ]; then
	imdbUrl="$(grep -o 'tt[0-9]\{7\}' "$source_detail_desc"|head -n 1)"
	echo 2:"$imdbUrl" >> "$log_Path"
fi

