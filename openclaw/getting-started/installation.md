---
title: "安装与部署"
description: "OpenClaw 安装教程：从环境准备到部署运行的完整指南，支持 npm 全局安装和 Docker 两种方式，5分钟快速上手。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-getting-started,OpenClaw]
order: 2
---


# 安装与部署

本篇将带你完成 OpenClaw 的安装和初始部署。无论你使用的是 Linux 服务器、macOS 还是 Windows（通过 WSL），都可以按照本教程快速上手。整个过程通常只需要 5-10 分钟。

## 环境要求

在开始安装之前，请确保你的系统满足以下要求：

### 必要条件

- **Node.js 22+**：OpenClaw 使用了较新的 Node.js 特性，因此需要 22.x 或更高版本
- **npm 或 yarn**：包管理器，随 Node.js 一起安装
- **操作系统**：Linux（推荐）、macOS、Windows（通过 WSL2）

### 推荐配置

- **内存**：至少 512MB 可用内存（推荐 1GB+）
- **磁盘**：至少 500MB 可用空间
- **网络**：稳定的互联网连接（需要访问 LLM API）

### 检查 Node.js 版本

```bash
node --version
# 输出应该是 v22.x.x 或更高
```

如果你还没有安装 Node.js 22+，推荐使用 [nvm](https://github.com/nvm-sh/nvm) 来管理版本：

```bash
# 安装 nvm（如果尚未安装）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# 重新加载 shell 配置
source ~/.bashrc  # 或 source ~/.zshrc

# 安装并使用 Node.js 22
nvm install 22
nvm use 22
nvm alias default 22

# 验证版本
node --version
```

> ⚠️ **注意**：如果你的系统自带的 Node.js 版本较低（如 Ubuntu 默认的 v12/v18），请不要使用系统包管理器安装，推荐使用 nvm 管理多版本。

## npm 全局安装（推荐）

这是最快捷的安装方式，一行命令即可完成：

```bash
npm install -g openclaw@latest
```

安装完成后，验证是否安装成功：

```bash
openclaw --version
```

如果你看到版本号输出，说明安装成功。

### 权限问题

在 Linux/macOS 上，全局安装 npm 包可能会遇到权限问题。有两种解决方案：

**方案一：使用 nvm（推荐）**

如果你通过 nvm 安装的 Node.js，通常不会有权限问题。

**方案二：修改 npm 全局安装目录**

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

> 💡 **提示**：不推荐使用 `sudo npm install -g`，这可能会导致后续的权限问题。

## 运行 Onboarding Wizard

安装完成后，运行 onboarding wizard 来完成初始化配置。这个向导会引导你完成以下步骤：

- 创建配置文件
- 设置 AI 模型提供商的 API Key
- 配置第一个通讯渠道
- 安装守护进程（daemon）

```bash
openclaw onboard --install-daemon
```

`--install-daemon` 参数会同时安装系统守护进程，让 Gateway 可以在后台持续运行并开机自启。

向导会以交互式问答的形式引导你完成配置。大致流程如下：

```
🐾 Welcome to OpenClaw!

? Select your AI provider: (Use arrow keys)
  ❯ Anthropic (Claude)
    OpenAI (GPT)
    Google (Gemini)
    Custom / OpenAI-compatible

? Enter your API key: sk-ant-xxxx...

? Choose a channel to set up:
  ❯ Telegram
    Discord
    WhatsApp
    Skip for now

✅ Configuration saved to ~/.openclaw/openclaw.json
✅ Daemon installed and started
```

> 💡 **提示**：如果你还没有准备好 API Key 或渠道配置，可以暂时跳过，后续通过编辑配置文件或 Control UI 来补充。

## 启动 Gateway

如果你在 onboarding 中选择了安装 daemon，Gateway 应该已经在运行了。你也可以手动启动：

```bash
# 前台运行（适合调试，按 Ctrl+C 停止）
openclaw gateway

# 以守护进程方式启动
openclaw gateway start

# 查看运行状态
openclaw gateway status

# 停止 Gateway
openclaw gateway stop

# 重启 Gateway
openclaw gateway restart
```

前台运行模式适合调试和开发，你可以直接在终端看到所有日志输出。守护进程模式适合正式部署，Gateway 会在后台运行，不受终端关闭影响。

## 验证安装

使用以下命令验证 OpenClaw 是否正确安装并正常运行：

### openclaw status

```bash
openclaw status
```

这个命令会显示 Gateway 的运行状态、连接的渠道、活跃的会话等信息。输出类似于：

```
OpenClaw Status
───────────────
Gateway:     running (pid 12345)
Uptime:      2h 15m
Channels:    telegram (connected), discord (connected)
Sessions:    3 active
Model:       claude-sonnet-4-20250514
```

### openclaw doctor

```bash
openclaw doctor
```

`openclaw doctor` 是一个诊断工具，它会检查你的安装环境和配置文件，并报告任何问题：

```
OpenClaw Doctor
───────────────
✅ Node.js version: v22.12.0
✅ OpenClaw version: 0.x.x
✅ Config file: ~/.openclaw/openclaw.json
✅ API key: configured (Anthropic)
⚠️ Workspace: SOUL.md not found (optional)
✅ Gateway: running
✅ Channel telegram: connected
```

如果有任何项目显示 ❌ 或 ⚠️，按照提示进行修复即可。

## 从源码安装

如果你想参与开发或需要使用最新的开发版本，可以从源码安装：

```bash
# 克隆仓库
git clone https://github.com/nicepkg/openclaw.git
cd openclaw

# 安装依赖
npm install

# 构建项目
npm run build

# 链接到全局（可选）
npm link

# 验证
openclaw --version
```

从源码安装的优势：

- 可以使用最新的开发特性
- 方便调试和提交 PR
- 可以修改源码适配自定义需求

> ⚠️ **注意**：从源码安装的版本可能不稳定，不推荐用于生产环境。

### 保持更新

```bash
cd openclaw
git pull origin main
npm install
npm run build
```

## Docker 安装

OpenClaw 也提供了 Docker 镜像，适合容器化部署场景：

```bash
# 拉取最新镜像
docker pull openclaw/openclaw:latest

# 运行容器
docker run -d \
  --name openclaw \
  -v ~/.openclaw:/root/.openclaw \
  -p 18789:18789 \
  openclaw/openclaw:latest
```

使用 Docker Compose：

```yaml
# docker-compose.yml
version: '3.8'
services:
  openclaw:
    image: openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    ports:
      - "18789:18789"
    volumes:
      - ./openclaw-data:/root/.openclaw
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
```

```bash
# 启动
docker compose up -d

# 查看日志
docker compose logs -f openclaw
```

> 💡 **提示**：使用 Docker 时，请确保将配置目录挂载到宿主机，避免容器重建时丢失配置。

## 环境变量说明

OpenClaw 支持通过环境变量来覆盖默认行为，这在 Docker 部署和 CI/CD 场景下非常有用：

### OPENCLAW_HOME

OpenClaw 的主目录，默认为 `~/.openclaw`。所有配置文件、工作空间文件、日志等都存储在此目录下。

```bash
export OPENCLAW_HOME=/opt/openclaw
```

### OPENCLAW_STATE_DIR

状态文件存储目录，默认为 `$OPENCLAW_HOME/state`。包含会话数据、运行时状态等。

```bash
export OPENCLAW_STATE_DIR=/var/lib/openclaw/state
```

### OPENCLAW_CONFIG_PATH

配置文件的完整路径，默认为 `$OPENCLAW_HOME/openclaw.json`。如果你想将配置文件放在其他位置，可以通过此变量指定。

```bash
export OPENCLAW_CONFIG_PATH=/etc/openclaw/config.json
```

### 示例：自定义部署路径

```bash
# 在 .bashrc 或 .zshrc 中添加
export OPENCLAW_HOME=/opt/openclaw
export OPENCLAW_STATE_DIR=/var/lib/openclaw/state
export OPENCLAW_CONFIG_PATH=/etc/openclaw/openclaw.json
```

这样 OpenClaw 的各个组件就会使用你指定的路径，方便在服务器上进行规范化部署。

## 常见安装问题排查

### 1. `openclaw: command not found`

**原因**：npm 全局安装的路径没有加入 PATH。

**解决方案**：

```bash
# 查看 npm 全局安装路径
npm config get prefix

# 将 bin 目录加入 PATH
echo 'export PATH=$(npm config get prefix)/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 2. `Error: Unsupported Node.js version`

**原因**：Node.js 版本低于 22。

**解决方案**：

```bash
# 使用 nvm 升级
nvm install 22
nvm use 22
```

### 3. `EACCES: permission denied`

**原因**：没有权限写入全局 npm 目录。

**解决方案**：参考上文「权限问题」部分，使用 nvm 或修改 npm 全局目录。

### 4. Gateway 启动失败

**原因**：端口被占用，或配置文件有误。

**解决方案**：

```bash
# 检查端口占用
lsof -i :18789

# 运行诊断
openclaw doctor

# 查看详细错误日志
openclaw gateway --verbose
```

### 5. API Key 配置后仍然报错

**原因**：API Key 可能有格式错误或已过期。

**解决方案**：

```bash
# 重新运行配置向导
openclaw onboard

# 或直接编辑配置文件
nano ~/.openclaw/openclaw.json
```

## 更新 OpenClaw

保持 OpenClaw 最新版本以获得最新功能和修复：

```bash
# npm 全局更新
npm update -g openclaw

# 或者指定最新版本
npm install -g openclaw@latest

# 更新后重启 Gateway
openclaw gateway restart
```

> 💡 **提示**：更新前建议备份你的配置文件 `~/.openclaw/openclaw.json`，虽然更新通常不会影响配置文件，但备份总是个好习惯。

## 下一步

安装完成后，建议继续阅读：

1. **[Gateway 基础](/academy/openclaw/getting-started/gateway-basics)** — 深入了解 Gateway 的运行原理和管理方式
2. **[配置文件详解](/academy/openclaw/config/config-guide)** — 学习如何配置 AI 模型、渠道和技能
3. **[打造你的 AI 人设](/academy/openclaw/config/persona)** — 给你的 AI 助手赋予独特的人格

