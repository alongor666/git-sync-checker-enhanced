#!/bin/bash
# Git Conflict Checker - 简化版
# 功能：检测本地与远程分支之间可能冲突的文件
# 说明：只报告事实，不进行伪科学的评分

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# 默认值
REMOTE_NAME="${1:-}"
OUTPUT_FORMAT="${2:-text}"  # text 或 json

# 错误处理函数
error_exit() {
    echo -e "${RED}错误: $1${NC}" >&2
    exit 1
}

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir &>/dev/null; then
    error_exit "当前目录不是 Git 仓库"
fi

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    error_exit "无法获取当前分支（可能处于分离头指针状态）"
fi

# 获取远程仓库名
if [ -z "$REMOTE_NAME" ]; then
    REMOTE_NAME=$(git remote | head -n 1 || true)
    if [ -z "$REMOTE_NAME" ]; then
        error_exit "未配置远程仓库"
    fi
fi

# 验证远程仓库存在
if ! git remote get-url "$REMOTE_NAME" &>/dev/null; then
    error_exit "远程仓库 '$REMOTE_NAME' 不存在"
fi

# 输出基本信息（非JSON模式）
if [ "$OUTPUT_FORMAT" = "text" ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "🔍 Git 冲突检查"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "分支: $CURRENT_BRANCH"
    echo "远程: $REMOTE_NAME"
    echo ""
fi

# 获取远程更新（不拉取代码）
if ! git fetch "$REMOTE_NAME" --quiet 2>/dev/null; then
    error_exit "无法从远程仓库 '$REMOTE_NAME' 获取更新（请检查网络连接）"
fi

# 检查远程分支是否存在
if ! git rev-parse --verify "$REMOTE_NAME/$CURRENT_BRANCH" &>/dev/null; then
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        cat <<EOF
{
  "branch": "$CURRENT_BRANCH",
  "remote": "$REMOTE_NAME",
  "remote_branch_exists": false,
  "message": "远程分支不存在，需要首次推送"
}
EOF
    else
        echo -e "${YELLOW}⚠️  远程分支 $REMOTE_NAME/$CURRENT_BRANCH 不存在${NC}"
        echo ""
        echo "这是一个新分支，需要首次推送："
        echo -e "${GREEN}git push -u $REMOTE_NAME $CURRENT_BRANCH${NC}"
    fi
    exit 0
fi

# 检查本地和远程是否已经同步
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse "$REMOTE_NAME/$CURRENT_BRANCH")

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        cat <<EOF
{
  "branch": "$CURRENT_BRANCH",
  "remote": "$REMOTE_NAME",
  "synced": true,
  "conflicts": []
}
EOF
    else
        echo -e "${GREEN}✅ 本地与远程完全同步，无需检查冲突${NC}"
    fi
    exit 0
fi

# 找到共同祖先
BASE_COMMIT=$(git merge-base HEAD "$REMOTE_NAME/$CURRENT_BRANCH" 2>/dev/null || echo "")
if [ -z "$BASE_COMMIT" ]; then
    error_exit "无法找到共同祖先（本地和远程分支可能完全不相关）"
fi

# 获取本地和远程修改的文件列表
LOCAL_FILES=$(git diff --name-only "$BASE_COMMIT" HEAD 2>/dev/null | sort || true)
REMOTE_FILES=$(git diff --name-only "$BASE_COMMIT" "$REMOTE_NAME/$CURRENT_BRANCH" 2>/dev/null | sort || true)

# 检查是否有修改
LOCAL_COUNT=$(echo "$LOCAL_FILES" | grep -c . || echo "0")
REMOTE_COUNT=$(echo "$REMOTE_FILES" | grep -c . || echo "0")

# 找出共同修改的文件
if [ -n "$LOCAL_FILES" ] && [ -n "$REMOTE_FILES" ]; then
    COMMON_FILES=$(comm -12 <(echo "$LOCAL_FILES") <(echo "$REMOTE_FILES") || true)
else
    COMMON_FILES=""
fi
COMMON_COUNT=$(echo "$COMMON_FILES" | grep -c . || echo "0")

