---
title: "会话管理"
description: "OpenClaw 会话管理教程：理解 Main Session 与 Group Session 的区别，正确隔离上下文、保护隐私、优化记忆连续性。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-advanced,OpenClaw]
order: 12
---


# 会话管理深入

OpenClaw 的会话（Session）系统是其多平台、多用户架构的核心。理解会话机制，能帮助你在复杂场景下正确隔离上下文、保护隐私、优化 AI 的记忆连续性。本文将深入讲解会话的概念、配置与最佳实践。

## Session 概念：Main Session vs Group Session

OpenClaw 中有两种核心会话类型：

### Main Session（主会话）

主会话是你与 AI 之间的 **一对一私聊会话**。它具有以下特点：

- 只有你和 AI 参与
- AI 可以加载 `MEMORY.md`（长期记忆），因为不存在隐私泄露风险
- 上下文窗口完全属于你
- 适合处理私密任务、个人事务

### Group Session（群组会话）

群组会话发生在多人频道中（如 Discord 服务器频道、Telegram 群组）：

- 多个用户共享同一个会话上下文
- AI **不会** 加载 `MEMORY.md`，避免将你的私人记忆暴露给其他人
- 所有参与者的消息都会进入同一个上下文窗口
- AI 需要区分不同发言者

```yaml
# 会话类型由通道自动决定
# 私聊 → main session
# 群组/频道 → group session
```

## dmScope 配置

`dmScope` 控制 **私聊会话的隔离粒度**。不同的设置决定了"谁和谁共享同一个会话"。

### 四种隔离级别

```yaml
# openclaw.yaml
agents:
  defaults:
    dmScope: "per-peer"  # 默认值
```

| 级别 | 说明 | 适用场景 |
|------|------|----------|
| `main` | 所有私聊共享一个会话 | 单用户、个人助手 |
| `per-peer` | 每个用户独立会话 | 多用户场景（推荐默认） |
| `per-channel-peer` | 每个平台+用户独立会话 | 同一用户在不同平台需要不同上下文 |
| `per-account-channel-peer` | 每个账号+平台+用户独立会话 | 多 Bot 账号运行场景 |

### 实际示例

假设用户 Alice 同时通过 Discord 和 Telegram 与你的 AI 私聊：

```yaml
# dmScope: main
# Alice (Discord) 和 Alice (Telegram) → 同一个会话
# Bob (Discord) → 也是同一个会话！（所有人共享）

# dmScope: per-peer
# Alice (Discord) 和 Alice (Telegram) → 同一个会话（同一用户）
# Bob (Discord) → 独立会话

# dmScope: per-channel-peer
# Alice (Discord) → 独立会话
# Alice (Telegram) → 独立会话
# Bob (Discord) → 独立会话

# dmScope: per-account-channel-peer
# Bot1 + Alice (Discord) → 独立会话
# Bot2 + Alice (Discord) → 独立会话（不同 Bot 账号也隔离）
```

**推荐**：大多数情况下使用 `per-peer`。如果你运行多个 Bot 实例服务不同社区，使用 `per-account-channel-peer`。

## 会话生命周期

会话不是永久存在的——它有自己的生命周期管理机制，防止上下文窗口无限膨胀。

### Daily Reset（每日重置）

默认情况下，会话在每天的特定时间自动重置：

```yaml
agents:
  defaults:
    session:
      dailyResetHour: 4  # UTC 时间凌晨 4 点重置
```

重置意味着：
- 上下文窗口清空
- AI "忘记" 当天之前的对话细节
- 但 `MEMORY.md` 和 `memory/*.md` 文件不受影响（持久化记忆）

### Idle Reset（空闲重置）

当会话长时间没有活动时，也会自动重置：

```yaml
agents:
  defaults:
    session:
      idleResetMinutes: 120  # 2 小时无活动后重置
```

这有助于：
- 释放不再需要的上下文
- 避免用户回来时看到过时的对话上下文
- 节省 token 消耗

### 生命周期流程

