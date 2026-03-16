---
title: "配置文件详解"
description: "OpenClaw 配置文件完全指南：openclaw.json 的每个配置项详细说明，包括模型、渠道、技能和安全配置的最佳实践。"
date: "2026-03-16"
category: "AI 助手搭建"
tags: [openclaw-config,OpenClaw]
order: 4
---


# 配置文件详解

OpenClaw 的强大之处在于它的高度可配置性。一个配置文件就能定义 AI 的行为、连接的渠道、可用的技能——几乎所有东西都可以通过配置来调整。本篇将带你深入了解配置文件的每个角落。

## 配置文件位置

OpenClaw 的配置文件默认位于：

```
~/.openclaw/openclaw.json
```

这是一个标准的 JSON 文件。如果你通过 `openclaw onboard` 向导完成了初始化，这个文件已经自动创建好了。

你也可以通过环境变量自定义配置文件路径：

```bash
export OPENCLAW_CONFIG_PATH=/etc/openclaw/config.json
```

> 💡 **提示**：配置文件使用 JSON 格式。如果你不熟悉 JSON 的语法，建议使用 Control UI 的可视化编辑器来修改配置，避免因格式错误导致 Gateway 无法启动。

## 最小配置示例

一个最简单的、能正常运行的配置文件长这样：

```json
{
  "agents": [
    {
      "name": "main",
      "model": "anthropic/claude-sonnet-4-20250514",
      "apiKey": "sk-ant-xxxxxxxxxxxx"
    }
  ],
  "channels": [
    {
      "type": "telegram",
      "token": "123456:ABC-DEF..."
    }
  ]
}
```

就这么简单！你只需要定义一个 Agent（指定 AI 模型和 API Key）和至少一个 Channel（指定通讯渠道），OpenClaw 就能运行起来。

当然，这只是起点。OpenClaw 提供了丰富的配置项，让你可以精确控制每一个细节。

## 配置编辑方式

OpenClaw 提供了多种编辑配置的方式，从图形界面到命令行，总有一种适合你：

### 1. Onboarding Wizard

最适合新手的方式。交互式问答，一步步引导你完成配置：

```bash
openclaw onboard
```

### 2. CLI 命令

通过命令行直接修改特定配置项：

```bash
# 添加或更新配置项
openclaw config set agents[0].model "anthropic/claude-opus-4-20250514"

# 查看当前配置
openclaw config get agents

# 验证配置文件
openclaw doctor
```

### 3. Control UI

通过浏览器访问控制面板，在可视化编辑器中修改配置：

```
http://localhost:18789
```

Control UI 提供了语法高亮、实时校验和自动补全，非常直观。修改后点击保存，支持热更新的配置项会立即生效。

### 4. 直接编辑

直接用你喜欢的编辑器打开配置文件：

```bash
# 使用 vim
vim ~/.openclaw/openclaw.json

# 使用 nano
nano ~/.openclaw/openclaw.json

# 使用 VS Code（需要 SSH Remote 扩展）
code ~/.openclaw/openclaw.json
```

> ⚠️ **注意**：直接编辑时请确保 JSON 格式正确。一个多余的逗号或缺失的引号都会导致解析失败。编辑完成后建议运行 `openclaw doctor` 验证。

## 核心配置项概览

OpenClaw 的配置文件由几个核心部分组成。下面逐一介绍：

### agents — AI 智能体配置

`agents` 数组定义了你的 AI 智能体。每个 Agent 代表一个 AI 实体，有自己的模型、人格和技能：

```json
{
  "agents": [
    {
      "name": "main",
      "model": "anthropic/claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "systemPrompt": "你是一个友好、幽默的 AI 助手。",
      "temperature": 0.7,
      "maxTokens": 4096,
      "thinkingLevel": "medium",
      "skills": ["web-search", "browser", "code-exec"]
    },
    {
      "name": "coder",
      "model": "anthropic/claude-opus-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "systemPrompt": "你是一个资深程序员，擅长代码审查和架构设计。",
      "skills": ["code-exec", "file-edit", "git"]
    }
  ]
}
```

常用字段说明：

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | Agent 名称，用于在多 Agent 场景下标识 |
| `model` | string | 模型标识，格式为 `provider/model-name` |
| `apiKey` | string | API Key，支持环境变量引用 |
| `systemPrompt` | string | 系统提示词（也可以用工作空间文件代替） |
| `temperature` | number | 温度参数（0-1），越高越有创造力 |
| `maxTokens` | number | 最大输出 token 数 |
| `thinkingLevel` | string | 思考深度（low/medium/high），影响模型推理 |
| `skills` | array | Agent 可用的技能列表 |

### channels — 通讯渠道配置

`channels` 数组定义了 OpenClaw 接入的通讯平台：

