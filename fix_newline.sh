#!/usr/bin/env bash
DB="$NOTION_DATABASE_ID"; API="$NOTION_API_KEY"; VER="${NOTION_VERSION:-2022-06-28}"
curl -sS -X POST "https://api.notion.com/v1/databases/$DB/query" \
 -H "Authorization: Bearer $API" -H "Notion-Version: $VER" \
 -H "Content-Type: application/json" -d '{"page_size":200}' \
| jq -r '.results[]
 | select((.properties.summary_ja.rich_text[0]?.plain_text // "") | test("\\\\n"))
 | [.id, (.properties.summary_ja.rich_text[0].plain_text)] | @tsv' \
| while IFS=$'\t' read -r PID RAW; do
  FIXED="$(printf '%s' "$RAW" | sed 's/\\n/\n/g')"
  jq -n --arg m "$FIXED" '{properties:{summary_ja:{rich_text:[{text:{content:$m}}]}}}' >/tmp/_m.json
  curl -sS -X PATCH "https://api.notion.com/v1/pages/$PID" \
   -H "Authorization: Bearer '"$API"'" -H "Notion-Version: '"$VER"'" \
   -H "Content-Type: application/json" --data-binary @/tmp/_m.json >/dev/null \
   && echo "fixed-newline $PID"
done
