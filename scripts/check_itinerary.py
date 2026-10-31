#!/usr/bin/env python3
"""校验 README 逐日行程的星期标注与周一闭馆规则。"""
import re
import sys
from pathlib import Path

README = Path(__file__).resolve().parent.parent / "README.md"
DAY_ORDER = ["一", "二", "三", "四"]
WEEKDAYS = ["一", "二", "三", "四", "五", "六", "日"]
CLOSED_ON_MONDAY = ["故宫", "国家博物馆", "国博"]


def main() -> int:
    text = README.read_text(encoding="utf-8")
    errors = []

    headings = re.findall(r"^##\s*第([一二三四1-4])天（周([一二三四五六日])）", text, re.M)
    if len(headings) != 4:
        errors.append(f"期望 4 个带星期标注的逐日标题，实际 {len(headings)} 个")

    days = [h[0] for h in headings]
    if days != DAY_ORDER:
        errors.append(f"逐日顺序应为 {DAY_ORDER}，实际 {days}")

    weeks = [h[1] for h in headings]
    if len(set(weeks)) != len(weeks):
        errors.append(f"星期标注存在重复：{weeks}")
    for w in weeks:
        if w not in WEEKDAYS:
            errors.append(f"非法星期标注：{w}")

    sections = re.split(r"^##\s*", text, flags=re.M)
    for sec in sections:
        m = re.match(r"第([一二三四1-4])天（周([一二三四五六日])）", sec)
        if not m:
            continue
        if m.group(2) == "一":
            for spot in CLOSED_ON_MONDAY:
                if spot in sec:
                    errors.append(f"周一（第{m.group(1)}天）行程包含周一闭馆景点：{spot}")

    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 1
    print("OK: 四天星期标注齐全、互不重复，周一无闭馆景点冲突")
    return 0


if __name__ == "__main__":
    sys.exit(main())
