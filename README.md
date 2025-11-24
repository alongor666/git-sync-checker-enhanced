# Git Sync Checker

一套简单实用的 Shell 脚本工具，用于检查 Git 仓库的同步状态、预测潜在冲突和检查配置问题。

## 功能特点

- ✅ **冲突检测**: 在合并前检测可能冲突的文件
- ✅ **批量检查**: 一次检查多个 Git 仓库的状态
- ✅ **敏感文件扫描**: 检测已提交的敏感文件（密钥、配置等）
- ✅ **大文件检测**: 发现不应提交的大文件
- ✅ **零依赖**: 纯 Bash 实现，只需要 Git
- ✅ **跨平台**: 支持 macOS 和 Linux

## 快速开始

### 安装

**方式 1: 个人使用（推荐）**

```bash
# 创建个人 skills 目录
mkdir -p ~/.claude/skills

# 克隆项目
git clone https://github.com/alongor666/git-sync-checker-enhanced.git ~/.claude/skills/git-sync-checker-enhanced

# 给脚本添加执行权限
chmod +x ~/.claude/skills/git-sync-checker-enhanced/*.sh
```

**方式 2: 项目共享**

```bash
# 在项目根目录
mkdir -p .claude/skills

# 克隆项目
git clone https://github.com/alongor666/git-sync-checker-enhanced.git .claude/skills/git-sync-checker-enhanced

# 提交到 Git
git add .claude/skills/git-sync-checker-enhanced
git commit -m "Add git sync checker"
```

**方式 3: 直接使用脚本**

```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/alongor666/git-sync-checker-enhanced/main/conflict-predictor.sh
curl -O https://raw.githubusercontent.com/alongor666/git-sync-checker-enhanced/main/batch-checker.sh
curl -O https://raw.githubusercontent.com/alongor666/git-sync-checker-enhanced/main/gitignore-checker.sh

# 添加执行权限
chmod +x *.sh
```

### 基本使用

#### 1. 检查合并冲突

在合并分支或拉取远程更新前，检查是否有潜在冲突：

```bash
cd /path/to/your/repo
bash conflict-predictor.sh

# 指定远程仓库
bash conflict-predictor.sh upstream

# 输出 JSON 格式
bash conflict-predictor.sh origin json
```

**示例输出**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Git 冲突检查
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
分支: feature/new-ui
远程: origin

📊 状态概览
本地修改文件: 5 个
远程修改文件: 3 个
共同修改文件: 2 个

⚠️  中等风险
本地和远程修改了相同的文件，可能需要手动解决冲突。

⚠️  可能冲突的文件：
  • src/components/Header.tsx
  • package.json

建议操作：
# 1. 备份当前分支
git branch backup-20251125-1430

# 2. 拉取并合并
git pull origin feature/new-ui

# 3. 如遇冲突，手动解决后：
git add <已解决的文件>
git commit
```

#### 2. 批量检查仓库

检查某个目录下所有 Git 仓库的状态：

```bash
# 检查当前目录
bash batch-checker.sh .

# 检查指定目录
bash batch-checker.sh ~/projects

# 限制搜索深度
bash batch-checker.sh ~/projects 2

# 输出 JSON 格式
bash batch-checker.sh ~/projects 3 json
```

**示例输出**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Git 仓库批量检查
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
搜索目录: /Users/you/projects
最大深度: 3

找到 5 个仓库

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅  project-a                  (main)
⚠️  project-b                  (dev)                 ↑2
🔴  project-c                  (feature/auth)        +3
✅  project-d                  (main)
⚠️  project-e                  (main)                ↓1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 检查完成

总计: 5 个仓库
✅ 已同步: 2
⚠️  需要同步: 2
🔴 需要立即处理: 1

建议：
1. 先处理有未提交修改的仓库
2. 推送/拉取需要同步的仓库
```

图标说明：
- `✅` - 仓库已同步
- `⚠️` - 有未推送或未拉取的提交
- `🔴` - 有未提交的修改
- `↑N` - N个未推送的提交
- `↓N` - N个未拉取的提交
- `+N` - N个未提交的文件

#### 3. 检查 .gitignore 配置

检查敏感文件和大文件：

```bash
bash gitignore-checker.sh
```

**示例输出**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 .gitignore 配置检查
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 找到 .gitignore 文件 (45 行)

🔒 检查敏感文件...

⚠️  发现 2 个已跟踪的敏感文件：

  🔴 .env
  🔴 config/database.yml

