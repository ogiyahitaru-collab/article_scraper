from notion_client import Client
import os
from dotenv import load_dotenv

load_dotenv()

notion = Client(auth=os.getenv("NOTION_API_KEY"))
database_id = os.getenv("NOTION_DATABASE_ID")
url_prop_name = os.getenv("NOTION_PROP_URL")


def get_existing_notion_urls():
    urls = set()
    query = notion.databases.query(database_id=database_id)
    for result in query.get("results", []):
        props = result.get("properties", {})
        url_prop = props.get(url_prop_name, {}).get("url")
        if url_prop:
            urls.add(url_prop)
    return urls


if __name__ == "__main__":
    urls = get_existing_notion_urls()
    print(f"✅ Notionに既存の記事URL数: {len(urls)}")
    for url in urls:
        print("-", url)
