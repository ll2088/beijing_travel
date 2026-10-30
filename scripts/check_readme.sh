#!/usr/bin/env bash
set -euo pipefail

README="README.md"

# 结构校验
grep -q '北京4天3晚' "$README"
grep -q '行程' "$README"
grep -q '预约' "$README"
grep -q '美食' "$README"
grep -q '交通' "$README"

# 行程分日校验：恰好 4 个 Day 小节
test "$(grep -c '^### Day' "$README")" -eq 4

# 每天含备选方案
test "$(grep -c '备选' "$README")" -ge 4

# 预约清单校验
grep -q '故宫' "$README"
grep -Eq '提前[0-9]+天|提前[一二三四五六七]天' "$README"

# 预算与交通校验
grep -Eq '预算|人均' "$README"
grep -Eq '地铁|公交|交通' "$README"

# 内容量校验
test "$(wc -m < "$README")" -ge 1500

echo 'README checks passed'
