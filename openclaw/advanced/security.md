---
title: "安全加固"
description: "OpenClaw 安全配置指南：从 DM 访问控制到工具沙箱，多层安全机制配置与最佳实践，构建安全可靠的 AI 代理系统。"
date: "2026-03-16"
category: "AI 助手搭建"
tags: [openclaw-advanced,openclaw-security,OpenClaw]
order: 16
---


# 安全加固

安全是运行 AI 代理系统时最不能忽视的问题。OpenClaw 提供了多层安全机制，从 DM 访问控制到工具沙箱，帮助你构建安全可靠的部署。本文将系统性地介绍各项安全功能的配置与最佳实践。

## openclaw security audit 命令

OpenClaw 提供了内置的安全审计工具，帮助你发现配置中的潜在风险。

### 运行安全审计

```bash
# 执行完整安全审计
openclaw security audit

# 输出示例
# 🔍 OpenClaw Security Audit
# ================================
# [WARN] DM policy is set to "open" - anyone can DM your bot
# [WARN] No tool restrictions configured - all tools are available
# [PASS] API keys are stored in environment variables
# [PASS] Workspace permissions are correctly set
# [WARN] 3 skills have network access without explicit approval
# [FAIL] Sensitive data found in openclaw.yaml (API key hardcoded)
#
# Summary: 1 FAIL, 3 WARN, 2 PASS
```

### 审计检查项

审计命令会检查以下方面：

- **DM 策略**：是否设置了访问控制
- **API Key 存储**：是否有硬编码的凭证
- **工具权限**：是否有过于宽泛的工具授权
- **技能安全**：已安装技能的权限需求
- **文件权限**：配置文件和数据目录的系统权限
- **网络暴露**：Gateway 是否暴露在公网

```bash
# 只检查特定类别
openclaw security audit --category credentials
openclaw security audit --category permissions

# 输出为 JSON 格式（便于自动化）
openclaw security audit --format json
```

## DM 策略

DM（私聊）策略控制 **谁可以与你的 AI 私聊**。这是多用户部署中最重要的安全设置之一。

### 三种策略模式

```yaml
# openclaw.yaml
security:
  dm:
    policy: "pairing"  # pairing | allowlist | open
```

### pairing（配对模式）— 推荐

用户需要通过配对流程才能与 AI 对话：

```yaml
security:
  dm:
    policy: "pairing"
    pairing:
      # 配对码有效时间（秒）
      codeExpiry: 300
      # 是否需要管理员批准
      requireApproval: true
```

配对流程：
1. 用户向 Bot 发送消息
2. Bot 回复"请输入配对码"
3. 管理员生成配对码并发给用户
4. 用户输入配对码完成配对
5. 后续对话无需重复配对

```bash
# 管理员生成配对码
openclaw pairing create --user "alice#1234"

# 查看待配对请求
openclaw pairing pending

# 批准/拒绝配对请求
openclaw pairing approve <request-id>
openclaw pairing reject <request-id>
```

### allowlist（白名单模式）

只允许列表中的用户与 AI 对话：

```yaml
security:
  dm:
    policy: "allowlist"
    allowlist:
      # 按平台+用户ID指定
      - platform: "discord"
        userId: "123456789"
      - platform: "telegram"
        userId: "987654321"
      # 也支持用户名匹配
      - platform: "discord"
        username: "alice#1234"
```

### open（开放模式）

任何人都可以与 AI 对话。**仅推荐用于测试或个人使用**：

```yaml
security:
  dm:
    policy: "open"
    # ⚠️ 警告：任何人都可以与你的 Bot 对话
    # 这可能导致 API 费用失控
```

## 硬化基线配置示例

以下是一个面向生产环境的安全硬化配置：

```yaml
# openclaw.yaml — 安全硬化基线配置

security:
  # DM 访问控制
  dm:
    policy: "pairing"
    pairing:
      requireApproval: true
      codeExpiry: 300

  # 速率限制
  rateLimit:
    # 每用户每分钟最大消息数
    messagesPerMinute: 20
    # 每用户每天最大消息数
    messagesPerDay: 500
    # 超限后的行为
    onExceeded: "reject"  # reject | queue | warn

# 工具安全
tools:
  profile: "restricted"
  deny:
    - "exec"           # 禁止执行系统命令
    - "file_delete"    # 禁止删除文件
    - "network_raw"    # 禁止原始网络访问

# 模型限制（控制成本）
agents:
  defaults:
    models:
      primary: "anthropic/claude-sonnet-4-20250514"
      denied:
        - "anthropic/claude-opus-4-20250514"
        - "openai/o3"

    # 会话安全
    dmScope: "per-peer"
    session:
      idleResetMinutes: 60
      dailyResetHour: 4
```

## 工具策略（tools.profile, allow/deny）

工具策略控制 AI 可以使用哪些工具，是防止 AI 执行危险操作的关键机制。

### tools.profile 预设

```yaml
tools:
  # 预设安全配置文件
  profile: "default"  # default | restricted | minimal | custom
```

各预设的能力范围：

- **default**：允许大部分工具，禁止高危操作（如系统命令执行）
- **restricted**：只允许读取类操作和安全的写入操作
- **minimal**：只允许最基本的对话工具，几乎不使用外部工具
- **custom**：完全自定义 allow/deny 列表

### allow/deny 列表

```yaml
tools:
  profile: "custom"
  
  # 允许使用的工具（白名单）
  allow:
    - "read"           # 读取文件
    - "web_search"     # 搜索网页
    - "web_fetch"      # 获取网页内容
    - "memory_search"  # 搜索记忆
    - "memory_get"     # 获取记忆
    - "send_email"     # 发送邮件
  
  # 明确禁止的工具（黑名单，优先级高于 allow）
  deny:
    - "exec"           # 执行系统命令
    - "write"          # 写入文件（如果不需要）
    - "file_delete"    # 删除文件
    - "browser"        # 浏览器控制
```