# JSON 输出
if [ "$OUTPUT_FORMAT" = "json" ]; then
    # 构建冲突文件数组
    CONFLICT_ARRAY="[]"
    if [ "$COMMON_COUNT" -gt 0 ]; then
        CONFLICT_ARRAY="["
        first=true
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                [ "$first" = false ] && CONFLICT_ARRAY="$CONFLICT_ARRAY,"
                CONFLICT_ARRAY="$CONFLICT_ARRAY\"$file\""
                first=false
            fi
        done <<< "$COMMON_FILES"
        CONFLICT_ARRAY="$CONFLICT_ARRAY]"
    fi

    cat <<EOF
{
  "branch": "$CURRENT_BRANCH",
  "remote": "$REMOTE_NAME",
  "synced": false,
  "local_changes": $LOCAL_COUNT,
  "remote_changes": $REMOTE_COUNT,
  "potential_conflicts": $COMMON_COUNT,
  "conflict_files": $CONFLICT_ARRAY
}
EOF
    exit 0
fi

# 文本输出
echo "📊 状态概览"
echo "本地修改文件: $LOCAL_COUNT 个"
echo "远程修改文件: $REMOTE_COUNT 个"
echo "共同修改文件: $COMMON_COUNT 个"
echo ""

# 判断冲突风险
if [ "$COMMON_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ 低风险${NC}"
    echo "本地和远程没有修改相同的文件，合并应该很顺利。"
    echo ""
    echo -e "${GREEN}建议操作：${NC}"
    echo "git pull $REMOTE_NAME $CURRENT_BRANCH"
elif [ "$COMMON_COUNT" -le 3 ]; then
    echo -e "${YELLOW}⚠️  中等风险${NC}"
    echo "本地和远程修改了相同的文件，可能需要手动解决冲突。"
    echo ""
    echo "⚠️  可能冲突的文件："
    echo "$COMMON_FILES" | while IFS= read -r file; do
        [ -n "$file" ] && echo "  • $file"
    done
    echo ""
    echo -e "${YELLOW}建议操作：${NC}"
    echo "# 1. 备份当前分支"
    echo "git branch backup-$(date +%Y%m%d-%H%M)"
    echo ""
    echo "# 2. 拉取并合并"
    echo "git pull $REMOTE_NAME $CURRENT_BRANCH"
    echo ""
    echo "# 3. 如遇冲突，手动解决后："
    echo "git add <已解决的文件>"
    echo "git commit"
else
    echo -e "${RED}🔴 高风险${NC}"
    echo "本地和远程修改了多个相同的文件，很可能遇到冲突。"
    echo ""
    echo "⚠️  可能冲突的文件："
    echo "$COMMON_FILES" | while IFS= read -r file; do
        [ -n "$file" ] && echo "  • $file"
    done
    echo ""
    echo -e "${RED}建议操作（谨慎）：${NC}"
    echo "# 1. 务必备份当前分支"
    echo "git branch backup-$(date +%Y%m%d-%H%M)"
    echo ""
    echo "# 2. 使用 rebase（推荐，历史更清晰）"
    echo "git fetch $REMOTE_NAME"
    echo "git rebase $REMOTE_NAME/$CURRENT_BRANCH"
    echo ""
    echo "# 或使用 merge（保留分支历史）"
    echo "git merge $REMOTE_NAME/$CURRENT_BRANCH"
    echo ""
    echo "# 3. 解决冲突后"
    echo "git add <已解决的文件>"
    echo "git rebase --continue  # 或 git commit（merge模式）"
fi

# 额外提示：检查关键文件
CRITICAL_FILES=$(echo "$COMMON_FILES" | grep -E "package\.json|package-lock\.json|requirements\.txt|go\.mod|go\.sum|Cargo\.toml|Cargo\.lock|pom\.xml" || true)
if [ -n "$CRITICAL_FILES" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  检测到依赖配置文件冲突：${NC}"
    echo "$CRITICAL_FILES" | while IFS= read -r file; do
        [ -n "$file" ] && echo "  • $file"
    done
    echo ""
    echo "提示：依赖文件冲突解决后，记得重新安装依赖："
    echo "  • package.json → npm install 或 pnpm install"
    echo "  • requirements.txt → pip install -r requirements.txt"
    echo "  • go.mod → go mod download"
    echo "  • Cargo.toml → cargo build"
fi

exit 0
