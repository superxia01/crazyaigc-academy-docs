---
title: "专属模型训练：LoRA 训练基础概念、数据集准备与模型微调"
description: "从零开始学习 LoRA 模型训练，涵盖基础概念、数据集准备、训练参数配置和模型使用，为品牌打造专属的 AI 图像生成模型。"
date: "2026-03-17"
category: "AI 学院"
tags: [academy, learning, ai-visual, branding, lora]
order: 2
---

# 专属模型训练：LoRA 训练基础概念与实践

LoRA（Low-Rank Adaptation）是目前最流行的 AI 图像模型微调方法。简单说，它让你可以用少量图片（15-30 张）训练一个「小模型」，让 AI 学会特定的角色、风格或产品，之后每次生成都能精确复现。

## LoRA 是什么？

```
类比理解：
大模型（Stable Diffusion）= 一个什么都会画但什么都不精的画师
LoRA = 给这个画师看的「专项训练手册」

训练后：
画师 + LoRA 手册 = 精通某个特定角色/风格的画师

技术层面：
- 不修改原始大模型（安全、可逆）
- 训练产物是一个小文件（50-200MB）
- 可以随时加载和卸载
- 多个 LoRA 可以叠加使用
```

## 训练前准备

### 硬件要求

| 配置 | 最低要求 | 推荐配置 |
|------|----------|----------|
| 显卡 | RTX 3060 (12GB) | RTX 4070 Ti (16GB+) |
| 内存 | 16GB | 32GB |
| 硬盘空间 | 20GB | 50GB+ SSD |
| 操作系统 | Windows/Linux | Linux（训练更稳定） |

### 环境搭建

```
方案一：本地搭建（有显卡的电脑）
1. 安装 Python 3.10
2. 安装 CUDA Toolkit
3. 下载 Kohya_ss（最流行的 LoRA 训练 GUI）
4. 运行 setup.bat 安装依赖
5. 启动训练界面

方案二：云端训练（推荐新手）
1. Google Colab（免费 T4 GPU，够用）
2. AutoDL / 矩池云（国内，便宜）
3. RunPod（海外，按小时计费）

方案三：OneTrainer（更简单的 GUI）
1. 下载 OneTrainer
2. 一键安装
3. 图形界面操作，适合完全的新手
```

## 数据集准备（最关键的步骤）

训练质量 80% 取决于数据集质量。

### 图片要求

```
数量：15-30 张（角色类）/ 20-50 张（风格类）

质量标准：
✅ 高清（至少 512x512，推荐 1024x1024）
✅ 主体清晰、背景干净
✅ 无水印、无压缩伪影
✅ 光线均匀、颜色准确

多样性要求（角色类）：
- 不同角度：正面 5 张 + 侧面 5 张 + 半身 5 张
- 不同表情：微笑、严肃、惊讶
- 不同背景：纯色底、简单场景、复杂场景
- 不同光线：顺光、侧光、逆光
```

### 标注（Captioning）

每张图片需要一个 .txt 文件描述图片内容。

```
标注原则：
1. 用英文标注
2. 从整体到细节描述
3. 包含关键词触发词（如 "xk_character"）
4. 不要标注你不想固定的元素（如背景、光线）

标注示例（角色 LoRA）：
图片：角色正面站立，绿色背景
标注：xk_character, 1girl, short black hair, round eyes,
wearing white t-shirt, standing, simple green background,
full body, front view

标注示例（风格 LoRA）：
图片：产品图，品牌风格
标注：xk_brand_style, product photography, minimalist,
warm golden tones, soft lighting, clean composition
```

### 自动标注工具

```
推荐工具：
1. WD14 Tagger（自动打标签，基于图像识别）
   - 在 Kohya_ss 中内置
   - 自动识别图片内容并生成标签
   - 然后人工微调补充

2. BLIP Captioning（更自然的描述）
   - 生成更接近自然语言的描述
   - 适合风格类 LoRA

3. 手动标注（最精确）
   - 用文本编辑器逐张写
   - 质量最高但耗时最长
   - 推荐对关键图片手动标注
```

## 训练参数配置

### Kohya_ss 关键参数

```
基础参数：
- Pretrained model: 选择基础大模型
  推荐：Stable Diffusion 1.5 或 SDXL
- Folder setup:
  - image folder: 放训练图片和标注
  - output folder: 训练产物保存位置

训练参数：
- Learning rate: 1e-4（角色）/ 5e-5（风格）
- LR Scheduler: cosine（推荐）
- Steps: 1500-3000（角色）/ 2000-5000（风格）
- Batch size: 1-2（显存够大可以增加）
- Resolution: 512（SD1.5）/ 1024（SDXL）

LoRA 参数：
- Network Dim: 16-32（角色）/ 32-64（风格）
- Network Alpha: 通常 = Network Dim 的一半
- Optimizer: AdamW8bit（省显存）
```

### 训练过程监控

```
关键指标：
- Loss 值：应该持续下降
  - 正常：从 0.3-0.5 逐渐降到 0.05-0.15
  - 异常：不下降或反弹 → 检查数据集
  - 过拟合：降到太低（< 0.03）→ 减少 steps

建议：
- 每训练 500 steps 保存一个检查点
- 用检查点生成测试图
- 选择效果最好的检查点作为最终模型
- 不是 steps 越多越好，过拟合会导致模型只会画训练图
```

## 模型使用

### 在 Stable Diffusion WebUI 中使用

```
1. 将 LoRA 文件放入 models/Lora/ 目录
2. 在提示词中调用：<lora:模型名:权重>
3. 权重范围：0.5-1.0
   - 0.5-0.6：轻微影响
   - 0.7-0.8：推荐范围
   - 0.9-1.0：强烈影响（可能过拟合）

示例提示词：
<lora:xiaoka_ip:0.8> xk_character, a cute cat barista,
wearing green apron, standing behind coffee bar,
making latte art, warm lighting, coffee shop interior
```

### 在 ComfyUI 中使用

```
工作流节点：
[Load Checkpoint] 加载基础大模型
    ↓
[Load LoRA] 加载你的 LoRA 模型
    ↓
[CLIP Text Encode] 输入提示词
    ↓
[KSampler] 生成图片
    ↓
[Save Image] 输出

可以在一个工作流中叠加多个 LoRA：
- 角色 LoRA + 风格 LoRA = 特定角色的特定画风
```

## 常见问题

**Q：训练出来的模型和原图不像？**
检查：① 数据集是否足够多样化 ② 标注是否准确 ③ 训练步数是否足够（至少 1500 steps）④ 触发词是否一致。

**Q：模型过拟合了（只会画训练图）？**
减少训练步数，或增加数据集数量。每张图至少对应 100 steps（如 20 张图 → 2000 steps）。

**Q：没有显卡怎么办？**
使用云端训练：Google Colab 免费 GPU 可以训练 SD1.5 的 LoRA，AutoDL 上 A100 大约 2-3 元/小时。一次训练通常只需 30-60 分钟。
