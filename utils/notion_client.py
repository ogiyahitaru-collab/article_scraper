import os, re, requests
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime

NOTION_TOKEN = os.environ.get("NOTION_TOKEN") or os.environ.get("NOTION_API_KEY")
DATABASE_ID = os.environ.get("NOTION_DATABASE_ID") or os.environ.get("NOTION_DB_ID")

HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}" if NOTION_TOKEN else "",
    "Content-Type": "application/json",
    "Notion-Version": "2022-06-28",
}


def _clean(text: str) -> str:
    if not text:
        return ""
    text = re.sub(r"\s+", " ", text).strip()
    return text[:2000]


def _to_iso8601(dt_str: str | None) -> str | None:
    """
    RSS/Bingの 'Mon, 15 Sep 2025 01:30:00 GMT' 等を ISO 8601 に変換。
    失敗したら None を返してプロパティを送らない（バリデーション回避）。
    """
    if not dt_str:
        return None
    # まずは RFC822/2822 を優先
    try:
        dt = parsedate_to_datetime(dt_str)
        # タイムゾーンが無ければ UTC 扱い
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.isoformat()
    except Exception:
        pass
    # 既にISO / 他形式の可能性
    try:
        return datetime.fromisoformat(dt_str).astimezone(timezone.utc).isoformat()
    except Exception:
        return None


def add_to_notion(art: dict) -> None:
    """
    art: {
      "url": str | None,
      "title": str | None,
      "published": str | None,  # RSS等の文字列でもOK（内部でISO化）
      "text": str | None,
      "source": str | None
    }
    """
    if not NOTION_TOKEN or not DATABASE_ID:
        print("⚠️ NOTION_TOKEN / NOTION_DATABASE_ID が未設定です。スキップします。")
        return

    title = _clean(art.get("title") or "No Title")
    url = art.get("url") or ""
    desc = _clean(art.get("text") or "")
    src = _clean(art.get("source") or "")
    published = art.get("published")
    iso_published = _to_iso8601(published)

    payload = {
        "parent": {"database_id": DATABASE_ID},
        "properties": {
            "Name": {"title": [{"text": {"content": title}}]},
        },
    }

    # オプションのプロパティは存在すれば使われる（無ければNotion側で無視される）
    payload["properties"]["URL"] = {"url": url or None}

    if iso_published:
        payload["properties"]["Published"] = {"date": {"start": iso_published}}

    if desc:
        payload["properties"]["Summary"] = {"rich_text": [{"text": {"content": desc}}]}

    if src:
        payload["properties"]["Source"] = {"rich_text": [{"text": {"content": src}}]}

    r = requests.post(
        "https://api.notion.com/v1/pages", headers=HEADERS, json=payload, timeout=20
    )
    if r.status_code >= 300:
        try:
            msg = r.json()
        except Exception:
            msg = r.text
        print(f"❌ Notion登録失敗: {r.status_code} {msg}")
    else:
        print(f"✅ Notion登録成功: {title}")
