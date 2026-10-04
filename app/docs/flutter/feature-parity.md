# Функциональное соответствие Flutter

Статус: подготовка переноса. Ни один раздел Flutter пока не реализован. Статический [реестр исходных контролов и методов](source-inventory.md) дополняет эту таблицу; полнота проверяется вручную по работающему приложению.

| ID | Функции | Источник | Экран Flutter | Предлагаемые команды | Проверка | Windows / mobile |
| --- | --- | --- | --- | --- | --- | --- |
| BUILD-01 | Класс, восхождение, уровень, автоматический уровень | Modules/Build.lua | Шапка сборки | setCharacter | Сравнить параметры и точки дерева | Не начато / не начато |
| BUILD-02 | Общие наборы и связи наборов дерева, предметов, умений, условий | BuildSetService, *SetService | Выбор набора | selectLoadout, editLoadout | TestLoadouts, переключение без потери состояния | Не начато / не начато |
| LIB-01 | Создание, сохранение, Save As, папки, архивы, внешние сборки | BuildList, BuildListControl, ExtBuildListProvider, PoBArchivesProvider | Библиотека | listBuilds, openBuild, saveBuild | TestBuildListHelpers + файловые сценарии | Не начато / не начато |
| TREE-01 | Версии дерева, поиск, назначение/возврат, маршруты, оружейные очки | TreeTab, PassiveSpec, PassiveTreeView | Дерево | inspectNode, allocatePath, refundNode | TestTreeTab, TestPassiveSpec, TestWeaponSetPoints | Не начато / не начато |
| TREE-02 | Самоцветы, радиусы, преобразования, timeless, отчёт силы узлов | PassiveTreeView, TimelessJewel*, PowerReportListControl | Дерево + инспектор | inspectJewel, getNodeReport | TestPowerReport + отдельные эталоны | Не начато / не начато |
| ITEM-01 | Все слоты, оружие, наборы, общие предметы, вставка текста, перенос | ItemsTab, ItemSlotControl, ItemSetService | Снаряжение | parseItem, equipItem, selectItemSet | TestItemsTab, TestItemParse, TestItemListControl | Не начато / не начато |
| ITEM-02 | Базы, уникальные, шаблоны, варианты, крафт, качество, модификаторы | ItemsTab, ItemDBControl, Item | Мастерская | searchItems, editItem | TestItemDBControl, TestItemVariants, TestItemMods, TestSocketables | Не начато / не начато |
| SKILL-01 | Группы, поддержки, уровень/качество, наборы, привязки, основное умение | SkillsTab, SkillsSetService, SkillListControl | Умения + инспектор | editSkillGroup, selectMainSkill | TestSkillsTab, TestSkills, TestGemGroupCount, TestTriggers | Не начато / не начато |
| CONFIG-01 | Полный перечень условий, пользовательские модификаторы, наборы | ConfigTab, ConfigSetService | Условия боя | editConfig, selectConfigSet | TestConfigTab, TestCustomModControl, TestDebuffs | Не начато / не начато |
| CALC-01 | Урон, защита, резервирование, источники, части умения, стадии, мины | CalcsTab, BuildDisplayStats, CalcBreakdownControl, Build | Инспектор + расчёты | calculate, getBreakdown, selectSkillPart | TestOffence, TestDefence, TestAttacks, TestAilments, TestFullDPSCache, TestBuildDisplayStats | Не начато / не начато |
| COMPARE-01 | Сравнение сборок, предметов и условий, отчёты улучшений | CompareTab, CompareCalcsHelpers | Сравнение | compareBuilds, previewChange | Эталон двух сборок, неизменность исходной | Не начато / не начато |
| TRADE-01 | Запросы, веса характеристик, похожие предметы, валюты, лимиты | TradeQuery*, CompareBuySimilar, TradeHelpers | Снаряжение + сравнение | createTradeQuery, searchTrade | TestTradeQuery*, TestCompareBuySimilar, TestTradeHelpers | Не начато / не начато |
| PARTY-01 | Группа, поддержка, приспешники, спектры, их параметры | PartyTab, Minion* | Группа + инспектор | editParty, selectMinion | TestPartyTab, TestMinionRage + эталон спектра | Не начато / не начато |
| IMPORT-01 | XML, коды, ссылки, персонажи, повторный импорт | ImportTab, PoEAPI, BuildExportPoE2 | Импорт/экспорт | importBuild, importCharacter, exportBuild | TestImportTab, TestImportReimport, TestBuildExportPoE2, TestUniqueVariantExport, TestPoEAPIAuth | Не начато / не начато |
| NOTES-01 | Заметки и сохранение | NotesTab | Заметки | updateNotes | Открыть → изменить → сохранить → открыть | Не начато / не начато |
| APP-01 | Настройки, обновления, запуск, восстановление, подсказки и горячие клавиши | Launch, Main, UndoHandler, Tooltip, SearchHost | Настройки + оболочка | settings, updateData, undo, redo | TestTooltip, TestSearchHost + ручные платформенные сценарии | Не начато / не начато |

Имена команд — предложения для контракта, а не существующий API. Наличие теста не означает, что он пройден или полностью покрывает строку. Списки параметров и диалоги необходимо развернуть в отдельные сценарии при ручной инвентаризации.

## Проверка каждой функции

1. Найти исходный контрол/обработчик и его условия доступности.
2. Выполнить сценарий в текущем приложении, записать входные данные и результат.
3. Сопоставить команду движка и формат сохранения.
4. Повторить в Flutter мышью/клавиатурой и касанием.
5. Сравнить данные, вычисления, undo/redo и повторное сохранение.
6. Отметить конкретную платформу готовой только после успешной проверки.
