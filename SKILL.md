---
name: git-sync-checker-enhanced
description: 智能检查本地代码与远程仓库的同步状态，支持多分支、多仓库、批量检查，提供AI驱动的冲突预测和智能建议。适用于多设备开发、团队协作、代码审查等场景。
allowed-tools: Bash, Read, Grep
---

# Instructions

## 核心职责

本技能是增强版的 Git 同步状态检查工具，提供智能分析和情境感知的操作建议。

**核心功能**：

- ✅ 自动检测分支和远程仓库配置
- ✅ 支持单个或批量检查多个仓库
- ✅ AI 驱动的冲突预测和风险评估
- ✅ 智能 .gitignore 检查和优化建议
- ✅ 项目类型感知的个性化建议
- ✅ 生成详细的同步报告（支持多种格式）
- ❌ 不自动执行危险操作（需用户确认）

## 执行流程

### 阶段 1：环境检测与配置识别

#### 1.1 检测仓库信息

```bash
# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)

# 获取远程仓库名称
REMOTE_NAME=$(git remote | head -n 1)

# 获取远程 URL
git remote -v

# 检测上游分支
git rev-parse --abbrev-ref @{upstream} 2>/dev/null
```

**识别内容**：
- 当前分支名
- 远程仓库名（origin/upstream/其他）
- 是否有上游分支配置
- 远程仓库类型（GitHub/GitLab/Bitbucket/自建）

#### 1.2 检测项目类型

```bash
# 检查项目配置文件
ls -la | grep -E "package.json|requirements.txt|go.mod|Cargo.toml|pom.xml|build.gradle"

# 检查框架标识
[ -f "package.json" ] && cat package.json | grep -E "react|vue|angular|next|nuxt"
```

**识别项目类型**：
- 前端（React/Vue/Angular）
- 后端（Node/Python/Go/Java）
- 全栈（Next.js/Nuxt）
- 移动端（React Native/Flutter）
- 其他

### 阶段 2：状态检查与分析

#### 2.1 工作区状态

```bash
# 详细状态
git status --porcelain

# 未跟踪文件
git ls-files --others --exclude-standard

# 已修改但未暂存
git diff --name-only

# 已暂存但未提交
git diff --cached --name-only
```

#### 2.2 本地与远程对比

```bash
# 获取远程更新（不拉取代码）
git fetch $REMOTE_NAME

# 本地领先的提交
git log $REMOTE_NAME/$CURRENT_BRANCH..$CURRENT_BRANCH --oneline

# 远程领先的提交
git log $CURRENT_BRANCH..$REMOTE_NAME/$CURRENT_BRANCH --oneline

# 检查分叉
git rev-list --left-right --count $CURRENT_BRANCH...$REMOTE_NAME/$CURRENT_BRANCH
```

#### 2.3 智能冲突预测（新增）

```bash
# 获取本地和远程修改的文件列表
LOCAL_FILES=$(git diff --name-only $REMOTE_NAME/$CURRENT_BRANCH..$CURRENT_BRANCH)
REMOTE_FILES=$(git diff --name-only $CURRENT_BRANCH..$REMOTE_NAME/$CURRENT_BRANCH)

# 找出可能冲突的文件（两边都修改了）
echo "$LOCAL_FILES" | sort > /tmp/local_files
echo "$REMOTE_FILES" | sort > /tmp/remote_files
comm -12 /tmp/local_files /tmp/remote_files
```

**冲突风险评级**：
- 🟢 低风险：无共同修改文件
- 🟡 中风险：1-3 个共同修改文件
- 🔴 高风险：>3 个共同修改文件或关键文件冲突

### 阶段 3：.gitignore 检查（新增）

#### 3.1 检查敏感文件

```bash
# 检查是否有不该提交的文件
git status --porcelain | grep -E "\.env|\.key|\.pem|node_modules|\.DS_Store|\.vscode"
```

#### 3.2 生成优化建议

根据项目类型推荐 .gitignore 规则：

**前端项目**：
```
node_modules/
dist/
.cache/
.env.local
.DS_Store
```

