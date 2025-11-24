#!/bin/bash
# Git Ignore Checker - 简化版
# 功能：检查 .gitignore 配置和潜在问题
# 说明：快速检测敏感文件和大文件

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# 错误处理
error_exit() {
    echo -e "${RED}错误: $1${NC}" >&2
    exit 1
}

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir &>/dev/null; then
    error_exit "当前目录不是 Git 仓库"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "🔍 .gitignore 配置检查"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查 .gitignore 文件是否存在
if [ -f ".gitignore" ]; then
    GITIGNORE_LINES=$(wc -l < .gitignore | tr -d ' ')
    echo -e "${GREEN}✅ 找到 .gitignore 文件${NC} ($GITIGNORE_LINES 行)"
else
    echo -e "${YELLOW}⚠️  未找到 .gitignore 文件${NC}"
    echo ""
    echo "建议："
    echo "  touch .gitignore"
    echo "  # 或访问 https://gitignore.io 生成适合你项目的 .gitignore"
    echo ""
fi

echo ""

# 检查敏感文件
echo "🔒 检查敏感文件..."
echo ""

SENSITIVE_PATTERNS=(
    "\.env$"
    "\.env\.local$"
    "\.env\.production$"
    "\.env\.development$"
    ".*\.key$"
    ".*\.pem$"
    ".*\.p12$"
    ".*\.pfx$"
    ".*\.secret$"
    "id_rsa$"
    "id_dsa$"
    "id_ecdsa$"
    "id_ed25519$"
    "\.aws/credentials$"
    "\.ssh/config$"
    "config/database\.yml$"
    "config/secrets\.yml$"
    "\.npmrc$"
    "\.pypirc$"
)

FOUND_SENSITIVE=false
SENSITIVE_FILES=()

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            SENSITIVE_FILES+=("$file")
            FOUND_SENSITIVE=true
        fi
    done < <(git ls-files | grep -E "$pattern" 2>/dev/null || true)
done

if [ "$FOUND_SENSITIVE" = true ]; then
    echo -e "${RED}⚠️  发现 ${#SENSITIVE_FILES[@]} 个已跟踪的敏感文件：${NC}"
    echo ""
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "  🔴 $file"
    done
    echo ""
    echo -e "${YELLOW}清理步骤：${NC}"
    echo "  # 1. 从 Git 移除（但保留本地文件）"
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "  git rm --cached \"$file\""
    done
    echo ""
    echo "  # 2. 添加到 .gitignore"
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "  echo \"$file\" >> .gitignore"
    done
    echo ""
    echo "  # 3. 提交修改"
    echo "  git commit -m \"chore: 移除敏感文件\""
    echo ""
    echo -e "${RED}警告：${NC}文件仍在 Git 历史中，如需完全清除请使用："
    echo "  git filter-branch 或 BFG Repo-Cleaner"
else
    echo -e "${GREEN}✅ 未发现已跟踪的敏感文件${NC}"
fi

echo ""

# 检查大文件
echo "📦 检查大文件 (>5MB)..."
echo ""

LARGE_FILES=()
LARGE_THRESHOLD=5242880  # 5MB in bytes

while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        # 跨平台文件大小获取
        if [ "$(uname)" = "Darwin" ]; then
            size=$(stat -f%z "$file" 2>/dev/null || echo "0")
        else
            size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        fi

        if [ "$size" -gt "$LARGE_THRESHOLD" ]; then
            size_mb=$(awk "BEGIN {printf \"%.2f\", $size/1024/1024}")
            LARGE_FILES+=("$file:$size_mb")
        fi
    fi
done < <(git ls-files -z 2>/dev/null || true)

if [ "${#LARGE_FILES[@]}" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 ${#LARGE_FILES[@]} 个大文件：${NC}"
    echo ""
    for entry in "${LARGE_FILES[@]}"; do
        file="${entry%:*}"
        size="${entry##*:}"
        echo "  📦 $file (${size}MB)"
    done
    echo ""
    echo -e "${YELLOW}建议：${NC}"
    echo "  1. 使用 Git LFS 管理大文件："
    echo "     git lfs install"
    echo "     git lfs track \"*.zip\" # 示例"
    echo ""
    echo "  2. 或将大文件添加到 .gitignore："
    echo "     echo \"large-file.zip\" >> .gitignore"
    echo "     git rm --cached large-file.zip"
else
    echo -e "${GREEN}✅ 未发现大文件${NC}"
fi

echo ""

# 检查常见问题文件
echo "🔍 检查常见问题..."
echo ""

PROBLEM_PATTERNS=(
    "node_modules"
    "__pycache__"
    ".DS_Store"
    "Thumbs.db"
    "*.swp"
    "*.swo"
    ".vscode"
    ".idea"
)

FOUND_PROBLEMS=false

for pattern in "${PROBLEM_PATTERNS[@]}"; do
    count=$(git ls-files | grep -c "$pattern" 2>/dev/null || echo "0")
    if [ "$count" -gt 0 ]; then
        if [ "$FOUND_PROBLEMS" = false ]; then
            echo -e "${YELLOW}⚠️  发现不应提交的文件：${NC}"
            echo ""
            FOUND_PROBLEMS=true
        fi
        echo "  • $pattern ($count 个文件)"
    fi
done

if [ "$FOUND_PROBLEMS" = true ]; then
    echo ""
    echo -e "${YELLOW}建议：${NC}"
    echo "  将这些模式添加到 .gitignore"
    echo "  访问 https://gitignore.io 获取完整的推荐配置"
else
    echo -e "${GREEN}✅ 未发现常见问题文件${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "检查完成"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 返回适当的退出码
if [ "$FOUND_SENSITIVE" = true ] || [ "${#LARGE_FILES[@]}" -gt 0 ]; then
    exit 1
fi

exit 0
