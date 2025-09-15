#!/usr/bin/env bash
DB="$NOTION_DATABASE_ID"; API="$NOTION_API_KEY"; VER="${NOTION_VERSION:-2022-06-28}"
curl -sS -X POST "https://api.notion.com/v1/databases/$DB/query" \
 -H "Authorization: Bearer $API" -H "Notion-Version: $VER" \
 -H "Content-Type: application/json" -d '{"page_size":200}' \
| jq -r '.results[]|[.id, (.properties.title.title[0]?.plain_text // ""),
 (.properties.summary_ja.rich_text[0]?.plain_text // ""), (.properties.URL.url // "")] | @tsv' \
| while IFS=$'\t' read -r PID TITLE SUM URL; do
  [ -n "$TITLE" ] && [ "$TITLE" != "No Title" ] && continue
  HEAD="$(printf '%s' "$SUM" | sed 's/\\n.*$//' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
  [ -z "$HEAD" ] || [ "$HEAD" = "No Title" ] && HEAD="$(printf '%s' "$URL" | sed -E 's#^https?://([^/]+)/?.*#\1#')"
  [ -z "$HEAD" ] && HEAD="(untitled)"
  jq -n --arg t "$HEAD" '{properties:{title:{title:[{text:{content:$t}}]}}}' >/tmp/_t.json
  curl -sS -X PATCH "https://api.notion.com/v1/pages/$PID" \
   -H "Authorization: Bearer '"$API"'" -H "Notion-Version: '"$VER"'" \
   -H "Content-Type: application/json" --data-binary @/tmp/_t.json >/dev/null \
   && echo "titled $PID -> $HEAD"
done
