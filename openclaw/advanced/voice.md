---
title: "语音交互"
description: "OpenClaw 语音功能教程：配置语音唤醒词、连续语音对话和高质量 TTS 语音合成，打造完整的语音交互体验。"
date: "2026-03-16"
category: "OpenClaw实操指南"
tags: [openclaw-advanced,OpenClaw]
order: 17
---


# 语音交互

OpenClaw 不只是一个文字聊天助手——它支持完整的语音交互体验，包括语音唤醒、连续语音对话和高质量语音合成。本文将介绍如何配置和使用 OpenClaw 的语音功能。

## Voice Wake（唤醒词配置）

Voice Wake 允许你通过语音唤醒词激活 AI，就像对 Siri 说"Hey Siri"或对 Alexa 说"Alexa"一样。

### 工作原理

```
环境音频流（持续监听）
    ↓
本地唤醒词检测引擎
    ↓ 检测到唤醒词
开始录音
    ↓ 用户说完话
语音转文字（STT）
    ↓
AI 处理并回复
    ↓
文字转语音（TTS）播放回复
```

### 配置唤醒词

```yaml
# openclaw.yaml
voice:
  wake:
    # 启用语音唤醒
    enabled: true
    
    # 唤醒词（支持多个）
    keywords:
      - "hey claw"
      - "ok claw"
      - "你好助手"
    
    # 唤醒灵敏度（0.0-1.0，越高越灵敏但误触率也越高）
    sensitivity: 0.5
    
    # 唤醒后的录音最大时长（秒）
    maxRecordingSeconds: 30
    
    # 静音检测（用户停止说话后自动结束录音）
    silenceDetection:
      enabled: true
      # 静音多久后结束（毫秒）
      thresholdMs: 1500
```

### 唤醒反馈

```yaml
voice:
  wake:
    # 唤醒成功后的反馈
    feedback:
      # 播放提示音
      sound: "~/.openclaw/sounds/wake.wav"
      # 或使用 TTS 回复
      ttsPrompt: "我在听"
```

## Talk Mode（连续语音对话）

Talk Mode 是更沉浸的语音交互模式——进入后无需每次说唤醒词，持续保持语音对话状态。

### 进入和退出 Talk Mode

```
# 通过唤醒词进入
"Hey Claw, 进入对话模式"

# 通过命令进入
/talk

# 退出 Talk Mode
"退出对话模式"
"再见"
/talk off
```

### Talk Mode 配置

```yaml
# openclaw.yaml
voice:
  talk:
    # 启用 Talk Mode
    enabled: true
    
    # 自动退出设置
    autoExit:
      # 静默多久后自动退出（秒）
      silenceTimeoutSeconds: 120
      # 最大连续对话时长（分钟）
      maxDurationMinutes: 30
    
    # Talk Mode 中的 TTS 设置
    tts:
      # 使用的 TTS 服务
      provider: "elevenlabs"
      
      # ElevenLabs 语音 ID
      voiceId: "21m00Tcm4TlvDq8ikWAM"
      
      # 语音模型
      modelId: "eleven_multilingual_v2"
      
      # 语音参数
      stability: 0.5
      similarityBoost: 0.8
      style: 0.0
      useSpeakerBoost: true
    
    # 语音转文字设置
    stt:
      # STT 提供商
      provider: "whisper"
      # 语言（留空则自动检测）
      language: "zh"
      # 模型大小
      model: "whisper-1"
```

### Talk Mode 行为定制

```yaml
voice:
  talk:
    # 对话间的停顿处理
    pauseHandling:
      # 短暂停顿视为思考中（不中断）
      shortPauseMs: 800
      # 长停顿视为说完了
      longPauseMs: 2000
    
    # 是否允许打断 AI 的回复
    interruptible: true
    
    # AI 回复前的过渡提示音
    transitionSound: "~/.openclaw/sounds/thinking.wav"
```

## ElevenLabs TTS 配置

ElevenLabs 是目前最优秀的 AI 语音合成服务之一，OpenClaw 原生支持与其集成。

### 基本配置

```yaml
# openclaw.yaml
voice:
  tts:
    provider: "elevenlabs"
    
    # API Key（推荐使用环境变量）
    apiKey: "${ELEVENLABS_API_KEY}"
```

```bash
# 设置 API Key
export ELEVENLABS_API_KEY="your-elevenlabs-api-key"
```

### 语音选择

ElevenLabs 提供了多种预设语音和自定义语音克隆：

```yaml
voice:
  tts:
    provider: "elevenlabs"
    
    # 预设语音 ID 示例
    # Rachel (女声, 美式英语): 21m00Tcm4TlvDq8ikWAM
    # Adam (男声, 美式英语): pNInz6obpgDQGcFmaJgB
    # Bella (女声, 温柔): EXAVITQu4vr4xnSDxMaL
    # Antoni (男声, 沉稳): ErXwobaYiN019PkySvjV
    voiceId: "21m00Tcm4TlvDq8ikWAM"
```

### 模型选择

```yaml
voice:
  tts:
    # 多语言模型 v2（推荐中文使用）
    modelId: "eleven_multilingual_v2"
    
    # 其他可选模型：
    # eleven_monolingual_v1  — 英语专用，速度最快
    # eleven_multilingual_v1 — 多语言 v1
    # eleven_multilingual_v2 — 多语言 v2（质量最好，推荐）
    # eleven_turbo_v2        — 低延迟模式
    # eleven_turbo_v2_5      — 低延迟增强版
```

### 语音参数微调

