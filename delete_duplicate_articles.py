from notion_client import Client
import os
from dotenv import load_dotenv
from collections import defaultdict

load_dotenv()

notion = Client(auth=os.getenv("NOTION_API_KEY"))
database_id = os.getenv("NOTION_DATABASE_ID")
url_prop_name = os.getenv("NOTION_PROP_URL")

def get_all_pages():
    pages = []
    next_cursor = None
    while True:
        response = notion.databases.query(
            database_id=database_id,
            start_cursor=next_cursor
        )
        pages.extend(response.get("results", []))
        next_cursor = response.get("next_cursor")
        if not next_cursor:
            break
    return pages

def find_duplicate_pages(pages):
    url_map = defaultdict(list)
    for page in pages:
        props = page.get("properties", {})
        url = props.get(url_prop_name, {}).get("url")
        if not url:
            continue
        url_map[url].append(page)
    
    duplicates = []
    for url, entries in url_map.items():
        if len(entries) > 1:
            duplicates.extend(entries[1:])  # 最初の1件は残す
    return duplicates

def delete_duplicates(duplicate_pages):
    for page in duplicate_pages:
        page_id = page["id"]
        url = page.get("properties", {}).get(url_prop_name, {}).get("url")
        print(f"🗑️ Deleting duplicate for URL: {url}")
        notion.pages.update(page_id=page_id, archived=True)

if __name__ == "__main__":
    all_pages = get_all_pages()
    duplicates = find_duplicate_pages(all_pages)
    print(f"✅ Found {len(duplicates)} duplicate URLs")
    delete_duplicates(duplicates)
    print("✅ 重複削除完了")
