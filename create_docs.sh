#!/bin/bash

# 创建文档文件的函数
create_doc() {
  local path=$1
  local title=$2
  local description=$3

  mkdir -p "$(dirname "$path")"
  
  cat > "$path.md" << MDX
---
title: "$title"
description: "$description"
date: "2026-03-17"
category: "AI 学院"
tags: [academy, learning]
order: 1
---

# $title

*本文档内容待补充*
MDX
}

# 创建 Foundation 系列文档 (A)
create_doc "foundation/a1-basics/capability-boundaries" "AI 能力边界洞察：理解 AI 模型的能力边界，识别可落地场景与暂时无法实现的盲区"
create_doc "foundation/a1-basics/tool-ecosystems" "主流工具阵营划分：通用大模型与专项工具的选择策略"
create_doc "foundation/a1-basics/compliance-copyright" "合规与版权避坑：AI 生成内容的商业版权、隐私泄露防护"
create_doc "foundation/a1-basics/roi-calculation" "各岗位降本增效测算模型：量化 AI 能省多少时间、人力成本"
create_doc "foundation/a1-basics/scenario-screening" "适配场景筛选：判断工作/项目能否用 AI 接管"
create_doc "foundation/a1-basics/workflow-setup" "个人/团队 AI 工作流搭建：从需求提出到 AI 输出的完整实操"

create_doc "foundation/a2-prompt/precise-command" "精准指令句式：角色 + 任务 + 要求 + 输出格式的万能公式"
create_doc "foundation/a2-prompt/scenario-adaptation" "不同场景提示词适配技巧：办公/销售/设计/编程差异化指令"
create_doc "foundation/a2-prompt/few-shot-learning" "少样本学习高阶玩法：用 1-2 个例子让 AI 精准模仿风格"
create_doc "foundation/a2-prompt/cot-techniques" "思维链提示技巧：让 AI 分步拆解复杂任务"
create_doc "foundation/a2-prompt/structured-output" "结构化输出控制：精准输出表格、清单、JSON 等格式"
create_doc "foundation/a2-prompt/prompt-optimization" "提示词优化与迭代：从答不好到一次达标的快速调整方法"
create_doc "foundation/a2-prompt/industry-prompts" "行业专属提示词模板：办公/销售/设计/编程可直接套用"

# 创建 Productivity 系列文档 (B)
create_doc "productivity/b1-office/office-tools" "主流办公 AI 工具：WPS AI、Office 365 Copilot、飞书 AI 适配与选择"
create_doc "productivity/b1-office/admin-hr-efficiency" "行政/人事效率化：快速撰写通知、制度，批量排版、改错"
create_doc "productivity/b1-office/finance-data" "财务与数据整理：AI 处理 Excel 公式、对账核对、生成报表"
create_doc "productivity/b1-office/general-scenarios" "通用场景：会议录音、聊天记录一键转纪要、生成待办清单"
create_doc "productivity/b1-office/report-presentation" "汇报与演示：写总结、周月报，搭建 PPT 大纲"
create_doc "productivity/b1-office/email-tasks" "邮件类：生成商务邮件、自动回复、跟进话术"
create_doc "productivity/b1-office/content-creation" "内容创作：公众号长文、小红书笔记、视频脚本"

create_doc "productivity/b2-sales/sales-scripts" "销售话术：开场白、产品介绍、逼单、回访、催款、安抚话术"
create_doc "productivity/b2-sales/service-scripts" "客服话术：处理异议、投诉，生成标准化回复"
create_doc "productivity/b2-sales/customer-analysis" "客户分析：从聊天记录中提炼需求、判断意向、精准跟进"
create_doc "productivity/b2-sales/trade-specific" "外贸专属：写外贸开发信、小语种邮件、实时翻译"
create_doc "productivity/b2-sales/social-leads" "社媒获客：写私信、评论互动话术、批量回复提升效率"

create_doc "productivity/b3-analytics/data-interpretation" "数据解读：看懂核心业务数据、通俗化解读专业数据"
create_doc "productivity/b3-analytics/data-processing" "数据处理：数据清洗、整理、对比、剔除无效信息"
create_doc "productivity/b3-analytics/report-generation" "报告生成：自动生成数据分析报告、复盘总结、节省撰写时间"
create_doc "productivity/b3-analytics/trend-prediction" "趋势预测：做简单业务预测、趋势判断、辅助管理层决策"
create_doc "productivity/b3-analytics/visualization" "可视化：生成图表让数据直观"
create_doc "productivity/b3-analytics/security-compliance" "安全合规：企业数据分析的脱敏与合规操作"

