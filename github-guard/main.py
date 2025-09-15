import os, time, yaml, requests

CONF = yaml.safe_load(open("config.yaml"))
TOK  = os.environ.get("GITHUB_TOKEN") or CONF["github"]["token"]
REPO = CONF["github"]["repo"]
INTERVAL = int(CONF["github"]["interval_sec"])

S = requests.Session()
if TOK:
    S.headers["Authorization"] = f"Bearer {TOK}"

def poll():
    r = S.get(f"https://api.github.com/repos/{REPO}", timeout=10)
    r.raise_for_status()
    open("/tmp/ok.ts","w").write(str(int(time.time())))
    print(f"ok: {REPO} stars={r.json().get('stargazers_count')}", flush=True)

print("github-guard: start")
while True:
    try:
        poll()
    except Exception as e:
        print("error:", e, flush=True)
    time.sleep(INTERVAL)
