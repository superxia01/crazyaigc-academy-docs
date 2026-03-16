---
title: "VPS + Docker 搭建"
description: "OpenClaw VPS 部署教程：手把手在云服务器上用 Docker 部署 OpenClaw，打造 7×24 小时在线的 AI 助手，含服务器选购建议。"
date: "2026-03-16"
category: "AI 助手搭建"
tags: [openclaw-cases,OpenClaw]
order: 18
---


# VPS 部署实战：Docker 搭建 24 小时在线助手

本文手把手带你在一台 VPS 上用 Docker 部署 OpenClaw，让你的 AI 助手全天候在线，随时通过 WhatsApp、Telegram 等渠道与你对话。

## 服务器选购建议

OpenClaw 本身是轻量级网关，不运行模型推理，所以对硬件要求不高。以下是推荐配置：

| 配置项 | 最低要求 | 推荐配置 |
|--------|---------|---------|
| CPU | 1 vCPU | 2 vCPU |
| 内存 | 1 GB | 2 GB |
| 硬盘 | 10 GB SSD | 20 GB SSD |
| 带宽 | 1 TB/月 | 不限流量 |
| 系统 | Ubuntu 22.04+ | Ubuntu 24.04 LTS |

**热门 VPS 供应商推荐：**

- **Hetzner**（推荐）：CX22 套餐约 €4.15/月，2 vCPU + 4GB RAM，性价比极高，欧洲机房延迟稳定
- **DigitalOcean**：$6/月起，适合北美用户
- **Vultr**：$6/月起，全球多机房
- **Contabo**：€4.99/月起，配置高但网络一般
- **腾讯云/阿里云轻量**：国内用户可选，但需注意海外 API 访问问题

> 💡 **提示**：如果你主要使用 Anthropic / OpenAI API，选择美国或欧洲机房延迟更低。国内机房可能需要额外配置代理。

## Docker 安装

SSH 连接到你的服务器后，执行以下命令安装 Docker：

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装 Docker（官方一键脚本）
curl -fsSL https://get.docker.com | sh

# 将当前用户加入 docker 组（免 sudo）
sudo usermod -aG docker $USER

# 重新登录使权限生效
exit
# 重新 SSH 连接

# 验证安装
docker --version
docker compose version
```

确认 `docker compose` 命令可用（Docker 新版本自带 Compose V2 插件）。

## 克隆 OpenClaw 仓库

```bash
# 创建工作目录
mkdir -p /opt/openclaw && cd /opt/openclaw

# 克隆仓库
git clone https://github.com/anthropics/openclaw.git .
```

仓库中包含了 `docker-compose.yml` 和相关配置模板。

## docker-compose 配置

OpenClaw 提供了开箱即用的 Docker Compose 配置。查看并根据需要调整：

```yaml
# docker-compose.yml
version: "3.8"

services:
  openclaw:
    image: ghcr.io/anthropics/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    ports:
      - "127.0.0.1:4100:4100"   # Gateway API（仅本地访问）
      - "127.0.0.1:4101:4101"   # Web UI
    volumes:
      - ./data:/root/.openclaw          # 持久化数据
      - /var/run/docker.sock:/var/run/docker.sock  # 沙箱支持
    env_file:
      - .env
    environment:
      - TZ=Asia/Shanghai              # 时区设置
```

> ⚠️ **安全提示**：端口绑定到 `127.0.0.1` 而不是 `0.0.0.0`，避免直接暴露到公网。通过 SSH 隧道或反向代理访问。

## 环境变量设置

创建 `.env` 文件配置关键参数：

```bash
# .env 文件

# === AI 模型 API ===
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
# 或使用 OpenAI
# OPENAI_API_KEY=sk-xxxxxxxxxxxxx

# === 渠道配置 ===
# Telegram Bot
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-xxxxx

# WhatsApp（使用内置 Baileys 桥接）
# 启动后扫码配对，无需额外 token

# Discord
# DISCORD_BOT_TOKEN=xxxxxxxxxxxxx

# === 可选配置 ===
# 默认模型
# OPENCLAW_DEFAULT_MODEL=claude-sonnet-4-20250514

# Web 搜索
# BRAVE_API_KEY=xxxxxxxxxxxxx