# 创建 Creative 系列文档 (C)
create_doc "creative/c1-visual-basics/visual-tools" "视觉工具阵营：Nano Banana、Midjourney、ComfyUI 等工具优劣势分析"
create_doc "creative/c1-visual-basics/precise-control" "精准画面指令：精准控制光影、材质、构图和镜头视角"
create_doc "creative/c1-visual-basics/image-editing" "图生图高阶玩法：垫图控制主体与替换背景"
create_doc "creative/c1-visual-basics/consistency" "一致性保持：角色与特定艺术风格一致性"
create_doc "creative/c1-visual-basics/visual-tuning" "视觉微调：局部重绘与细节精修实操手法"
create_doc "creative/c1-visual-basics/copyright-guide" "商业版权避坑指南：保持产品主轮廓不变、微调细节以规避外观专利"

create_doc "creative/c2-ecommerce/scene-variation" "场景秒变技术：白底图快速转化为高转化产品场景图"
create_doc "creative/c2-ecommerce/ip-avoidance" "知识产权规避：保持产品主轮廓不变、微调细节以规避外观专利"
create_doc "creative/c2-ecommerce/global-aesthetics" "全球审美适配：生成符合海外受众审美的营销海报"
create_doc "creative/c2-ecommerce/batch-production" "批量视觉产出：独立站、Instagram 广告素材批量生产、结合节日/节气快速生成营销物料"

create_doc "creative/c3-video/script-breakdown" "脚本与分镜拆解：AI 生成视频脚本并同步转化为视觉分镜画面"
create_doc "creative/c3-video/video-production" "视频改编全链路实操：从图文/小说到高质量动画视频的完整制作流程"
create_doc "creative/c3-video/dynamic-control" "动态镜头控制：视频工具的镜头推拉摇移、人物动作一致性控制"
create_doc "creative/c3-video/voice-acting" "逼真配音与口播：AI 制作带多语种/方言的逼真配音、商用级剪辑"
create_doc "creative/c3-video/viral-generation" "爆款短视频生成：图文内容一键转视频的实操流程"
create_doc "creative/c3-video/professional-level" "商业水平提升：TVC 级别视频剪辑、配乐与质感提升"

create_doc "creative/c4-branding/ip-image" "IP 形象：从 0 到 1 设计品牌专属 IP 形象"
create_doc "creative/c4-branding/custom-model" "专属模型训练：LoRA 训练基础概念、数据集准备与模型微调"
create_doc "creative/c4-branding/visual-packaging" "视觉包装：餐饮/快消品牌年轻化、国际化视觉升级"
create_doc "creative/c4-branding/industrial-design" "工业设计：构建产品三维概念图与工业设计草图"

# 创建 Social Media 系列文档 (S)
create_doc "social-media/s1-mechanism/platform-mechanics" "平台机制：抖音、小红书、公众号算法逻辑（流量池、权重、分发机制）"
create_doc "social-media/s1-mechanism/account-positioning" "账号定位：差异化赛道筛选、人设商业模型建立、视觉体系规划"
create_doc "social-media/s1-mechanism/topic-matrix" "选题矩阵：热点追踪、选题库搭建、长视频/短图文内容组合"
create_doc "social-media/s1-mechanism/ai-integration" "AI 深度结合：用 AI 预测选题热度、批量改写文案、全自动视频初剪"

create_doc "social-media/s2-content/topic-strategy" "选题策略：热点追踪、选题库搭建、长视频/短图文的内容组合策略"
create_doc "social-media/s2-content/full-production" "全案创作：用 AI 写公众号长文、小红书笔记、视频脚本"
create_doc "social-media/s2-content/batch-efficiency" "批量提效：用 AI 批量改写文案、内容去重润色、适配多平台分发"

create_doc "social-media/s3-monetization/operation-loop" "运营闭环：橱子内容设置、评论区高情商维护、公域转私域导流 SOP"
create_doc "social-media/s3-monetization/ai-empowerment" "AI 赋能：用 AI 编写高转化引流话术、社媒私信互动模板"
create_doc "social-media/s3-monetization/private-conversion" "私域转化：橱子设置、评论维护、公域转私域导流 SOP"

# 创建 Cross-border 系列文档 (K)
create_doc "cross-border/k1-market/product-selection" "选品逻辑：亚马逊/TikTok/独立站选品工具应用、竞争对手分析"
create_doc "cross-border/k1-market/store-setup" "店铺起步：店铺注册规范、Listing 埋词优化、转化率核心因素拆解"
create_doc "cross-border/k1-market/ai-empowerment" "AI 赋能：用 AI 自动生成高权重 Listing、批量产出符合海外审美的广告主图"
create_doc "cross-border/k1-market/data-mining" "AI 数据挖掘：AI 挖掘海关数据与客户信息、一键生成海外模特图/实景图"

create_doc "cross-border/k2-marketing/ad-practice" "投放实务：FB/Google Ads/TikTok Ads 投放逻辑"
create_doc "cross-border/k2-marketing/content-leads" "内容获客：用 AI 优化社媒发帖内容、提升海外曝光、批量生成 TikTok 广告短视频素材"
create_doc "cross-border/k2-marketing/ai-automation" "AI 自动化：AI 自动生成 Listing、批量产出海外模特图/海报、跨语言客诉自动化"
create_doc "cross-border/k2-marketing/kol-partnership" "达人营销建联：达人营销（KOL/KOC）建联与合作 SOP"

