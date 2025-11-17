#!/bin/bash
# Git Sync Checker Enhanced - 安装脚本
# 用于快速安装到 Claude Code

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Git Sync Checker Enhanced${NC}"
echo -e "${BLUE}Claude Code Skill 安装器${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""

# 检测安装类型
echo -e "${YELLOW}请选择安装类型：${NC}"
echo "1) 个人 Skill（推荐 - 所有项目可用）"
echo "2) 项目 Skill（仅当前项目）"
echo "3) 命令行工具（不使用 Claude Code）"
echo ""
read -p "请输入选项 [1-3]: " choice

case $choice in
    1)
        # 个人 Skill 安装
        INSTALL_DIR="$HOME/.claude/skills/git-sync-checker-enhanced"
        echo ""
        echo -e "${GREEN}安装到个人 Skills 目录...${NC}"

        # 创建目录
        mkdir -p "$HOME/.claude/skills"

        # 检查是否已安装
        if [ -d "$INSTALL_DIR" ]; then
            echo -e "${YELLOW}检测到已安装，是否覆盖？(y/n)${NC}"
            read -p "> " overwrite
            if [ "$overwrite" != "y" ]; then
                echo -e "${RED}安装已取消${NC}"
                exit 1
            fi
            rm -rf "$INSTALL_DIR"
        fi

        # 复制文件
        cp -r "$(pwd)" "$INSTALL_DIR"

        echo -e "${GREEN}✅ 安装完成！${NC}"
        echo ""
        echo "安装位置: $INSTALL_DIR"
        echo ""
        echo -e "${GREEN}下一步：${NC}"
        echo "1. 打开 Claude Code"
        echo "2. 在任何 Git 仓库中尝试：'检查同步状态'"
        ;;

    2)
        # 项目 Skill 安装
        echo ""
        read -p "请输入项目路径（留空使用当前目录）: " project_path

        if [ -z "$project_path" ]; then
            project_path="."
        fi

        INSTALL_DIR="$project_path/.claude/skills/git-sync-checker-enhanced"
        echo ""
        echo -e "${GREEN}安装到项目 Skills 目录...${NC}"

        # 创建目录
        mkdir -p "$project_path/.claude/skills"

        # 检查是否已安装
        if [ -d "$INSTALL_DIR" ]; then
            echo -e "${YELLOW}检测到已安装，是否覆盖？(y/n)${NC}"
            read -p "> " overwrite
            if [ "$overwrite" != "y" ]; then
                echo -e "${RED}安装已取消${NC}"
                exit 1
            fi
            rm -rf "$INSTALL_DIR"
        fi

        # 复制文件
        cp -r "$(pwd)" "$INSTALL_DIR"

        echo -e "${GREEN}✅ 安装完成！${NC}"
        echo ""
        echo "安装位置: $INSTALL_DIR"
        echo ""
        echo -e "${YELLOW}建议：提交到 Git 供团队使用${NC}"
        echo "  cd $project_path"
        echo "  git add .claude/skills/git-sync-checker-enhanced"
        echo "  git commit -m 'feat: 添加 Git 同步检查 Skill'"
        echo "  git push"
        ;;

    3)
        # 命令行工具安装
        INSTALL_DIR="$HOME/bin/git-sync-tools"
        echo ""
        echo -e "${GREEN}安装命令行工具...${NC}"

        # 创建目录
        mkdir -p "$INSTALL_DIR"

        # 复制脚本
        cp *.sh "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR"/*.sh

        # 检查 PATH
        if [[ ":$PATH:" != *":$HOME/bin/git-sync-tools:"* ]]; then
            echo ""
            echo -e "${YELLOW}需要添加到 PATH${NC}"

            # 检测 shell
            if [ -n "$ZSH_VERSION" ]; then
                SHELL_RC="$HOME/.zshrc"
            elif [ -n "$BASH_VERSION" ]; then
                SHELL_RC="$HOME/.bashrc"
            else
                SHELL_RC="$HOME/.profile"
            fi

            echo "export PATH=\"\$HOME/bin/git-sync-tools:\$PATH\"" >> "$SHELL_RC"

            echo ""
            echo -e "${GREEN}✅ 已添加到 $SHELL_RC${NC}"
            echo ""
            echo "请运行: source $SHELL_RC"
        fi

        echo -e "${GREEN}✅ 安装完成！${NC}"
        echo ""
        echo "安装位置: $INSTALL_DIR"
        echo ""
        echo -e "${GREEN}可用命令：${NC}"
        echo "  bash ~/bin/git-sync-tools/conflict-predictor.sh"
        echo "  bash ~/bin/git-sync-tools/batch-checker.sh ~/projects"
        echo "  bash ~/bin/git-sync-tools/gitignore-checker.sh"
        ;;

    *)
        echo -e "${RED}无效选项${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}==================================${NC}"
echo -e "${GREEN}感谢使用 Git Sync Checker!${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""
echo "文档: https://github.com/alongor666/git-sync-checker-enhanced"
echo "反馈: https://github.com/alongor666/git-sync-checker-enhanced/issues"
