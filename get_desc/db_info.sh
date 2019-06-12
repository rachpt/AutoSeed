#!/bin/bash
# FileName: get_desc/db_info.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2019-05-24
#
#-------------------------------------#
# https://github.com/Rhilip/PT-help/blob/master/modules/infogen/gen.py
# 的 bash 实现，豆瓣apikey 随机选择。
#-------------------------------------#
# 处理 json 信息
get_json_values_by_awk() { 
  awk -v json="$1" -v key="$2" -v defaultValue="" 'BEGIN{
  foundKeyCount = 0; sp = 0;
  while (length(json) > 0) {
    pos = match(json, "\""key"\"[ \\t]*?:[ \\t]*");
    if (pos == 0) {if (foundKeyCount == 0) {print defaultValue;} exit 0;}

    ++foundKeyCount;
    start = 0; stop = 0; layer = 0;
    for (i = pos + length(key) + 1; i <= length(json); ++i) {
      lastChar = substr(json, i - 1, 1)
      currChar = substr(json, i, 1)

      if (start <= 0) {
        if (lastChar == ":") {
          start = currChar == " " ? i + 1: i;
          if (currChar == "{" || currChar == "[") { layer = 1; ++sp; }
        }
      } else {
        if (currChar == "{" || currChar == "[") { ++layer; ++sp; }
        if (currChar == "}" || currChar == "]") { --layer; }
        if ((currChar == "," || currChar == "}" || currChar == "]") && layer <= 0) {
          stop = currChar == "," ? i : i + 1 + layer;
          break;
        }
      }
    }

    if (start <= 0 || stop <= 0 || start > length(json) || stop > length(json) || start >= stop) {
      if (foundKeyCount == 0) {print defaultValue;} exit 0;
    } else {
      if (sp == 0) { ++sp; }
      print substr(json, start + sp, stop - start - 2 * sp);
    }

    json = substr(json, stop + 1, length(json) - stop)
  }
  }' 
}

#-------------------------------------#
# 豆瓣详情页面，获取中英文名、集数、获奖信息、imdb链接
douban_page() {
  local db_pg _chinese_title _foreign_title _aka
  unset this_title trans_title episodes awards
  db_pg="$(http -Ib --pretty=format "${1%/}/" "$user_agent"|sed \
    '/<meta/d;/<script/d;/<!/d;s/^ *//g;/^ *$/d;s/ *$//g')"
  if [[ -n $db_pg ]]; then
  _chinese_title="$(echo "$db_pg"|grep -A1 '<title>'|tail -1|sed 's/(豆瓣)//')"
  _aka="$(echo "$db_pg"|grep '又名'|sed 's/.*span> *//;s/<br.*//;s% / %/%g')"
  _foreign_title="$(echo "$db_pg"|grep 'property="v:itemreviewed"'| \
    sed "s/.*\">$_chinese_title *//;s/<.*//")"
  [[ $_foreign_title ]] && {
    [[ $_aka ]] && trans_title="$_chinese_title/$_aka" || trans_title="$_chinese_title"
    this_title="$_foreign_title"
  } || {
    [[ $_aka ]] && trans_title="$_aka"
    this_title="$_chinese_title"
  }
  [[ $imdb_link ]] || imdb_link="https://www.imdb.com/title/$(echo "$db_pg"| \
    grep -Eo 'tt[0-9]+'|head -1)/"
  episodes="$(echo "$db_pg"|grep  '<span class="pl">集数:'|grep -Eo '[0-9]+')"
  awards="$(http -Ib --pretty=format "${1%/}/awards/" "$user_agent"|grep -A30 \
    'class="awards"'|grep -v '<li><a'|grep -Eo '>[^<;]+<'|sed 's/[<>]//g;s/^/　　&/')"
  export chs_name_douban="$_chinese_title"
  export eng_name_douban="$_foreign_title"
  fi
}
#-------------------------------------#
# imdb详情页面json数据，获取评分以及 Amazon 海报
imdb_page() {
  local im_json
  unset imdb_img imdb_rating num_raters_im
  im_json="$(printf "`http -Ib --pretty=format "${1%/}/" "$user_agent"|sed \
    '1,\%<script type="application/ld+json">%d'|sed '\%</script>%,$ d;s/[ ]*//g'`")"
  if [[ -n $im_json ]]; then
    imdb_rating="$(get_json_values_by_awk "$im_json" 'aggregateRating'|grep -Eo \
      '"ratingValue": *".*"'|grep -Eo "[0-9\.]+")"
    num_raters_im="$(get_json_values_by_awk "$im_json" 'aggregateRating'|grep -Eo \
      '"ratingCount": *[0-9]+'|grep -Eo '[0-9]+')"
    imdb_img="$(get_json_values_by_awk "$im_json" 'image')"
  fi
}

