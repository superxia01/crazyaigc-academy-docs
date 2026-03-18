---
title: "模型配置与切换"
description: "OpenClaw 模型配置教程：接入多个 AI 模型提供商，配置优先级链和回退机制，运行时动态切换模型。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-advanced,OpenClaw]
order: 14
---


# 模型配置与切换

OpenClaw 支持接入多个 AI 模型提供商，并提供灵活的模型选择、切换和回退机制。本文将详细讲解如何配置模型、管理多提供商认证，以及在运行时动态切换模型。

## 模型选择优先级

OpenClaw 的模型选择遵循 **优先级链** 机制：

```
用户运行时指定（/model 命令）
    ↓ 未指定则
Agent 配置中的 primary model
    ↓ 不可用则
Fallback 模型列表（按顺序尝试）
    ↓ 全部不可用则
系统默认模型
```

### 配置 Primary 和 Fallbacks

```yaml
# openclaw.yaml
agents:
  defaults:
    models:
      # 主要模型（优先使用）
      primary: "anthropic/claude-sonnet-4-20250514"
      
      # 回退模型列表（按优先级排序）
      fallbacks:
        - "anthropic/claude-sonnet-4-20250514"
        - "openai/gpt-4o"
        - "google/gemini-2.5-pro"
```

### 回退触发条件

当以下情况发生时，系统自动尝试下一个回退模型：

- 当前模型 API 返回错误（500/503）
- 模型服务限流（429 Rate Limit）
- API Key 无效或额度不足
- 网络连接超时

```yaml
agents:
  defaults:
    models:
      primary: "anthropic/claude-sonnet-4-20250514"
      fallbacks:
        - "openai/gpt-4o"
      
      # 回退行为配置
      fallbackPolicy:
        # 最大重试次数
        maxRetries: 2
        # 重试间隔（毫秒）
        retryDelayMs: 1000
        # 是否在回退时通知用户
        notifyOnFallback: true
```

## 支持的提供商

OpenClaw 支持主流 AI 模型提供商，覆盖绝大多数使用场景。

### Anthropic（Claude 系列）

```yaml
providers:
  anthropic:
    apiKey: "${ANTHROPIC_API_KEY}"
    # 可用模型
    # - claude-sonnet-4-20250514（推荐，性价比最高）
    # - claude-opus-4-20250514（最强推理能力）
    # - claude-haiku-3-20250414（最快速度，最低成本）
```

### OpenAI（GPT 系列）

```yaml
providers:
  openai:
    apiKey: "${OPENAI_API_KEY}"
    # 可用模型
    # - gpt-4o（多模态旗舰）
    # - gpt-4o-mini（快速经济）
    # - o3（高级推理）
    # - o4-mini（轻量推理）
```

### Google（Gemini 系列）

```yaml
providers:
  google:
    apiKey: "${GOOGLE_AI_API_KEY}"
    # 可用模型
    # - gemini-2.5-pro（旗舰）
    # - gemini-2.5-flash（快速）
```

### OpenRouter（模型聚合器）

OpenRouter 是一个模型聚合平台，一个 API Key 即可访问数百个模型：

```yaml
providers:
  openrouter:
    apiKey: "${OPENROUTER_API_KEY}"
    # 通过 OpenRouter 使用任意模型
    # - openrouter/anthropic/claude-sonnet-4-20250514
    # - openrouter/openai/gpt-4o
    # - openrouter/meta-llama/llama-3.1-405b
    # - openrouter/deepseek/deepseek-chat-v3
```

### 其他兼容提供商

任何兼容 OpenAI API 格式的提供商都可以接入：

```yaml
providers:
  custom:
    apiBase: "https://your-provider.com/v1"
    apiKey: "${CUSTOM_API_KEY}"
    # 适用于：
    # - 私有部署的开源模型（vLLM, Ollama）
    # - 区域性 API 代理
    # - 企业内部模型网关
```

## 认证方式

OpenClaw 提供两种认证方式来使用模型。

### 方式一：API Key 直接配置

最直接的方式——在环境变量或配置文件中设置 API Key：

```bash
# 方式 A：环境变量（推荐）
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxxx"
export OPENROUTER_API_KEY="sk-or-xxxxxxxxxxxxx"

# 方式 B：.env 文件
# 在 ~/.openclaw/.env 中
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
```

```yaml
# 方式 C：直接写在 openclaw.yaml 中（不推荐，有安全风险）
providers:
  anthropic:
    apiKey: "sk-ant-xxxxxxxxxxxxx"
```

**安全建议**：优先使用环境变量或 `.env` 文件，避免将 API Key 提交到 Git 仓库。

### 方式二：OAuth 订阅

如果你使用 OpenClaw 的托管服务或订阅计划：

