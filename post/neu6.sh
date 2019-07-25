#!/bin/bash
# FileName: post/neu6.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2018-12-05
#
#-------------settings---------------#
cookie="$cookie_neu6"
passkey="$passkey_neu6"
anonymous="$anonymous_neu6"
ratio_set=$ratio_neu6
to_client="$client_neu6"
#---static---#
postUrl="${post_site[neu6]}/forum.php"
editUrl="${post_site[neu6]}/takeedit.php"
downloadUrl="${post_site[neu6]}/forum.php?mod=attachment&aid=NTMxNjc3NHw3OTU0OWY0NXwxNTUxNDEyMTUxfDY0NDE2OHwxNjQ2NDM5&ck=bfc4cae3"
#-------------------------------------#
# 需要的参数
gen_neu6_parameter() {

if [ -s "$source_desc" ]; then
neu6_des="${descrCom_simple//&ratio_in_desc&/$ratio_neu6}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
else
neu6_des="${descrCom_simple//&ratio_in_desc&/$ratio_neu6}
$failed_to_get_des"
fi

#-------------------------------------#
# 判断类型，纪录片、电影、剧集
if [ "$documentary" = 'yes' ]; then
    neu6_type='404'
    neu6_source='41'
else
  if [ "$serials" = 'yes' ]; then
    # 剧集分类
    neu6_type='402'
    case "$region" in
      *中国大陆*)
          neu6_source='23' ;;
      *香港*|*台湾*|*澳门*)
          neu6_source='24' ;;
      *日本*)
          neu6_source='26' ;;
      *韩国*)
          neu6_source='27' ;;
      *美国*)
          neu6_source='25' ;;
      *英国*)
          neu6_source='65' ;;
      *)
          neu6_source='63' ;;
    esac
  else
    # 电影类别
    neu6_type='401'
    case "$region" in
      *中国大陆*|*香港*|*台湾*|*澳门*)
          neu6_source='6' ;;
      *日本*|*韩国*)
          neu6_source='4' ;;
      *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*)
          neu6_source='5' ;;
      *)
          neu6_source='7' ;;
    esac

  fi
fi

    # 副标题
    neu6_small_descr="$chinese_title $chs_included"
#-------------------------------------#
    #---base64 encode---#
    des_enc="$(echo "$neu6_des"|base64)"
    name_enc="$(echo "$dot_name"|base64)"
    sub_title_enc="$(echo "$neu6_small_descr"|base64)"
}
neu6_tmp="$ROOT_PATH/tmp/neu6_tmp.html"
http 'http://bt.neu6.edu.cn/home.php' "$cookie_neu6" > "$neu6_tmp"
formhash="$(iconv -f GBK -t utf-8 neu6.html |grep -Eio 'formhash=[0-9a-z]+'|sed 's/.*=//')"
if [[ $formhash ]] && \rm -f "$neu6_tmp"
#-------------------------------------#
neu6_post_func() {
    gen_neu6_parameter
    #---post data---#
t_id="$(http --verify=no --ignore-stdin --print=h -f  POST "$postUrl"\
    mod==post action==newthread fid==156 topicsubmit==yes \
    'formhash'="$formhash"\
    'posttime'="$(date +%s)"\
    'subject'="$name_enc"\
    'wysiwyg'="1"\
    'message'="$des_enc"\
    'typeid'="$neu6_type"\
    'specialextra'="torrent"\
    'special'="127"\
    torrent@"${torrent_Path}"\
    "$cookie_neu6"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

    if [[ -z "$t_id" ]]; then
        # 辅种
        reseed_torrent
    fi
}

#-------------------------------------#