#-------------------------------------#
# 通过两个豆瓣api接口，获取大部分信息，并打印
gen_format_desc() {
# 参数 tt1234567 或者 12345678
json="`http -b -I --pretty=format "$base_url/${1}?apikey=$2" "$user_agent"| \
  sed ':a;N;s/\n//;t a;'|sed -E 's/[ ]+//g'`"
[[ `echo "$json"|grep -E 'code":104|code":5000'` ]] && json=''
if [[ -n "$json" ]]; then
local poster year region genre language playdate douban_rating num_raters_db
local duration director writer cast tags introduction
#-----------
poster="$(get_json_values_by_awk "$json" 'image'|sed 's/s_ratio_/l_ratio_/;s/img3/img1/')"
[[ -n $douban_link ]] || douban_link="$(get_json_values_by_awk "$json" 'alt'|sed 's%movie/%subject/%')"
year="$(get_json_values_by_awk "$json" 'year')" 
region="$(get_json_values_by_awk "$json" 'country'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"
genre="$(get_json_values_by_awk "$json" 'movie_type'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"
language="$(get_json_values_by_awk "$json" 'language'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"
playdate="$(get_json_values_by_awk "$json" 'pubdate'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"

douban_rating="$(get_json_values_by_awk "`get_json_values_by_awk "$json" 'rating'`" 'average')"
num_raters_db="$(get_json_values_by_awk "$json" 'rating'|grep -Eo '"numRaters":[0-9]+'|grep -Eo '[0-9]+')"
[[ -n $douban_link ]] || \
douban_link="$(get_json_values_by_awk "$json" 'alt'|sed 's%/movie/%/subject/%')"

[[ -n $douban_link ]] && douban_page "$douban_link"
[[ -n $imdb_link ]] && imdb_page "$imdb_link"

duration="$(get_json_values_by_awk "$json" 'movie_duration'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"

director="$(get_json_values_by_awk "$json" 'director'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"
writer="$(get_json_values_by_awk "$json" 'writer'|sed ':a;N;s/\n//;t a;'|sed 's%","%/%g')"
cast="$(get_json_values_by_awk "$json" 'cast'|sed 's/","/\n/g'|sed '1 ! {s/^/　　　　　　&/g}')"

tags="$(get_json_values_by_awk "`get_json_values_by_awk "$json" 'tags'`" 'name'| \
  sed ':a;N;s/\n/\|/;t a;'|sed 's%","%/%g')"
introduction="$(get_json_values_by_awk "$json" 'summary'|sed ':a;N;s/\n//;t a;')"
#----------
export douban_poster_url="$poster"
# print
[[ -n $poster ]] && \
    echo "[img]$poster[/img]"
[[ -n $imdb_img ]] && echo -e "Amazon poster:\n$imdb_img\n" || echo ''
[[ -n $trans_title ]] && \
    echo "◎译　　名　$trans_title"
[[ -n $this_title ]] && \
    echo "◎片　　名　$this_title"
[[ -n $year ]] && \
    echo "◎年　　代　${year//\"/}"
[[ -n $region ]] && \
    echo "◎产　　地　${region//\"/}"
[[ -n $genre ]] && \
    echo "◎类　　别　${genre//\"/}"
[[ -n $language ]] && \
    echo "◎语　　言　${language//\"/}"
[[ -n $playdate ]] && \
    echo "◎上映日期　${playdate//\"/}"
[[ -n $imdb_rating ]] && {
    echo -e "◎IMDb评分  $imdb_rating\c" && \
    [[ -n $num_raters_im ]] &&  echo " from $num_raters_im users" || echo ''; }
[[ -n $imdb_link ]] && \
    echo "◎IMDb链接  $imdb_link"
[[ -n $douban_rating ]] && {
    echo -e "◎豆瓣评分　$douban_rating\c" && \
    [[ -n "$num_raters_db" ]] && echo " from $num_raters_db users" || echo ''; }
[[ -n $douban_link ]] && \
    echo "◎豆瓣链接　$douban_link"
[[ -n $episodes ]] && \
    echo "◎集　　数　$episodes"
[[ -n $duration ]] && \
    echo "◎片　　长　${duration//\"/}"
[[ -n $director ]] && \
    echo "◎导　　演　${director//\"/}"
[[ -n $writer ]] && \
    echo "◎编　　剧　${writer//\"/}"
[[ -n $cast ]] && \
    echo "◎主　　演　${cast//\"/}"
echo -e "\n"
[[ -n $tags ]] && \
    echo -e "◎标　　签　$tags\n"
[[ -n $introduction ]] && \
    echo -e "◎简　　介  \n　　$introduction\n"
[[ -n $awards ]] && \
    echo -e "◎获奖情况  \n$awards\n"
fi
}
#---------------main------------------#
[[ $1 =~ https?://(movie.)?douban.com/subject/[0-9]+/? ]] && \
  _kw="$(echo "$1"|grep -Eo '[0-9]+')" || {
[[ $1 =~ https?://www.imdb.com/title/tt[0-9]+/? ]] && \
  _kw="$(echo "$1"|grep -Eo 'tt[0-9]+')"; }
[[ -z $_kw ]] && _kw="$1" # 简略形式

db_apikey_1='02646d3fb69a52ff072d47bf23cef8fd'
db_apikey_2='0b2bdeda43b5688921839c8ecb20399b'
db_apikey_3='0dad551ec0f84ed02907ff5c42e8ec70'
db_apikey_4='0df993c66c0c636e29ecbb5344252a4a'
db_apikey_5='07c78782db00a121175696889101e363'

[[ "$user_agent" ]] || \
user_agent='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0'

[[ $_kw =~ tt[0-9]+ ]] && {
    base_url='https://api.douban.com/v2/movie/imdb'
    imdb_link="https://www.imdb.com/title/$_kw/"
} || {
    base_url='https://api.douban.com/v2/movie'
    douban_link="https://movie.douban.com/subject/$_kw/"; }

_rand="$((1 + RANDOM % 5))"
gen_format_desc "$_kw" "$(eval echo '$'db_apikey_$_rand)"
_count=1
while [[ -z $json && $_count -le 5 ]]; do
  [[ $_rand -eq 5 ]] && _rand=1 || _rand=$((_rand + 1))
  gen_format_desc "$_kw" "$(eval echo '$'db_apikey_$_rand)"
  ((_count++))
done
unset json _rand _kw _count base_url imdb_img imdb_rating num_raters_im
unset this_title trans_title episodes awards
#-------------------------------------#