```yaml
# 通过 OAuth 认证，无需手动管理 API Key
auth:
  method: "oauth"
  # OAuth 配置由 openclaw login 命令自动处理
```

```bash
# 登录并关联订阅
openclaw login

# 查看当前订阅状态
openclaw subscription status
```

OAuth 方式的优点：
- 无需管理多个 API Key
- 统一的用量计费
- 自动轮转凭证

## /model 命令切换模型

在对话中，你可以随时使用 `/model` 命令切换当前使用的模型。

### 基本用法

```
# 查看当前模型
/model

# 切换到指定模型
/model claude-sonnet-4-20250514

# 切换到 GPT-4o
/model gpt-4o

# 通过 OpenRouter 使用模型
/model openrouter/deepseek/deepseek-chat-v3
```

### 切换行为

- 切换 **立即生效**，当前会话的后续消息将使用新模型
- **不会清空** 会话上下文（历史消息保留）
- 会话重置后恢复为配置文件中的默认模型
- 不同模型对上下文长度的支持不同，切换时需注意

### 切换场景建议

```
简单问答、日常聊天 → claude-haiku 或 gpt-4o-mini（快速便宜）
代码编写、技术分析 → claude-sonnet 或 gpt-4o（平衡）
复杂推理、长文写作 → claude-opus 或 o3（最强能力）
```

## agents.defaults.models 白名单

在多用户环境中，你可能希望 **限制用户可以使用的模型**，避免他们切换到昂贵的模型导致账单暴增。

### 配置模型白名单

```yaml
# openclaw.yaml
agents:
  defaults:
    models:
      primary: "anthropic/claude-sonnet-4-20250514"
      
      # 允许用户通过 /model 切换到的模型列表
      allowed:
        - "anthropic/claude-sonnet-4-20250514"
        - "anthropic/claude-haiku-3-20250414"
        - "openai/gpt-4o-mini"
      
      # 明确禁止的模型（即使在 allowed 中也会被拒绝）
      denied:
        - "anthropic/claude-opus-4-20250514"  # 太贵了！
```

### 白名单行为

- 如果配置了 `allowed`，用户只能切换到列表中的模型
- 如果未配置 `allowed`，用户可以切换到任何已认证的模型
- `denied` 列表优先级最高，始终会被拒绝
- 管理员不受白名单限制

## 完整配置示例

### 个人用户配置

```yaml
# openclaw.yaml — 个人用户推荐配置
agents:
  defaults:
    models:
      primary: "anthropic/claude-sonnet-4-20250514"
      fallbacks:
        - "openai/gpt-4o"

providers:
  anthropic:
    apiKey: "${ANTHROPIC_API_KEY}"
  openai:
    apiKey: "${OPENAI_API_KEY}"
```

### 社区 Bot 配置

```yaml
# openclaw.yaml — 社区 Bot 推荐配置（控制成本）
agents:
  defaults:
    models:
      primary: "anthropic/claude-haiku-3-20250414"
      fallbacks:
        - "openai/gpt-4o-mini"
      
      # 限制用户可用模型
      allowed:
        - "anthropic/claude-haiku-3-20250414"
        - "anthropic/claude-sonnet-4-20250514"
        - "openai/gpt-4o-mini"
      
      # 禁止使用昂贵模型
      denied:
        - "anthropic/claude-opus-4-20250514"
        - "openai/o3"

providers:
  anthropic:
    apiKey: "${ANTHROPIC_API_KEY}"
  openai:
    apiKey: "${OPENAI_API_KEY}"
```

### 使用 OpenRouter 的统一配置

```yaml
# openclaw.yaml — 通过 OpenRouter 访问所有模型
agents:
  defaults:
    models:
      primary: "openrouter/anthropic/claude-sonnet-4-20250514"
      fallbacks:
        - "openrouter/openai/gpt-4o"
        - "openrouter/google/gemini-2.5-flash"

providers:
  openrouter:
    apiKey: "${OPENROUTER_API_KEY}"
```

## 模型性能对比参考

选择模型时，可以参考以下维度：

```
模型                        速度    质量    价格    上下文长度
claude-opus-4              ★★☆    ★★★★★  $$$$   200K
claude-sonnet-4            ★★★    ★★★★   $$     200K
claude-haiku-3.5           ★★★★★  ★★★    $      200K
gpt-4o                     ★★★★   ★★★★   $$     128K
gpt-4o-mini                ★★★★★  ★★★    $      128K
gemini-2.5-pro             ★★★    ★★★★   $$     1M
gemini-2.5-flash           ★★★★★  ★★★    $      1M
deepseek-chat-v3           ★★★★   ★★★    $      64K
```

> 💡 **提示**：价格和性能会随模型更新而变化，请以各提供商官方文档为准。

合理配置模型和回退策略，能让你的 OpenClaw 实例在性能、成本和可用性之间取得最佳平衡。