# TTS 语音
# ELEVENLABS_API_KEY=xxxxxxxxxxxxx
```

```bash
# 设置文件权限，保护 API 密钥
chmod 600 .env
```

## 持久化存储

Docker 卷映射 `./data:/root/.openclaw` 确保以下数据在容器重启后保留：

```
data/
├── workspace/           # Agent 工作空间
│   ├── SOUL.md         # AI 人格定义
│   ├── MEMORY.md       # 长期记忆
│   ├── memory/         # 每日记忆
│   └── ...
├── config.yaml         # 全局配置
├── agents/             # Agent 配置
├── channels/           # 渠道状态（WhatsApp session 等）
└── skills/             # 已安装的 Skill
```

**备份建议：**

```bash
# 定期备份数据目录
tar czf openclaw-backup-$(date +%Y%m%d).tar.gz ./data

# 或使用 cron 自动备份
crontab -e
# 添加：每天凌晨3点备份
# 0 3 * * * cd /opt/openclaw && tar czf /backups/openclaw-$(date +\%Y\%m\%d).tar.gz ./data
```

## 启动与管理

```bash
# 启动（后台运行）
docker compose up -d

# 查看日志
docker compose logs -f

# 重启
docker compose restart

# 停止
docker compose down

# 更新到最新版本
docker compose pull
docker compose up -d
```

启动后，OpenClaw Gateway 会在 `localhost:4100` 运行。

## SSH 隧道访问

由于端口仅绑定到本地，你需要通过 SSH 隧道从本机访问 Web UI：

```bash
# 在你的本地电脑执行（不是服务器上）
ssh -L 4101:localhost:4101 -L 4100:localhost:4100 user@your-server-ip

# 然后在浏览器打开
# http://localhost:4101
```

**使用 VS Code Remote SSH：** 如果你用 VS Code 的 Remote SSH 连接服务器，端口会自动转发，更方便。

**使用反向代理（进阶）：** 如果需要公网访问，可配置 Nginx + Let's Encrypt：

```nginx
server {
    listen 443 ssl;
    server_name openclaw.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/openclaw.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/openclaw.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:4101;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

## 渠道配置

### Telegram Bot

1. 在 Telegram 中找到 [@BotFather](https://t.me/BotFather)，发送 `/newbot` 创建机器人
2. 复制获得的 Token 填入 `.env` 的 `TELEGRAM_BOT_TOKEN`
3. 重启 OpenClaw：`docker compose restart`
4. 向你的 Bot 发送消息即可开始对话

### WhatsApp 配对

OpenClaw 内置了 WhatsApp Web 桥接（基于 Baileys）：

1. 启动 OpenClaw 后，查看日志中的 QR 码：
   ```bash
   docker compose logs -f | grep -A 20 "QR"
   ```
2. 打开手机 WhatsApp → 设置 → 关联设备 → 扫描二维码
3. 配对成功后，session 数据会持久化，重启无需重新扫码

> 💡 **注意**：WhatsApp 会话可能在 14 天左右失效，需要重新扫码。建议定期检查连接状态。

### Discord Bot

1. 在 [Discord Developer Portal](https://discord.com/developers/applications) 创建 Application
2. 进入 Bot 页面，复制 Token
3. 开启 Message Content Intent
4. 生成邀请链接，将 Bot 加入你的服务器
5. 在 `.env` 中设置 `DISCORD_BOT_TOKEN`

## 常见问题

### Q: 容器启动后立刻退出怎么办？

```bash
# 查看退出日志
docker compose logs --tail 50

# 常见原因：
# 1. .env 文件格式错误（不要有多余空格）
# 2. API Key 无效
# 3. 端口被占用
```

### Q: WhatsApp 扫码后仍无法收发消息？

- 确认手机 WhatsApp 版本是最新的
- 检查服务器能否访问 WhatsApp 的 WebSocket 服务器
- 查看日志中是否有连接错误

### Q: 如何设置 AI 人格？

编辑 `data/workspace/SOUL.md` 文件：

```bash
cat > data/workspace/SOUL.md << 'EOF'
# 你的名字

你是一个友善、专业的 AI 助手。

## 性格特点
- 温暖亲切，偶尔幽默
- 回答简洁但有深度
- 主动提供有价值的信息

## 技能
- 中英双语流利
- 熟悉技术领域
EOF
```

### Q: 如何监控 OpenClaw 运行状态？

```bash
# 查看容器状态
docker compose ps

# 查看资源使用
docker stats openclaw

# 简单的健康检查脚本
curl -s http://localhost:4100/health || echo "OpenClaw is down!"
```

### Q: 如何升级 OpenClaw？

```bash
cd /opt/openclaw
docker compose pull          # 拉取最新镜像
docker compose up -d         # 重建容器
docker image prune -f        # 清理旧镜像
```

数据目录挂载在宿主机上，升级不会丢失配置和记忆。