```json
{
  "channels": [
    {
      "type": "telegram",
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowedUsers": ["your_telegram_id"],
      "agent": "main"
    },
    {
      "type": "discord",
      "token": "${DISCORD_BOT_TOKEN}",
      "applicationId": "your_app_id",
      "allowedGuilds": ["guild_id_1"],
      "agent": "main"
    },
    {
      "type": "qqbot",
      "appId": "${QQ_APP_ID}",
      "secret": "${QQ_SECRET}",
      "agent": "main"
    }
  ]
}
```

每种渠道类型有自己特定的配置字段。详细的渠道配置请参考各渠道的专题文档。

### tools — 技能/工具配置

`tools` 用于配置 Agent 可使用的技能和工具：

```json
{
  "tools": {
    "browser": {
      "enabled": true,
      "headless": true
    },
    "code-exec": {
      "enabled": true,
      "sandbox": true,
      "timeout": 30000
    },
    "web-search": {
      "enabled": true,
      "provider": "brave",
      "apiKey": "${BRAVE_API_KEY}"
    }
  }
}
```

### session — 会话配置

`session` 控制对话会话的行为：

```json
{
  "session": {
    "ttl": 3600,
    "maxHistory": 50,
    "maxContextTokens": 128000,
    "summarize": true,
    "summaryModel": "anthropic/claude-haiku-4-20250514"
  }
}
```

| 字段 | 说明 |
|------|------|
| `ttl` | 会话超时时间（秒），超时后开始新会话 |
| `maxHistory` | 最大保留的消息条数 |
| `maxContextTokens` | 发送给模型的最大上下文 token 数 |
| `summarize` | 是否启用自动摘要（上下文过长时压缩） |
| `summaryModel` | 用于生成摘要的模型（可选更便宜的模型） |

### gateway — Gateway 配置

`gateway` 控制 Gateway 本身的行为：

```json
{
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "configReload": "hybrid",
    "auth": {
      "password": "${GATEWAY_PASSWORD}"
    },
    "log": {
      "level": "info",
      "file": "~/.openclaw/logs/gateway.log"
    }
  }
}
```

## 热更新说明

OpenClaw 的配置热更新是一个非常实用的特性。当你修改配置文件后，Gateway 会自动检测到变更并尝试应用。

### 可以热更新的配置

以下配置修改后**不需要重启** Gateway：

- ✅ Agent 的 `systemPrompt`、`temperature`、`maxTokens`
- ✅ Agent 的 `skills` 列表
- ✅ `session` 相关配置（`ttl`、`maxHistory` 等）
- ✅ `tools` 中各技能的参数调整
- ✅ `thinkingLevel` 思考深度

### 需要重启的配置

以下配置修改后**需要重启** Gateway：

- ❌ `channels` 的增加或删除
- ❌ `gateway.port` 端口变更
- ❌ `gateway.bind` 绑定模式变更
- ❌ `gateway.auth` 认证方式变更
- ❌ 渠道的 Token/API Key 变更

在默认的 `hybrid` 模式下，Gateway 会自动判断变更是否可以热更新。如果需要重启，它会在日志中提示你。

```bash
# 手动重启以应用需要重启的配置
openclaw gateway restart
```

## 环境变量引用

配置文件中支持使用 `${VAR_NAME}` 语法引用环境变量。这是**强烈推荐**的做法——永远不要把 API Key 等敏感信息直接写在配置文件中。

```json
{
  "agents": [
    {
      "name": "main",
      "model": "anthropic/claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}"
    }
  ],
  "channels": [
    {
      "type": "telegram",
      "token": "${TELEGRAM_BOT_TOKEN}"
    }
  ],
  "gateway": {
    "auth": {
      "password": "${GATEWAY_PASSWORD}"
    }
  }
}
```

然后在你的环境中设置这些变量：

```bash
# 在 ~/.bashrc 或 ~/.zshrc 中添加
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxx"
export TELEGRAM_BOT_TOKEN="123456:ABC-DEF..."
export GATEWAY_PASSWORD="my-secure-password"
```

或者使用 `.env` 文件：

```bash
# ~/.openclaw/.env
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxx
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
GATEWAY_PASSWORD=my-secure-password
```

> ⚠️ **安全提示**：确保 `.env` 文件的权限设置正确（`chmod 600`），不要将包含敏感信息的文件提交到 Git 仓库。

## 严格验证模式

OpenClaw 在读取配置文件时会进行语法和语义校验。如果配置有误，Gateway 会拒绝启动并给出详细的错误提示。

常见的校验错误：

```
❌ Config Error: agents[0].model is required
❌ Config Error: channels[0].type "wechat" is not a valid channel type
❌ Config Error: session.ttl must be a positive number
❌ Config Error: Invalid JSON: Unexpected token } at position 234
```

