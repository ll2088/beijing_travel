import re
from pathlib import Path

README = Path(__file__).resolve().parents[1] / "README.md"


def read_readme():
    return README.read_text(encoding="utf-8")


def test_required_sections_exist():
    text = read_readme()
    for heading in ["行前准备与预约规则", "风险提示", "预算参考", "备选方案"]:
        assert heading in text
    assert re.search(r"^## 第一天", text, re.M)
    assert re.search(r"^## 第二天", text, re.M)
    assert re.search(r"^## 第三天", text, re.M)
    assert re.search(r"^## 第四天", text, re.M)


def test_key_rules_defined_once():
    text = read_readme()
    assert text.count("周一闭馆") == 1
    assert text.count("提前7天") == 1
    assert text.count("实名预约") == 1


def test_daily_itinerary_has_four_days():
    text = read_readme()
    for day in ["Day1", "Day2", "Day3", "Day4"]:
        assert day in text
    assert "周一" not in re.sub(r"周一闭馆", "", text)


def test_budget_and_alternatives():
    text = read_readme()
    assert "预算参考" in text
    assert "备选方案" in text
    assert "若故宫预约失败" in text
