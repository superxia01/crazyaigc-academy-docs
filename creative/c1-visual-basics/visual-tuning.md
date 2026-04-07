---
title: "视觉微调：局部重绘与细节精修实操手法"
description: "掌握 AI 图像的局部重绘、细节精修和放大修复技巧，把 AI 生成的图从「能用」提升到「商用级别」。"
date: "2026-03-17"
category: "AI 学院"
tags: ["academy", "learning", "ai-visual", "retouching"]
order: 5
---

# 视觉微调：局部重绘与细节精修实操手法

AI 生成的图片往往「远看不错，近看有瑕疵」——手指多了一根、文字乱码、局部模糊。这些问题不需要重新生成整张图，通过局部重绘和细节精修就能解决。

## 局部重绘的三个层次

```
第一层：局部修复（Inpaint）
  修复小面积瑕疵：手指、文字、局部错误

第二层：细节增强（Upscale + Enhance）
  提升分辨率和清晰度

第三层：全局调色（Color Grading）
  统一色调、修正曝光
```

## 第一层：局部修复（Inpaint）

### Midjourney 局部重绘

```
# Vary Region 功能
操作步骤：
1. 选中已生成的图片
2. 点击 "Vary (Region)" 按钮
3. 用套索工具框选需要修改的区域
4. 修改提示词描述新内容
5. 点击提交

示例：
原图提示词：A woman holding a red cup
框选杯子区域，修改提示词：holding a blue ceramic cup
→ 只有杯子变化，其余不变
```

### Stable Diffusion WebUI 局部重绘

```
操作路径：img2img → Inpaint 标签页

关键参数：
- Mask mode: Inpaint masked（只改涂抹区域）
- Masked content: Original（基于原图内容修复）
- Inpaint area: Only masked（聚焦涂抹区域）
- Mask blur: 4-8（边缘过渡自然）
- Denoising strength: 0.5-0.7
```

### 常见修复场景

**场景一：修复手指问题**

```
问题：AI 生成的手有 6 根手指或关节扭曲
涂抹区域：只涂抹手部
提示词：natural hand with five fingers
重绘幅度：0.5-0.6
```

**场景二：修改文字**

```
问题：图中文字需要修正
涂抹区域：只涂抹文字区域
提示词：text reading "SALE 50% OFF", bold font, white color
重绘幅度：0.6
提示：如果文字渲染仍不准确，改用 Ideogram 的 inpaint 功能
```

**场景三：修改局部颜色**

```
问题：想让角色换个包的颜色
涂抹区域：只涂抹包的区域
提示词：red leather handbag, glossy finish
重绘幅度：0.5
```

### ComfyUI 批量局部重绘

当你有 50 张图都需要修改同一类问题时：

```
工作流：
[Load Image Batch] 加载多张图片
    ↓
[Auto Mask] 自动检测需要修改的区域
（可以用 Segment Anything 自动分割）
    ↓
[Inpaint] 批量重绘指定区域
    ↓
[Save Image] 批量输出
```

## 第二层：细节增强（Upscale and Enhance）

AI 生成的图默认分辨率通常在 512x512 到 1024x1024 之间。电商和印刷场景需要更高分辨率。

### 方法一：AI 超分辨率放大

```
推荐工具：
- Stable Diffusion WebUI 的 Extras → UltraSharp / 4x_NMKD
- ComfyUI 的 Ultimate SD Upscale 节点
- Topaz Gigapixel AI（付费，效果最好）

操作（以 WebUI 为例）：
1. 进入 Extras 标签页
2. 上传图片
3. 选择放大模型：UltraSharp（推荐）或 R-ESRGAN 4x+
4. 设置放大倍数：2x（通常够用）
5. 点击 Generate
```

### 方法二：高分修复（High-res Fix）

在生成时就直接输出高分辨率图片：

```
Stable Diffusion 高分修复设置：
- Enable Hires. fix
- Upscaler: UltraSharp
- Hires steps: 15-20
- Denoising strength: 0.3-0.4
- Upscale by: 1.5-2.0x

效果：从 512x768 放大到 1024x1536，细节更丰富
```

### 方法三：人脸修复

AI 生成的人像经常在缩小后脸部模糊，用专用人脸修复模型处理：

```
工具：CodeFormer / GFPGAN / ADetailer

ADetailer（最推荐，自动检测+修复）：
- 扩展安装：adetailer
- 自动检测画面中的人脸
- 对人脸区域单独进行高清重绘
- 参数：
  - Detection confidence: 0.5
  - Mask dilation: 4
  - Denoising strength: 0.3-0.4
```

## 第三层：全局调色（Color Grading）

### 方法一：提示词调色

在生成时通过提示词控制色调：

```
# 暖色调
warm color palette, golden tones, kodak portra 400 film

# 冷色调
cool blue tones, fuji pro 400h, muted colors

# 高对比
high contrast, dramatic lighting, deep shadows

# 低饱和
desaturated, muted colors, pastel tones
```

### 方法二：后期调色

生成后用工具进行精确调色：

```
推荐工具：
- Photoshop（专业，功能最全）
- Lightroom（批量调色利器）
- Canva（简单快速，适合新手）
- ComfyUI Color Adjust 节点（自动化）

调色流程：
1. 白平衡校正（确保颜色准确）
2. 曝光调整（高光不溢出，暗部有细节）
3. 色调统一（HSL 面板调整各色彩通道）
4. 风格化（添加胶片预设或 LUT）
```

## 实战：一张电商图的完整精修流程

```
步骤一：AI 生成初图
Midjourney 生成产品场景图

步骤二：局部修复
Inpaint 修复小瑕疵（如产品边缘不整齐）

步骤三：放大增强
UltraSharp 2x 放大，提升分辨率到 2048px+

步骤四：人脸/人物修复（如有人物出镜）
ADetailer 自动修复面部细节

步骤五：调色统一
在 Lightroom 中统一色调，匹配品牌色

步骤六：最终输出
导出为 WebP（网页用）和 PNG（印刷用）
```

## 常见问题

**Q：局部重绘后修复区域和周围不融合？**
增大 Mask blur 值（8-12），让边缘过渡更自然。也可以在重绘后用 Photoshop 的羽化工具手动融合。

**Q：放大后图片变糊了？**
降低 Denoising strength（0.2-0.3），或换用更高质量的放大模型（UltraSharp > R-ESRGAN）。

**Q：多张图色调不一致？**
在 Lightroom 中选中所有图片，先对一张调色，然后「同步设置」到所有图片。

## 下一步

下一章我们学习「商业版权避坑指南」——如何在 AI 生成中规避版权和外观专利风险。
