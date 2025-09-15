#!/usr/bin/env bash
set -euo pipefail
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -a; . /volume2/docker/article_scraper/.env; set +a

DB="$NOTION_DATABASE_ID"
API="$NOTION_API_KEY"
VER="${NOTION_VERSION:-2022-06-28}"
DKEY="${NOTION_PROP_DATE:-日付}"

cursor=""
while :; do
  body='{"page_size":100'$( [ -n "${cursor}" ] && printf ', "start_cursor":"%s"' "$cursor" )'}'
  resp="$(curl -sS -X POST "https://api.notion.com/v1/databases/${DB}/query" \
    -H "Authorization: Bearer ${API}" -H "Notion-Version: ${VER}" \
    -H "Content-Type: application/json" -d "${body}")"

  printf '%s' "$resp" \
  | jq -r --arg d "$DKEY" '
      .results[] 
      | select(.properties[$d].date.start?)
      | [.id, .properties[$d].date.start]
      | @tsv' \
  | while IFS=$'\t' read -r PID START; do
      YMD="${START:0:10}"
      [ -z "$YMD" ] && continue
      [ "$YMD" = "$START" ] && continue
      jq -n --arg d "$DKEY" --arg s "$YMD" \
        '{properties:{($d):{date:{start:$s}}}}' >/tmp/_d.json
      curl -sS -X PATCH "https://api.notion.com/v1/pages/${PID}" \
        -H "Authorization: Bearer ${API}" -H "Notion-Version: ${VER}" \
        -H "Content-Type: application/json" --data-binary @/tmp/_d.json >/dev/null \
        && echo "fixed-date ${PID} -> ${YMD}"
      sleep 0.2
    done

  cursor="$(printf '%s' "$resp" | jq -r '.next_cursor // empty')"
  has_more="$(printf '%s' "$resp" | jq -r '.has_more')"
  [ "$has_more" = "true" ] || break
done
