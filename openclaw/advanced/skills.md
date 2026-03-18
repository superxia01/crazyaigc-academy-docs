---
title: "技能系统"
description: "OpenClaw 技能系统教程：了解 Skill 的目录结构、安装配置方法，让 AI 助手获得操作外部工具和服务的能力。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-advanced,openclaw-skills,OpenClaw]
order: 15
---


# 技能系统入门

技能（Skills）是 OpenClaw 的扩展机制，让 AI 能够操作外部工具和服务。从发送邮件、控制智能家居到搜索网页，技能赋予了 AI 与真实世界交互的能力。本文将全面介绍技能系统的架构、安装和配置。

## 技能是什么

一个技能本质上是 **一个目录**，包含描述文件和支持文件：

```
my-skill/
├── SKILL.md          # 技能描述文件（必需）
├── config.yaml       # 技能配置（可选）
├── handler.js        # 工具实现逻辑（可选）
└── README.md         # 使用说明（可选）
```

### SKILL.md — 技能的核心

`SKILL.md` 是 AI 理解技能用途和使用方法的关键文件。它用自然语言描述了技能提供的工具和使用规则：

```markdown
# Email Skill

This skill provides email sending and reading capabilities.

## Tools

### send_email
Send an email to a recipient.
- `to` (required): Email address
- `subject` (required): Email subject
- `body` (required): Email content

### read_inbox
Read recent emails from the inbox.
- `limit` (optional): Number of emails to return (default: 10)

## Rules
- Always confirm with the user before sending emails
- Never send emails to addresses not explicitly provided
```

### 技能与工具的关系

```
技能（Skill）= 一组相关工具（Tools）的集合
    ├── 工具 A（如 send_email）
    ├── 工具 B（如 read_inbox）
    └── 工具 C（如 search_email）
```

一个技能可以提供多个工具，这些工具共享配置（如 API Key）和上下文。

## 三个加载位置及优先级

OpenClaw 从三个位置加载技能，按 **优先级从高到低**：

### 1. Workspace Skills（工作区技能）— 最高优先级

```
~/.openclaw/workspace/skills/
├── my-custom-skill/
│   └── SKILL.md
└── another-skill/
    └── SKILL.md
```

- 存放在你的工作区目录中
- 适合自定义技能或本地开发中的技能
- **优先级最高**：同名技能会覆盖其他位置的版本

### 2. Managed Skills（托管技能）— 中等优先级

```
~/.openclaw/skills/
├── email/
│   └── SKILL.md
└── calendar/
    └── SKILL.md
```

- 通过 `clawhub install` 安装的技能
- 由 ClawdHub 市场管理和更新
- 优先级中等

### 3. Bundled Skills（内置技能）— 最低优先级

```
/usr/lib/openclaw/skills/   # 系统安装位置
├── web-search/
│   └── SKILL.md
├── file-ops/
│   └── SKILL.md
└── memory/
    └── SKILL.md
```

- OpenClaw 安装时自带的核心技能
- 包括文件操作、Web 搜索、记忆管理等基础功能
- **优先级最低**：可被上层同名技能覆盖

### 优先级覆盖示例

```
假设三个位置都有 "web-search" 技能：

workspace/skills/web-search/  → ✅ 使用这个（最高优先级）
~/.openclaw/skills/web-search/ → ❌ 被覆盖
bundled/skills/web-search/     → ❌ 被覆盖
```

这让你可以 **定制内置技能的行为**，而无需修改系统文件。

## ClawdHub 技能市场

ClawdHub 是 OpenClaw 的官方技能市场，提供社区维护的各种技能。

### 搜索技能

```bash
# 搜索可用技能
clawhub search email
clawhub search "smart home"

# 查看技能详情
clawhub info email-gmail
```

### 安装技能

```bash
# 安装技能
clawhub install email-gmail

# 安装特定版本
clawhub install email-gmail@1.2.0

# 安装到 workspace 而非 managed 目录
clawhub install email-gmail --workspace
```

### 更新技能

```bash
# 更新单个技能
clawhub update email-gmail

# 更新所有已安装技能
clawhub update --all

# 查看可更新的技能
clawhub outdated
```

### 卸载技能

```bash
# 卸载技能
clawhub uninstall email-gmail

# 列出已安装技能
clawhub list
```

## 技能配置

安装技能后，通常需要在 `openclaw.yaml` 中进行配置。

### skills.entries 配置

