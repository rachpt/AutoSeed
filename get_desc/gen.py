#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Copyright (c) 2017-2020 Rhilip <rhilipruan@gmail.com>

import re
import json
import requests
from bs4 import BeautifulSoup
from html2bbcode.parser import HTML2BBCode

__version__ = "0.3.4"
__author__ = "Rhilip"

douban_format = [
    # (key name in dict. the format of key, string format) with order
    ("poster", "[img]{}[/img]\n\n"),
    ("trans_title", "◎译　　名　{}\n"),
    ("this_title", "◎片　　名　{}\n"),
    ("year", "◎年　　代　{}\n"),
    ("region", "◎产　　地　{}\n"),
    ("genre", "◎类　　别　{}\n"),
    ("language", "◎语　　言　{}\n"),
    ("playdate", "◎上映日期　{}\n"),
    ("imdb_rating", "◎IMDb评分　{}\n"),
    ("imdb_link", "◎IMDb链接　{}\n"),
    ("douban_rating", "◎豆瓣评分　{}\n"),
    ("douban_link", "◎豆瓣链接　{}\n"),
    ("episodes", "◎集　　数　{}\n"),
    ("duration", "◎片　　长　{}\n"),
    ("director", "◎导　　演　{}\n"),
    ("writer", "◎编　　剧　{}\n"),
    ("cast", "◎主　　演　{}\n\n"),
    ("tags", "\n◎标　　签　{}\n"),
    ("introduction", "\n◎简　　介  \n\n　　{}\n"),
    ("awards", "\n◎获奖情况  \n\n{}\n"),
]

bangumi_format = [
    ("cover", "[img]{}[/img]\n\n"),
    ("story", "[b]Story: [/b]\n\n{}\n\n"),
    ("staff", "[b]Staff: [/b]\n\n{}\n\n"),
    ("cast", "[b]Cast: [/b]\n\n{}\n\n"),
    ("alt", "(来源于 {} )\n")
]

steam_format = [
    ("cover", "[img]{}[/img]\n\n"),
    ('baseinfo', "【基本信息】\n\n{}\n"),
    ('descr', "【游戏简介】\n\n{}\n\n"),
    ('sysreq', "【配置需求】\n\n{}\n\n"),
    ('screenshot', "【游戏截图】\n\n{}\n\n"),
]

support_list = [
    ("douban", re.compile("(https?://)?movie\.douban\.com/(subject|movie)/(?P<sid>\d+)/?")),
    ("imdb", re.compile("(https?://)?www\.imdb\.com/title/(?P<sid>tt\d+)")),
    # ("3dm", re.compile("(https?://)?bbs\.3dmgame\.com/thread-(?P<sid>\d+)(-1-1\.html)?")),
    ("steam", re.compile("(https?://)?(store\.)?steam(powered|community)\.com/app/(?P<sid>\d+)/?")),
    ("bangumi", re.compile("(https?://)?(bgm\.tv|bangumi\.tv|chii\.in)/subject/(?P<sid>\d+)/?")),
]

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/61.0.3163.100 Safari/537.36 ',
    "Accept-Language": "en,zh-CN;q=0.9,zh;q=0.8"
}


def get_page(url: str, json_=False, jsonp_=False, bs_=False, text_=False, **kwargs):
    kwargs.setdefault("headers", headers)
    page = requests.get(url, **kwargs)
    page.encoding = "utf-8"
    page_text = page.text
    if json_:
        return page.json()
    elif jsonp_:
        start_idx = page_text.find('(')
        end_idx = page_text.rfind(')')
        return json.loads(page_text[start_idx + 1:end_idx])
    elif bs_:
        return BeautifulSoup(page.text, "lxml")
    elif text_:
        return page_text
    else:
        return page


def html2ubb(html: str) -> str:
    return str(HTML2BBCode().feed(html))


