---
title: "图生图高阶玩法：垫图控制主体与替换背景"
description: "深入掌握图生图（Image-to-Image）技术，学会用垫图控制画面主体、替换背景、融合多张参考图，实现从「随机生成」到「精准控制」的跨越。"
date: "2026-03-17"
category: "AI 学院"
tags: [""academy"", ""learning"", ""ai-visual"", ""img2img""]
order: 4
---

# 图生图高阶玩法：垫图控制主体与替换背景

纯文字提示词能控制的范围有限。当你需要「保留这个产品，换一个海边背景」或者「参考这张图的风格，画一个新的场景」时，就需要用到**图生图（Image-to-Image）**技术。

## 什么是图生图？

图生图就是给 AI 一张参考图片（垫图），让它在参考图的基础上生成新图。根据控制方式的不同，可以分为：

```
文字生图（Text-to-Image）：
  文字描述 → AI → 全新图片

图生图（Image-to-Image）：
  参考图 + 文字描述 → AI → 基于参考图的新图片
```

## 核心概念：重绘幅度（Denoising Strength）

重绘幅度是图生图最重要的参数，决定了 AI 对参考图的「改动程度」。

| 重绘幅度 | 效果 | 适用场景 |
|----------|------|----------|
| 0.1-0.3 | 微调：只改变色彩和纹理 | 色调调整、风格微调 |
| 0.3-0.5 | 中度变化：改变部分元素 | 换背景、加道具 |
| 0.5-0.7 | 大幅变化：保留构图和主体轮廓 | 场景变换、风格转换 |
| 0.7-0.9 | 接近重绘：只保留大致色彩倾向 | 几乎全新创作 |

## Midjourney 中的图生图

### 方法一：图片提示（Image Prompt）

```
# 在提示词中粘贴图片 URL 作为参考
https://your-image-url.jpg A cozy living room,
Scandinavian design, warm lighting --v 6.1

# 用 --iw 控制图片权重（0-2）
# --iw 1.0 默认权重
# --iw 2.0 强烈参考原图
https://your-image-url.jpg same composition, cyberpunk style --iw 1.5 --v 6.1
```

### 方法二：混合（/blend）

```
/blend 命令：最多混合 6 张图片

操作步骤：
1. 输入 /blend
2. 上传 2-6 张图片
3. 可选添加文字提示词
4. 输出：融合所有参考图特征的新图
```

## Stable Diffusion 中的图生图

### 基础 img2img

```python
# Stable Diffusion WebUI 操作流程
1. 切换到 "img2img" 标签页
2. 将参考图拖入输入区域
3. 输入提示词描述你想要的变化
4. 设置重绘幅度（Denoising strength）
5. 点击生成
```

### Inpaint：局部重绘

只修改图片的特定区域，其他部分保持不变。

```
操作步骤：
1. 上传图片到 inpaint 模式
2. 用画笔涂抹需要修改的区域（黑色遮罩）
3. 输入提示词描述新内容
4. 设置重绘幅度
5. 生成：只有涂抹区域会被重新绘制
```

**电商场景示例——替换产品背景：**

```
原始图片：一双运动鞋，白底

操作：
1. 用画笔涂抹鞋子以外的白色背景区域
2. 提示词：urban basketball court, golden hour, gritty texture
3. 重绘幅度：0.6
4. 结果：鞋子不变，背景变成篮球场
```

## ComfyUI 高级图生图工作流

### 工作流一：产品换背景

```
[Load Image] 白底产品图
    ↓
[RemBG] 自动去除背景 → 透明底产品图
    ↓
[Depth/ControlNet] 提取产品轮廓深度信息
    ↓
[CLIP Text Encode] 输入目标场景提示词
    ↓
[KSampler] 生成新背景
    ↓
[Mask Composite] 合成产品 + 新背景
    ↓
[Save Image] 输出：产品不变，背景全新
```

### 工作流二：风格迁移

```
[Load Image A] 内容参考图（如产品照片）
    ↓
[Load Image B] 风格参考图（如水彩画）
    ↓
[IP-Adapter] 提取风格 B 的特征
    ↓
[ControlNet Canny] 提取内容 A 的轮廓
    ↓
[KSampler] 生成：A 的内容 + B 的风格
    ↓
[Save Image] 输出：产品以水彩画风格呈现
```

## 实用技巧

### 技巧一：先粗后细

不要一步到位。先用高重绘幅度（0.7）确定大方向，再用低重绘幅度（0.3）精修细节。

```
第一步：大改
参考图 + "sunset beach scene" + denoising 0.7
→ 得到大致满意的场景

第二步：微调
第一步结果 + "warmer tones, add palm tree shadow" + denoising 0.3
→ 细节优化
```

### 技巧二：多次迭代

每次只做一个方向的调整，逐步靠近目标效果：

```
迭代 1：确定场景风格
迭代 2：调整光影方向
迭代 3：优化材质质感
迭代 4：微调构图比例
```

### 技巧三：保持主体不变形

使用 ControlNet 的 Canny 或 Depth 预处理器锁定主体轮廓：

```
ComfyUI 配置：
- ControlNet: Canny Edge Detection
- ControlNet Strength: 0.8-1.0（值越高约束越强）
- 重绘幅度: 0.5-0.7

效果：主体形状固定，背景自由变化
```

## 常见问题

**Q：图生图后主体变形了怎么办？**
降低重绘幅度，或添加 ControlNet 约束。重绘幅度 0.4 以下通常不会大幅变形。

**Q：背景替换后边缘有白边？**
先用 RemBG 去除背景，再合成新背景。ComfyUI 的 Mask Composite 节点可以处理边缘过渡。

**Q：参考图和生成图差异太大？**
提高 `--iw` 参数（Midjourney）或降低重绘幅度（SD），让 AI 更忠实于参考图。

## 下一步

下一章我们学习「视觉微调」——如何用局部重绘和细节精修做最后的打磨。
