---
title: "多 Agent 架构"
description: "OpenClaw 多 Agent 教程：在同一个 Gateway 运行多个 AI 人格，通过路由规则分配渠道和用户，实现工作生活分离。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-cases,openclaw-multi-agent,OpenClaw]
order: 19
---


# 多 Agent 架构：一台机器跑多个 AI 人格

OpenClaw 支持在同一个 Gateway 实例中运行多个 Agent，每个 Agent 拥有独立的人格、记忆、工作空间和工具配置。通过灵活的路由规则（bindings），你可以将不同渠道、不同用户的消息分发给不同的 Agent 处理。

## 什么场景需要多 Agent？

在以下场景中，多 Agent 架构非常有用：

- **工作/生活分离**：一个 Agent 处理工作相关事务（邮件、日程、代码），另一个负责生活助手（购物清单、菜谱、闲聊）
- **多语言服务**：中文用户路由给中文 Agent，英文用户路由给英文 Agent
- **多渠道专精**：Telegram 渠道用一个专注技术的 Agent，WhatsApp 渠道用一个偏生活化的 Agent
- **家庭共享**：一个 WhatsApp 号码，家里每个人对话的 Agent 人格不同
- **团队协作**：不同部门或项目使用不同的 Agent，各自独立记忆和工作空间
- **测试开发**：开一个测试 Agent 用于调试新功能，不影响线上主 Agent

## Agent 配置基础

### agents.list —— 定义 Agent 列表

OpenClaw 的多 Agent 配置始于 `config.yaml` 中的 `agents` 部分。每个 Agent 有一个唯一的名称标识：

```yaml
# config.yaml
agents:
  list:
    main:
      model: claude-sonnet-4-20250514
      workspace: /root/.openclaw/workspace
    work:
      model: claude-sonnet-4-20250514
      workspace: /root/.openclaw/workspace-work
    family:
      model: gpt-4o
      workspace: /root/.openclaw/workspace-family
```

**关键字段说明：**

| 字段 | 说明 |
|------|------|
| `model` | 该 Agent 使用的默认模型 |
| `workspace` | 独立的工作空间路径 |

每个 Agent 的工作空间是完全隔离的，拥有独立的：

- `SOUL.md` —— 人格定义
- `MEMORY.md` —— 长期记忆
- `memory/` —— 每日记忆
- `AGENTS.md` —— 行为规则
- `TOOLS.md` —— 工具配置

### 为每个 Agent 设置人格

```bash
# 主 Agent（默认）
cat > /root/.openclaw/workspace/SOUL.md << 'EOF'
# Atlas

你是 Atlas，一个全能型 AI 助手。你聪明、高效、略带幽默感。
你擅长编程、写作、数据分析。回答简洁精准。
EOF

# 工作 Agent
mkdir -p /root/.openclaw/workspace-work
cat > /root/.openclaw/workspace-work/SOUL.md << 'EOF'
# WorkBot

你是 WorkBot，一个专注工作效率的 AI 助手。
- 语言风格：专业、简练
- 擅长：项目管理、代码审查、技术文档
- 不闲聊，专注任务
EOF

# 家庭 Agent
mkdir -p /root/.openclaw/workspace-family
cat > /root/.openclaw/workspace-family/SOUL.md << 'EOF'
# 小助

你是小助，一个温馨的家庭助手。
- 语言风格：亲切温暖，使用中文
- 擅长：菜谱推荐、家务提醒、孩子学习辅导
- 会用 emoji 表达情感 😊
EOF
```

## Bindings 路由规则

`bindings` 定义了消息如何路由到不同 Agent。这是多 Agent 架构的核心机制。

### 按渠道路由

最简单的路由方式 —— 不同渠道的消息发给不同 Agent：

```yaml
# config.yaml
agents:
  list:
    main:
      model: claude-sonnet-4-20250514
      workspace: /root/.openclaw/workspace
    work:
      model: claude-sonnet-4-20250514
      workspace: /root/.openclaw/workspace-work

  bindings:
    - agent: work
      channel: telegram        # Telegram 渠道全部走 work Agent
    - agent: main
      channel: whatsapp        # WhatsApp 渠道走 main Agent
    - agent: main
      channel: "*"             # 其他渠道走 main（兜底规则）
```

### 按发送者路由

在同一个渠道中，根据发送者的 ID 路由到不同 Agent：

```yaml
agents:
  bindings:
    # 妈妈的消息 → 家庭助手
    - agent: family
      channel: whatsapp
      sender: "8613800138000@s.whatsapp.net"

    # 老板的消息 → 工作助手
    - agent: work
      channel: whatsapp
      sender: "8613900139000@s.whatsapp.net"

    # 其他人 → 默认 Agent
    - agent: main
      channel: whatsapp
```

