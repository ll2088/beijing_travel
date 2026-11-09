#!/usr/bin/env bash
set -euo pipefail

PLAN="docs/beijing-4d3n-plan.md"

fail() {
  echo "CHECK FAILED: $*" >&2
  exit 1
}

# 固定字符串匹配，避免正则元字符与全角/半角差异导致误判
has() {
  local file="$1" pattern="$2" label="$3"
  grep -Fq -- "$pattern" "$file" || fail "$label: 文件 $file 缺少固定字符串 [$pattern]"
}

# 结构：文件存在且包含逐日小节与必备小节
test -f "$PLAN" || fail "计划文档不存在: $PLAN"
grep -q '^## ' "$PLAN" || fail "计划文档缺少二级标题"
grep -Eq '^###? *Day *1|^###? *第 *1 *天' "$PLAN" || fail "计划文档缺少 Day 1 小节"
grep -Eq '^###? *Day *2|^###? *第 *2 *天' "$PLAN" || fail "计划文档缺少 Day 2 小节"
grep -Eq '^###? *Day *3|^###? *第 *3 *天' "$PLAN" || fail "计划文档缺少 Day 3 小节"
grep -Eq '^###? *Day *4|^###? *第 *4 *天' "$PLAN" || fail "计划文档缺少 Day 4 小节"
has "$PLAN" '预约' '计划文档必备词'
has "$PLAN" '预算' '计划文档必备词'
has "$PLAN" '备选' '计划文档必备词'

# 内容深度：字节数与列表条目下限
test "$(wc -c < "$PLAN")" -ge 2000 || fail "计划文档字节数不足 2000"
test "$(grep -c '^- ' "$PLAN")" -ge 20 || fail "计划文档列表条目不足 20"
has "$PLAN" '交通' '计划文档必备词'
has "$PLAN" '餐饮' '计划文档必备词'

# 索引：README 链接
has README.md 'docs/beijing-4d3n-plan.md' 'README 计划文档链接'

# README 故宫预约规则小节必备条目
README_FC_SECTION=$(awk '/^- 故宫预约规则：/{flag=1} flag{print} /^- 天安门广场：/{flag=0}' README.md)
test -n "$README_FC_SECTION" || fail "README 缺少故宫预约规则小节（以 '- 故宫预约规则：' 起始、'- 天安门广场：' 结束）"
for field in '放票时间' '证件要求' '闭馆日'; do
  echo "$README_FC_SECTION" | grep -Fq -- "$field" || {
    echo "--- README 故宫小节实际内容 ---" >&2
    echo "$README_FC_SECTION" >&2
    fail "README 故宫小节缺少必备条目 [$field]"
  }
done

# README 与计划文档故宫规则关键字段一致性
for field in '放票时间' '证件要求' '闭馆日'; do
  has README.md "$field" 'README 故宫字段'
  has "$PLAN" "$field" '计划文档故宫字段'
done
has README.md '提前7天' 'README 放票提前量'
has "$PLAN" '提前 7 天' '计划文档放票提前量'
has README.md '20:00' 'README 放票时间点'
has "$PLAN" '20:00' '计划文档放票时间点'
has README.md '身份证' 'README 证件类型'
has "$PLAN" '身份证' '计划文档证件类型'
has README.md '周一闭馆' 'README 闭馆日'
has "$PLAN" '周一闭馆' '计划文档闭馆日'

# 一致性：标题天数、逐日小节数量、预算合计
has "$PLAN" '4天3晚' '计划文档标题天数'
test "$(grep -Ec '^###? *(Day|第) *[1-4] *(天)?' "$PLAN")" -eq 4 || fail "计划文档逐日小节数量不为 4"
grep -Eq '合计|总计' "$PLAN" || fail "计划文档缺少预算合计/总计"

echo "beijing plan checks passed"
