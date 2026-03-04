#!/bin/bash
# WSL2 Ubuntu 上に Docker Engine をインストールするスクリプト
# 使い方: WSL2 Ubuntu ターミナルで bash setup-docker-wsl.sh を実行

set -e

echo "=================================="
echo "Docker Engine セットアップ開始"
echo "=================================="

# 既存のDockerパッケージを削除（Docker Desktopの残骸など）
echo "[1/5] 古いDockerパッケージを削除中..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y $pkg 2>/dev/null || true
done

# 必要なパッケージを追加
echo "[2/5] 必要なパッケージをインストール中..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Docker の公式 GPG キーを追加
echo "[3/5] Docker GPGキーを追加中..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker リポジトリを追加
echo "[4/5] Dockerリポジトリを追加中..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Docker Engine をインストール
echo "[5/5] Docker Engine をインストール中..."
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# 現在のユーザーを docker グループに追加（sudo なしで docker を使用可能に）
sudo usermod -aG docker "$USER"

# Docker サービスを起動
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "=================================="
echo "インストール完了！"
echo "=================================="
echo ""
echo "動作確認:"
docker --version
docker compose version
echo ""
echo "注意: グループ変更を反映するため、以下のコマンドを実行してください:"
echo "  newgrp docker"
echo "  または WSL2 を再起動してください (PowerShell で: wsl --shutdown)"
