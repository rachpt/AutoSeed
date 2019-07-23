#!/bin/bash
# FileName: get_desc/customize.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-07-14
#
#-------------------------------------#
# 本文件对特定资源发布站点进行特殊设置，
# 配置文件路径 $ROOT_PATH/tmp/dupe-rules.txt，
# 调用需要一个全局变量，$dot_name.
#-------------------------------------#
#
my_dupe_rules() {
  local lists _d i _name _one_name _url _site _line
  lists="$ROOT_PATH/tmp/dupe-rules.txt"
  # 过滤后的数据
  _d="$(sed -E 's/[#＃].*//g;s/[ 　]+//g;/^$/d;s/[A-Z]/\l&/g' "$lists")"
  if [[ -f $lists && $(echo "$_d"|wc -l) -ge 1 ]]; then
    for ((i=1;i<=$(echo "$_d"|wc -l);i++)); do
      _name="$(echo "$dot_name"|sed 'y/。，？；：‘“、（）｀～！＠＃％＊ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/.,?;:\"\",()`~!@#%*abcdefghijklmnopqrstuvwxyz/')"
      _name="$(echo "${_name,,}"|sed 's/[\. 　]//g')"
      _line="$(echo "$_d"|sed -n "${i}{s/[\. 　]//g;p;q}")"
      _one_name="$(echo "$_line"|awk -F '+' '{print $NF}'|sed  "s/[\. 　]//g")"
      _one_name="$(echo "$_one_name"|sed 'y/。，？；：‘“、（）｀～！＠＃％＊ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/.,?;:\"\",()`~!@#%*abcdefghijklmnopqrstuvwxyz/')"
      [[ $_name =~ .*$_one_name.* ]] && {
        _site="$(echo "$_line"|awk -F '+' '{print NF}')" 
        ((_site>1)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $1}') =~ 1|yes ]] && enable_hudbt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $1}') =~ 0|no ]] && enable_hudbt='no'
        }
        ((_site>2)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $2}') =~ 1|yes ]] && enable_whu='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $2}') =~ 0|no ]] && enable_whu='no'
        }
        ((_site>3)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $3}') =~ 1|yes ]] && enable_npupt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $3}') =~ 0|no ]] && enable_npupt='no'
        }
        ((_site>4)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $4}') =~ 1|yes ]] && enable_nanyangpt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $4}') =~ 0|no ]] && enable_nanyangpt='no'
        }
        ((_site>5)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $5}') =~ 1|yes ]] && enable_byrbt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $5}') =~ 0|no ]] && enable_byrbt='no'
        }
        ((_site>6)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $6}') =~ 1|yes ]] && enable_cmct='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $6}') =~ 0|no ]] && enable_cmct='no'
        }
        ((_site>7)) && {
         [[ $(echo "$_line"|awk -F '+' '{print $7}') =~ 1|yes ]] && enable_tjupt='yes'
         [[ $(echo "$_line"|awk -F '+' '{print $7}') =~ 0|no ]] && enable_tjupt='no'
        }
        #source "$ROOT_PATH/static.sh"  # update trackers post_site
        debug_func 'dupe:use-customize-dupe-rules'  #----debug---
        break  # jump out
      } 
    done
  else
    debug_func ':dupe:no-dupe-rules-file!'  #----debug---
  fi
  # test tracker's status
  [[ ${completion:-100} -ge 92 && $HAVE_TESTED != yes ]] && {
    is_tracker_down      # static.sh
    HAVE_TESTED='yes'    # 减少重复测试
  }
}
#----------------------------------------#

