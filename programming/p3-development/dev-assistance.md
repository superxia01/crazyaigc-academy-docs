---
title: "开发辅助：辅助编程工具（GitHub Copilot 等）使用技巧、小程序/APP 核心功能辅助开发"
description: ""
date: "2026-03-17"
category: "AI 学院"
tags: [""academy"", ""learning""]
order: 2
---

# 开发辅助：辅助编程工具（GitHub Copilot 等）使用技巧、小程序/APP 核心功能辅助开发

## 主流 AI 编程工具对比

| 工具 | 集成方式 | 核心能力 | 价格 | 推荐场景 |
|------|----------|----------|------|----------|
| GitHub Copilot | VS Code/JetBrains 插件 | 行级补全、Chat | $10/月 | 日常编码 |
| Cursor | 独立 IDE | 全项目理解、多文件编辑 | $20/月 | 中大型项目 |
| ChatGPT/Claude | 网页对话 | 生成完整代码、解释代码 | 免费/Plus | 学习、脚本 |
| 通义灵码 | VS Code 插件 | 中文友好、行级补全 | 免费 | 中文开发者 |
| Codeium | VS Code 插件 | 免费补全、Chat | 免费 | 预算有限 |

## 实战一：GitHub Copilot 使用技巧

### 高效使用 Copilot 的 5 个习惯

**1. 写好注释，让 AI 懂你的意图**

```python
# 不好的注释（太模糊）
# 处理数据
def process(data):
    ...

# 好的注释（意图清晰）
# 从销售数据中筛选出金额大于1000的订单，
# 按客户分组统计总消费金额，返回降序排列的前10名客户
def process(data):
    ...
```

**2. 用类型注解给 AI 更多上下文**

```python
from typing import List, Dict

# 有了类型注解，Copilot 能更准确地补全
def merge_reports(
    sales: List[Dict[str, float]], 
    returns: List[Dict[str, float]]
) -> Dict[str, float]:
    # Copilot 看到输入输出类型，能更准确补全
```

**3. 先写测试，让 AI 填实现**

```python
def test_calculate_discount():
    assert calculate_discount(100, "VIP") == 80
    assert calculate_discount(100, "NORMAL") == 100
    assert calculate_discount(100, "NEW") == 90

# 写完测试后，Copilot 会根据测试自动生成实现
def calculate_discount(price: float, user_type: str) -> float:
    # Copilot 自动补全...
```

**4. 用 Copilot Chat 提问**

常用 Chat 指令：
- `@workspace 这个函数的作用是什么？` —— 理解项目中的代码
- `/explain 解释这段代码的逻辑` —— 学习未知代码
- `/tests 为这个函数生成单元测试` —— 自动生成测试
- `/fix 这段代码有个 bug：[描述问题]` —— AI 辅助修复

**5. 逐段生成，不要一次性要求太长**

```
正确做法：
1. 先让 Copilot 生成函数签名和文档
2. 按 Tab 接受
3. 再写注释引导它生成具体逻辑
4. 逐段验证

错误做法：
期望一次 Tab 就生成整个模块
```

## 实战二：Cursor 高效开发流程

### Cursor 的优势

Cursor 是基于 VS Code 的 AI IDE，能理解整个项目上下文。

### 多文件编辑实战

```
场景：给现有项目添加一个"导出 PDF 报告"功能

操作步骤：
1. Cmd+K（Mac）或 Ctrl+K（Windows）打开 AI 编辑框
2. 输入："在 report 模块中添加导出 PDF 功能，使用 reportlab 库，
   包含封面页、数据表格和图表，支持自定义模板"
3. Cursor 会：
   - 在 requirements.txt 中添加 reportlab 依赖
   - 修改 report.py 添加导出函数
   - 更新路由注册新的导出接口
   - 同时修改多个文件

4. Cmd+L 打开 Chat 面板，输入 "@report.py 这个函数的参数需要改吗？"
5. 根据回答继续迭代
```

### 项目级对话

```
在 Cursor Chat 中：
@workspace 请分析这个项目的目录结构，并说明各模块的职责。
然后告诉我如果要添加"用户权限管理"功能，应该在哪里添加代码。
```

## 实战三：AI 辅助小程序开发

### 场景：用 AI 开发微信小程序核心功能

### Step 1：生成项目骨架

```
请生成一个微信小程序项目的基础结构：
- pages/index/index（首页：轮播图+功能入口）
- pages/list/list（列表页：数据展示+下拉刷新+上拉加载）
- pages/detail/detail（详情页：信息展示+操作按钮）
- pages/mine/mine（我的：用户信息+设置项）

要求：
1. 使用微信小程序原生开发（非 uni-app）
2. 底部 TabBar 导航
3. 全局样式使用 CSS 变量定义主题色
4. 封装 wx.request 为统一的请求工具函数（utils/request.js）
5. 包含登录态管理

输出完整的项目文件结构和每个文件的核心代码。
```

### Step 2：生成核心业务逻辑

```
为小程序的列表页实现以下功能：
1. 调用 API 获取数据列表
2. 下拉刷新重新加载
3. 上拉触底加载更多（分页）
4. 搜索框支持关键词搜索（防抖 500ms）
5. 列表项点击跳转详情页

后端接口：
- GET /api/items?page=1&size=10&keyword=xxx
- 返回：{ list: [], total: 100, page: 1 }

请输出 JS、WXML、WXSS 完整代码。
```

### Step 3：AI 辅助调试

```
小程序运行时出现以下问题：
[粘贴控制台报错信息]

相关代码：
[粘贴相关 JS 代码]

请分析原因并给出修复方案。
```

## 实战四：AI 辅助 APP 开发

### Flutter + AI 快速开发

```
请用 Flutter 生成一个简单的 TODO APP：
1. 任务列表页（滑动删除、勾选完成）
2. 新增任务弹窗（标题+截止日期+优先级）
3. 本地数据持久化（shared_preferences）
4. 深色/浅色主题切换

要求使用 Material 3 设计规范，输出完整 Dart 代码。
```

## AI 编程工具使用原则

| 原则 | 说明 |
|------|------|
| 先理解再接受 | 不要无脑 Tab，先看懂 AI 生成的代码 |
| 小步快跑 | 每次生成一小段，验证通过再继续 |
| 测试驱动 | AI 生成的代码一定要写测试验证 |
| 安全意识 | 不要把密钥、密码写进代码让 AI 看到 |
| 持续学习 | AI 生成的代码是自己学习的最好教材 |

## 常见问题

**Q：Copilot 补全的代码不准确怎么办？**
按 Esc 拒绝，写更详细的注释或类型注解，重新触发补全。

**Q：Cursor 和 Copilot 该选哪个？**
日常编码选 Copilot（轻量）。需要跨文件重构、理解整个项目时用 Cursor。

**Q：AI 生成的代码有 bug 怎么办？**
把 bug 现象和报错贴给 AI，说"这段代码运行时出现了 [错误信息]，请修复"。
