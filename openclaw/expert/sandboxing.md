---
title: "沙箱模式深入"
description: "OpenClaw 沙箱安全教程：深入理解执行环境隔离机制，包括沙箱模式配置、Docker 镜像选择和安全最佳实践。"
date: "2026-03-16"
category: "AI 助手搭建"
tags: [openclaw-expert,OpenClaw]
order: 26
---


# 沙箱模式深入：安全隔离执行环境

OpenClaw 的 Agent 拥有执行代码、操作文件系统、运行浏览器等强大能力。但能力越大，风险越大 —— 一个不小心的 `rm -rf /` 就可能酿成大祸。沙箱（Sandbox）机制为 Agent 的执行环境提供隔离保护，让你既能享受 AI 自动化的便利，又能守住安全底线。

## 为什么需要沙箱？

### 风险场景

考虑以下真实场景：

- **误操作**：Agent 执行清理脚本时误删了重要文件
- **恶意注入**：用户通过对话诱导 Agent 执行危险命令（prompt injection）
- **脚本漏洞**：Agent 安装的第三方 Skill 包含恶意代码
- **资源耗尽**：Agent 运行的程序占用过多 CPU/内存，影响宿主机
- **数据泄露**：Agent 意外读取了不该看的系统文件

### 沙箱的作用

沙箱通过 Docker 容器将 Agent 的执行环境与宿主机隔离：

- ✅ Agent 执行的命令在容器内运行，无法影响宿主机
- ✅ 文件系统隔离，只能访问授权的目录
- ✅ 网络可以限制
- ✅ 资源使用可控（CPU、内存限制）
- ✅ 容器销毁后，临时文件自动清理

## sandbox.mode —— 沙箱模式

OpenClaw 提供三种沙箱模式：

```yaml
# config.yaml
sandbox:
  mode: "non-main"    # off | non-main | all
```

### `off` —— 关闭沙箱

```yaml
sandbox:
  mode: "off"
```

所有命令直接在宿主机上执行。适合：

- 开发调试阶段
- 完全信任的单用户环境
- 需要访问宿主机特定硬件或服务

> ⚠️ **风险极高**：Agent 拥有与运行用户相同的系统权限。不建议在生产环境使用。

### `non-main` —— 非主会话沙箱化（推荐）

```yaml
sandbox:
  mode: "non-main"
```

- **主会话**（直接与 Agent 对话）：不使用沙箱，命令直接执行
- **非主会话**（子 Agent、Cron 任务、Heartbeat 等）：在沙箱中执行

适合：

- 日常使用的平衡方案
- 主人直接对话时需要完整权限，自动任务需要隔离

### `all` —— 全部沙箱化

```yaml
sandbox:
  mode: "all"
```

所有命令都在沙箱容器中执行，包括主会话。最安全但也最受限。

适合：

- 多用户共享环境
- 高安全要求场景
- 不需要 Agent 操作宿主机

## sandbox.scope —— 沙箱作用域

作用域决定沙箱容器的生命周期和共享方式：

```yaml
sandbox:
  scope: "session"    # session | agent | shared
```

### `session` —— 会话级隔离

```yaml
sandbox:
  scope: "session"
```

每个会话创建独立的沙箱容器，会话结束后容器销毁。

- ✅ 最高隔离级别，会话之间完全独立
- ✅ 临时文件自动清理
- ❌ 每次会话都要重新初始化环境
- ❌ 跨会话无法共享状态

### `agent` —— Agent 级共享

```yaml
sandbox:
  scope: "agent"
```

同一个 Agent 的所有会话共享同一个沙箱容器。

- ✅ 会话之间可以共享文件和状态
- ✅ 不同 Agent 之间仍然隔离
- ✅ 环境只初始化一次
- ❌ 一个会话的操作可能影响另一个会话

### `shared` —— 全局共享

```yaml
sandbox:
  scope: "shared"
```

所有 Agent 共享同一个沙箱容器。

- ✅ 资源利用最高效
- ✅ Agent 之间可以共享数据
- ❌ 隔离性最低

## workspaceAccess —— 工作空间访问权限

控制沙箱内对 Agent 工作空间的访问级别：

```yaml
sandbox:
  workspaceAccess: "rw"    # none | ro | rw
```

| 值 | 说明 | 适用场景 |
|------|------|---------|
| `none` | 无法访问工作空间 | 纯计算任务，不需要文件 |
| `ro` | 只读访问 | 数据分析、报告生成 |
| `rw` | 读写访问 | 正常工作模式，可创建/修改文件 |

```yaml
# 典型配置：允许读写工作空间
sandbox:
  mode: "non-main"
  scope: "agent"
  workspaceAccess: "rw"
```

## Docker 镜像配置

沙箱运行在 Docker 容器中，你可以自定义使用的基础镜像。

### 使用默认镜像

OpenClaw 提供预构建的沙箱镜像，包含常用工具：

```yaml
sandbox:
  image: "ghcr.io/anthropics/openclaw-sandbox:latest"
```

默认镜像包含：

- Python 3.11 + pip
- Node.js 22 + npm
- Git, curl, wget
- 常用编译工具（gcc, make）
- Chromium（用于沙箱浏览器）

### 自定义镜像

