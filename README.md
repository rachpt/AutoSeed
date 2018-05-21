# AutoSeed

Pt auto seed.

目前只适用于 从 HDSky 自动转载 iPad [普通 720p 也可以] 电影至 HUDBT/WHUPT 站。

自动生成并提交简介，依赖原种简介。

可以自动清理种子，不会爆仓。

[![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/rachpt/AutoSeed/master/LICENSE)

|  源站点（from）   |        转至（to）         | 时间（time） |
| :---------------: | :-----------------------: | :----------: |
| https://hdsky.me/ | https://hudbt.hust.edu.cn |  2018-05-19  |
| https://hdsky.me/ | https://pt.whu.edu.cn |  2018-05-21  |




## 环境要求

- GNU/Linux （在ubuntu 18.04 lts 测试通过）。
- 软件：
  - transmission-daemon，transmission-remote，transmission-show，
  - html2bbcode ，（python 模块）安装命令：`sudo pip3 install html2bbcode`，
  - httpie，安装命令`sudo apt-get install httpie`，
  - 其他常用软件工具，curl，grep等。

## 使用方法

1. clone 本 repo 至本地；
2. 修改设置文件`setting.sh`(包括cookie、passkey，路径等)；
3. 添加 `auto_main.sh` 脚本路径至 transmission 的 `script-torrent-done-filename`。具体可以参见 [这里](https://rachpt.github.io/2018/03/25/transmission-settings/) ；
4. 如果 `transmission` 运行脚本诡异，可以将 `auto_main.sh` 添加到  `crontab` 之类的程序周期运行。


*其他：*

请使用 flexget 订阅下载，使用 [transmissionrpc](https://flexget.com/Plugins/transmission) 将源种传入 transmission。



一个运行 log：

```sh
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

## 更新日志

- 2018-05-21
  - 进一步模块化，添加对 WHUPT 的支持。

- 2018-05-19
  - 完成 debug 工作。

- 2018-05-17
  - 首次提交，错误较多。

## 实现流程

```flow
st=>start: 导入settings
cond1=>condition: 监控目录是否有torrent文件?
cond2=>condition: 变量TR_TORRENT_NAME是否为空?
op1=>operation: 使用transmission-show重命名tr文件
op2=>operation: 遍历每个tr文件
cond3=>condition: 种子Name与完成种子匹配?
op3=>operation: 生成种子Name
op4=>operation: 获取HDSky rss页面
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