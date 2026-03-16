---
title: "安全实践"
description: "OpenClaw 极简安全实践指南：面向 Root 权限场景的安全框架，涵盖行为层黑名单、安全审计协议、哈希基线、业务风控、自动巡检与灾备方案。"
date: "2026-03-16"
category: "AI 助手搭建"
tags: [openclaw-expert,openclaw-security,OpenClaw]
order: 27
---


# OpenClaw 极简安全实践指南 v2.7

> **适用场景**：OpenClaw 拥有目标机器 Root 权限，安装各种 Skill/MCP/Script/Tool 等，追求能力最大化。
> **核心原则**：日常零摩擦，高危必确认，每晚有巡检（显性化汇报），**拥抱零信任（Zero Trust）**。
> **路径约定**：本文用 `$OC` 指代 OpenClaw 状态目录，即 `${OPENCLAW_STATE_DIR:-$HOME/.openclaw}`。