```
用户发送消息
    ↓
检查是否存在活跃会话
    ↓ 是                    ↓ 否
检查是否过期              创建新会话
(daily/idle)              加载系统提示
    ↓ 是     ↓ 否          加载记忆文件
重置会话   继续对话          ↓
    ↓                     开始对话
创建新会话
```

## 会话隔离与安全

在多用户场景下，会话隔离直接关系到 **用户隐私**。

### 隐私保护原则

1. **MEMORY.md 仅在主会话加载**：群聊中不会泄露你的私人笔记
2. **per-peer 隔离确保用户间不串话**：Alice 看不到 Bob 的对话历史
3. **文件系统权限**：会话数据存储在 `~/.openclaw/sessions/` 目录下，按会话 ID 隔离

### 多用户场景配置建议

```yaml
# 面向多用户的安全配置
agents:
  defaults:
    dmScope: "per-peer"
    session:
      dailyResetHour: 4
      idleResetMinutes: 60  # 缩短空闲时间，更快释放上下文
```

### 群组会话的注意事项

在群组会话中：
- 所有成员的消息都对 AI 可见
- AI 的回复对所有成员可见
- 不要在群组中让 AI 处理敏感信息
- 考虑使用 `/dm` 将敏感对话转到私聊

## resetTriggers：手动重置会话

有时你需要手动清空当前会话，开始一段全新的对话。OpenClaw 提供了 **重置触发器**。

### 内置重置命令

```
/new    — 开始新会话（清空上下文）
/reset  — 重置当前会话（效果相同）
```

### 配置自定义触发器

```yaml
agents:
  defaults:
    session:
      resetTriggers:
        - "/new"
        - "/reset"
        - "/clear"
        - "重新开始"  # 支持自然语言触发
```

### 使用场景

- **切换话题**：从写代码切换到聊天，避免无关上下文干扰
- **调试问题**：AI 回复异常时，重置会话排除上下文污染
- **隐私考虑**：讨论完敏感话题后清空上下文

## 完整配置示例

以下是一个面向生产环境的完整会话配置：

```yaml
# openclaw.yaml — 会话管理配置
agents:
  defaults:
    # 会话隔离级别
    dmScope: "per-peer"

    session:
      # 每日重置时间（UTC）
      dailyResetHour: 4

      # 空闲重置时间（分钟）
      idleResetMinutes: 90

      # 手动重置触发器
      resetTriggers:
        - "/new"
        - "/reset"

      # 上下文窗口管理
      # 当上下文接近模型限制时，自动压缩旧消息
      compaction:
        enabled: true
        # 压缩前自动刷新记忆到文件
        preCompactionMemoryFlush: true
```

### 针对不同场景的配置调优

```yaml
# 场景一：个人助手（单用户）
agents:
  defaults:
    dmScope: "main"
    session:
      idleResetMinutes: 480  # 8小时，保持长对话
      dailyResetHour: 5

# 场景二：社区 Bot（多用户）
agents:
  defaults:
    dmScope: "per-peer"
    session:
      idleResetMinutes: 30   # 30分钟，快速释放
      dailyResetHour: 4
      resetTriggers:
        - "/new"
        - "/reset"

# 场景三：企业多 Bot 部署
agents:
  defaults:
    dmScope: "per-account-channel-peer"
    session:
      idleResetMinutes: 60
      dailyResetHour: 0  # UTC 午夜重置
```

## 调试技巧

当会话行为不符合预期时：

1. **查看当前会话状态**：使用 `/status` 命令查看当前会话的元信息
2. **检查日志**：`openclaw logs` 中会记录会话的创建、重置事件
3. **确认 dmScope**：多用户问题多半是 dmScope 设置不当
4. **手动重置测试**：发送 `/new` 验证重置机制是否正常工作

```bash
# 查看会话相关日志
openclaw logs | grep -i session
```

掌握会话管理，是构建稳定、安全的 OpenClaw 应用的基础。合理配置会话隔离和生命周期，能让你的 AI 助手在多用户、多平台环境中可靠运行。