**Python 项目**：
```
__pycache__/
*.pyc
.env
venv/
.pytest_cache/
```

### 阶段 4：批量检查支持（新增）

#### 4.1 单仓库模式
```bash
# 当前目录检查
git -C . status
```

#### 4.2 批量模式
```bash
# 扫描指定目录下的所有 Git 仓库
find /path/to/projects -maxdepth 2 -type d -name ".git" | while read gitdir; do
    REPO_DIR=$(dirname "$gitdir")
    echo "检查: $REPO_DIR"
    git -C "$REPO_DIR" status --short
done
```

**批量检查输出**：
```
📦 批量检查结果 (3 个仓库)

✅ project-a: 已同步
⚠️ project-b: 2 个未推送提交
🔴 project-c: 有未提交修改 + 远程领先
```

### 阶段 5：智能报告生成（新增）

#### 5.1 标准报告格式

```markdown
# Git 同步状态报告
生成时间: 2025-11-17 14:30:00

## 📊 基本信息
- 仓库: my-project
- 分支: feature/new-feature
- 远程: origin (github.com)
- 项目类型: React 前端项目

## 🔍 状态概览
- 工作区: 3 个文件有修改
- 暂存区: 1 个文件已暂存
- 本地提交: 2 个未推送
- 远程更新: 0 个未拉取

## ⚠️ 风险评估
- 冲突风险: 🟢 低风险
- 敏感文件: ⚠️ 发现 .env 文件未忽略

## 💡 操作建议
1. 添加 .env 到 .gitignore
2. 提交当前修改
3. 推送到远程

## 📝 详细命令
\`\`\`bash
echo ".env" >> .gitignore
git add .gitignore src/
git commit -m "feat: 完成新功能"
git push origin feature/new-feature
\`\`\`
```

#### 5.2 简洁模式（适合快速查看）

```
✅ main | ↑2 | 干净
⚠️ feature | ↑1 ↓3 | 2 个修改
🔴 hotfix | ↑0 ↓1 | 有冲突
```

### 阶段 6：情境感知建议（新增）

#### 6.1 时间感知

```python
import datetime

hour = datetime.datetime.now().hour

if 17 <= hour <= 19:
    context = "下班前"
    priority = ["推送代码", "清理工作区"]
elif 9 <= hour <= 11:
    context = "上班后"
    priority = ["拉取更新", "检查依赖"]
else:
    context = "常规检查"
```

#### 6.2 项目类型感知

**前端项目**：
- 检查 node_modules 是否被忽略
- 提醒运行 `npm install` 或 `pnpm install`
- 建议检查 package-lock.json 冲突

**后端项目**：
- 检查虚拟环境是否被忽略
- 提醒运行数据库迁移
- 建议检查 API 版本兼容性

**全栈项目**：
- 检查前后端同步状态
- 提醒环境变量配置
- 建议测试端到端功能

## 高级功能

### 1. 智能冲突预测算法

```bash
#!/bin/bash
# conflict_predictor.sh

predict_conflicts() {
    local base_commit=$(git merge-base HEAD origin/$CURRENT_BRANCH)
    
    # 获取两边修改的行数
    local local_changes=$(git diff $base_commit HEAD --numstat | awk '{sum+=$1+$2} END {print sum}')
    local remote_changes=$(git diff $base_commit origin/$CURRENT_BRANCH --numstat | awk '{sum+=$1+$2} END {print sum}')
    
    # 计算冲突概率
    local conflict_score=0
    
    # 共同修改文件 +30 分
    local common_files=$(comm -12 <(git diff --name-only $base_commit HEAD | sort) \
                                   <(git diff --name-only $base_commit origin/$CURRENT_BRANCH | sort) | wc -l)
    conflict_score=$((conflict_score + common_files * 30))
    
    # 修改行数 >100 +20 分
    [ $local_changes -gt 100 ] && conflict_score=$((conflict_score + 20))
    [ $remote_changes -gt 100 ] && conflict_score=$((conflict_score + 20))
    
    # 输出风险等级
    if [ $conflict_score -lt 30 ]; then
        echo "🟢 低风险 (${conflict_score}分)"
    elif [ $conflict_score -lt 70 ]; then
        echo "🟡 中风险 (${conflict_score}分)"
    else
        echo "🔴 高风险 (${conflict_score}分)"
    fi
}
```

