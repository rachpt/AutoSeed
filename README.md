# AutoSeed

An Autoseed used to reseed Movies in PT sites powered by shell scripts. Get a python version [HERE](https://github.com/Rhilip/Pt-Autoseed).

目前适用于 从 HDSky / TTG / HDChina 自动转载 电影 [针对 iPad 资源特别优化] 至 HUDBT / WHUPT / NPUBITS / NanYangPT / BYRBT / 北洋园 PT 站。

[![release](https://img.shields.io/badge/Version-2.4-brightgreen.svg)](https://github.com/rachpt/AutoSeed/releases/tag/v2.4)  [![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/rachpt/AutoSeed/master/LICENSE)

|  源站点（from）   |      支持站点（to）      | 时间（time） |
| :---------------: | :-----------------------: | :----------: |
| https://hdsky.me/ | https://hudbt.hust.edu.cn |  2018-05-19  |
| https://totheglory.im/ | https://whu.pt |  2018-05-21  |
| https://hdchina.org | https://npupt.com |  2018-06-07 |
|                   | https://nanyangpt.com | 2018-06-07 |
|                   | https://bt.byr.cn | 2018-06-17 |
|                   | https://hdcmct.org  | 2018-07-28 |
|                   | https://tjupt.org  | 2018-08-28 |

## 特点

 - 自动生成并提交简介，尽量与原种简介一致。
 - 自动设置做种时间，分享率。自动清理种子，硬盘不会爆仓。
 - 支持自动 Dupe 以及禁转判断。
 - 开箱即用，不需要使用数据库等复杂操作。
 - 速度快，使用临时文件提前生成简介。
 - 自动判断并处理简介缺失海报情况。 


## 环境要求

- GNU/Linux （在ubuntu 18.04 lts 测试通过）。
- 软件：
  - transmission-daemon，transmission-remote，transmission-show，安装`sudo apt-get install transmission-cli`；
  - ~~html2bbcode，安装命令：`sudo pip3 install html2bbcode`~~(已经使用本地正则表达式实现，转换耗时小于0.6s)；
  - httpie，安装命令`sudo apt-get install httpie`；
  - 其他常用软件工具，curl，grep等(一般系统自带)。
  - 默认使用`python3`本地解析豆瓣简介(作为最后的办法)，感谢 [@Rhilip](https://github.com/Rhilip/PT-help/blob/master/modules/infogen/gen.py) 的脚本，Python依赖自行查看。

## 使用方法

1. clone 本 repo 至本地；
2. 修改设置文件`setting.sh`(包括cookie、passkey，监控 torrent 文件路径等)；
3. 添加 `main.sh` 脚本路径至 transmission 的 `script-torrent-done-filename`。具体可以参见 [这里](https://rachpt.github.io/2018/03/25/transmission-settings/) ；
4. 如果 `transmission` 运行脚本诡异，可以将 `main.sh` 添加到  `crontab` 之类的程序周期运行（运行锁会解决和3的冲突问题），提前生成简介依赖该项。


*其他：*

请使用 flexget 订阅下载，使用 [transmissionrpc](https://flexget.com/Plugins/transmission) 将源种传入 transmission。
如果 `crontab` 无法运行，参考命令 `*/5 * * * * /home/rachpt/shell/AutoSeed/main.sh >/dev/null 2>&1`。

如果种子名中使用了部分中文符号，比如已知的 `’` （中文单引号）会导致 httpie 文件传输失败，2.1版修复了中文单引号 bug。

python 并非必须，只需将 `setting.sh` 中的`USE_Local_Gen='yes'`改为其他值，即可使用基于 [web](https://rhilip.github.io/PT-help/ptgen) 的生成方法，只有原种简介不符合要求时才会主动生成。


一个运行 log：

```sh
+++++++++++++[start]+++++++++++++
[2018-06-10 22:51:41] 准备发布 [Pacific.Rim.Uprising.2018.BluRay.iPad.720p.AAC.x264-HDSPad]
2:tt2557478
+++++++++++[post data]+++++++++++
name=Pacific.Rim.Uprising.2018.BluRay.iPad.720p.AAC.x264-HDSPad
small_descr=Pacific Rim: Uprising 
imdburl=tt2557478
uplver=no
https://hudbt.hust.edu.cn
https://hdsky.me
t_id: [138967]
+++++++++++++[added]+++++++++++++
Dupe! [https://pt.whu.edu.cn]
+++++++++++[post data]+++++++++++
name=Pacific.Rim.Uprising.2018.BluRay.iPad.720p.AAC.x264-HDSPad
small_descr=Pacific Rim: Uprising 
imdburl=tt2557478
uplver=no
https://npupt.com
https://hdsky.me
t_id: [133088]
+++++++++++++[added]+++++++++++++
+++++++++++[post data]+++++++++++
name=Pacific.Rim.Uprising.2018.BluRay.iPad.720p.AAC.x264-HDSPad
small_descr=Pacific Rim: Uprising 
imdburl=tt2557478
uplver=no
https://nanyangpt.com
https://hdsky.me
t_id: [55997]
+++++++++++++[added]+++++++++++++
++++++++++[deleted tmp]++++++++++
+++++++++++++++++++++++++++++++++
[2018-06-10 22:52:09] 发布了：[Pacific.Rim.Uprising.2018.BluRay.iPad.720p.AAC.x264-HDSPad]
+++++++++++++[clean]+++++++++++++
++++++++++++++[end]+++++++++++++

```

## 更新日志
- 2018-08-28 --> 2.4
  - 添加对 北洋园pt 的支持。
  - 修复部分错误。

- 2018-08-23 --> 2.3
  - 添加对 CMCT 的支持，以后不再维护该项。
  - 提前生成简介(大约完成 70% 后开始，由 crontab 等驱动)。
  - 优化结构，添加处理非法简介代码。
  - 感谢 Rhilip 大佬的 python 模块。
  - whu.pt 暂时需要使用 `transmission-edit` 修改 tracker 添加 `s`。

- 2018-06-17 --> 2.2
  - 添加对 BYRBT 的支持，图片自动转至其服务器。
  - 添加处理脚本超时代码，默认 300 秒。
  - 修复可能导致 bug 的代码。
  - 这可能是最后一个 release 版本。

- 2018-06-15 --> 2.1
  - 修复 edit 中的错误参数。
  - 加强 Dupe 判断逻辑。
  - 修复 ttg 简介中 imdb 链接问题。
  - 修复 hdc 海报外链问题，海报转至图床 https://sm.ms/ 。
  - 修复几个分类判断问题。

- 2018-06-10 --> 2.0
  - 更新至2.0版。
  - 支持三个源站点获取简介，不只是 iPad类型。
  - 添加对南洋PT以及蒲公英PT的支持。
  - 添加Dupe以及禁转判断代码。
  - 使用本地正则表达式转换html至bbcode。
  - 框架重构。

- 2018-06-07 --> v1.7 （未发布）
  - 添加对 NPUBITS 的支持。
  - 修复上版 v1.6 引入的 bug。

- 2018-06-04 --> v1.6
  - 添加代码防止重复运行扰乱生成 LOG。
  - 添加基于网络的 [html2bbcode](https://www.garyshood.com/htmltobb/) 代码。
  - 使用绝对路径。
  - 已知 bug：后台自动运行程序在 html2bbcode 处 bug，终端手动运行程序无此问题。

- 2018-05-24 --> v1.5
  - 修复简介获取失败，添加通过 detail 页面获取简介以及二次编辑代码(基于LOG)。
  - 修复一些 bug。

- 2018-05-21 --> v1.4
  - 进一步模块化，添加对 WHUPT 的支持。

- 2018-05-19 --> v1.2 v1.3
  - 完成 debug 工作。

- 2018-05-17 --> v1.0
  - 首次提交，错误较多。

## 实现流程（v1.6）

```flow
st=>start: 导入settings
cond1=>condition: 监控目录是否有torrent文件?
cond2=>condition: 变量TR_TORRENT_NAME是否为空?
op1=>operation: 使用transmission-show重命名tr文件
op2=>operation: 遍历每个tr文件
cond3=>condition: 种子Name与完成种子匹配?
op3=>operation: 生成种子Name
op4=>operation: 获取简介页面
op5=>operation: 设置TR_TORRENT_NAME等于匹配项name
op6=>operation: 根据 item 生成数组，用于截断简介
cond4=>condition: Name遍历item，包含？
op7=>operation: 过滤得到简介
op8=>operation: 使用自定义消息代替
op9=>operation: 根据enable项分别post发布
cond5=>condition: 得到发布种子ID?
op10=>operation: 构造下载链接（包含passkey）至tr-remote
op11=>operation: 添加链接，设置下载位置至TR_TORRENT_DIR
op12=>operation: 设置ratio，进入clean
op13=>operation: 清理中间文件
op14=>operation: 清理有问题的种子（红种），不删数据
op15=>operation: 清理在TR_TORRENT_DIR中的不在tr列表的文件
cond6=>condition: free空间是否符合settings值？
op16=>operation: 清理tr中完成状态的种子
e=>end: 退出

st->cond1
cond1(yes)->cond2
cond1(no)->e
cond2(yes)->op1->op3->op4->op6->cond4
cond2(no)->op2->cond3
cond3(no)->e
cond3(yes)->op5->op1
cond4(no)->op8->op9
cond4(yes)->op7->op9->cond5
cond5(no)->op13->e
cond5(yes)->op10->op11->op12->op14->op15->cond6
cond6(no)->op16->cond6
cond6(yes)->e
```
