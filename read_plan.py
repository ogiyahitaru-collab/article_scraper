import json

# plan.jsonの読み込み
with open('config/plan.json', 'r', encoding='utf-8') as f:
    plan_data = json.load(f)

print(json.dumps(plan_data, indent=4, ensure_ascii=False))
