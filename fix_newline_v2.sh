#!/usr/bin/env bash
DB="$NOTION_DATABASE_ID"; API="$NOTION_API_KEY"; VER="${NOTION_VERSION:-2022-06-28}"

# 1回200件。必要なら while next_cursor で拡張可。
resp="$(curl -sS -X POST "https://api.notion.com/v1/databases/$DB/query" \
 -H "Authorization: Bearer $API" -H "Notion-Version: $VER" \
 -H "Content-Type: application/json" -d '{"page_size":200}')"

printf '%s' "$resp" \
| jq -r '.results[]
 | [.id, (.properties.summary_ja.rich_text[0]?.plain_text // "")]
 | @tsv' \
| while IFS=$'\t' read -r PID RAW; do
  # スキップ条件：空なら何もしない
  [ -z "$RAW" ] && continue

  # 文字列の \\n -> 実改行、先頭 "No Title\n\n" を削除、前後空白トリム
  FIXED="$(printf '%s' "$RAW" \
    | sed 's/\\n/\n/g' \
    | sed '1s/^No Title[[:space:]]*$//' \
    | sed '1{/^No Title$/d;}' \
    | sed '1{/^No Title$/d;}' \
    | sed '1s/^No Title[[:space:]]*\n\n//' \
    | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
  )"

  # 変化が無ければスキップ
  [ "$FIXED" = "$RAW" ] && continue

  jq -n --arg m "$FIXED" \
    '{properties:{summary_ja:{rich_text:[{text:{content:$m}}]}}}' >/tmp/_m.json

  curl -sS -X PATCH "https://api.notion.com/v1/pages/$PID" \
   -H "Authorization: Bearer '"$API"'" -H "Notion-Version: '"$VER"'" \
   -H "Content-Type: application/json" --data-binary @/tmp/_m.json >/dev/null \
   && echo "fixed-newline/titleprefix $PID"
  sleep 0.3
done