> 💡 **获取 sender ID**：查看 OpenClaw 日志中的消息记录，可以找到每个发送者的 ID 格式。WhatsApp 的 sender 格式通常是 `国家码+手机号@s.whatsapp.net`。

### 按群组路由

将特定群组的消息路由给特定 Agent：

```yaml
agents:
  bindings:
    # 工作群 → 工作 Agent
    - agent: work
      channel: whatsapp
      group: "120363xxx@g.us"

    # 家庭群 → 家庭 Agent
    - agent: family
      channel: whatsapp
      group: "120363yyy@g.us"
```

### 复合规则

Bindings 规则按从上到下的顺序匹配，**第一个匹配的规则生效**：

```yaml
agents:
  bindings:
    # 规则1：Telegram 中特定用户 → work
    - agent: work
      channel: telegram
      sender: "123456789"

    # 规则2：Telegram 其他用户 → main
    - agent: main
      channel: telegram

    # 规则3：WhatsApp 工作群 → work
    - agent: work
      channel: whatsapp
      group: "120363xxx@g.us"

    # 规则4：所有其他 → main
    - agent: main
      channel: "*"
```

## 完整配置示例

下面是一个完整的多 Agent 配置，包含三个 Agent 和详细的路由规则：

```yaml
# config.yaml

gateway:
  port: 4100

# 渠道配置
channels:
  telegram:
    botToken: ${TELEGRAM_BOT_TOKEN}
  whatsapp:
    enabled: true

# Agent 配置
agents:
  default: main

  list:
    main:
      model: claude-sonnet-4-20250514
      workspace: /root/.openclaw/workspace
      thinking: false

    coder:
      model: claude-sonnet-4-20250514
      workspace: /root/.openclaw/workspace-coder
      thinking: true
      # 可以为不同 Agent 配置不同的模型参数
      systemPromptPath: /root/.openclaw/workspace-coder/SOUL.md

    assistant:
      model: gpt-4o
      workspace: /root/.openclaw/workspace-assistant

  bindings:
    # Discord #coding 频道 → coder Agent
    - agent: coder
      channel: discord
      group: "coding-channel-id"

    # WhatsApp 特定联系人 → assistant
    - agent: assistant
      channel: whatsapp
      sender: "8613800138000@s.whatsapp.net"

    # 其余所有 → main
    - agent: main
      channel: "*"
```

## 独立工作空间管理

每个 Agent 的工作空间完全独立，意味着你可以：

**1. 独立安装 Skill：**

```bash
# 在 coder Agent 的工作空间中安装编程相关 Skill
cd /root/.openclaw/workspace-coder
openclaw skill install code-review

# assistant 不需要代码类 Skill
cd /root/.openclaw/workspace-assistant
openclaw skill install weather
openclaw skill install calendar
```

**2. 独立配置工具权限：**

每个 Agent 的 `AGENTS.md` 可以设置不同的安全策略：

```markdown
<!-- workspace-coder/AGENTS.md -->
## 安全
- 允许执行 shell 命令
- 允许读写文件系统
- 允许访问 GitHub API

<!-- workspace-assistant/AGENTS.md -->
## 安全
- 不允许执行 shell 命令
- 只读文件系统
- 允许搜索网页
```

**3. 独立记忆：**

各 Agent 互不干扰，coder 记住了你上次的代码项目，assistant 记住了你的饮食偏好。

## 实用技巧

### 查看消息路由到了哪个 Agent

```bash
# 查看 Gateway 日志，包含路由信息
docker compose logs -f | grep "routing"
```

### 在 Agent 之间共享文件

虽然工作空间独立，但你可以通过符号链接共享特定文件：

```bash
# 共享用户信息文件
ln -s /root/.openclaw/workspace/USER.md /root/.openclaw/workspace-work/USER.md
```

### 动态切换 Agent

部分渠道支持通过命令前缀切换 Agent（取决于实现）：

```
/agent coder    ← 临时切换到 coder Agent
帮我审查一下这段代码
/agent main     ← 切回默认 Agent
```

### 为 Agent 设置不同的模型

不同 Agent 可以使用不同模型以优化成本：

```yaml
agents:
  list:
    main:
      model: claude-sonnet-4-20250514      # 日常对话用 Sonnet（快且便宜）
    researcher:
      model: claude-opus-4-20250514         # 深度研究用 Opus（强但贵）
    quick:
      model: claude-haiku-3-20250620       # 简单任务用 Haiku（最便宜）
```

## 注意事项

1. **Agent 名称唯一**：`agents.list` 中的 key 不能重复
2. **兜底规则**：建议最后一条 binding 使用 `channel: "*"` 确保所有消息都有归属
3. **工作空间隔离**：不要让多个 Agent 共享同一个 workspace 路径，会导致记忆混乱
4. **资源消耗**：每个 Agent 会维护独立的会话上下文，Agent 越多内存占用越大
5. **重启生效**：修改 `config.yaml` 后需要重启 Gateway 才能生效