你可以随时使用 `openclaw doctor` 来验证配置文件：

```bash
openclaw doctor
```

输出示例：

```
OpenClaw Doctor
───────────────
✅ Config file: valid JSON
✅ Schema validation: passed
✅ Agent "main": model configured
✅ Agent "main": API key resolved
⚠️ Agent "main": systemPrompt is empty (will use workspace files)
✅ Channel telegram: token resolved
✅ Channel discord: token resolved
✅ Tools: web-search API key resolved
⚠️ Workspace: SOUL.md not found (optional)
───────────────
Result: 2 warnings, 0 errors
```

## 配置示例合集

以下是几个常见场景的完整配置示例，方便你参考和复用。

### 个人助手（最简配置）

适合个人使用的最简配置，一个 Agent + 一个 Telegram 渠道：

```json
{
  "agents": [
    {
      "name": "main",
      "model": "anthropic/claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "temperature": 0.7,
      "maxTokens": 4096
    }
  ],
  "channels": [
    {
      "type": "telegram",
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowedUsers": ["your_telegram_id"]
    }
  ],
  "session": {
    "ttl": 7200,
    "maxHistory": 30
  }
}
```

### 多渠道助手

同时接入 Telegram、Discord 和 QQ 的配置：

```json
{
  "agents": [
    {
      "name": "main",
      "model": "anthropic/claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "temperature": 0.7,
      "skills": ["web-search", "browser", "code-exec"]
    }
  ],
  "channels": [
    {
      "type": "telegram",
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowedUsers": ["user_id_1"]
    },
    {
      "type": "discord",
      "token": "${DISCORD_BOT_TOKEN}",
      "applicationId": "${DISCORD_APP_ID}",
      "allowedGuilds": ["guild_id_1"]
    },
    {
      "type": "qqbot",
      "appId": "${QQ_APP_ID}",
      "secret": "${QQ_SECRET}"
    }
  ],
  "session": {
    "ttl": 3600,
    "maxHistory": 50,
    "maxContextTokens": 128000
  },
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "configReload": "hybrid"
  }
}
```

### 高级配置（多 Agent + 完整技能栈）

面向高级用户的完整配置示例：

```json
{
  "agents": [
    {
      "name": "main",
      "model": "anthropic/claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "temperature": 0.7,
      "maxTokens": 8192,
      "thinkingLevel": "medium",
      "skills": ["web-search", "browser", "code-exec", "file-edit", "tts"]
    },
    {
      "name": "coder",
      "model": "anthropic/claude-opus-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}",
      "temperature": 0.3,
      "maxTokens": 16384,
      "thinkingLevel": "high",
      "skills": ["code-exec", "file-edit", "git", "browser"]
    }
  ],
  "channels": [
    {
      "type": "telegram",
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowedUsers": ["admin_user_id"],
      "agent": "main"
    },
    {
      "type": "discord",
      "token": "${DISCORD_BOT_TOKEN}",
      "applicationId": "${DISCORD_APP_ID}",
      "agent": "main"
    }
  ],
  "tools": {
    "web-search": {
      "provider": "brave",
      "apiKey": "${BRAVE_API_KEY}"
    },
    "browser": {
      "headless": true
    },
    "code-exec": {
      "sandbox": true,
      "timeout": 60000
    },
    "tts": {
      "provider": "elevenlabs",
      "apiKey": "${ELEVENLABS_API_KEY}",
      "voice": "nova"
    }
  },
  "session": {
    "ttl": 7200,
    "maxHistory": 100,
    "maxContextTokens": 200000,
    "summarize": true,
    "summaryModel": "anthropic/claude-haiku-4-20250514"
  },
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "configReload": "hybrid",
    "log": {
      "level": "info"
    }
  }
}
```

## 配置文件管理技巧

### 备份配置

```bash
# 备份当前配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak

# 带日期的备份
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.$(date +%Y%m%d).json
```

### 使用 Git 管理配置变更

```bash
cd ~/.openclaw
git init
echo ".env" >> .gitignore
echo "state/" >> .gitignore
git add openclaw.json workspace/
git commit -m "Initial config"
```

> ⚠️ **注意**：不要将包含明文 API Key 的配置文件提交到公开仓库。使用环境变量引用 `${VAR_NAME}` 后，配置文件本身不包含敏感信息，可以安全地进行版本管理。

## 下一步

配置文件是 OpenClaw 的「骨架」，而人格设定是它的「灵魂」。建议继续阅读：

1. **[打造你的 AI 人设](/academy/openclaw/config/persona)** — 通过工作空间文件定义 AI 的人格和行为
2. **[渠道配置](/academy/openclaw/channels/overview)** — 各个通讯渠道的详细配置指南
3. **[技能系统](/academy/openclaw/skills/overview)** — 了解和配置 AI 的技能

