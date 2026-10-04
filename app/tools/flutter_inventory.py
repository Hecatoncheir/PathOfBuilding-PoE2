"""Создать проверяемый реестр исходных модулей для переноса на Flutter."""

import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "app" / "docs" / "flutter"
SECTIONS = {
    "Сборка и библиотека": ["Modules/Build.lua", "Modules/BuildList.lua", "Classes/BuildListControl.lua", "Classes/BuildSetService.lua", "Classes/ExtBuildListProvider.lua", "Classes/PoBArchivesProvider.lua"],
    "Дерево": ["Classes/TreeTab.lua", "Classes/PassiveTreeView.lua", "Classes/PassiveSpec.lua", "Classes/PassiveTree.lua", "Classes/TimelessJewelListControl.lua"],
    "Снаряжение": ["Classes/ItemsTab.lua", "Classes/ItemDBControl.lua", "Classes/ItemListControl.lua", "Classes/ItemSlotControl.lua", "Classes/ItemSetService.lua", "Classes/SharedItemListControl.lua"],
    "Умения": ["Classes/SkillsTab.lua", "Classes/SkillListControl.lua", "Classes/SkillsSetService.lua", "Classes/GemSelectControl.lua"],
    "Условия боя": ["Classes/ConfigTab.lua", "Classes/ConfigSetService.lua"],
    "Расчёты": ["Classes/CalcsTab.lua", "Classes/CalcBreakdownControl.lua", "Classes/CalcSectionControl.lua", "Modules/BuildDisplayStats.lua"],
    "Сравнение и торговля": ["Classes/CompareTab.lua", "Classes/CompareBuySimilar.lua", "Classes/TradeQuery.lua", "Classes/TradeQueryGenerator.lua", "Classes/TradeQueryRequests.lua", "Classes/TradeQueryRateLimiter.lua"],
    "Группа и приспешники": ["Classes/PartyTab.lua", "Classes/MinionListControl.lua", "Classes/MinionSearchListControl.lua"],
    "Импорт и экспорт": ["Classes/ImportTab.lua", "Classes/PoEAPI.lua", "Modules/BuildExportPoE2.lua"],
    "Заметки": ["Classes/NotesTab.lua"],
    "Запуск и настройки": ["Launch.lua", "Modules/Main.lua"],
}


def extract(path):
    source = ROOT / "src" / path
    text = source.read_text(encoding="utf-8-sig")
    controls = {}
    methods = {}
    for line_number, line in enumerate(text.splitlines(), 1):
        for name in re.findall(r"self\.controls\.([A-Za-z_][A-Za-z_0-9]*)", line):
            controls.setdefault(name, line_number)
        match = re.search(r"^function\s+([\w.:]+)\s*\(", line)
        if match:
            methods.setdefault(match.group(1), line_number)
    return {"source": "src/" + path, "controls": controls, "methods": methods}


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    inventory = {section: [extract(path) for path in paths] for section, paths in SECTIONS.items()}
    payload = {"revision": revision, "sections": inventory}
    (OUTPUT / "source-inventory.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = ["# Реестр контролов и методов", "", "Создан командой `python app/tools/flutter_inventory.py`.", "", f"Исходная ревизия: `{revision}`.", "", "Это статическая выборка по выбранным модулям, а не доказательство полного функционального покрытия. Динамические контролы, меню, обработчики клавиш и зависимости требуют ручной проверки. Номера строк указывают первое упоминание, которое может быть обращением, а не объявлением.", ""]
    for section, modules in inventory.items():
        lines.extend(["## " + section, ""])
        for module in modules:
            lines.extend(["### `" + module["source"] + "`", "", "| Элемент | Первая строка | Проверка переноса |", "| --- | --- | --- |"])
            for kind in ("controls", "methods"):
                for name, number in module[kind].items():
                    lines.append(f"| `{kind}: {name}` | {number} | Не проверено |")
            lines.append("")
    (OUTPUT / "source-inventory.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"Модулей: {sum(map(len, inventory.values()))}; реестр: {OUTPUT}")


if __name__ == "__main__":
    main()
