# AutoSeed

Pt auto seed.

目前只适用于 从 HDSky 自动转载 iPad [普通 720p 也可以] 电影至 HUDBT 站。

自动生成并提交简介，依赖原种简介。

可以自动清理种子，不会爆仓。

[![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/rachpt/AutoSeed/master/LICENSE)

|  源站点（from）   |        转至（to）         | 时间（time） |
| :---------------: | :-----------------------: | :----------: |
| https://hdsky.me/ | https://hudbt.hust.edu.cn |  2018-05-19  |



## 环境要求

- GNU/Linux （在ubuntu 18.04 lts 测试通过）。
- 软件：
  - transmission-daemon，transmission-remote，transmission-show，
  - html2bbcode ，（python 模块）安装命令：`sudo pip3 install html2bbcode`，
  - httpie，安装命令`sudo apt-get install httpie`，
  - 其他常用软件工具，curl，grep等。

## 使用方法

1. clone 本 repo 至本地；
2. 修改设置文件`setting.sh`；
3. 添加 `auto_main.sh` 脚本路径至 transmission 的 `script-torrent-done-filename`。具体可以参见 [这里](https://rachpt.github.io/2018/03/25/transmission-settings/) ；
4. 如果 `transmission` 运行脚本诡异，可以将 `auto_main.sh` 添加到 `crontab`  之类的程序周期运行。


*其他：*

请使用 flexget 订阅下载，使用 [transmissionrpc](https://flexget.com/Plugins/transmission) 将源种传入 transmission。



一个运行 log：

```sh
+++++++++++++[start]+++++++++++++
[2018-05-19 22:15:33]
[2018-05-19 22:15:33] 准备发布 [Message.from.the.King.2016.BluRay.iPad.720p.AAC.x264-HDSPad]
+++++++++++++++++++++++++++++++++
[2018-05-19 22:15:33] 发布了：[Message.from.the.King.2016.BluRay.iPad.720p.AAC.x264-HDSPad]
=================================
+++++++++++++[start]+++++++++++++
[2018-05-19 22:16:45]
[2018-05-19 22:16:46] 准备发布 [Message.from.the.King.2016.BluRay.iPad.720p.AAC.x264-HDSPad]
1180 == 15 step 4 1179 1254
+++++++++++[post data]+++++++++++
name=Message from the King 2016 BluRay iPad 720p AAC x264-HDSPad 
 small_descr=国王口信 / 金恩的訊息(台) 
 url=tt1712192 
 type=430 
 standard_sel=3 
 uplver=yes
t_id: [138696]
++++++++++++++[add]++++++++++++++
+++++++++++++[clean]+++++++++++++
+++++++++++++++++++++++++++++++++
[2018-05-19 22:17:02] 发布了：[Message.from.the.King.2016.BluRay.iPad.720p.AAC.x264-HDSPad]
=================================
+++++++++++[delet tmp]+++++++++++

```