class Gen(object):
    site = sid = url = ret = None
    img_list = []  # 临时存储图片信息

    def __init__(self, url: str):
        self.clear()
        self.pat(url)

    def pat(self, url: str):
        for site, pat in support_list:
            search = pat.search(url)
            if search:
                self.sid = search.group("sid")
                self.site = site
        if not self.site:
            self.ret["error"] = "No support link."

    def clear(self):
        self.site = self.sid = self.url = None
        self.img_list = []  # 临时存储图片信息
        self.ret = {
            "success": False,
            "error": None,
            "format": "",
            "copyright": "Powered by @{}".format(__author__),
            "version": __version__
        }

    def gen(self, _debug=False):
        if not self.ret.get("error"):
            try:
                getattr(self, "_gen_{}".format(self.site))()
                self.ret["img"] = self.img_list
                self.ret["success"] = True if not self.ret.get("error") else False
            except Exception as err:
                raw_error = self.ret["error"]
                self.ret["error"] = "Internal error : {}, please connect @{}, thank you.".format(raw_error, __author__)
                if _debug:
                    raise Exception("Internal error").with_traceback(err.__traceback__)
        return self.ret

    def _gen_douban(self):
        douban_link = "https://movie.douban.com/subject/{}/".format(self.sid)
        douban_page = get_page(douban_link, bs_=True)
        douban_api_json = get_page('https://api.douban.com/v2/movie/{}?apikey=0df993c66c0c636e29ecbb5344252a4a'.format(self.sid), json_=True)

        if "msg" in douban_api_json:
            self.ret["error"] = douban_api_json["msg"]
        elif str(douban_page).find("检测到有异常请求") > -1:
            self.ret["error"] = "GenHelp was banned by Douban."
        elif douban_page.title.text == "页面不存在":
            self.ret["error"] = "The corresponding resource does not exist."
        else:
            data = {"douban_link": douban_link}

            def fetch(node):
                return node.next_element.next_element.strip()

            # 对主页面进行解析
            data["chinese_title"] = (douban_page.title.text.replace("(豆瓣)", "").strip())
            data["foreign_title"] = (douban_page.find("span", property="v:itemreviewed").text
                                     .replace(data["chinese_title"], '').strip())

            aka_anchor = douban_page.find("span", class_="pl", text=re.compile("又名"))
            data["aka"] = sorted(fetch(aka_anchor).split(' / ')) if aka_anchor else []

            if data["foreign_title"]:
                trans_title = data["chinese_title"] + (('/' + "/".join(data["aka"])) if data["aka"] else "")
                this_title = data["foreign_title"]
            else:
                trans_title = "/".join(data["aka"]) if data["aka"] else ""
                this_title = data["chinese_title"]

            data["trans_title"] = trans_title.split("/")
            data["this_title"] = this_title.split("/")

            region_anchor = douban_page.find("span", class_="pl", text=re.compile("制片国家/地区"))
            language_anchor = douban_page.find("span", class_="pl", text=re.compile("语言"))
            episodes_anchor = douban_page.find("span", class_="pl", text=re.compile("集数"))
            imdb_link_anchor = douban_page.find("a", text=re.compile("tt\d+"))
            year_anchor = douban_page.find("span", class_="year")

            data["year"] = douban_page.find("span", class_="year").text[1:-1] if year_anchor else ""  # 年代
            data["region"] = fetch(region_anchor).split(" / ") if region_anchor else []  # 产地
            data["genre"] = list(map(lambda l: l.text.strip(), douban_page.find_all("span", property="v:genre")))  # 类别
            data["language"] = fetch(language_anchor).split(" / ") if language_anchor else []  # 语言
            data["playdate"] = sorted(map(lambda l: l.text.strip(),  # 上映日期
                                          douban_page.find_all("span", property="v:initialReleaseDate")))
            data["imdb_link"] = imdb_link_anchor.attrs["href"] if imdb_link_anchor else ""  # IMDb链接
            data["imdb_id"] = imdb_link_anchor.text if imdb_link_anchor else ""  # IMDb号
            data["episodes"] = fetch(episodes_anchor) if episodes_anchor else ""  # 集数

            duration_anchor = douban_page.find("span", class_="pl", text=re.compile("单集片长"))
            runtime_anchor = douban_page.find("span", property="v:runtime")

            duration = ""  # 片长
            if duration_anchor:
                duration = fetch(duration_anchor)
            elif runtime_anchor:
                duration = runtime_anchor.text.strip()
            data["duration"] = duration

            # 请求其他资源
            if data["imdb_link"]:  # 该影片在豆瓣上存在IMDb链接
                imdb_source = ("https://p.media-imdb.com/static-content/documents/v1/title/{}/ratings%3Fjsonp="
                               "imdb.rating.run:imdb.api.title.ratings/data.json".format(data["imdb_id"]))
                try:
                    imdb_json = get_page(imdb_source, jsonp_=True)  # 通过IMDb的API获取信息，（经常超时555555）
                    imdb_average_rating = imdb_json["resource"]["rating"]
                    imdb_votes = imdb_json["resource"]["ratingCount"]
                    if imdb_average_rating and imdb_votes:
                        data["imdb_rating"] = "{}/10 from {} users".format(imdb_average_rating, imdb_votes)
                except Exception as err:
                    pass

            # 获取获奖情况
            awards = ""
            awards_page = get_page("https://movie.douban.com/subject/{}/awards".format(self.sid), bs_=True)
            for awards_tag in awards_page.find_all("div", class_="awards"):
                _temp_awards = ""
                _temp_awards += "　　" + awards_tag.find("h2").get_text(strip=True) + "\n"
                for specific in awards_tag.find_all("ul"):
                    _temp_awards += "　　" + specific.get_text(" ", strip=True) + "\n"

                awards += _temp_awards + "\n"

            data["awards"] = awards

            # 豆瓣评分，简介，海报，导演，编剧，演员，标签
            data["douban_rating_average"] = douban_average_rating = douban_api_json["rating"]["average"] or 0
            data["douban_votes"] = douban_votes = douban_api_json["rating"]["numRaters"] or 0
            data["douban_rating"] = "{}/10 from {} users".format(douban_average_rating, douban_votes)
            data["introduction"] = re.sub("^None$", "暂无相关剧情介绍", douban_api_json["summary"])
            data["poster"] = poster = re.sub("s(_ratio_poster|pic)", r"l\1", douban_api_json["image"])
            self.img_list.append(poster)

            data["director"] = douban_api_json["attrs"]["director"] if "director" in douban_api_json["attrs"] else []
            data["writer"] = douban_api_json["attrs"]["writer"] if "writer" in douban_api_json["attrs"] else []
            data["cast"] = douban_api_json["attrs"]["cast"] if "cast" in douban_api_json["attrs"] else ""
            data["tags"] = list(map(lambda member: member["name"], douban_api_json["tags"]))

            # -*- 组合数据 -*-
            descr = ""
            for key, ft in douban_format:
                _data = data.get(key)
                if _data:
                    if isinstance(_data, list):
                        join_fix = " / "
                        if key == "cast":
                            join_fix = "\n　　　　　　"
                        elif key == "tags":
                            join_fix = " | "
                        _data = join_fix.join(_data)
                    descr += ft.format(_data)
            self.ret["format"] = descr

            # 将清洗的数据一并发出
            self.ret.update(data)

    def _gen_imdb(self):
        douban_imdb_api = get_page("https://api.douban.com/v2/movie/imdb/{}?apikey=0df993c66c0c636e29ecbb5344252a4a".format(self.sid), json_=True)
        if douban_imdb_api.get("alt"):
            # 根据tt号先在豆瓣搜索，如果有则直接使用豆瓣解析结果
            self.pat(douban_imdb_api["alt"])
            self._gen_douban()
        else:  # TODO 如果没有，则转而从imdb上解析数据。
            self.ret["error"] = "Can't find this imdb_id({}) in Douban.".format(self.sid)

    def _gen_steam(self):
        steam_chs_url = "http://store.steampowered.com/app/{}/?l=schinese".format(self.sid)
        steam_page = requests.get(steam_chs_url,
                                  # 使用cookies避免 Steam 年龄认证
                                  cookies={"mature_content": "1", "birthtime": "157737601",
                                           "lastagecheckage": "1-January-1975", "wants_mature_content": "1"})
        if re.search("(欢迎来到|Welcome to) Steam", steam_page.text):  # 不存在的资源会被302到首页，故检查标题或r.history
            self.ret["error"] = "The corresponding resource does not exist."
        else:
            data = {}
            steam_bs = BeautifulSoup(steam_page.text, "lxml")
            # 从网页中定位数据
            name_anchor = steam_bs.find("div", class_="apphub_AppName") or steam_bs.find("span", itemprop="name")  # 游戏名
            cover_anchor = steam_bs.find("img", class_="game_header_image_full")  # 游戏封面图
            detail_anchor = steam_bs.find("div", class_="details_block")  # 游戏基本信息
            linkbar_anchor = steam_bs.find("a", class_="linkbar")  # 官网
            language_anchor = steam_bs.select("table.game_language_options > tr")[1:]  # 已支持语言
            tag_anchor = steam_bs.find_all("a", class_="app_tag")  # 标签
            rate_anchor = steam_bs.find_all("div", class_="user_reviews_summary_row")  # 游戏评价
            descr_anchor = steam_bs.find("div", id="game_area_description")  # 游戏简介
            sysreq_anchor = steam_bs.select("div.sysreq_contents > div.game_area_sys_req")  # 系统需求
            screenshot_anchor = steam_bs.select("div.screenshot_holder a")  # 游戏截图

            # 请求第三方中文名信息
            try:  # Thanks @Deparsoul with his Database
                steamcn_json = get_page("https://steamdb.steamcn.com/app/{}/data.js?v=38".format(self.sid), jsonp_=True)
            except Exception:
                pass
            else:
                if "name_cn" in steamcn_json:
                    data["name_chs"] = steamcn_json["name_cn"]

            # 数据清洗
            def reviews_clean(tag):
                return tag.get_text(" ", strip=True).replace("：", ":")

            def sysreq_clean(tag):
                os_dict = {"win": "Windows", "mac": "Mac OS X", "linux": "SteamOS + Linux"}
                os_type = os_dict[tag["data-os"]]
                sysreq_content = re.sub("([^配置]):\n", r"\1: ", tag.get_text("\n", strip=True))

                return "{}\n{}".format(os_type, sysreq_content)

            def lag_clean(tag):
                lag_checkcol_list = ["界面", "完全音频", "字幕"]
                tag_td_list = tag.find_all("td")
                lag_support_checkcol = []
                lag = tag_td_list[0].get_text(strip=True)
                if re.search("不支持", tag.text):
                    lag_support_checkcol.append("不支持")
                else:
                    for i, j in enumerate(tag_td_list[1:]):
                        if j.find("img"):
                            lag_support_checkcol.append(lag_checkcol_list[i])

                return lag + ("({})".format(", ".join(lag_support_checkcol)) if lag_support_checkcol else "")

            data["cover"] = re.sub("^(.+?)(\?t=\d+)?$", r"\1", (cover_anchor or {"src": ""})["src"])
            data["name"] = name_anchor.get_text(strip=True)
            data["detail"] = detail_anchor.get_text("\n", strip=True).replace(":\n", ": ").replace("\n,\n", ", ")
            data["tags"] = list(map(lambda t: t.get_text(strip=True), tag_anchor)) or []
            data["review"] = list(map(reviews_clean, rate_anchor)) or []
            if linkbar_anchor and re.search("访问网站", linkbar_anchor.text):
                data["linkbar"] = re.sub("^.+?url=(.+)$", r"\1", linkbar_anchor["href"])
            data["language"] = list(filter(lambda s: s.find("不支持") == -1, map(lag_clean, language_anchor)))[:3] or []

            base_info = "中文名: {}\n".format(data["name_chs"]) if data.get("name_chs") else ""
            base_info += (data["detail"] + "\n") if data.get("detail") else ""
            base_info += "官方网站： {}\n".format(data["linkbar"]) if data.get("linkbar") else ""
            base_info += ("游戏语种: " + " | ".join(data["language"]) + "\n") if data.get("language") else ""
            base_info += ("标签: " + " | ".join(data["tags"]) + "\n") if data.get("tags") else ""
            base_info += ("\n".join(data["review"]) + "\n") if data.get("review") else ""

            data["baseinfo"] = base_info
            data["descr"] = html2ubb(str(descr_anchor)).replace("[h2]关于这款游戏[/h2]", "").strip()
            data["screenshot"] = list(map(lambda dic: re.sub("^.+?url=(http.+?)\.[\dx]+(.+?)(\?t=\d+)?$",
                                                             r"\1\2", dic["href"]), screenshot_anchor))
            data["sysreq"] = list(map(sysreq_clean, sysreq_anchor))

            # 主介绍生成
            descr = ""
            for key, ft in steam_format:
                _data = data.get(key)
                if _data:
                    if isinstance(_data, list):
                        join_fix = "\n"
                        if key == "screenshot":
                            _data = map(lambda d: "[img]{}[/img]".format(d), _data)
                        if key == "sysreq":
                            join_fix = "\n\n"
                        _data = join_fix.join(_data)
                    descr += ft.format(_data)
            self.ret["format"] = descr

            # 将清洗的数据一并发出
            self.ret.update(data)

    def _gen_bangumi(self):
        bangumi_link = "https://bgm.tv/subject/{}".format(self.sid)
        bangumi_characters_link = "https://bgm.tv/subject/{}/characters".format(self.sid)

        bangumi_page = get_page(bangumi_link, bs_=True)
        if str(bangumi_page).find("出错了") > -1:
            self.ret["error"] = "The corresponding resource does not exist."
        else:
            data = {"id": self.sid, "alt": bangumi_link}

            # 对页面进行划区
            cover_staff_another = bangumi_page.find("div", id="bangumiInfo")
            cover_another = cover_staff_another.find("img")
            staff_another = cover_staff_another.find("ul", id="infobox")
            story_another = bangumi_page.find("div", id="subject_summary")
            # cast_another = bangumi_page.find("ul", id="browserItemList")

            data["cover"] = re.sub("/cover/[lcmsg]/", "/cover/l/", "https:" + cover_another["src"])  # Cover
            data["story"] = story_another.get_text() if story_another else ""  # Story
            data["staff"] = list(map(lambda tag: tag.get_text(), staff_another.find_all("li")[4:4 + 15]))  # Staff

            bangumi_characters_page = get_page(bangumi_characters_link, bs_=True)

            cast_actors = bangumi_characters_page.select("div#columnInSubjectA > div.light_odd > div.clearit")

            def cast_clean(tag):
                h2 = tag.find("h2")
                char = (h2.find("span", class_="tip") or h2.find("a")).get_text().replace("/", "").strip()
                cv = "、".join(map(lambda p: (p.find("small").get_text() or p.find("a").get_text()).strip(),
                                  tag.select("> div.clearit > p")))
                return "{}:{}".format(char, cv)

            data["cast"] = list(map(cast_clean, cast_actors))[:9]  # Cast

            descr = ""
            for key, ft in bangumi_format:
                _data = data.get(key)
                if _data:
                    if isinstance(_data, list):
                        _data = "\n".join(_data)
                    descr += ft.format(_data)
            data["format"] = descr

            self.ret.update(data)
