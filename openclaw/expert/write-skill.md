---
title: "开发 Skill"
description: "OpenClaw Skill 开发教程：从零创建、测试和发布自定义技能，以天气查询为完整示例，含目录结构和 API 详解。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-expert,OpenClaw]
order: 25
---


# 从零开发一个 OpenClaw Skill

Skill 是 OpenClaw 的能力扩展单元。通过安装 Skill，你的 Agent 可以获得新的工具和能力 —— 比如查天气、控制智能家居、调用特定 API。本文以一个「天气查询 Skill」为例，手把手教你从零开发到发布。

## Skill 概念

Skill 本质上是一个包含配置文件和可选脚本的目录。安装到 Agent 工作空间后，Agent 就能理解并使用该 Skill 提供的工具。

**Skill 的组成：**

- `SKILL.md` —— Skill 的核心定义文件，包含描述和使用说明
- `metadata.openclaw` —— 元数据配置（依赖、安装脚本等）
- 可选的脚本、配置文件、模板等

## Skill 目录结构

一个标准的 Skill 目录结构如下：

```
weather-skill/
├── SKILL.md              # Skill 定义（必须）
├── metadata.openclaw     # 元数据配置（必须）
├── scripts/
│   ├── get_weather.py    # 业务逻辑脚本
│   └── requirements.txt  # Python 依赖
├── templates/
│   └── weather_report.md # 输出模板
└── README.md             # 说明文档（可选）
```

## SKILL.md —— Skill 定义文件

`SKILL.md` 是 Skill 最核心的文件。它使用 frontmatter + Markdown 格式，既定义元信息，又包含 Agent 使用说明。

### Frontmatter 格式

```markdown
