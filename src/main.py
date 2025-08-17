def process_url(url, sent):
    print(f"URL 処理中: {url}")
    article = scrape_single_article(url)
    print(f"記事情報: {article}")  # 記事の情報を表示
    if article:
        post_to_notion(article['title'], article['content'])
    else:
        print("記事の情報がありません")

# その他のコード
