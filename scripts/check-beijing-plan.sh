#!/usr/bin/env bash
set -euo pipefail

PLAN="docs/beijing-4d3n-plan.md"

fail() {
  echo "[FAIL] $1：$2" >&2
  exit 1
}

# 结构：文件存在且包含逐日小节与必备小节
[ -f "$PLAN" ] || fail "结构" "缺少计划文件 $PLAN"
grep -q '^## ' "$PLAN" || fail "结构" "缺少二级标题"
grep -Eq '^###? *Day *1|^###? *第 *1 *天' "$PLAN" || fail "结构" "缺少 Day 1 小节"
grep -Eq '^###? *Day *2|^###? *第 *2 *天' "$PLAN" || fail "结构" "缺少 Day 2 小节"
grep -Eq '^###? *Day *3|^###? *第 *3 *天' "$PLAN" || fail "结构" "缺少 Day 3 小节"
grep -Eq '^###? *Day *4|^###? *第 *4 *天' "$PLAN" || fail "结构" "缺少 Day 4 小节"
grep -q '预约' "$PLAN" || fail "结构" "缺少预约小节"
grep -q '预算' "$PLAN" || fail "结构" "缺少预算小节"
grep -q '备选' "$PLAN" || fail "结构" "缺少备选小节"
echo "[OK] 结构检查通过"

# 内容深度：字节数与列表条目下限
[ "$(wc -c < "$PLAN")" -ge 2000 ] || fail "内容深度" "计划文件不足 2000 字节"
[ "$(grep -c '^- ' "$PLAN")" -ge 20 ] || fail "内容深度" "列表条目少于 20 条"
grep -q '交通' "$PLAN" || fail "内容深度" "缺少交通说明"
grep -q '餐饮' "$PLAN" || fail "内容深度" "缺少餐饮说明"
echo "[OK] 内容深度检查通过"

# 索引：README 链接
grep -q 'docs/beijing-4d3n-plan.md' README.md || fail "索引" "README 缺少计划文档链接"
echo "[OK] 索引检查通过"

# 一致性：标题天数、逐日小节数量、预算合计
grep -q '4天3晚' "$PLAN" || fail "一致性" "标题缺少 4天3晚"
[ "$(grep -Ec '^###? *(Day|第) *[1-4] *(天)?' "$PLAN")" -eq 4 ] || fail "一致性" "逐日小节数量不为 4"
grep -Eq '合计|总计' "$PLAN" || fail "一致性" "缺少预算合计"
echo "[OK] 一致性检查通过"

echo "beijing plan checks passed"