清理步骤：
  # 1. 从 Git 移除（但保留本地文件）
  git rm --cached ".env"
  git rm --cached "config/database.yml"

  # 2. 添加到 .gitignore
  echo ".env" >> .gitignore
  echo "config/database.yml" >> .gitignore

  # 3. 提交修改
  git commit -m "chore: 移除敏感文件"

警告：文件仍在 Git 历史中，如需完全清除请使用：
  git filter-branch 或 BFG Repo-Cleaner

📦 检查大文件 (>5MB)...

⚠️  发现 1 个大文件：

  📦 assets/video.mp4 (12.34MB)

建议：
  1. 使用 Git LFS 管理大文件：
     git lfs install
     git lfs track "*.mp4"

  2. 或将大文件添加到 .gitignore：
     echo "assets/video.mp4" >> .gitignore
     git rm --cached assets/video.mp4
```

## 在 Claude Code 中使用

安装后，你可以在 Claude Code 中通过自然语言调用这些功能：

```
检查同步状态
```

```
我要合并最新代码，会有冲突吗？
```

```
检查 ~/projects 下所有仓库
```

```
检查 gitignore 配置
```

详细的 Claude Code 集成说明请参考 [SKILL.md](SKILL.md)。

## 工作原理

### 冲突预测算法

脚本使用以下步骤预测潜在冲突：

1. 找到本地和远程分支的共同祖先（`git merge-base`）
2. 列出本地修改的文件（`git diff --name-only BASE HEAD`）
3. 列出远程修改的文件（`git diff --name-only BASE REMOTE`）
4. 找出共同修改的文件（两个列表的交集）
5. 根据共同修改的文件数量判断风险级别：
   - 0个：低风险，可以安全合并
   - 1-3个：中等风险，可能需要手动解决冲突
   - >3个：高风险，很可能遇到冲突

**注意**：这是一个简单的启发式算法，不是精确的冲突预测。即使文件相同，如果修改的代码行不重叠，也不会产生冲突。反之，算法说"无风险"也不能100%保证无冲突。

### 批量检查

脚本使用 `find` 命令搜索指定目录下的所有 `.git` 目录，然后对每个仓库执行：

1. 获取当前分支名
2. 检查工作区状态（`git status --porcelain`）
3. 获取远程更新（`git fetch`）
4. 计算未推送的提交数（`git rev-list --count`）
5. 计算未拉取的提交数
6. 检测敏感文件模式

### 敏感文件检测

使用预定义的文件模式列表（如 `\.env$`、`.*\.key$`）检查已被 Git 跟踪的文件。这些模式涵盖常见的敏感文件类型。

## 常见问题

### Q: 冲突预测准确吗？

A: 不是100%准确。脚本只能检测两边是否修改了相同的文件，但无法知道是否修改了相同的代码行。它是一个有用的参考，但不能替代实际的合并测试。

### Q: 批量检查会很慢吗？

A: 对于少量仓库（<20个）通常很快。每个仓库的检查有30秒超时保护。如果有大量仓库，可以通过减少搜索深度来优化。

### Q: 支持哪些平台？

A: macOS 和 Linux。Windows 用户可以在 WSL、Git Bash 或 Cygwin 中使用。

### Q: 需要什么依赖？

A: 只需要 Bash 和 Git。所有脚本都是纯 Shell 实现。

### Q: 脚本会修改我的仓库吗？

A: 不会。所有脚本都是只读的，只检查状态不做修改。唯一的操作是 `git fetch` 获取远程更新（不拉取代码）。

## 项目改进历程

本项目最初存在一些问题：

- ❌ 使用"AI驱动"等误导性宣传
- ❌ 伪科学的冲突评分算法（魔法数字）
- ❌ 过于复杂的项目类型检测
- ❌ 缺乏错误处理

经过重构后：

- ✅ 诚实的功能描述
- ✅ 基于事实的冲突检测（不评分）
- ✅ 简化的核心功能
- ✅ 完善的错误处理和安全性
- ✅ 代码量减少约40%

详细的改进分析请参考 [IMPROVEMENT_PROPOSAL.md](IMPROVEMENT_PROPOSAL.md)。

## 贡献

欢迎提交 Issue 和 Pull Request！

改进建议：
- 性能优化
- 更多的检查功能
- 更好的跨平台支持
- 文档改进

## 许可证

MIT License

## 相关链接

- [Git 官方文档](https://git-scm.com/doc)
- [.gitignore 模板](https://github.com/github/gitignore)
- [gitignore.io](https://gitignore.io) - 生成 .gitignore 文件
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) - 清理 Git 历史

## 致谢

感谢所有提供反馈和建议的用户。特别感谢那些指出项目问题并帮助改进的批评者。
