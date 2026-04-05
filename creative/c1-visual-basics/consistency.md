---
title: "一致性保持：角色与特定艺术风格一致性"
description: "掌握 AI 图像生成中的角色一致性和风格一致性技巧，使用 Seed、Character Reference、Style Reference、LoRA 等方法，让多张图片保持统一的人物形象和视觉风格。"
date: "2026-03-17"
category: "AI 学院"
tags: [academy, learning, ai-visual, consistency]
order: 3
---

# 一致性保持：角色与特定艺术风格一致性

AI 绘画最大的痛点之一就是「每张图长得不一样」。你画了一个满意的角色，下一张就变脸了；你定好了品牌风格，换个场景就跑偏了。本章系统讲解如何在 AI 生成中保持一致性。

## 为什么一致性这么难？

AI 图像模型的本质是「每次从概率分布中采样」。即使提示词完全相同，每次生成的结果也不同。要让结果一致，我们需要额外引入**约束条件**。

```
没有约束：
提示词 → 模型 → 随机输出（每次不同）

有约束：
提示词 + 参考图/种子值/LoRA → 模型 → 受控输出（高度一致）
```

## 方法一：Seed 值锁定

**适用场景：** 在同一组提示词下微调参数

**原理：** AI 生成图片时有一个随机种子值。固定 seed 后，同样的提示词会产出非常相似的结果。

### Midjourney 中的用法

```
# 第一次生成，记住返回的 seed 值
A cute robot character, Pixar style --v 6.1
（假设 seed 值为 4293817465）

# 微调时锁定 seed
A cute robot character, Pixar style, wearing a red scarf --seed 4293817465 --v 6.1
```

**局限性：** seed 锁定只在提示词变化很小时有效。大幅修改提示词后，即使 seed 相同，结果也会大变。

## 方法二：角色参考（Character Reference）

**适用场景：** 同一角色在不同场景中出现

### Midjourney 的 `--cref`

```
# 第一步：生成一张满意的角色图
A young woman with short black hair, wearing a white t-shirt, simple background --v 6.1

# 第二步：用 --cref 引用这个角色的形象
The same character walking in a Japanese garden,
cherry blossom season --cref https://url-to-image.png --cw 100 --v 6.1
```

参数说明：
- `--cref`：角色参考图的 URL
- `--cw 100`：参考权重（0-100），值越高越忠实原图
- `--cw 0`：只参考脸部，忽略服装

### Stable Diffusion 的 IP-Adapter

在 ComfyUI 中使用 IP-Adapter 节点：

```
工作流：
1. 加载参考人物图 → IP-Adapter 节点
2. 输入场景提示词
3. ControlNet OpenPose（可选，控制姿势）
4. 输出：同一人物，新场景，新姿势
```

## 方法三：风格参考（Style Reference）

**适用场景：** 保持多张图的视觉风格统一

### Midjourney 的 `--sref`

```
# 第一步：找到你喜欢的风格图
# 第二步：用 --sref 锁定风格

A product photo of a water bottle on a beach --sref https://style-image.png --sv 500 --v 6.1

# --sv 控制风格影响强度（0-1000）
# 低值（100-300）：轻微影响色调和构图
# 高值（500-1000）：强烈复刻风格
```

### 多图风格混合

```
# 混合两种风格，各占不同权重
A product photo --sref url1::2 url2::1 --v 6.1
# url1 的风格权重是 url2 的两倍
```

## 方法四：LoRA 微调（最专业）

**适用场景：** 长期项目、品牌 IP、需要反复使用

**原理：** 用 10-30 张样本图训练一个轻量级模型（通常 50-200MB），之后每次生成都能精确复现特定的角色或风格。

### LoRA 训练流程

```
1. 准备数据集
   ├── 15-30 张角色/风格的高质量图片
   ├── 每张图片配一个 txt 描述文件
   └── 背景多样、角度多样、表情多样

2. 训练（使用 Kohya_ss / OneTrainer 等工具）
   ├── 推荐参数：learning rate 1e-4
   ├── 训练步数：1500-3000 steps
   └── 输出：your_character.safetensors

3. 使用
   ├── Stable Diffusion WebUI 中加载 LoRA
   ├── ComfyUI 中通过 LoRA Loader 节点加载
   └── 提示词中调用：<lora:your_character:0.8>
```

### 数据集准备要点

| 要素 | 建议 | 避免 |
|------|------|------|
| 图片数量 | 15-30 张 | 少于 10 张会欠拟合 |
| 图片质量 | 高清、无水印 | 模糊、压缩过度的图 |
| 背景多样性 | 不同背景、场景 | 全部同一背景 |
| 角度多样性 | 正面、侧面、半身、全身 | 只有一种角度 |
| 标注质量 | 详细描述每个细节 | 笼统的一句话标注 |

## 方法五：ControlNet 约束

**适用场景：** 需要精确控制姿态、轮廓、深度关系

```
ComfyUI 工作流：

输入参考图
    ↓
ControlNet 预处理器（选择一种或多种）
    ├── OpenPose：提取骨骼姿态
    ├── Canny：提取边缘轮廓
    ├── Depth：提取深度图
    └── Lineart：提取线稿
    ↓
结合提示词生成新图
    ↓
输出：保持轮廓/姿态一致的新图
```

## 实战：品牌 IP 角色的一致性方案

假设你在为一家咖啡品牌设计 IP 角色「小咖」，需要在不同场景中保持一致：

### 方案 A（快速验证）：Midjourney + cref

```
# 优点：无需训练，立即可用
# 缺点：一致性约 70-80%，细节会有偏差

# 初始设计
A cute cartoon cat barista character named XiaoKa,
round body, brown and cream fur, wearing a green apron,
holding a coffee cup, friendly smile, simple background,
flat illustration style --v 6.1

# 场景变化时用 --cref 保持角色
XiaoKa standing behind a coffee bar making latte art --cref url --cw 80 --v 6.1
XiaoKa delivering coffee on a bicycle --cref url --cw 80 --v 6.1
```

### 方案 B（长期方案）：LoRA 训练

```
# 优点：一致性 95%+，可无限扩展场景
# 缺点：前期需要训练，需要显卡

# 1. 生成 20 张不同角度/场景的小咖图片
# 2. 标注并训练 LoRA
# 3. 后续每次生成：<lora:xiaoka:0.85> a cute cat barista...
```

## 一致性检查清单

每次生图后，对照以下清单检查一致性：

- [ ] 面部特征是否一致（眼睛、鼻子、嘴型）
- [ ] 配色方案是否统一（主色、辅色、点缀色）
- [ ] 体型比例是否稳定（头身比、四肢比例）
- [ ] 服装/配饰是否匹配
- [ ] 画风是否统一（扁平、3D、水彩等）
- [ ] 画面质感是否一致（噪点、清晰度、色彩饱和度）

## 下一步

下一章我们学习「图生图高阶玩法」——如何用已有图片作为基础，精确控制主体并替换背景。