### 策略优先级

```
deny 列表 > allow 列表 > profile 预设
```

即使工具在 `allow` 中出现，如果它也在 `deny` 中，则 **始终被禁止**。

### 针对不同场景的工具策略

```yaml
# 场景一：只读助手（信息查询类）
tools:
  profile: "custom"
  allow:
    - "read"
    - "web_search"
    - "web_fetch"
    - "memory_search"
  deny:
    - "write"
    - "edit"
    - "exec"

# 场景二：开发助手（需要文件操作）
tools:
  profile: "default"
  deny:
    - "exec"          # 仍然禁止系统命令
    - "browser"       # 不需要浏览器

# 场景三：全能助手（信任用户）
tools:
  profile: "default"
  # 不额外限制
```

## 沙箱简介

OpenClaw 支持在 **沙箱环境** 中运行工具，为工具执行提供额外的隔离层。

### 沙箱的作用

```
AI 请求执行工具
    ↓
OpenClaw 工具路由
    ↓ 沙箱启用
在隔离环境中执行
    - 独立文件系统
    - 网络访问受限
    - 无法访问宿主敏感文件
    ↓
返回结果给 AI
```

### 沙箱配置

```yaml
# openclaw.yaml
sandbox:
  enabled: true
  # 沙箱类型
  type: "container"  # container | nsjail | bubblewrap
  
  # 允许沙箱访问的目录
  mounts:
    - source: "~/.openclaw/workspace"
      target: "/workspace"
      readOnly: false
    - source: "~/.openclaw/skills"
      target: "/skills"
      readOnly: true
  
  # 网络限制
  network:
    enabled: true
    # 允许的外部域名
    allowedDomains:
      - "api.openai.com"
      - "api.anthropic.com"
      - "*.googleapis.com"
  
  # 资源限制
  resources:
    maxMemory: "512m"
    maxCpu: "1.0"
    maxDisk: "1g"
    timeout: 30  # 秒
```

### 何时使用沙箱

- **运行不可信代码**：用户要求 AI 执行任意代码时
- **测试第三方技能**：首次使用新技能时
- **多租户环境**：多个用户共享同一个 OpenClaw 实例时
- **合规要求**：企业环境中需要工具执行隔离

## 凭证存储位置

了解 OpenClaw 在哪里存储敏感信息，有助于你正确保护它们。

### 凭证存储路径

```
~/.openclaw/
├── .env                 # 环境变量（API Keys 等）
├── openclaw.yaml        # 主配置文件（不应包含明文凭证）
├── auth/
│   ├── oauth-tokens.json    # OAuth 令牌
│   └── pairing-codes.json   # 配对码
├── sessions/
│   └── *.json           # 会话数据（可能包含对话内容）
└── credentials/
    └── *.enc            # 加密存储的凭证
```

### 保护建议

```bash
# 确保配置目录权限正确
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/.env
chmod 600 ~/.openclaw/auth/*

# 检查是否有明文凭证泄露
grep -r "sk-" ~/.openclaw/openclaw.yaml
grep -r "password" ~/.openclaw/openclaw.yaml

# 确保 .env 不被 Git 追踪
echo ".env" >> ~/.openclaw/.gitignore
```

### 凭证轮换

```bash
# 定期轮换 API Key
# 1. 在提供商控制台生成新 Key
# 2. 更新 .env 文件
# 3. 重启 Gateway 使其生效
openclaw gateway restart
```

## 安全检查清单

部署 OpenClaw 到生产环境前，请逐项检查以下清单：

### 访问控制

- [ ] DM 策略已设置为 `pairing` 或 `allowlist`（非 `open`）
- [ ] 配对/白名单已正确配置
- [ ] 速率限制已启用
- [ ] 会话隔离级别 `dmScope` 已设置为 `per-peer` 或更细

### 工具与技能

- [ ] 已配置工具策略（`tools.profile` 或 allow/deny）
- [ ] 危险工具已被禁用（exec, file_delete 等）
- [ ] 已审查所有已安装的第三方技能
- [ ] 不需要的技能已被禁用

### 凭证管理

- [ ] 所有 API Key 存储在环境变量或 `.env` 文件中
- [ ] `openclaw.yaml` 中没有硬编码凭证
- [ ] `.env` 文件权限设为 600
- [ ] OAuth 令牌文件权限正确
- [ ] `.env` 已添加到 `.gitignore`

### 网络安全

- [ ] Gateway 不直接暴露在公网（或有防火墙规则）
- [ ] 如使用沙箱，网络白名单已配置
- [ ] HTTPS/TLS 已启用（如果 Gateway 对外服务）

### 监控与审计

- [ ] 定期运行 `openclaw security audit`
- [ ] 日志记录已启用
- [ ] 异常行为告警已配置
- [ ] 定期审查对话日志中的异常模式

### 成本控制

- [ ] 模型白名单已配置（防止使用昂贵模型）
- [ ] 速率限制防止 API 费用爆发
- [ ] 设置了每日/每月费用告警

```bash
# 一键执行安全审计
openclaw security audit

# 查看详细报告
openclaw security audit --verbose

# 修复已知问题后重新审计
openclaw security audit --fix  # 自动修复安全配置
```

安全没有终点，只有持续改进。建议每次更新 OpenClaw 或添加新技能后，都重新运行安全审计，确保你的部署始终处于安全状态。

