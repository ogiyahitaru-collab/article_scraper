#!/usr/bin/env bash
set -euo pipefail
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -a; . /volume2/docker/article_scraper/.env; set +a

DB="$NOTION_DATABASE_ID"
API="$NOTION_API_KEY"
VER="${NOTION_VERSION:-2022-06-28}"
SKEY="${NOTION_PROP_SUMMARY:-summary_ja}"

cursor=""
while :; do
  body='{"page_size":100'$( [ -n "${cursor}" ] && printf ', "start_cursor":"%s"' "$cursor" )'}'
  resp="$(curl -sS -X POST "https://api.notion.com/v1/databases/${DB}/query" \
    -H "Authorization: Bearer ${API}" -H "Notion-Version: ${VER}" \
    -H "Content-Type: application/json" -d "${body}")"

  printf '%s' "$resp" \
  | jq -r --arg s "$SKEY" '
      .results[]
      | [.id, (.properties[$s].rich_text[0]?.plain_text // "")]
      | @tsv' \
  | while IFS=$'\t' read -r PID RAW; do
      [ -z "$RAW" ] && continue
      FIXED="$(jq -r --arg txt "$RAW" '
         $txt
         | gsub("^No Title[[:space:]]*(\\\\n)*"; "")
         | (split("\\n") | join("\n"))
         | gsub("[[:space:]]+$"; "")
       ' <<< '')"
      [ "$FIXED" = "$RAW" ] && continue
      jq -n --arg s "$SKEY" --arg m "$FIXED" \
        '{properties:{($s):{rich_text:[{text:{content:$m}}]}}}' >/tmp/_m.json
      curl -sS -X PATCH "https://api.notion.com/v1/pages/${PID}" \
        -H "Authorization: Bearer ${API}" -H "Notion-Version: ${VER}" \
        -H "Content-Type: application/json" --data-binary @/tmp/_m.json >/dev/null \
        && echo "fixed-summary ${PID}"
      sleep 0.2
    done

  cursor="$(printf '%s' "$resp" | jq -r '.next_cursor // empty')"
  has_more="$(printf '%s' "$resp" | jq -r '.has_more')"
  [ "$has_more" = "true" ] || break
done
