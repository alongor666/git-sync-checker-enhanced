#!/bin/bash
# Git Batch Checker - 简化版
# 功能：批量检查多个 Git 仓库的同步状态
# 说明：简洁高效，支持并行处理

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# 配置参数
SEARCH_DIR="${1:-.}"
MAX_DEPTH="${2:-3}"
OUTPUT_FORMAT="${3:-text}"  # text, json, simple
TIMEOUT=30  # 每个仓库的检查超时时间（秒）

# 统计计数器
TOTAL_REPOS=0
CLEAN_COUNT=0
WARN_COUNT=0
ERROR_COUNT=0

# 错误处理
error_exit() {
    echo -e "${RED}错误: $1${NC}" >&2
    exit 1
}

# 验证搜索目录
if [ ! -d "$SEARCH_DIR" ]; then
    error_exit "目录不存在: $SEARCH_DIR"
fi

# 输出头部
if [ "$OUTPUT_FORMAT" = "text" ]; then
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "🔍 Git 仓库批量检查"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "搜索目录: $SEARCH_DIR"
    echo "最大深度: $MAX_DEPTH"
    echo ""
fi

# 查找所有 Git 仓库
if [ "$OUTPUT_FORMAT" = "text" ]; then
    echo "正在扫描目录..."
fi

REPOS=$(find "$SEARCH_DIR" -maxdepth "$MAX_DEPTH" -type d -name ".git" 2>/dev/null | sed 's/\/.git$//' || true)

if [ -z "$REPOS" ]; then
    error_exit "未找到任何 Git 仓库"
fi

TOTAL_REPOS=$(echo "$REPOS" | wc -l | tr -d ' ')

if [ "$OUTPUT_FORMAT" = "text" ]; then
    echo "找到 $TOTAL_REPOS 个仓库"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

# 检查单个仓库的函数
check_repo() {
    local repo_path="$1"
    local repo_name
    repo_name=$(basename "$repo_path")

    # 进入仓库目录
    cd "$repo_path" || return 1

    # 获取当前分支
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    # 获取远程仓库
    local remote
    remote=$(git remote 2>/dev/null | head -n 1 || echo "")

    # 检查工作区状态
    local uncommitted=0
    local status
    status=$(git status --porcelain 2>/dev/null || echo "")
    if [ -n "$status" ]; then
        uncommitted=$(echo "$status" | wc -l | tr -d ' ')
    fi

    # 检查未推送和未拉取的提交
    local unpushed=0
    local unpulled=0
    local behind_ahead=""

    if [ -n "$remote" ] && git rev-parse --verify "$remote/$branch" &>/dev/null 2>&1; then
        # 静默获取远程更新
        timeout "$TIMEOUT" git fetch "$remote" --quiet 2>/dev/null || true

        # 计算领先和落后的提交数
        unpushed=$(git rev-list --count "$remote/$branch"..HEAD 2>/dev/null || echo "0")
        unpulled=$(git rev-list --count HEAD.."$remote/$branch" 2>/dev/null || echo "0")

        # 构建状态标识
        [ "$unpushed" -gt 0 ] && behind_ahead="↑$unpushed"
        [ "$unpulled" -gt 0 ] && behind_ahead="${behind_ahead:+$behind_ahead }↓$unpulled"
    fi

    # 检测敏感文件
    local has_sensitive=false
    if echo "$status" | grep -qE "\.env$|\.key$|\.pem$|\.secret$|id_rsa|\.p12$" 2>/dev/null; then
        has_sensitive=true
    fi

    # 判断状态
    local status_icon="✅"
    local status_text="已同步"
    local status_color="$GREEN"

    if [ "$uncommitted" -gt 0 ]; then
        status_icon="🔴"
        status_text="有未提交修改"
        status_color="$RED"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    elif [ "$has_sensitive" = true ]; then
        status_icon="🔴"
        status_text="有敏感文件"
        status_color="$RED"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    elif [ "$unpushed" -gt 0 ] || [ "$unpulled" -gt 0 ]; then
        status_icon="⚠️"
        status_text="需要同步"
        status_color="$YELLOW"
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        CLEAN_COUNT=$((CLEAN_COUNT + 1))
    fi

    # 输出结果（根据格式）
    if [ "$OUTPUT_FORMAT" = "simple" ]; then
        echo "$status_icon $repo_name"
    elif [ "$OUTPUT_FORMAT" = "json" ]; then
        # JSON 格式将在后续统一输出
        echo "{\"name\":\"$repo_name\",\"path\":\"$repo_path\",\"branch\":\"$branch\",\"uncommitted\":$uncommitted,\"unpushed\":$unpushed,\"unpulled\":$unpulled,\"status\":\"$status_text\"}"
    else
        # 文本格式
        printf "${status_color}%-3s${NC} ${BLUE}%-30s${NC} " "$status_icon" "$repo_name"
        printf "%-20s " "($branch)"
        [ -n "$behind_ahead" ] && printf "%s " "$behind_ahead"
        [ "$uncommitted" -gt 0 ] && printf "${RED}+%d${NC} " "$uncommitted"
        [ "$has_sensitive" = true ] && printf "${RED}[敏感]${NC} "
        echo ""
    fi
}

# 存储 JSON 结果
declare -a JSON_RESULTS=()

# 处理所有仓库
ORIGINAL_DIR=$(pwd)

while IFS= read -r repo; do
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        result=$(check_repo "$repo" 2>/dev/null || echo "")
        [ -n "$result" ] && JSON_RESULTS+=("$result")
    else
        check_repo "$repo" 2>/dev/null || echo -e "${RED}✗ $(basename "$repo") - 检查失败${NC}"
    fi
    cd "$ORIGINAL_DIR"
done <<< "$REPOS"

# 输出统计信息
if [ "$OUTPUT_FORMAT" = "text" ]; then
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "📊 检查完成"
    echo ""
    echo "总计: $TOTAL_REPOS 个仓库"
    echo -e "${GREEN}✅ 已同步: $CLEAN_COUNT${NC}"
    echo -e "${YELLOW}⚠️  需要同步: $WARN_COUNT${NC}"
    echo -e "${RED}🔴 需要立即处理: $ERROR_COUNT${NC}"

    # 提供快捷操作建议
    if [ "$WARN_COUNT" -gt 0 ] || [ "$ERROR_COUNT" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}建议：${NC}"
        [ "$ERROR_COUNT" -gt 0 ] && echo "1. 先处理有未提交修改的仓库"
        [ "$WARN_COUNT" -gt 0 ] && echo "2. 推送/拉取需要同步的仓库"
    fi
fi

# JSON 输出
if [ "$OUTPUT_FORMAT" = "json" ]; then
    echo "{"
    echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"search_dir\": \"$SEARCH_DIR\","
    echo "  \"summary\": {"
    echo "    \"total\": $TOTAL_REPOS,"
    echo "    \"clean\": $CLEAN_COUNT,"
    echo "    \"warning\": $WARN_COUNT,"
    echo "    \"error\": $ERROR_COUNT"
    echo "  },"
    echo "  \"repositories\": ["

    first=true
    for result in "${JSON_RESULTS[@]}"; do
        [ "$first" = false ] && echo ","
        echo "    $result"
        first=false
    done

    echo ""
    echo "  ]"
    echo "}"
fi

# 返回适当的退出码
[ "$ERROR_COUNT" -gt 0 ] && exit 2
[ "$WARN_COUNT" -gt 0 ] && exit 1
exit 0