如果默认镜像不满足需求，可以构建自定义镜像：

```dockerfile
# Dockerfile.sandbox
FROM ghcr.io/anthropics/openclaw-sandbox:latest

# 安装额外工具
RUN apt-get update && apt-get install -y \
    ffmpeg \
    imagemagick \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 包
RUN pip3 install \
    pandas \
    numpy \
    matplotlib \
    requests \
    beautifulsoup4

# 安装 Node.js 包
RUN npm install -g \
    typescript \
    tsx

# 自定义配置
COPY custom-config /etc/custom-config
```

构建并使用：

```bash
# 构建镜像
docker build -f Dockerfile.sandbox -t my-openclaw-sandbox:latest .

# 在配置中引用
```

```yaml
sandbox:
  image: "my-openclaw-sandbox:latest"
```

### 多镜像配置

不同 Agent 可以使用不同的沙箱镜像：

```yaml
agents:
  list:
    coder:
      sandbox:
        image: "my-sandbox-dev:latest"     # 开发工具齐全
    analyst:
      sandbox:
        image: "my-sandbox-data:latest"    # 数据分析工具
```

## 自定义 Bind Mounts

除了工作空间，你可能需要将宿主机的其他目录挂载到沙箱中：

```yaml
sandbox:
  mounts:
    # 只读挂载数据集目录
    - source: /data/datasets
      target: /datasets
      readonly: true

    # 读写挂载输出目录
    - source: /data/output
      target: /output
      readonly: false

    # 挂载 SSH 密钥（只读）
    - source: ~/.ssh
      target: /root/.ssh
      readonly: true

    # 挂载 Docker socket（允许沙箱内操作 Docker）
    - source: /var/run/docker.sock
      target: /var/run/docker.sock
      readonly: false
```

> ⚠️ **安全警告**：挂载 Docker socket 意味着沙箱内可以控制宿主机的 Docker，等同于 root 权限。仅在信任的环境中使用。

### 挂载最佳实践

1. **最小化挂载**：只挂载必需的目录
2. **优先只读**：除非需要写入，否则使用 `readonly: true`
3. **避免敏感目录**：不要挂载 `/etc`, `/root` 等敏感系统目录
4. **使用专用目录**：创建专门的共享目录，而不是挂载整个 home

## 沙箱浏览器

当沙箱模式启用时，浏览器也运行在沙箱容器内：

```yaml
sandbox:
  mode: "all"
  browser:
    enabled: true
    # 沙箱浏览器使用 Chromium
    # 以无头模式运行，通过 CDP 协议控制
```

沙箱浏览器与 `openclaw` profile 的浏览器行为一致，但运行在隔离环境中：

- ✅ 浏览器进程无法访问宿主机文件系统
- ✅ 浏览器的网络可以受限
- ✅ 浏览器崩溃不影响宿主机
- ❌ 无法使用 Chrome Extension Relay（需要使用 `chrome` profile）

## 完整配置示例

### 个人使用（平衡安全与便利）

```yaml
sandbox:
  mode: "non-main"
  scope: "agent"
  workspaceAccess: "rw"
  image: "ghcr.io/anthropics/openclaw-sandbox:latest"
  resources:
    memory: "2g"
    cpus: "2.0"
```

### 多用户共享（高安全）

```yaml
sandbox:
  mode: "all"
  scope: "session"
  workspaceAccess: "rw"
  image: "my-locked-sandbox:latest"
  resources:
    memory: "1g"
    cpus: "1.0"
  network: "none"          # 禁用网络
  mounts: []               # 不挂载额外目录
```

### 开发环境（功能优先）

```yaml
sandbox:
  mode: "off"
  # 开发阶段关闭沙箱，充分利用系统工具
  # ⚠️ 上线前务必切换到 non-main 或 all
```

## 安全注意事项

### 1. 定期更新镜像

```bash
# 拉取最新沙箱镜像
docker pull ghcr.io/anthropics/openclaw-sandbox:latest

# 清理旧镜像
docker image prune -f
```

### 2. 资源限制

防止沙箱内程序耗尽宿主机资源：

```yaml
sandbox:
  resources:
    memory: "2g"           # 最大内存
    cpus: "2.0"            # 最大 CPU 核数
    pids: 256              # 最大进程数
    storage: "10g"         # 最大存储空间
```

### 3. 网络控制

```yaml
sandbox:
  network: "bridge"        # bridge（默认）| host | none
  # none: 完全禁止网络访问
  # bridge: 通过 Docker 网桥访问（可配置防火墙规则）
  # host: 使用宿主机网络（不推荐）
```

### 4. 监控和审计

```bash
# 查看沙箱容器状态
docker ps --filter "label=openclaw.sandbox=true"

# 查看资源使用
docker stats --filter "label=openclaw.sandbox=true"

# 查看容器日志
docker logs openclaw-sandbox-main
```

### 5. 安全检查清单

- ✅ 生产环境不使用 `mode: "off"`
- ✅ 设置内存和 CPU 限制
- ✅ 不挂载 Docker socket（除非必要）
- ✅ 定期更新沙箱镜像
- ✅ 敏感目录使用只读挂载
- ✅ 多用户场景使用 `scope: "session"`
- ✅ 审计沙箱内的命令执行记录

