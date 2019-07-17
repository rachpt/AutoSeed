# AutoSeed

An Autoseed used to reseed Movies in PT sites powered by shell scripts. Get a python version [HERE](https://github.com/Rhilip/Pt-Autoseed).

目前适用于 从 HDS / TTG / HDC / CMCT / MTeam 等站点自动转载 电影、剧集、纪录片 [针对 iPad 资源特别优化] 至 HUDBT / WHU / NPUPT / NYPT / BYRBT / TJUPT。

[![release](https://img.shields.io/badge/Version-3.1-brightgreen.svg)](https://github.com/rachpt/AutoSeed/releases/tag/v3.1)  [![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/rachpt/AutoSeed/master/LICENSE)

|  源站点（from）  | 支持站点（to） | 时间（time） |
| :--------------: | :------------: | :----------: |
| hds | hudbt |  2018-05-19  |
| ttg  | whu |  2018-05-21  |
| hdc | npupt |  2018-06-07 |
| cmct | nypt | 2018-06-07 |
| mteam | byrbt | 2018-06-17 |
|       | cmct  | 2018-07-28 |
|       | tjupt | 2018-08-28 |
| 不限\*  |     | 2018-10-23 |

\* 源站点表示支持抓取其部分简介用于发布，没有则本地生成简介.

## 特点

 - 自动生成并提交简介，与原种简介尽量一致。
 - 自动设置做种时间与分享率、清理旧种子、硬盘容量释放。
 - 速度快，使用临时文件提前生成简介，使用多线程提速。
 - 开箱即用，不需要使用数据库等复杂操作。
 - 支持自动 Dupe 以及禁转判断。
 - 支持多项自定义规则优化任务。
 - 总的来说，几乎全自动。 


## 环境要求

- GNU/Linux（ubuntu 18.04 lts、archLinux、centos7 测试通过）。
- 软件：
  - transmission-daemon，transmission-remote，transmission-show，transmission-edit；
  - qBittorrent v4.1+，(使用该客户端须安装transmission-show,edit！)； 
  - httpie 0.9.8+，用于和web服务器通讯；
  - mediainfo，[mtn](http://moviethumbnail.sourceforge.net/)(非必须) 用于本地生成info信息;
  - ffmpeg，用于本地生成缩略图(配合mediainfo);
  - 其他常用软件工具，sed，grep，awk等(详见 setting.sh，一般系统自带)；
  - 默认先使用`python3`本地解析豆瓣简介，感谢 [@Rhilip](https://github.com/Rhilip/PT-help/blob/master/modules/infogen/gen.py) 的脚本，(Python相关依赖requests,bs4,html2bbcode)；
  - curl，备用下载工具;
  - unrar、[dottorrent](https://github.com/kz26/dottorrent)，解压0day分卷资源。

- ubuntu 系安装
  ```sh
  sudo apt install transmission-daemon \
    transmission-cli qbittorrent(or nox) \
    httpie mediainfo python3 ffmpeg
  sudo pip3 install requests bs4 html2bbcode
  ``` 
- arch 系安装
  ```sh
  sudo pacman -Sy transmsiion-cli \
    qbittorrent(or nox) httpie mediainfo \
    python python-pip ffmpeg
  sudo pacman -Sy python-requests python-beautifulsoup4 
  # 不要通过 pip 安装上面两个库到系统
  sudo pip3 install html2bbcode 
  ```
- centos 安装
  ```sh
  sudo yum -y install transmission-cli \
    transmission-common transmission-daemon \
    qbittorrent(or nox) httpie mediainfo \
    python python-pip ffmpeg
  sudo pip3 install install requests bs4 html2bbcode
  ```

## 使用方法

1. clone 本 repo (或者下载 zip) 至本地，请使用最新的版本；
2. 修改设置文件`setting.sh`(包括cookie、passkey，监控 torrent 文件路径等)；
3. 使用 transmission **订阅源种**，添加 `main.sh` 路径至 `script-torrent-done-filename`，具体见 [这里](https://rachpt.github.io/2018/03/25/transmission-settings/) ；
5. 使用 qbittorrent **订阅源种**，添加如 `/home/AutoSeed/main.sh "%N" "%D"` 所示代码至`完成时运行外部程序`处；  
   3、4只能选其一，目前只能使用一个客户端订阅源种；
6. (推荐)将 `main.sh` 添加到  `crontab` 周期运行(运行锁会解决各种问题)，以提前生成简介；
7. 调试请看 test.sh 中的说明。

详细请看[WIKI](https://github.com/rachpt/AutoSeed/wiki)。

*其他：*

请使用 flexget 订阅下载，transmission 使用 [transmissionrpc](https://flexget.com/Plugins/transmission) 将源种传入，qbittorrent 使用 flexget 的 qbittorrent 模块。  
 `crontab` 运行参考命令 `*/5 * * * * /home/AutoSeed/main.sh >/dev/null 2>&1`。  
ubuntu 用户注意使用 bash 运行而非系统默认的 dash!  
python 并非必须，只需将 `setting.sh` 中的`Use_Local_Gen='yes'`改为其他值，则使用基于 [web](https://rhilip.github.io/PT-help/ptgen) 的生成方法，当然本地解析失败时，也会尝试使用web方法生成。


## 更新日志

- 2019-02-18 --> 3.1
  - 修复几处 bug。
  - 新增使用 ffmpeg 生成缩略图。
  - 新增自定义豆瓣链接匹配规则。
  - 新增特定资源的单独发布规则。
  - 完善多处细节，比如解决 WiKi 美剧 imdb 固定为第一季情况，添加备用图床等。

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

[点击查看](https://www.processon.com/view/link/5c088855e4b0ca4b40c93a49)

## License

[GPL-3.0](https://github.com/rachpt/AutoSeed/blob/master/LICENSE)