### 2. 大文件检测

```bash
# 检查大于 5MB 的文件
git ls-files -z | while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [ $size -gt 5242880 ]; then
            echo "⚠️ 大文件: $file ($(numfmt --to=iec $size))"
        fi
    fi
done
```

### 3. 多格式报告导出

```bash
# Markdown 格式
generate_report "markdown" > sync-report.md

# HTML 格式（带样式）
cat > sync-report.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <style>
        .status-ok { color: green; }
        .status-warn { color: orange; }
        .status-error { color: red; }
    </style>
</head>
<body>
    <h1>Git 同步报告</h1>
    <!-- 报告内容 -->
</body>
</html>
EOF

# JSON 格式（供其他工具使用）
cat > sync-report.json <<'EOF'
{
  "timestamp": "2025-11-17T14:30:00Z",
  "repository": "my-project",
  "branch": "main",
  "status": {
    "uncommitted": 3,
    "unpushed": 2,
    "conflict_risk": "low"
  }
}
EOF
```

## 使用场景

### 📍 场景 1：下班前检查（公司电脑）

**触发词**："准备下班"、"检查同步"、"推送代码"

**执行流程**：
1. 检测当前时间（17:00-19:00）
2. 自动启用"下班模式"
3. 重点检查：
   - ✅ 所有修改已提交
   - ✅ 所有提交已推送
   - ✅ 无敏感文件泄露
   - ✅ 依赖文件同步（package-lock.json）

**智能建议**：
```bash
# 如果有未提交修改
"发现 3 个文件有修改，建议提交后再下班："
git add .
git commit -m "feat: 完成今日开发任务"
git push origin main

# 如果工作区干净
"✅ 代码已全部推送，可以安心下班！"
```

### 🏠 场景 2：上班后检查（家里/公司电脑）

**触发词**："开始工作"、"拉取最新代码"

**执行流程**：
1. 检测当前时间（9:00-11:00）
2. 自动启用"上班模式"
3. 重点检查：
   - ✅ 工作区干净
   - ✅ 拉取远程更新
   - ✅ 检查依赖是否需要更新
   - ✅ 验证开发环境

**智能建议**：
```bash
# 如果远程有更新
"远程有 5 个新提交，包含依赖更新："
git pull origin main
pnpm install  # 根据项目类型推荐命令

# 如果本地有未推送提交
"⚠️ 检测到本地有 2 个未推送提交，可能与远程冲突。"
"建议先备份当前分支："
git branch backup-$(date +%Y%m%d)
```

### 🔄 场景 3：批量检查多个项目

**触发词**："检查所有项目"、"批量同步检查"

**用户输入示例**：
```
检查 ~/projects 下所有仓库的同步状态
```

**执行流程**：
```bash
# 扫描所有 Git 仓库
find ~/projects -maxdepth 2 -name ".git" -type d

# 生成批量报告
📦 批量检查结果 (5 个仓库)

✅ project-a (main)
   干净，已同步

⚠️ project-b (dev)
   2 个未推送提交
   建议: git push origin dev

🔴 project-c (feature)
   3 个未提交修改 + 远程领先 1 个提交
   风险: 🟡 中等冲突风险
   建议: 先提交，再 git pull --rebase

✅ project-d (main)
   干净，已同步

⚠️ project-e (hotfix)
   发现 .env 文件未忽略
   建议: 添加到 .gitignore
```

### 🚨 场景 4：检测到危险情况

**情况 1：即将强制推送**
```
🔴 危险操作警告

检测到本地历史与远程不一致，可能需要强制推送。

❌ 不建议: git push --force
✅ 建议: 
1. 确认远程代码是否重要
2. 使用 git push --force-with-lease (更安全)
3. 或者创建新分支: git checkout -b recovery-branch
```

