#!/usr/bin/env bash
# Render でデプロイするたびに実行するビルド手順
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
bin/rails db:migrate
# 質問・配点・タイプなどのマスタを YAML から登録・更新する（何度実行しても同じ結果になる）
bin/rails db:seed
