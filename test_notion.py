from dotenv import load_dotenv
import os

# .envファイルの読み込み
load_dotenv()

# 環境変数の取得
notion_api_key = os.getenv("NOTION_API_KEY")
notion_database_id = os.getenv("NOTION_DATABASE_ID")

print(f"Notion API Key: {notion_api_key}")
print(f"Notion Database ID: {notion_database_id}")