**情况 2：敏感文件即将提交**
```
🔴 敏感文件警告

检测到以下文件包含敏感信息：
- .env (包含 API 密钥)
- config/database.yml (包含数据库密码)

建议操作：
1. 添加到 .gitignore
2. 从 Git 历史中移除（如果已提交）
3. 使用环境变量管理

命令：
echo ".env" >> .gitignore
echo "config/database.yml" >> .gitignore
git rm --cached .env config/database.yml
git commit -m "chore: 移除敏感文件"
```

## 限制与边界

### 安全限制
- ❌ 永不执行强制推送（`--force`）
- ❌ 永不修改已推送的提交历史
- ❌ 永不自动删除分支
- ⚠️ 危险操作必须明确警告

### 功能边界
- ✅ 只检查和建议，不自动执行修改操作
- ✅ 所有 Git 命令需用户手动确认
- ✅ 冲突解决提供方案，不自动处理
- ✅ 敏感信息检测后立即警告

### 性能考虑
- 批量检查时限制仓库数量（建议 ≤20）
- 大仓库检查时显示进度
- 超时保护（单个仓库检查 <30 秒）

## 输出格式选项

用户可以指定报告格式：

```
# 默认格式（带颜色的终端输出）
检查同步状态

# Markdown 报告
检查同步状态，生成 markdown 报告

# JSON 格式（供脚本使用）
检查同步状态，输出 json

# HTML 报告（可在浏览器查看）
检查同步状态，生成 html 报告
```

# Examples

## 示例 1：自动检测分支和远程仓库

**用户输入**：
> 检查同步状态

**正确处理流程**：

1. 自动检测环境：
```bash
$ git branch --show-current
feature/user-auth

$ git remote -v
origin  https://github.com/user/my-project.git (fetch)
upstream https://github.com/org/my-project.git (fetch)
```

2. 生成智能报告：
```markdown
📊 同步状态检查

## 基本信息
- 分支: feature/user-auth
- 远程: origin (GitHub)
- 上游: upstream (组织仓库)
- 项目类型: React + TypeScript

## 状态
- 本地提交: 3 个未推送到 origin
- 上游更新: 5 个新提交在 upstream/main
- 工作区: 2 个文件有修改

## 建议操作
1. 提交当前修改
2. 推送到个人仓库: git push origin feature/user-auth
3. 同步上游更新: git fetch upstream && git merge upstream/main
```

## 示例 2：智能冲突预测

**用户输入**：
> 我要合并最新代码，会有冲突吗？

**正确处理流程**：

1. 运行冲突预测算法：
```bash
# 分析共同修改文件
共同修改: src/utils/api.ts, src/components/UserList.tsx

# 计算冲突概率
- 共同文件: 2 个 (+60 分)
- 本地修改: 150 行 (+20 分)
- 远程修改: 80 行
- 总分: 80 分
```

2. 生成风险报告：
```markdown
🔍 冲突风险分析

## 风险等级: 🔴 高风险 (80分)

## 可能冲突的文件
1. src/utils/api.ts
   - 本地: 修改了 fetchUser 函数
   - 远程: 修改了 fetchUser 函数
   - 冲突概率: 85%

2. src/components/UserList.tsx
   - 本地: 添加了新的 props
   - 远程: 重构了组件结构
   - 冲突概率: 60%

## 建议
1. 先备份当前分支: git branch backup-feature
2. 使用交互式 rebase: git rebase -i origin/main
3. 准备手动解决冲突（预计 10-15 分钟）

## 安全操作步骤
git fetch origin
git branch backup-$(date +%Y%m%d-%H%M)
git rebase origin/main
# 如果有冲突，逐个解决后：
git rebase --continue
```

## 示例 3：批量检查多个项目

**用户输入**：
> 检查 ~/work 目录下所有项目的同步状态

**正确处理流程**：

1. 扫描目录：
```bash
找到 4 个 Git 仓库：
- ~/work/frontend-app
- ~/work/backend-api
- ~/work/mobile-app
- ~/work/docs
```

