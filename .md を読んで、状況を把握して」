# 🧠 開発ガイドライン・ログ運用ルール

## 🗂️ 開発ディレクトリ構成
- 実装場所：`/volume2/docker/article_scraper`
- 仮想環境：`.venv`
- ログ保存先：`/volume2/logs/progress.log`

## 🪵 ログ記録ルール
- 開始前・終了時・節目ごとに：
```bash
bash /volume2/logs/progress_log.sh "コメント"

# 🛠 開発方針ドキュメント

## 🧭 基本方針

- ターミナル操作で完結させる（GUI不要）
- 作業ログは `/volume2/logs/progress.log` に記録
- 毎セッション開始時に `bash /volume2/logs/progress_log.sh` を使って記録する
- 仮想環境は `/volume2/docker/article_scraper/.venv` を使用
- Git でバージョン管理（`git add . && git commit -m "..."`）

## 📁 ディレクトリ構成（例）
/volume2/docker/article_scraper/
├── .venv/ # 仮想環境
├── main.py # メイン処理
├── utils/ # 補助処理
├── output/ # 出力ファイル
├── requirements.txt # 依存パッケージ
├── Dockerfile # Docker構成
├── dev_guidelines.md # ←このファイル

## 🧪 よく使うコマンド

```bash
# 仮想環境の作成と起動
python3 -m venv .venv
source .venv/bin/activate

# 依存パッケージのインストール
pip install --break-system-packages -r requirements.txt

# ログ記録
bash /volume2/logs/progress_log.sh "🔧 作業開始：機能追加 or 修正"

# Docker起動
bash start_dev.sh

# Git 操作
git add .
git commit -m "〇〇対応"


貼り付け後は下記キー操作で保存してください：

- `Ctrl + O` → `Enter`（保存）
- `Ctrl + X`（終了）

---

## 🔁 次の行動

完了したらこのように打って動作確認しましょう：

```bash
cat /volume2/docker/article_scraper/dev_guidelines.md
