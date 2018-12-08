#!/bin/bash
# FileName: test.sh
#
# Author: rachpt@126.com
# Version: 3.0v
# Date: 2018-12-08
#
#--------------------------------------#
# 说明：该文件用于逐个测试站点情况，
# 仅用于 debug。
# 使用该测试文件的效果：
#   - 快速设置发布站点，
#   - 不会删除 tmp 中的简介文件，方便 debug，
#   - 不会删除已经发布的 .torrent 文件，
#   - 不会进入脚本超时控制模块，不会进入清理种子模块，
#   - 使用 test_func，会跳过种子下载完成检测(*)。
#--------------------------------------#
test_func() {
    test_func_probe=1
    #---[hudbt]---#
    enable_hudbt='no'
    #---[whu]---#
    enable_whu='no'
    #---[npupt]---#
    enable_npupt='no'
    #---[nanyangpt]---#
    enable_nanyangpt='no'
    #---[byrbt]---#
    enable_byrbt='no'
    #---[cmct]---#
    enable_cmct='no'
    #---[tjupt]---#
    enable_tjupt='no'
    #
}
#--------------------------------------#
# 正式运行时，请注释掉下面一行，# test_func
#test_func  #--
#