```yaml
# openclaw.yaml
skills:
  entries:
    # 启用邮件技能并配置
    email-gmail:
      enabled: true
      apiKey: "${GMAIL_API_KEY}"
      env:
        GMAIL_USER: "your@gmail.com"
    
    # 启用日历技能
    calendar-google:
      enabled: true
      apiKey: "${GOOGLE_CALENDAR_KEY}"
    
    # 禁用某个内置技能
    web-search:
      enabled: false
    
    # 技能自定义参数
    smart-home:
      enabled: true
      env:
        HOME_ASSISTANT_URL: "http://192.168.1.100:8123"
        HOME_ASSISTANT_TOKEN: "${HA_TOKEN}"
```

### enabled 控制

```yaml
skills:
  entries:
    # 显式启用
    my-skill:
      enabled: true
    
    # 显式禁用
    dangerous-skill:
      enabled: false
    
    # 未指定 enabled → 默认启用（如果已安装）
    another-skill:
      apiKey: "${API_KEY}"
```

### 环境变量传递

技能可以接收环境变量作为配置：

```yaml
skills:
  entries:
    my-skill:
      enabled: true
      # 方式 1：直接设置 API Key
      apiKey: "${MY_SKILL_API_KEY}"
      
      # 方式 2：通过 env 传递多个变量
      env:
        DATABASE_URL: "postgresql://localhost/mydb"
        CACHE_TTL: "3600"
        DEBUG: "false"
```

```bash
# 也可以在环境变量中设置
export MY_SKILL_API_KEY="sk-xxxxx"
```

## 技能门控

技能可以通过 **元数据门控** 声明自己需要的前置条件。

### metadata.openclaw.requires

在 `SKILL.md` 或 `config.yaml` 中声明需求：

```yaml
# config.yaml
metadata:
  openclaw:
    requires:
      # 需要特定平台
      platform:
        - "macos"
        - "linux"
      
      # 需要特定通道
      channel:
        - "discord"
        - "telegram"
      
      # 需要其他技能
      skills:
        - "web-fetch"  # 依赖 web-fetch 技能
      
      # 需要特定能力
      capabilities:
        - "filesystem"  # 需要文件系统访问
        - "network"     # 需要网络访问
```

### 门控行为

当技能的 `requires` 条件不满足时：

```
条件不满足 → 技能自动禁用（不会报错）
    ↓
AI 看不到该技能提供的工具
    ↓
如果 AI 尝试调用 → 返回工具不可用错误
```

这确保了技能只在合适的环境中运行，避免在不兼容的平台上出错。

## 安全注意事项

技能系统是 OpenClaw 中 **最需要关注安全的部分**，因为技能直接与外部系统交互。

### 1. 审查技能来源

```bash
# 安装前查看技能内容
clawhub info suspicious-skill --full

# 查看技能的 SKILL.md 了解它能做什么
cat ~/.openclaw/skills/suspicious-skill/SKILL.md
```

**只安装你信任的技能**。第三方技能可能包含恶意代码。

### 2. 最小权限原则

```yaml
# 只启用你实际需要的技能
skills:
  entries:
    email-gmail:
      enabled: true    # 确实需要发邮件
    file-delete:
      enabled: false   # 不需要就禁用
    system-exec:
      enabled: false   # 危险！除非确实需要
```

### 3. API Key 安全

```bash
# ✅ 使用环境变量
export SKILL_API_KEY="sk-xxxxx"

# ✅ 使用 .env 文件
echo 'SKILL_API_KEY=sk-xxxxx' >> ~/.openclaw/.env

# ❌ 不要硬编码在配置文件中
# apiKey: "sk-xxxxx"  # 可能被提交到 Git！
```

### 4. 工具策略配合

通过 `tools.profile` 进一步限制技能可以执行的操作：

```yaml
# 参见安全加固章节
tools:
  profile: "restricted"
  allow:
    - "send_email"
    - "read_inbox"
  deny:
    - "delete_all_emails"  # 明确禁止危险操作
```

### 5. 定期更新

```bash
# 定期检查并更新技能
clawhub outdated
clawhub update --all
```

及时更新可以获取安全补丁和 bug 修复。

## 创建自定义技能

如果市场上没有你需要的技能，可以自己创建：

```bash
# 创建技能目录
mkdir -p ~/.openclaw/workspace/skills/my-custom-skill

# 编写 SKILL.md
cat > ~/.openclaw/workspace/skills/my-custom-skill/SKILL.md << 'EOF'
# My Custom Skill

这个技能提供了自定义功能。

## Tools

### my_tool
描述你的工具做什么。
- `param1` (required): 参数说明
- `param2` (optional): 可选参数说明

## Rules
- 在执行危险操作前询问用户确认
EOF
```

将技能放在 `workspace/skills/` 目录下即可自动加载，无需安装步骤。

技能系统让 OpenClaw 从一个聊天机器人进化为一个真正的智能代理平台。合理选择和配置技能，你的 AI 助手将能够完成越来越多的实际任务。

