#!/bin/bash
# Git Sync Checker Enhanced - 更新脚本
# 用于更新已安装的 Skill

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Git Sync Checker Enhanced${NC}"
echo -e "${BLUE}Claude Code Skill 更新器${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""

# 检测安装位置
PERSONAL_SKILL="$HOME/.claude/skills/git-sync-checker-enhanced"
CLI_TOOLS="$HOME/bin/git-sync-tools"

updated=false

# 更新个人 Skill
if [ -d "$PERSONAL_SKILL" ]; then
    echo -e "${YELLOW}发现个人 Skill 安装${NC}"
    echo "位置: $PERSONAL_SKILL"

    if [ -d "$PERSONAL_SKILL/.git" ]; then
        echo -e "${GREEN}通过 Git 更新...${NC}"
        cd "$PERSONAL_SKILL"
        git pull origin main
        echo -e "${GREEN}✅ 个人 Skill 已更新${NC}"
    else
        echo -e "${YELLOW}不是 Git 仓库，跳过更新${NC}"
        echo "建议：删除并重新安装"
        echo "  rm -rf $PERSONAL_SKILL"
        echo "  bash install.sh"
    fi
    updated=true
    echo ""
fi

# 更新命令行工具
if [ -d "$CLI_TOOLS" ]; then
    echo -e "${YELLOW}发现命令行工具安装${NC}"
    echo "位置: $CLI_TOOLS"

    # 检查当前目录是否是源码
    if [ -f "$(pwd)/install.sh" ]; then
        echo -e "${GREEN}从当前目录更新脚本...${NC}"
        cp *.sh "$CLI_TOOLS/"
        chmod +x "$CLI_TOOLS"/*.sh
        echo -e "${GREEN}✅ 命令行工具已更新${NC}"
    else
        echo -e "${YELLOW}无法自动更新，请手动更新${NC}"
        echo "步骤："
        echo "  1. cd 到源码目录"
        echo "  2. 运行 bash update.sh"
    fi
    updated=true
    echo ""
fi

# 检查项目 Skill
echo -e "${YELLOW}检查项目 Skill...${NC}"
if [ -d ".claude/skills/git-sync-checker-enhanced" ]; then
    echo "发现项目 Skill: .claude/skills/git-sync-checker-enhanced"

    if [ -d ".claude/skills/git-sync-checker-enhanced/.git" ]; then
        echo -e "${GREEN}通过 Git 更新...${NC}"
        cd .claude/skills/git-sync-checker-enhanced
        git pull origin main
        cd ../../..
        echo -e "${GREEN}✅ 项目 Skill 已更新${NC}"
    else
        echo -e "${YELLOW}不是 Git 仓库${NC}"
        echo "团队成员应通过 'git pull' 获取更新"
    fi
    updated=true
    echo ""
fi

if [ "$updated" = false ]; then
    echo -e "${RED}未发现任何安装${NC}"
    echo ""
    echo "请先运行安装脚本: bash install.sh"
    exit 1
fi

# 显示版本信息
if [ -f "$PERSONAL_SKILL/CHANGELOG.md" ]; then
    echo -e "${BLUE}==================================${NC}"
    echo -e "${GREEN}最新版本信息${NC}"
    echo -e "${BLUE}==================================${NC}"
    head -20 "$PERSONAL_SKILL/CHANGELOG.md"
fi

echo ""
echo -e "${BLUE}==================================${NC}"
echo -e "${GREEN}更新完成！${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""
echo "查看更新日志: https://github.com/alongor666/git-sync-checker-enhanced/blob/main/CHANGELOG.md"
