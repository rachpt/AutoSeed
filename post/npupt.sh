#!/bin/bash
# FileName: post/npupt.sh
#
# Author: rachpt@126.com
# Version: 3.1v
# Date: 2018-12-05
#
#-------------settings---------------#
cookie="$cookie_npupt"
passkey="$passkey_npupt"
anonymous="$anonymous_npupt"
ratio_set=$ratio_npupt
to_client="$client_npupt"
#---static---#
postUrl="${post_site[npupt]}/takeupload.php"
editUrl="${post_site[npupt]}/takeedit.php"
downloadUrl="${post_site[npupt]}/download.php?id="
#-------------------------------------#
# 需要的参数
gen_npupt_parameter() {

if [ -s "$source_desc" ]; then
npupt_des="${descrCom_simple//&ratio_in_desc&/$ratio_npupt}
$(sed '/&shc_name_douban&/d;/&eng_name_douban&/d' "$source_desc")"
else
npupt_des="${descrCom_simple//&ratio_in_desc&/$ratio_npupt}
$failed_to_get_des"
fi

#-------------------------------------#
# 判断类型，纪录片、电影、剧集
if [ "$documentary" = 'yes' ]; then
    npupt_type='404'
    npupt_source='41'
else
  if [ "$serials" = 'yes' ]; then
    # 剧集分类
    npupt_type='402'
    case "$region" in
      *中国大陆*)
          npupt_source='23' ;;
      *香港*|*台湾*|*澳门*)
          npupt_source='24' ;;
      *日本*)
          npupt_source='26' ;;
      *韩国*)
          npupt_source='27' ;;
      *美国*)
          npupt_source='25' ;;
      *英国*)
          npupt_source='65' ;;
      *)
          npupt_source='63' ;;
    esac
  else
    # 电影类别
    npupt_type='401'
    case "$region" in
      *中国大陆*|*香港*|*台湾*|*澳门*)
          npupt_source='6' ;;
      *日本*|*韩国*)
          npupt_source='4' ;;
      *美国*|*英国*|*德国*|*法国*|*墨西哥*|*俄罗斯*|*西班牙*|*加拿大*|*澳大利亚*)
          npupt_source='5' ;;
      *)
          npupt_source='7' ;;
    esac

  fi
fi

    # 副标题
    npupt_small_descr="$chinese_title $chs_included"
#-------------------------------------#
    #---base64 encode---#
    des_enc="$(echo "$npupt_des"|base64)"
    name_enc="$(echo "$dot_name"|base64)"
    sub_title_enc="$(echo "$npupt_small_descr"|base64)"
}

#-------------------------------------#
npupt_post_func() {
    gen_npupt_parameter
    #---post data---#
t_id="$(http --verify=no --ignore-stdin --print=h -f  POST "$postUrl"\
    'name'="$name_enc"\
    'small_descr'="$sub_title_enc"\
    'descr'="$des_enc"\
    'type'="$npupt_type"\
    'source_sel'="$npupt_source"\
    'uplver'="$anonymous_npupt"\
    file@"${torrent_Path}"\
    "$cookie_npupt"|grep -om1 '[^a-z]detail[^;"]*id=[0-9]*'|grep -om1 '[0-9]*')"

    if [[ -z "$t_id" ]]; then
        # 辅种
        reseed_torrent
    fi
}

#-------------------------------------#