2. 生成批量报告：
```markdown
📦 批量同步检查报告
检查时间: 2025-11-17 18:45

## 概览
- 总计: 4 个仓库
- 已同步: 1 个 ✅
- 需要处理: 3 个 ⚠️

---

### 1. frontend-app (React)
- 分支: main
- 状态: ⚠️ 需要处理
- 问题:
  - 2 个未提交文件
  - 1 个未推送提交
- 建议:
  ```bash
  cd ~/work/frontend-app
  git add .
  git commit -m "feat: 更新用户界面"
  git push origin main
  ```

### 2. backend-api (Node.js)
- 分支: develop
- 状态: 🔴 需要立即处理
- 问题:
  - 远程领先 3 个提交
  - 本地有 2 个未推送提交
  - 冲突风险: 🟡 中等
- 建议:
  ```bash
  cd ~/work/backend-api
  git fetch origin
  git rebase origin/develop
  ```

### 3. mobile-app (React Native)
- 分支: feature/push-notification
- 状态: ✅ 已同步
- 备注: 一切正常

### 4. docs (Markdown)
- 分支: main
- 状态: ⚠️ 建议优化
- 问题:
  - 发现 .DS_Store 文件
- 建议:
  ```bash
  cd ~/work/docs
  echo ".DS_Store" >> .gitignore
  git rm --cached .DS_Store
  git commit -m "chore: 忽略系统文件"
  ```

## 快速操作脚本
一键处理所有问题（需手动确认每步）:
```bash
# 保存为 sync-all.sh
cd ~/work/frontend-app && git add . && git commit -m "update" && git push
cd ~/work/backend-api && git fetch && git rebase origin/develop
cd ~/work/docs && echo ".DS_Store" >> .gitignore && git add .gitignore && git commit -m "chore"
```
```

## 示例 4：下班前智能检查

**用户输入**（18:30）：
> 准备下班了

**正确处理流程**：

1. 检测到下班时间，自动启用下班模式：
```markdown
🌆 下班前检查清单

检测到当前时间: 18:30
项目: my-saas-platform (Next.js 全栈)

## ✅ 检查项
- [x] 工作区干净
- [x] 所有提交已推送
- [ ] ⚠️ package-lock.json 有更新但未提交
- [x] 无敏感文件泄露
- [ ] ⚠️ 环境变量文件需要更新

## 需要处理
1. package-lock.json 更新
   - 原因: 今天安装了新依赖 (react-query)
   - 影响: 其他电脑需要同步依赖
   - 操作:
     ```bash
     git add package-lock.json
     git commit -m "chore: 更新依赖锁文件"
     git push origin main
     ```

2. .env.example 需要同步
   - 发现: .env 中有新变量 NEXT_PUBLIC_API_URL
   - 建议: 更新 .env.example 供团队参考
   - 操作:
     ```bash
     # 添加新环境变量到示例文件
     echo "NEXT_PUBLIC_API_URL=https://api.example.com" >> .env.example
     git add .env.example
     git commit -m "docs: 添加新环境变量说明"
     git push origin main
     ```

## 预计耗时: 2 分钟

处理完成后即可安心下班 🎉
```

## 示例 5：.gitignore 优化建议

**用户输入**：
> 检查一下我的 gitignore 配置

**正确处理流程**：

1. 分析项目和当前 .gitignore：
```bash
# 检测项目类型
发现: package.json, next.config.js → Next.js 项目

# 检查当前 .gitignore
当前规则:
- node_modules/
- .next/
```

2. 生成优化建议：
```markdown
🔍 .gitignore 优化建议

## 当前配置
✅ 已忽略: node_modules/, .next/

## 🟡 建议添加的规则

### 开发工具
.DS_Store          # macOS 系统文件
.vscode/           # VS Code 配置
.idea/             # WebStorm 配置
*.swp              # Vim 临时文件

### Next.js 相关
.next/
out/
.vercel/
.env*.local        # 本地环境变量

### 依赖和缓存
node_modules/
.pnpm-store/
.npm/
.yarn/

### 日志和临时文件
*.log
npm-debug.log*
.cache/

### 测试覆盖率
coverage/
.nyc_output/

## 一键应用优化
```bash
cat >> .gitignore <<'EOF'

