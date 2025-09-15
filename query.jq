.results[]? as $p
| [
    ($p.properties.title.title[0]?.plain_text // "-"),
    ($p.properties.URL.url // "-"),
    ($p.properties["選択"].select.name // "-"),
    ($p.properties.summary_ja.rich_text[0]?.plain_text // "-"),
    ($p.properties["日付"].date.start // "-")
  ] | @tsv
