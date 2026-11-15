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

# 一致性：标题天数、逐日小节数量、预算合计
grep -q '4天3晚' "$PLAN"
test "$(grep -Ec '^###? *(Day|第) *[1-4] *(天)?' "$PLAN")" -eq 4
grep -Eq '合计|总计' "$PLAN"

# 日期锚点：README 与计划文档均须包含 Day1–Day4 具体日期（2025-XX-XX 或 X月X日）
for f in README.md "$PLAN"; do
  grep -Eq '2025-[0-9]{2}-[0-9]{2}|[0-9]{1,2}月[0-9]{1,2}日' "$f"
done
grep -q '2025-09-11' README.md
grep -q '2025-09-11' "$PLAN"
grep -q '2025-09-14' README.md
grep -q '2025-09-14' "$PLAN"

# 倒排节点：D-7、D-3、D-1 必须同时出现，且每个节点关联具体日期或 Day 编号
for f in README.md "$PLAN"; do
  grep -q 'D-7' "$f"
  grep -q 'D-3' "$f"
  grep -q 'D-1' "$f"
  grep -Eq 'D-7[^|]*\|[^|]*(2025-[0-9]{2}-[0-9]{2}|Day *[1-4])' "$f"
  grep -Eq 'D-3[^|]*\|[^|]*(2025-[0-9]{2}-[0-9]{2}|Day *[1-4])' "$f"
  grep -Eq 'D-1[^|]*\|[^|]*(2025-[0-9]{2}-[0-9]{2}|Day *[1-4])' "$f"
done

# 周一闭馆规则：须显式声明，且闭馆日不得安排需预约场馆
for f in README.md "$PLAN"; do
  grep -q '周一闭馆' "$f"
done
grep -Eq '周四至周日|不含周一' README.md
grep -Eq '周四至周日|不含周一' "$PLAN"

# 需预约场馆：每个场馆须同时给出预约开放日、倒排提醒日与对应日期
for f in README.md "$PLAN"; do
  grep -q '预约开放日' "$f"
  grep -q '倒排提醒日' "$f"
  grep -q '对应日期' "$f"
  for venue in 故宫博物院 天安门广场 颐和园 天坛公园 中国科学技术馆 慕田峪长城 恭王府; do
    grep -q "$venue" "$f"
  done
done

# 日期自洽：D-7 早于 Day1，D-1 晚于 Day4 之前且早于 Day1
python3 - <<'PY'
import re, sys

def load(path):
    with open(path, encoding='utf-8') as fh:
        return fh.read()

def check(path):
    text = load(path)
    day1 = re.search(r'Day1[^0-9]*(\d{4}-\d{2}-\d{2})', text)
    day4 = re.search(r'Day4[^0-9]*(\d{4}-\d{2}-\d{2})', text)
    d7 = re.search(r'D-7[^|]*\|\s*(\d{4}-\d{2}-\d{2})', text)
    d3 = re.search(r'D-3[^|]*\|\s*(\d{4}-\d{2}-\d{2})', text)
    d1 = re.search(r'D-1[^|]*\|\s*(\d{4}-\d{2}-\d{2})', text)
    if not all([day1, day4, d7, d3, d1]):
        print(f'{path}: missing date anchors', file=sys.stderr)
        return False
    from datetime import date
    def parse(m):
        y, mo, d = map(int, m.group(1).split('-'))
        return date(y, mo, d)
    day1d, day4d = parse(day1), parse(day4)
    d7d, d3d, d1d = parse(d7), parse(d3), parse(d1)
    ok = d7d < day1d and d3d < day1d and d1d < day1d and d7d < d3d < d1d and day1d <= day4d
    if not ok:
        print(f'{path}: date anchors inconsistent', file=sys.stderr)
    return ok

ok = check('README.md') and check('docs/beijing-4d3n-plan.md')
sys.exit(0 if ok else 1)
PY

echo "beijing plan checks passed"
