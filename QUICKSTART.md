# 快速开始指南

5分钟上手 Git Sync Checker。

## 1. 安装（30秒）

```bash
# 克隆项目
git clone https://github.com/alongor666/git-sync-checker-enhanced.git
cd git-sync-checker-enhanced

# 添加执行权限
chmod +x *.sh

# 运行测试（可选）
bash test.sh
```

## 2. 三个核心功能

### 功能 1: 检查合并冲突（最常用）

**什么时候用**：在 `git pull` 或 `git merge` 之前

```bash
bash conflict-predictor.sh
```

**输出示例**：
```
⚠️  中等风险
共同修改文件: 2 个

可能冲突的文件：
  • src/app.ts
  • package.json
```

### 功能 2: 批量检查仓库

**什么时候用**：管理多个项目

```bash
bash batch-checker.sh ~/projects
```

**输出示例**：
```
✅  project-a    (main)
⚠️  project-b    (dev)      ↑2
🔴  project-c    (feature)  +3
```

图标含义：
- `↑2` = 2个未推送的提交
- `↓1` = 1个未拉取的提交
- `+3` = 3个未提交的文件

### 功能 3: 检查敏感文件

**什么时候用**：确保不提交密钥和配置

```bash
bash gitignore-checker.sh
```

**输出示例**：
```
⚠️  发现 1 个已跟踪的敏感文件：
  🔴 .env

清理步骤：
  git rm --cached ".env"
  echo ".env" >> .gitignore
  git commit -m "chore: 移除敏感文件"
```

## 3. 在 Claude Code 中使用

安装为 Claude Code Skill：

```bash
# 安装到个人 skills 目录
mkdir -p ~/.claude/skills
cp -r git-sync-checker-enhanced ~/.claude/skills/
```

然后在 Claude Code 中说：

```
检查同步状态
```

```
我要合并最新代码，会有冲突吗？
```

```
检查 ~/projects 下所有仓库
```

## 4. 常用场景

### 场景 1: 下班前检查

```bash
# 检查工作区是否干净
git status

# 检查是否有未推送的提交
bash conflict-predictor.sh

# 推送代码
git push
```

### 场景 2: 开始工作前

```bash
# 检查远程更新
git fetch

# 检查冲突风险
bash conflict-predictor.sh

# 拉取最新代码
git pull
```

### 场景 3: 代码审查前

```bash
# 检查是否有不该提交的文件
bash gitignore-checker.sh

# 检查所有项目
bash batch-checker.sh ~/work
```

## 5. 故障排除

### 问题: "权限被拒绝"

```bash
chmod +x *.sh
```

### 问题: "未找到远程仓库"

```bash
git remote -v  # 查看远程配置
git remote add origin <url>  # 添加远程仓库
```

### 问题: "当前目录不是 Git 仓库"

```bash
cd /path/to/your/git/repo
```

## 6. 进阶使用

### JSON 输出（供脚本使用）

```bash
bash conflict-predictor.sh origin json
bash batch-checker.sh ~/projects 3 json
```

### 自定义搜索深度

```bash
# 只搜索 2 层目录
bash batch-checker.sh ~/projects 2
```

### 检查特定远程仓库

```bash
bash conflict-predictor.sh upstream
```

## 需要帮助？

- 完整文档：[README.md](README.md)
- Claude Code 集成：[SKILL.md](SKILL.md)
- 改进历程：[IMPROVEMENT_PROPOSAL.md](IMPROVEMENT_PROPOSAL.md)
- 问题反馈：[GitHub Issues](https://github.com/alongor666/git-sync-checker-enhanced/issues)