```yaml
voice:
  tts:
    provider: "elevenlabs"
    voiceId: "21m00Tcm4TlvDq8ikWAM"
    modelId: "eleven_multilingual_v2"
    
    # 稳定性（0.0-1.0）
    # 低值 = 更有表现力但不稳定
    # 高值 = 更稳定但可能单调
    stability: 0.5
    
    # 相似度增强（0.0-1.0）
    # 高值 = 更接近原始语音
    similarityBoost: 0.8
    
    # 风格（0.0-1.0, 仅 v2 模型）
    # 高值 = 更有感情和风格
    style: 0.0
    
    # 说话人增强
    useSpeakerBoost: true
    
    # 输出格式
    outputFormat: "mp3_44100_128"
    # 可选：mp3_44100_64, mp3_44100_128, mp3_44100_192,
    #        pcm_16000, pcm_22050, pcm_24000, pcm_44100
```

### 备用 TTS 提供商

如果不使用 ElevenLabs，OpenClaw 也支持其他 TTS 方案：

```yaml
# macOS 内置 TTS
voice:
  tts:
    provider: "system"
    # macOS 系统语音
    systemVoice: "Ting-Ting"  # 中文语音

# OpenAI TTS
voice:
  tts:
    provider: "openai"
    apiKey: "${OPENAI_API_KEY}"
    voice: "nova"  # alloy, echo, fable, onyx, nova, shimmer
    model: "tts-1"  # tts-1 或 tts-1-hd
```

## 平台支持

OpenClaw 的语音功能在不同平台上的支持程度不同。

### macOS

macOS 是语音功能支持最完善的平台：

```yaml
# macOS 完整语音配置
voice:
  wake:
    enabled: true
    keywords: ["hey claw"]
    sensitivity: 0.5
  
  talk:
    enabled: true
    tts:
      provider: "elevenlabs"
      voiceId: "21m00Tcm4TlvDq8ikWAM"
      modelId: "eleven_multilingual_v2"
    stt:
      provider: "whisper"
      language: "zh"
  
  # macOS 特有设置
  macos:
    # 使用系统麦克风
    inputDevice: "default"
    # 使用系统扬声器
    outputDevice: "default"
    # 菜单栏图标
    menuBarIcon: true
```

支持的功能：
- Voice Wake（唤醒词检测）
- Talk Mode（连续对话）
- 系统通知集成
- 菜单栏快捷操作
- 系统音频输入/输出

### iOS

iOS 上通过 OpenClaw 移动端 App 支持语音：

```yaml
voice:
  # iOS 设置
  ios:
    # Siri 快捷指令集成
    siriShortcuts: true
    # 后台语音检测
    backgroundListening: false  # iOS 限制，仅前台可用
    # 触觉反馈
    hapticFeedback: true
```

iOS 支持的功能：
- Talk Mode（App 内）
- Siri 快捷指令触发
- 语音消息发送
- 推送通知语音播报

### Android

Android 上通过配套 App 支持：

```yaml
voice:
  # Android 设置
  android:
    # 使用 Android 语音服务
    useSystemStt: false  # false = 使用 Whisper
    # 通知渠道语音播报
    notificationTts: true
    # 后台监听（需要权限）
    backgroundListening: true
```

Android 支持的功能：
- Talk Mode（App 内和后台）
- 通知语音播报
- 语音消息识别
- Widget 快捷操作

## 完整配置示例

### 个人语音助手配置

```yaml
# openclaw.yaml — 完整语音交互配置

voice:
  # 语音唤醒
  wake:
    enabled: true
    keywords:
      - "hey claw"
      - "你好助手"
    sensitivity: 0.5
    maxRecordingSeconds: 30
    silenceDetection:
      enabled: true
      thresholdMs: 1500
    feedback:
      ttsPrompt: "我在"

  # Talk Mode
  talk:
    enabled: true
    autoExit:
      silenceTimeoutSeconds: 120
      maxDurationMinutes: 30
    interruptible: true

    # TTS 配置
    tts:
      provider: "elevenlabs"
      voiceId: "21m00Tcm4TlvDq8ikWAM"
      modelId: "eleven_multilingual_v2"
      stability: 0.5
      similarityBoost: 0.8
      style: 0.0
      useSpeakerBoost: true
      outputFormat: "mp3_44100_128"

    # STT 配置
    stt:
      provider: "whisper"
      language: "zh"
      model: "whisper-1"
```

### 仅 TTS 输出配置（不需要语音输入）

```yaml
# 只使用语音输出，不监听语音输入
voice:
  wake:
    enabled: false
  talk:
    enabled: false
  tts:
    provider: "elevenlabs"
    voiceId: "21m00Tcm4TlvDq8ikWAM"
    modelId: "eleven_multilingual_v2"
    # 在这些通道中自动使用 TTS
    autoChannels:
      - "telegram"   # Telegram 语音消息
      - "discord"    # Discord 语音频道
```

## 调试语音功能

如果语音功能不正常，可以使用以下方法排查：

```bash
# 测试 TTS 是否正常工作
openclaw voice test-tts "你好，这是一条测试消息"

# 测试 STT 是否正常工作
openclaw voice test-stt  # 录制一段音频并转文字

# 测试唤醒词检测
openclaw voice test-wake  # 进入唤醒词测试模式

# 查看音频设备列表
openclaw voice devices

# 查看语音相关日志
openclaw logs | grep -i voice
```

### 常见问题

1. **唤醒词不响应**：检查麦克风权限，降低 `sensitivity` 值
2. **TTS 无声音**：确认 `ELEVENLABS_API_KEY` 是否正确，检查输出设备
3. **STT 识别不准确**：明确指定 `language: "zh"` 而非自动检测
4. **延迟过高**：尝试使用 `eleven_turbo_v2_5` 模型，或切换到本地 TTS

语音交互让 AI 助手从屏幕走进了真实生活。配合 Voice Wake 和 Talk Mode，你可以在做饭、开车或运动时与 AI 自然对话，体验真正的智能助手。