# 系统文件
.DS_Store
.vscode/
.idea/
*.swp

# Next.js
out/
.vercel/
.env*.local

# 依赖
.pnpm-store/
.npm/
.yarn/

# 日志
*.log
npm-debug.log*

# 测试
coverage/
.nyc_output/
EOF

git add .gitignore
git commit -m "chore: 优化 gitignore 配置"
```

## 🚨 警告: 已跟踪的不该提交的文件
检测到以下文件应该被忽略但已被跟踪:
- .env.local (包含敏感信息)

清理步骤:
```bash
# 从 Git 移除但保留本地文件
git rm --cached .env.local
git commit -m "chore: 移除敏感文件"

# 添加到 .gitignore
echo ".env*.local" >> .gitignore
git add .gitignore
git commit -m "chore: 忽略本地环境变量"
```
```

## 示例 6：项目类型感知建议

**用户输入**：
> 刚拉取了最新代码，需要做什么？

**正确处理流程**：

1. 检测项目类型和变更：
```bash
# 检测到 Python Django 项目
项目文件: requirements.txt, manage.py, settings.py

# 检查变更
git diff HEAD@{1} HEAD --name-only
- requirements.txt (依赖更新)
- migrations/0005_add_user_profile.py (数据库迁移)
- .env.example (环境变量示例)
```

2. 生成项目特定建议：
```markdown
🐍 Python Django 项目 - 更新后操作清单

## 检测到的变更
1. ✅ 依赖更新 (requirements.txt)
2. ✅ 数据库迁移文件
3. ✅ 环境变量配置更新

## 必须执行的操作

### 1. 更新 Python 依赖
```bash
# 激活虚拟环境
source venv/bin/activate  # Linux/Mac
# 或 venv\Scripts\activate  # Windows

# 安装新依赖
pip install -r requirements.txt
```

### 2. 运行数据库迁移
```bash
# 检查迁移状态
python manage.py showmigrations

# 执行迁移
python manage.py migrate

# 验证迁移成功
python manage.py dbshell  # 可选：检查数据库
```

### 3. 更新环境变量
```bash
# 对比新旧配置
diff .env .env.example

# 添加新的环境变量到 .env
# 新增变量: EMAIL_BACKEND, EMAIL_HOST
```

### 4. 验证更新
```bash
# 运行测试
python manage.py test

# 启动开发服务器
python manage.py runserver

# 检查后台管理
open http://localhost:8000/admin
```

## ⚠️ 注意事项
- 数据库迁移不可逆，建议先备份数据
- 如果是生产环境，谨慎执行迁移
- 新依赖可能需要重启服务

## 预计耗时: 5-10 分钟
```

**如果是 React 项目**：
```markdown
⚛️ React 项目 - 更新后操作清单

## 必须执行
```bash
# 安装新依赖
pnpm install

# 检查是否有破坏性更新
git log HEAD@{1}..HEAD --oneline | grep -i "breaking"

# 重启开发服务器
pnpm dev
```

## 建议检查
- [ ] Tailwind 配置是否有更新
- [ ] ESLint 规则是否有变化
- [ ] TypeScript 类型是否需要更新
```

# Version History

## v2.0 (2025-11-17)

### 🚀 新功能
- ✅ 自动检测分支和远程仓库名称
- ✅ 支持批量检查多个仓库
- ✅ AI 驱动的冲突预测算法
- ✅ 智能 .gitignore 检查和优化
- ✅ 项目类型感知建议（前端/后端/全栈）
- ✅ 大文件检测和警告
- ✅ 多格式报告导出（Markdown/HTML/JSON）
- ✅ 时间感知的情境建议（下班/上班）

### 🔧 改进
- 从硬编码 `main` 改为动态检测当前分支
- 从假设 `origin` 改为自动识别远程仓库
- 增强错误处理和边界情况
- 优化批量检查性能

### 📚 文档
- 新增 6 个详细使用示例
- 添加项目类型特定指南
- 补充安全限制说明

## v1.0 (2025-11-17)
- 初始版本