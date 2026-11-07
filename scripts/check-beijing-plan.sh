#!/usr/bin/env bash
set -euo pipefail

PLAN="docs/beijing-4d3n-plan.md"

# 结构：文件存在且包含逐日小节与必备小节
test -f "$PLAN"
grep -q '^## ' "$PLAN"
grep -q '第1天' "$PLAN"
grep -q '第2天' "$PLAN"
grep -q '第3天' "$PLAN"
grep -q '第4天' "$PLAN"
grep -q '预约' "$PLAN"
grep -q '体力' "$PLAN"
grep -q '家庭' "$PLAN"
grep -q '避坑' "$PLAN"
grep -q '预算' "$PLAN"
grep -q '备选' "$PLAN"

# 内容深度：字节数与列表条目下限
test "$(wc -m < "$PLAN")" -ge 1500
test "$(grep -c '^- ' "$PLAN")" -ge 20
grep -q '交通' "$PLAN"
grep -q '餐饮' "$PLAN"

# 索引：README 链接
grep -q 'docs/beijing-4d3n-plan.md' README.md

# 一致性：标题天数、逐日小节数量、预算合计
grep -q '4天3晚' "$PLAN"
test "$(grep -Ec '^###? *第[1-4]天' "$PLAN")" -eq 4
grep -Eq '合计|总计' "$PLAN"

echo "beijing plan checks passed"
