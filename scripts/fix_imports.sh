#!/bin/bash

TARGET_FILE="src/main.py"

# バックアップ作成
cp "$TARGET_FILE" "${TARGET_FILE}.bak"

# notion系
sed -i 's/^from[ \t]\+notion_uploader/from src.notion.notion_uploader/' "$TARGET_FILE"
sed -i 's/^from[ \t]\+post_to_notion/from src.notion.post_to_notion/' "$TARGET_FILE"

# summarizer系
sed -i 's/^from[ \t]\+summarizer_/from src.summarizer.summarizer_/' "$TARGET_FILE"

# クローラー系
sed -i 's/^from[ \t]\+rss_crawler_bbc/from src.crawler.rss_crawler_bbc/' "$TARGET_FILE"
sed -i 's/^from[ \t]\+slow_crawler_v2/from src.crawler.slow_crawler_v2/' "$TARGET_FILE"

# utils系
sed -i 's/^from[ \t]\+fetch_and_post/from src.utils.fetch_and_post/' "$TARGET_FILE"
sed -i 's/^from[ \t]\+check_existing_notion_urls/from src.utils.check_existing_notion_urls/' "$TARGET_FILE"
sed -i 's/^from[ \t]\+delete_duplicate_articles/from src.utils.delete_duplicate_articles/' "$TARGET_FILE"

echo "✅ import 文の置換が完了しました。バックアップは ${TARGET_FILE}.bak に保存されています。"
