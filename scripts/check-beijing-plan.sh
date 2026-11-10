#!/usr/bin/env bash
set -euo pipefail

PLAN="docs/beijing-4d3n-plan.md"

# 结构：文件存在且包含逐日小节与必备小节
test -f "$PLAN"
grep -q '^## ' "$PLAN"
grep -Eq '^###? *Day *1|^###? *第 *1 *天' "$PLAN"
grep -Eq '^###? *Day *2|^###? *第 *2 *天' "$PLAN"
grep -Eq '^###? *Day *3|^###? *第 *3 *天' "$PLAN"
grep -Eq '^###? *Day *4|^###? *第 *4 *天' "$PLAN"
grep -q '预约' "$PLAN"
grep -q '预算' "$PLAN"
grep -q '备选' "$PLAN"

# 内容深度：字节数与列表条目下限
test "$(wc -c < "$PLAN")" -ge 2000
test "$(grep -c '^- ' "$PLAN")" -ge 20
grep -q '交通' "$PLAN"
grep -q '餐饮' "$PLAN"

# 索引：README 链接
grep -q 'docs/beijing-4d3n-plan.md' README.md

# README 故宫预约规则：小节存在且包含放票时间与预约方式
README="README.md"
test -f "$README"
grep -q '故宫预约规则' "$README"
grep -q '提前7天每日20:00' "$README"
grep -q '预约渠道' "$README"
grep -q '实名' "$README"

# 一致性：README 与计划文档放票时间表述一致
grep -q '提前 7 天 20:00' "$PLAN"
if ! grep -q '提前7天每日20:00' "$README" || ! grep -q '提前 7 天 20:00' "$PLAN"; then
  echo "故宫放票时间检查失败：README 与计划文档表述不一致" >&2
  exit 1
fi
echo "故宫放票时间检查通过"

# 一致性：标题天数、逐日小节数量、预算合计
grep -q '4天3晚' "$PLAN"
test "$(grep -Ec '^###? *(Day|第) *[1-4] *(天)?' "$PLAN")" -eq 4
grep -Eq '合计|总计' "$PLAN"

echo "beijing plan checks passed"