create_doc "cross-border/k3-service/supply-chain" "供应链管理：FBA/海外仓代发流程、成本控制与利润核算模型"
create_doc "cross-border/k3-service/cross-border-loop" "跨境闭环：用 AI 写外贸开发信、小语种邮件、实时翻译并适配海外沟通习惯"
create_doc "cross-border/k3-service/ai-empowerment" "AI 赋能：自动化处理跨语言客诉与异议处理、利用 AI 提炼售后反馈优化产品线"

# 创建 Programming 系列文档 (P)
create_doc "programming/p1-website/quick-website" "实战建站：用 AI 快速搭建企业官网、产品营销站、外贸独立站"
create_doc "programming/p1-website/multi-platform" "多端适配：无需复杂代码实现多语言适配、多终端自适应布局"
create_doc "programming/p1-website/ai-empowerment" "AI 赋能：AI 辅助界面改版、样式调整、SEO 架构自动化优化"

create_doc "programming/p2-automation/efficiency-tools" "提效利器：编写批量数据处理、重复操作自动化脚本"
create_doc "programming/p2-automation/data-mining" "数据挖掘：用 AI 做简单数据爬虫、信息采集、快速获取行业数据与客户线索"
create_doc "programming/p2-automation/ai-empowerment" "AI 赋能：零基础通过 AI 编写 Python 或常用脚本逻辑、AI 辅助进行代码重构"

create_doc "programming/p3-development/dev-assistance" "开发辅助：辅助编程工具（GitHub Copilot 等）使用技巧、小程序/APP 核心功能辅助开发"
create_doc "programming/p3-development/system-logic" "系统逻辑：用 AI 解释复杂代码逻辑、查 Bug、优化后端业务流程"
create_doc "programming/p3-development/ai-empowerment" "AI 赋能：利用 AI + 低代码工具、快速搭建企业内部管理系统"

# 创建 Governance 系列文档 (G)
create_doc "governance/g1-strategy/core-logic" "企业 AI 落地的核心逻辑：从 0 到 1 的完整步骤（调研→选型→试点→推广→优化）"
create_doc "governance/g1-strategy/department-checklist" "各部门应用清单：销售/市场/客服/行政/技术/生产、精准匹配业务需求"
create_doc "governance/g1-strategy/tool-recommendations" "工具采购建议：根据企业规模、预算、选择高适配、高性价比的 AI 工具"
create_doc "governance/g1-strategy/training-system" "培训体系：分层培训（全员基础/岗位专项）、制定培训计划与考核标准"
create_doc "governance/g1-strategy/pitfall-guide" "AI 落地避坑指南：避免盲目投入、工具滥用、版权纠纷等常见问题"
create_doc "governance/g1-strategy/security-knowledge" "安全与知识库：内部 AI 使用规范、数据安全制度、企业 AI 知识库搭建"

# 创建 Monetization 系列文档 (M)
create_doc "monetization/m1-business/full-process" "全流程跑通：个人/微型团队如何实现导演+美术+后期闭环"
create_doc "monetization/m1-business/requirement-communication" "需求沟通：接洽商单技巧、将模糊需求转化为精准指令"
create_doc "monetization/m1-business/pricing-strategy" "报价策略：个人/工作室如何用 AI 接文案/视觉商单、报价策略与交付流程"
create_doc "monetization/m1-business/contract-standards" "合同规范：AI 视觉与视频商业项目的合同规范与积分制/项目制逻辑"
create_doc "monetization/m1-business/onboarding-sop" "接单 SOP：建立高效接单工作流与个人素材库"

create_doc "monetization/m2-industry/cross-border" "跨境/出海：亚马逊主图差异化、海外社媒视觉、海关数据挖掘"
create_doc "monetization/m2-industry/hardware" "硬件/制造：外观规避侵权微调、智能硬件渲染、工艺流程文档"
create_doc "monetization/m2-industry/fmcg" "快消/餐饮：品牌宣发视频、菜单/海报视觉、活动文案/会员话术"
create_doc "monetization/m2-industry/film-animation" "影视/动漫：IP 三维化、动态漫低成本预演、宣发物料批量生成"
create_doc "monetization/m2-industry/service-training" "服务/教培/礼品/医美：营销视频、教案题库生成、公文写作、会议纪要"
create_doc "monetization/m2-industry/admin-soe" "行政/国企：撰写公文、通知、汇报材料、整理会议纪要、优化办公流程"
create_doc "monetization/m2-industry/industry-cases" "行业案例库：各行业 AI 应用的成功案例库"

echo "所有文档创建完成！"
