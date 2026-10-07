# じぶんノート

質問に答えて、自分の強みを7つの診断軸から見つける自己理解アプリ（RUNTEQ 卒業制作）。

## 技術構成

- Ruby 3.4 / Ruby on Rails 8.1
- PostgreSQL 16
- Tailwind CSS / Hotwire
- 開発環境: Docker（compose.yml）
- デプロイ先: Render（予定）

## 開発環境の起動

```sh
docker compose build
docker compose run --rm web bin/rails db:prepare
docker compose up
```

ブラウザで http://localhost:3000 を開く。

3000番が使用中のときは `WEB_PORT=3001 docker compose up` のようにポートを変えられる。

## よく使うコマンド

```sh
docker compose exec web bin/rails console        # Rails コンソール
docker compose exec web bin/rails db:migrate     # マイグレーション
docker compose exec web bundle install           # Gem を追加したとき
docker compose down                              # 停止
```
