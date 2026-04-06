---
title: "AI 赋能：零基础通过 AI 编写 Python 或常用脚本逻辑、AI 辅助进行代码重构"
description: ""
date: "2026-03-17"
category: "AI 学院"
tags: [""academy"", ""learning""]
order: 1
---

# AI 赋能：零基础通过 AI 编写 Python 或常用脚本逻辑、AI 辅助进行代码重构

## 零基础也能写脚本？

是的。你不需要学完 Python 教程才能写代码。用 AI 辅助，你只需要 **描述清楚你要做什么**。

### AI 写脚本的三种模式

| 模式 | 你做什么 | AI 做什么 | 适合场景 |
|------|----------|-----------|----------|
| 描述需求 | 用自然语言描述 | 生成完整代码 | 新建脚本 |
| 改错修复 | 贴报错信息 | 分析原因+给修复代码 | 调试问题 |
| 代码重构 | 贴旧代码 | 优化+重构输出 | 改进现有代码 |

## 实战一：零基础写第一个 Python 脚本

### 场景：批量重命名文件夹中的文件

```
请写一个 Python 脚本：
1. 读取指定文件夹中的所有文件
2. 把文件名中的空格替换为下划线
3. 把文件名全部转为小写
4. 在文件名前加上日期前缀（格式：20260317_）
5. 重命名前先预览新文件名，用户确认后再执行
6. 打印处理了多少个文件

文件夹路径通过命令行参数传入。
```

AI 会生成类似这样的代码：

```python
import os
import sys
from datetime import datetime

def preview_rename(folder_path):
    date_prefix = datetime.now().strftime("%Y%m%d")
    rename_map = []
    
    for filename in os.listdir(folder_path):
        old_path = os.path.join(folder_path, filename)
        if not os.path.isfile(old_path):
            continue
        # 空格→下划线，转小写，加日期前缀
        new_name = f"{date_prefix}_{filename.replace(' ', '_').lower()}"
        new_path = os.path.join(folder_path, new_name)
        rename_map.append((old_path, new_path, filename, new_name))
    
    return rename_map

def main():
    if len(sys.argv) < 2:
        print("用法: python rename.py <文件夹路径>")
        return
    
    folder = sys.argv[1]
    changes = preview_rename(folder)
    
    print("预览重命名：")
    for old_path, new_path, old_name, new_name in changes:
        print(f"  {old_name} → {new_name}")
    
    confirm = input(f"\n共 {len(changes)} 个文件，确认执行？(y/n): ")
    if confirm.lower() == 'y':
        for old_path, new_path, _, _ in changes:
            os.rename(old_path, new_path)
        print(f"✅ 完成，已处理 {len(changes)} 个文件")

if __name__ == "__main__":
    main()
```

### 运行方式

```bash
python rename.py /path/to/your/folder
```

## 实战二：AI 辅助代码重构

### 重构 Prompt 模板

```
请重构以下 Python 代码，要求：
1. 提取重复逻辑为函数
2. 添加类型注解
3. 添加 docstring 文档
4. 处理异常情况（文件不存在、网络超时等）
5. 遵循 PEP 8 代码风格

[粘贴代码]
```

### 重构前后对比示例

**重构前：**

```python
data = []
f = open("sales.csv")
for line in f:
    parts = line.split(",")
    data.append({"name": parts[0], "amount": float(parts[1])})
f.close()

total = 0
for d in data:
    total += d["amount"]
print(total)

data2 = []
f = open("returns.csv")
for line in f:
    parts = line.split(",")
    data2.append({"name": parts[0], "amount": float(parts[1])})
f.close()
```

**重构后（AI 输出）：**

```python
from pathlib import Path
from typing import List, Dict

def read_csv_records(filepath: str) -> List[Dict[str, str | float]]:
    """读取 CSV 文件，返回字典列表。"""
    path = Path(filepath)
    if not path.exists():
        raise FileNotFoundError(f"文件不存在: {filepath}")
    
    records = []
    with path.open("r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            parts = line.split(",")
            if len(parts) < 2:
                print(f"⚠️ 第 {line_num} 行格式异常，已跳过")
                continue
            try:
                records.append({"name": parts[0], "amount": float(parts[1])})
            except ValueError:
                print(f"⚠️ 第 {line_num} 行金额格式错误，已跳过")
    return records

def calc_total(records: List[Dict]) -> float:
    """计算所有记录的金额总和。"""
    return sum(r["amount"] for r in records)

if __name__ == "__main__":
    sales = read_csv_records("sales.csv")
    returns = read_csv_records("returns.csv")
    print(f"销售额总计: ¥{calc_total(sales):,.2f}")
    print(f"退货额总计: ¥{calc_total(returns):,.2f}")
    print(f"净收入: ¥{calc_total(sales) - calc_total(returns):,.2f}")
```

### 重构收益

| 指标 | 重构前 | 重构后 |
|------|--------|--------|
| 重复代码 | 2 段几乎相同的逻辑 | 提取为通用函数 |
| 错误处理 | 无 | 文件不存在、格式异常 |
| 可读性 | 差 | 有类型注解和文档 |
| 可维护性 | 改一个漏一个 | 改函数即可 |

## 实战三：常用脚本场景速查

直接复制这些 Prompt，改参数即可使用：

### 批量处理 Excel

```
写一个 Python 脚本：
1. 读取 input.xlsx 文件
2. 筛选"金额"列大于 1000 的行
3. 按"部门"列分组求和
4. 结果保存到 output.xlsx
5. 使用 openpyxl 库
```

### 定时检查网站状态

```
写一个 Python 脚本：
1. 每隔 5 分钟检查 https://example.com 是否可访问
2. 如果状态码不是 200，发送邮件通知 admin@company.com
3. 记录每次检查的时间和状态到 log.txt
4. 使用 requests 库，SMTP 发邮件
5. 脚本通过 Ctrl+C 停止
```

### 文件整理脚本

```
写一个 Python 脚本：
1. 扫描下载文件夹
2. 按文件扩展名分类到子文件夹：图片(jpg/png/gif)、文档(pdf/docx)、视频(mp4/avi)、其他
3. 自动创建目标文件夹
4. 移动文件前先预览，确认后执行
```

## 零基础写代码的原则

1. **先描述需求，再要代码** —— 不要直接说"写个爬虫"，要说清楚爬什么网站、提取什么数据、存什么格式
2. **一次一个功能** —— 先跑通核心功能，再逐步加需求
3. **遇到报错直接贴给 AI** —— 不用自己分析，AI 比你分析得快
4. **保存能跑通的版本** —— 每次成功运行后备份一份，改坏了可以回退
