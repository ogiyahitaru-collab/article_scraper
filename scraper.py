#!/usr/bin/env python3
import urllib.request, urllib.error, xml.etree.ElementTree as ET
import json, datetime, os, pathlib, re

OUT = "/app/out/articles.jsonl"
SOURCES = [
    {"name": "NHK", "url": "https://www3.nhk.or.jp/rss/news/cat0.xml"},
    {"name": "Reuters", "url": "https://feeds.reuters.com/reuters/businessNews"},
]

pathlib.Path(os.path.dirname(OUT)).mkdir(parents=True, exist_ok=True)


def iso_now():
    return datetime.datetime.now().isoformat()


def fetch(url, timeout=15):
    try:
        with urllib.request.urlopen(url, timeout=timeout) as resp:
            return resp.read()
    except Exception as e:
        print(f"[WARN] fetch error {url}: {e}")
        return None


TAG_RE = re.compile(r"<[^>]+>")
WS_RE = re.compile(r"\s+")


def clean_html(text: str) -> str:
    if not text:
        return ""
    t = TAG_RE.sub("", text)
    t = WS_RE.sub(" ", t).strip()
    return t


def summarize_ja(title: str, desc: str, limit=120) -> str:
    base = clean_html(desc) or title
    return (base[:limit] + "…") if len(base) > limit else base


def parse_rss(xml_bytes):
    try:
        root = ET.fromstring(xml_bytes)
    except Exception:
        return []
    items = []
    for it in root.findall(".//item"):
        title = (it.findtext("title") or "").strip()
        link = (it.findtext("link") or "").strip()
        pub = (it.findtext("pubDate") or "").strip()
        desc = (it.findtext("description") or "").strip()
        items.append({"title": title, "url": link, "pub": pub, "desc": desc})
    return items


def load_seen(path):
    seen = set()
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                try:
                    obj = json.loads(line)
                    if obj.get("url"):
                        seen.add(obj["url"])
                except:
                    continue
    return seen


def main():
    print(f"[scraper] start {iso_now()}")
    seen = load_seen(OUT)
    new = 0
    with open(OUT, "a", encoding="utf-8") as f:
        for src in SOURCES:
            xml = fetch(src["url"])
            if not xml:
                continue
            for item in parse_rss(xml):
                if not item.get("url") or item["url"] in seen:
                    continue
                seen.add(item["url"])
                obj = {
                    "source": src["name"],
                    "title": item["title"],
                    "url": item["url"],
                    "pub": item["pub"],
                    "summary_ja": summarize_ja(item["title"], item["desc"]),
                    "ts": iso_now(),
                }
                f.write(json.dumps(obj, ensure_ascii=False) + "\n")
                new += 1
    print(f"[scraper] wrote {new} items")
    print("[scraper] finished")


if __name__ == "__main__":
    main()
