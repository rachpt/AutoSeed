#!/bin/bash
# FileName: test.sh
#
# Author: rachpt@126.com
# Version: 2.4.2v
# Date: 2018-10-23
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
    # 检测测试的标志，勿改！
    test_func_probe=1
    #---------------------#
    #---[hudbt]---#
    enable_hudbt='no'     # yes,发。其他值，不发。
    #---[whu]---#
    enable_whu='no'       # yes,发。其他值，不发。
    #---[npupt]---#
    enable_npupt='no'     # yes,发。其他值，不发。
    #---[nanyangpt]---#
    enable_nanyangpt='no' # yes,发。其他值，不发。
    #---[byrbt]---#
    enable_byrbt='no'     # yes,发。其他值，不发。
    #---[cmct]---#
    enable_cmct='no'      # yes,发。其他值，不发。
    #---[tjupt]---#
    enable_tjupt='yes'    # yes,发。其他值，不发。
    #
}
#--------------------------------------#
# 正式运行时，请注释掉下面一行，# test_func
#test_func

