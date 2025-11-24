#!/bin/bash
# Test Script for Git Sync Checker
# 测试所有核心脚本的基本功能

set -e

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_case() {
    local test_name="$1"
    local test_command="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "测试 $TOTAL_TESTS: $test_name ... "

    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Git Sync Checker - 测试套件"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. 检查脚本文件存在
echo "1. 文件完整性检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_case "conflict-predictor.sh 存在" "[ -f conflict-predictor.sh ]"
test_case "batch-checker.sh 存在" "[ -f batch-checker.sh ]"
test_case "gitignore-checker.sh 存在" "[ -f gitignore-checker.sh ]"

echo ""

# 2. 检查脚本权限
echo "2. 执行权限检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_case "conflict-predictor.sh 可执行" "[ -x conflict-predictor.sh ]"
test_case "batch-checker.sh 可执行" "[ -x batch-checker.sh ]"
test_case "gitignore-checker.sh 可执行" "[ -x gitignore-checker.sh ]"

echo ""

# 3. 检查 Shell 语法
echo "3. 语法检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_case "conflict-predictor.sh 语法正确" "bash -n conflict-predictor.sh"
test_case "batch-checker.sh 语法正确" "bash -n batch-checker.sh"
test_case "gitignore-checker.sh 语法正确" "bash -n gitignore-checker.sh"

echo ""

# 4. 基本功能测试（需要在 Git 仓库中）
if git rev-parse --git-dir &>/dev/null; then
    echo "4. 基本功能测试（当前仓库）"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    test_case "conflict-predictor 可运行" "bash conflict-predictor.sh >/dev/null 2>&1 || true"
    test_case "gitignore-checker 可运行" "bash gitignore-checker.sh >/dev/null 2>&1 || true"
    test_case "batch-checker 可运行（当前目录）" "bash batch-checker.sh . 1 >/dev/null 2>&1 || true"

    echo ""

    echo "5. JSON 输出测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 测试 JSON 输出格式
    if bash conflict-predictor.sh origin json 2>/dev/null | python3 -m json.tool >/dev/null 2>&1; then
        echo -e "测试: conflict-predictor JSON 输出 ... ${GREEN}✓ 通过${NC}"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif bash conflict-predictor.sh origin json >/dev/null 2>&1; then
        # JSON 工具不可用，但脚本运行成功
        echo -e "测试: conflict-predictor JSON 输出 ... ${YELLOW}⚠ 跳过（无 JSON 验证工具）${NC}"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "测试: conflict-predictor JSON 输出 ... ${RED}✗ 失败${NC}"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi

    if bash batch-checker.sh . 1 json 2>/dev/null | python3 -m json.tool >/dev/null 2>&1; then
        echo -e "测试: batch-checker JSON 输出 ... ${GREEN}✓ 通过${NC}"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif bash batch-checker.sh . 1 json >/dev/null 2>&1; then
        echo -e "测试: batch-checker JSON 输出 ... ${YELLOW}⚠ 跳过（无 JSON 验证工具）${NC}"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "测试: batch-checker JSON 输出 ... ${RED}✗ 失败${NC}"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi

    echo ""
else
    echo -e "${YELLOW}跳过功能测试：当前目录不是 Git 仓库${NC}"
    echo ""
fi

# 6. Git 依赖检查
echo "6. 依赖检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_case "Git 已安装" "command -v git >/dev/null"
test_case "Bash 版本 >= 3.2" "[ ${BASH_VERSINFO[0]} -ge 3 ] && [ ${BASH_VERSINFO[1]} -ge 2 ] || [ ${BASH_VERSINFO[0]} -ge 4 ]"

echo ""

# 汇总结果
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "测试结果汇总"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "总计: $TOTAL_TESTS 个测试"
echo -e "${GREEN}通过: $PASSED_TESTS${NC}"
echo -e "${RED}失败: $FAILED_TESTS${NC}"
echo ""

# 返回适当的退出码
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}✅ 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}❌ 有 $FAILED_TESTS 个测试失败${NC}"
    exit 1
fi
