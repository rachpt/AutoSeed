# AutoSeed

An Autoseed used to reseed Movies in PT sites powered by shell scripts. Get a python version [HERE](https://github.com/Rhilip/Pt-Autoseed).

目前适用于 从 HDSky / TTG / HDChina / CMCT / M-Team 等站点自动转载 电影、剧集、纪录片 [针对 iPad 资源特别优化] 至 HUDBT / WHUPT / NPUBITS / NanYangPT / BYRBT / 北洋园 PT 站。

[![release](https://img.shields.io/badge/Version-3.0-brightgreen.svg)](https://github.com/rachpt/AutoSeed/releases/tag/v3.0)  [![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/rachpt/AutoSeed/master/LICENSE)

|  源站点（from）   |      支持站点（to）      | 时间（time） |
| :---------------: | :-----------------------: | :----------: |
| https://hdsky.me/ | https://hudbt.hust.edu.cn |  2018-05-19  |
| https://totheglory.im/ | https://whu.pt |  2018-05-21  |
| https://hdchina.org | https://npupt.com |  2018-06-07 |
| https://hdcmct.org | https://nanyangpt.com | 2018-06-07 |
| https://tp.m-team.cc | https://bt.byr.cn | 2018-06-17 |
|                   | https://hdcmct.org  | 2018-07-28 |
|                   | https://tjupt.org  | 2018-08-28 |
|      不限\*       |                    | 2018-10-23 |

\* 源站点表示支持抓取其部分简介用于发布，没有则本地生成简介.

## 特点

 - 自动生成并提交简介，尽量与原种简介一致。
 - 自动设置做种时间，分享率。自动清理种子，硬盘不会爆仓。
 - 支持自动 Dupe 以及禁转判断。
 - 开箱即用，不需要使用数据库等复杂操作。
 - 速度快，使用临时文件提前生成简介。
 - 几乎全自动。 


## 环境要求

- GNU/Linux （在ubuntu 18.04 lts、archLinux、centos7 测试通过）。
- 软件：
  - transmission-daemon，transmission-remote，transmission-show，transmission-edit；
  - qBittorrent v4.1+, 如果选择使用该客户端做种(transmission-show,edit 为必须项！)； 
  - httpie 0.9.8+，用于和web服务器通讯；
  - mediainfo，用于本地生成info信息;
  - 其他常用软件工具，sed，grep，awk等(详见 setting.sh，一般系统自带)；
  - 默认使用`python3`本地解析豆瓣简介(作为最后的办法)，感谢 [@Rhilip](https://github.com/Rhilip/PT-help/blob/master/modules/infogen/gen.py) 的脚本，Python相关依赖(requests,bs4,html2bbcode)。

- ubuntu 系安装
  ```sh
  sudo apt install transmission-daemon transmission-cli qbittorrent(or nox) httpie mediainfo python3
  sudo pip3 install requests bs4 html2bbcode
  ``` 
- arch 系安装
  ```sh
  sudo pacman -Sy transmsiion-cli qbittorrent(or nox) httpie mediainfo python python-pip
  sudp pacman -Sy python-requests python-beautifulsoup4 
  sudo pip3 install html2bbcode # 不要通过 pip 安装上面两个库
  ```
- centos 安装
  ```sh
  sudo yum -y install transmission-cli transmission-common transmission-daemon qbittorrent(or nox) httpie mediainfo python python-pip
  sudo pip3 install install requests bs4 html2bbcode
  ```

## 使用方法

1. clone 本 repo (或者下载 zip) 至本地，请使用最新的版本；
2. 修改设置文件`setting.sh`(包括cookie、passkey，监控 torrent 文件路径等)；
3. 添加 `main.sh` 脚本路径至 transmission 的 `script-torrent-done-filename`。具体可以参见 [这里](https://rachpt.github.io/2018/03/25/transmission-settings/) ；
4. 使用 qbittorrent，则需要添加如 `/home/AutoSeed/main.sh "%N" "%D"` 所示代码至 完成时运行外部程序处；
4. (推荐)将 `main.sh` 添加到  `crontab` 之类的程序周期运行（运行锁会解决各种冲突问题），以提前生成简介；
5. 调试请看 test.sh 中的说明。


*其他：*

请使用 flexget 订阅下载，transmission 使用 [transmissionrpc](https://flexget.com/Plugins/transmission) 将源种传入，qbittorrent 参考使用方法4 。

 `crontab` 运行参考命令 `*/5 * * * * /home/AutoSeed/main.sh >/dev/null 2>&1`。

ubuntu 用户注意使用 bash 运行而非系统默认的 dash!

python 并非必须，只需将 `setting.sh` 中的`Use_Local_Gen='yes'`改为其他值，默认使用基于 [web](https://rhilip.github.io/PT-help/ptgen) 的生成方法，只有web方法失败时才会主动使用本地python生成。


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

- 2018-12-19 --> 3.0 (release)
  - 完善clean模块，部分功能使用多线程。
  - 新的qbittorrent分享率设置实现。
  - 代码稳定性增强。

- 2018-12-08 --> 3.0 (开发版,几乎完成)
  - 重构几乎全部代码，以支持更多的站点。
  - 使用豆瓣简介，尽量保留原始 iNFO 以及 screens，没有则生成。
  - 添加对 qbittorrent 的支持，目前 clean、edit 模块还未重构。
  - 主体稳定性正在测试...

- 2018-10-23 --> 3.0 (开发版,未完成)
  - 重构部分代码，以支持更多的站点。
  - 使用豆瓣豆瓣，尽量保留原始 iNFO 以及 screens，没有则生成。
  - 目前修改了'get_desc'，以及部分 'post'，其他正在修改中……

## 实现流程

![流程图](https://ws1.sinaimg.cn/large/675bda05ly1fyd32i63xvj20oy0sdted.jpg)
