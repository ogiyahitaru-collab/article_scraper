#!/usr/bin/env bash
DB="$NOTION_DATABASE_ID"; API="$NOTION_API_KEY"; VER="${NOTION_VERSION:-2022-06-28}"

resp="$(curl -sS -X POST "https://api.notion.com/v1/databases/$DB/query" \
 -H "Authorization: Bearer $API" -H "Notion-Version: $VER" \
 -H "Content-Type: application/json" -d '{"page_size":200}')"

printf '%s' "$resp" \
| jq -r '.results[]
 | select(.properties.summary_ja.rich_text|length>0)
 | [.id, .properties.summary_ja.rich_text[0].plain_text] | @tsv' \
| while IFS=$'\t' read -r PID RAW; do
  FIXED="$(jq -r --arg s "$RAW" '
    ($s
     | sub("^No Title\\\\n\\\\n"; "")      # 先頭の「No Title\n\n」を除去
     | split("\\n") | join("\n")           # リテラル \n を実改行へ
     | gsub("[[:space:]]+$"; "")           # 末尾空白を削る
    )' <<< '')"
  [ "$FIXED" = "$RAW" ] && continue
  jq -n --arg m "$FIXED" '{properties:{summary_ja:{rich_text:[{text:{content:$m}}]}}}' >/tmp/_sum.json
  curl -sS -X PATCH "https://api.notion.com/v1/pages/$PID" \
   -H "Authorization: Bearer '"$API"'" -H "Notion-Version: '"$VER"'" \
   -H "Content-Type: application/json" --data-binary @/tmp/_sum.json >/dev/null \
   && echo "fixed-summary $PID"
  sleep 0.2
done
