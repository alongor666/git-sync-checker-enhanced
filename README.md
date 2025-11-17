# Git Sync Checker Enhanced - 使用指南

一个智能的 Git 同步状态检查工具，支持多分支、多仓库、批量检查，提供 AI 驱动的冲突预测和智能建议。

## 📁 文档结构

本项目采用模块化文档结构，便于快速查找和学习：

| 文件 | 用途 | 适合 |
|------|------|------|
| **[SKILL.md](SKILL.md)** | 核心指令和快速参考（327行） | Claude Code 技能文件，包含执行流程和命令 |
| **[examples.md](examples.md)** | 6个详细使用场景示例 | 想了解实际使用案例的开发者 |
| **[reference.md](reference.md)** | 高级功能和算法详解 | 需要深入了解技术细节的用户 |
| **README.md** | 本文件，快速上手指南 | 初次使用者 |
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | 安装和部署说明 | 想要安装此技能的用户 |
| **[CHANGELOG.md](CHANGELOG.md)** | 版本历史和更新日志 | 关注项目演进的用户 |

### 可用脚本

| 脚本 | 功能 | 文档位置 |
|------|------|---------|
| `batch-checker.sh` | 批量检查多个仓库 | [本文 - 实用脚本](#脚本-2-batch-checkersh) |
| `conflict-predictor.sh` | 运行冲突预测算法 | [本文 - 实用脚本](#脚本-1-conflict-predictorsh) |
| `gitignore-checker.sh` | 检查和优化 .gitignore | [本文 - 实用脚本](#脚本-3-gitignore-checkersh) |

## 快速开始

### 基础检查

```bash
# 检查当前仓库同步状态
检查同步状态

# 下班前检查
准备下班

# 上班后检查
开始工作
```

### 批量检查

```bash
# 检查指定目录下所有仓库
检查 ~/projects 下所有仓库

# 生成 Markdown 报告
检查所有项目，生成 markdown 报告

# 生成 JSON 报告
检查所有项目，输出 json
```

### 冲突预测

```bash
# 预测合并冲突
我要合并最新代码，会有冲突吗？

# 查看冲突详情
分析一下可能的冲突文件
```

### .gitignore 优化

```bash
# 检查配置
检查 gitignore 配置

# 检测敏感文件
检查是否有不该提交的文件

# 生成优化建议
优化 gitignore
```

## 进阶用法

### 场景 1：多设备开发工作流

**公司电脑 - 下班前**
```bash
# 18:30
准备下班了，检查一下代码

# Claude 会自动:
# 1. 检测到下班时间
# 2. 重点检查未推送代码
# 3. 验证依赖文件
# 4. 提醒环境变量同步
```

**家里电脑 - 开始工作**
```bash
# 19:30
开始工作，拉取最新代码

# Claude 会自动:
# 1. 检查远程更新
# 2. 提醒安装依赖
# 3. 建议运行测试
# 4. 验证开发环境
```

### 场景 2：项目切换管理

```bash
# 查看所有项目状态
检查 ~/work 目录下所有仓库的同步状态

# 输出示例:
# 📦 批量检查结果 (5 个仓库)
# 
# ✅ project-a (main) - 已同步
# ⚠️ project-b (dev) - 2 个未推送提交
# 🔴 project-c (feature) - 有未提交修改
```

### 场景 3：冲突风险评估

```bash
# 在合并前评估风险
git fetch origin
我要合并 origin/main，会有冲突吗？

# 输出示例:
# 🔍 冲突风险分析
# 
# 风险等级: 🟡 中风险 (65分)
# 
# 可能冲突的文件:
# 1. src/utils/api.ts
#    - 冲突概率: 75%
# 2. package.json
#    - 冲突概率: 40%
```

## 配置文件示例

### 推荐的 .gitignore（Next.js）

```gitignore
# 依赖
node_modules/
.pnp/
.yarn/*

# 构建产物
.next/
out/
build/

# 环境变量
.env
.env*.local
.env.production

# 测试
coverage/
.nyc_output/

# 日志
*.log
npm-debug.log*

# 系统文件
.DS_Store
.vscode/
.idea/

# Vercel
.vercel/
```

### 推荐的 .gitignore（Python Django）

```gitignore
# Python
__pycache__/
*.py[cod]
*.so

# 虚拟环境
venv/
env/
.venv

# Django
*.log
db.sqlite3
/media
/staticfiles
local_settings.py

# 测试
.pytest_cache/
.coverage
htmlcov/

# 环境变量
.env
.env.local

# IDE
.vscode/
.idea/
*.swp

# 系统文件
.DS_Store
```

## 实用脚本

### 脚本 1: conflict-predictor.sh

```bash
# 运行冲突预测
cd /path/to/your/repo
bash conflict-predictor.sh

# 输出 JSON 格式
bash conflict-predictor.sh --json
```

**输出示例**：
```
🔍 正在分析冲突风险...
分支: feature/new-ui
远程: origin

📊 冲突风险评估
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
共同修改文件: 2 个
本地修改行数: 156 行
远程修改行数: 89 行
冲突分数: 80 分

🔴 高风险 - 很可能遇到冲突，建议备份

⚠️ 可能冲突的文件:
  - src/components/Header.tsx
    本地: 45 行 | 远程: 32 行
  - src/styles/globals.css
    本地: 12 行 | 远程: 8 行

💡 建议操作:
  # 1. 备份当前分支
  git branch backup-20251117-1845
  
  # 2. 使用交互式 rebase（推荐）
  git fetch origin
  git rebase -i origin/feature/new-ui
```

### 脚本 2: batch-checker.sh

```bash
# 检查当前目录
bash batch-checker.sh .

# 检查指定目录
bash batch-checker.sh ~/projects

# 生成 Markdown 报告
bash batch-checker.sh ~/projects markdown > report.md

# 生成 JSON 报告
bash batch-checker.sh ~/projects json > report.json
```

### 脚本 3: gitignore-checker.sh

```bash
# 基本检查
bash gitignore-checker.sh

# 保存报告
bash gitignore-checker.sh --save-report
```

## 命令速查表

| 场景 | 触发词示例 | 功能 |
|------|-----------|------|
| **日常检查** | "检查同步状态" | 检查当前仓库 |
| **下班前** | "准备下班" | 重点检查未推送 |
| **上班后** | "开始工作" | 重点检查远程更新 |
| **批量检查** | "检查所有项目" | 批量检查多个仓库 |
| **冲突预测** | "会有冲突吗" | 预测合并冲突 |
| **配置优化** | "检查 gitignore" | 优化配置文件 |
| **敏感文件** | "检查敏感文件" | 检测不该提交的文件 |

## 输出格式

### 1. 标准终端输出（带颜色）

```
📊 Git 同步状态

分支: feature/user-auth
远程: origin (GitHub)

✅ 工作区干净
⚠️ 2 个未推送提交
✅ 远程无更新

💡 建议操作:
git push origin feature/user-auth
```

### 2. Markdown 报告

```markdown
# Git 同步状态报告

生成时间: 2025-11-17 18:30

## 基本信息
- 仓库: my-project
- 分支: main
- 远程: origin

## 状态概览
- 工作区: 干净
- 未推送: 2 个提交
- 未拉取: 0 个提交
```

### 3. JSON 输出

```json
{
  "timestamp": "2025-11-17T18:30:00Z",
  "repository": "my-project",
  "branch": "main",
  "status": {
    "uncommitted": 0,
    "unpushed": 2,
    "unpulled": 0,
    "conflict_risk": "low"
  }
}
```

## 常见问题

### Q1: 如何处理代码分叉？

```bash
# 场景：本地和远程都有独有提交

# 方案 1: Rebase（推荐，历史更清晰）
git fetch origin
git rebase origin/main

# 方案 2: Merge（保留分支历史）
git fetch origin
git merge origin/main

# 方案 3: 如果确定远程代码正确
git fetch origin
git reset --hard origin/main  # ⚠️ 会丢失本地修改
```

### Q2: 如何清理已提交的敏感文件？

```bash
# 1. 从 Git 移除但保留本地文件
git rm --cached .env

# 2. 添加到 .gitignore
echo ".env" >> .gitignore

# 3. 提交修改
git commit -m "chore: 移除敏感文件"

# 4. 如果已推送，需要清理历史
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all
```

### Q3: 批量检查速度慢？

```bash
# 限制搜索深度
find ~/projects -maxdepth 2 -name ".git"

# 只检查最近修改的仓库
find ~/projects -name ".git" -mtime -7
```

### Q4: 如何集成到开发工具？

```bash
# VS Code 任务配置 (.vscode/tasks.json)
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Git Sync Check",
      "type": "shell",
      "command": "bash",
      "args": ["${workspaceFolder}/scripts/conflict-predictor.sh"],
      "problemMatcher": []
    }
  ]
}

# Git Hook (pre-push)
#!/bin/bash
# .git/hooks/pre-push

bash scripts/conflict-predictor.sh
if [ $? -ne 0 ]; then
    echo "⚠️ 检测到潜在冲突，是否继续推送？(y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi
```

## 最佳实践

### 1. 建立工作习惯

```bash
# 每天开始工作前
开始工作

# 每天结束工作后
准备下班

# 切换任务前
检查同步状态
```

### 2. 项目规范

```bash
# 统一 .gitignore 配置
# 1. 检查当前配置
检查 gitignore

# 2. 应用推荐配置
# 3. 提交到仓库
git add .gitignore
git commit -m "chore: 优化 gitignore 配置"
```

### 3. 团队协作

```bash
# 合并前检查
我要合并 feature 分支，会有冲突吗？

# 推送前验证
准备推送代码，检查一下状态
```

## 故障排除

### 脚本执行错误

```bash
# 赋予执行权限
chmod +x conflict-predictor.sh
chmod +x batch-checker.sh
chmod +x gitignore-checker.sh

# 检查依赖
which git  # 确保 Git 已安装
git --version  # 确保版本 ≥ 2.0
```

### 远程仓库无法访问

```bash
# 检查远程配置
git remote -v

# 测试连接
git fetch --dry-run

# 重新配置
git remote set-url origin <new-url>
```

## 相关资源

- [Git 官方文档](https://git-scm.com/doc)
- [Git 冲突解决指南](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging)
- [.gitignore 模板](https://github.com/github/gitignore)

## 技术支持

如有问题或建议，请：
1. 查看本文档的常见问题部分
2. 运行带 `--verbose` 参数获取详细日志
3. 检查 Git 配置和权限
