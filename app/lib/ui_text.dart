import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

class WorkshopCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const WorkshopCupertinoDelegate();
  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);
  @override
  Future<CupertinoLocalizations> load(Locale locale) => SynchronousFuture(
    locale.languageCode == 'ru'
        ? const _RussianCupertino()
        : const DefaultCupertinoLocalizations(),
  );
  @override
  bool shouldReload(WorkshopCupertinoDelegate old) => false;
}

class _RussianCupertino extends DefaultCupertinoLocalizations {
  const _RussianCupertino();
  @override
  String get copyButtonLabel => 'Копировать';
  @override
  String get cutButtonLabel => 'Вырезать';
  @override
  String get pasteButtonLabel => 'Вставить';
  @override
  String get selectAllButtonLabel => 'Выделить всё';
  @override
  String get modalBarrierDismissLabel => 'Закрыть диалог';
}

class WorkshopMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const WorkshopMaterialDelegate();
  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);
  @override
  Future<MaterialLocalizations> load(Locale locale) => SynchronousFuture(
    locale.languageCode == 'ru'
        ? const _RussianMaterial()
        : const DefaultMaterialLocalizations(),
  );
  @override
  bool shouldReload(WorkshopMaterialDelegate old) => false;
}

class _RussianMaterial extends DefaultMaterialLocalizations {
  const _RussianMaterial();
  @override
  String get backButtonTooltip => 'Назад';
  @override
  String get closeButtonTooltip => 'Закрыть';
  @override
  String get deleteButtonTooltip => 'Удалить';
  @override
  String get moreButtonTooltip => 'Ещё';
  @override
  String get showMenuTooltip => 'Открыть меню';
  @override
  String get cancelButtonLabel => 'Отмена';
  @override
  String get closeButtonLabel => 'Закрыть';
  @override
  String get copyButtonLabel => 'Копировать';
  @override
  String get cutButtonLabel => 'Вырезать';
  @override
  String get pasteButtonLabel => 'Вставить';
  @override
  String get selectAllButtonLabel => 'Выделить всё';
  @override
  String get okButtonLabel => 'ОК';
  @override
  String get saveButtonLabel => 'Сохранить';
  @override
  String get searchFieldLabel => 'Поиск';
  @override
  String get modalBarrierDismissLabel => 'Закрыть диалог';
}

class WorkshopLocale extends InheritedWidget {
  const WorkshopLocale({
    super.key,
    required this.language,
    required super.child,
  });
  final String language;
  static String languageOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorkshopLocale>()?.language ??
      'ru';
  @override
  bool updateShouldNotify(WorkshopLocale oldWidget) =>
      language != oldWidget.language;
}

String tr(BuildContext context, String text) {
  if (WorkshopLocale.languageOf(context) != 'en') return text;
  final exact = englishUi[text];
  if (exact != null) return exact;
  for (final entry in englishUi.entries) {
    if (entry.key.endsWith(' ') && text.startsWith(entry.key)) {
      return entry.value + text.substring(entry.key.length);
    }
  }
  return text;
}

String formatUiNumber(
  BuildContext context,
  num? value, {
  bool percent = false,
}) {
  if (value == null || !value.isFinite) return '—';
  final english = WorkshopLocale.languageOf(context) == 'en';
  final parts = value
      .toStringAsFixed(value == value.roundToDouble() ? 0 : 2)
      .split('.');
  final groups = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => english ? ',' : '\u202f',
  );
  return '$groups${parts.length == 2 ? '${english ? '.' : ','}${parts.last}' : ''}${percent ? '%' : ''}';
}

const englishUi = <String, String>{
  'Мастерская сборок': 'Build workshop',
  'Дерево пассивных умений': 'Passive skill tree',
  'Предупреждения': 'Warnings',
  'Результат Lua · ревизия ': 'Lua result · revision ',
  'Рецепт: ': 'Recipe: ',
  'Основа': 'Base',
  'Редкость': 'Rarity',
  'узлов': 'nodes',
  'Результаты поиска': 'Search results',
  'Команды сборки': 'Build commands',
  'Расчёты': 'Calculations',
  'Условия боя': 'Configuration',
  'Импорт / экспорт': 'Import / export',
  'Дерево': 'Passive tree',
  'Снаряжение': 'Equipment',
  'Умения': 'Skills',
  'Сравнение': 'Compare',
  'Группа': 'Party',
  'Заметки': 'Notes',
  'Сохранить в библиотеку': 'Save to library',
  'Копировать сборку': 'Copy build',
  'Переименовать сборку': 'Rename build',
  'Название сборки': 'Build name',
  'Папка (необязательно)': 'Folder (optional)',
  'Поиск сборок': 'Search builds',
  'Библиотека пока пуста': 'The library is empty',
  'Обновить': 'Refresh',
  'Новая сборка': 'New build',
  'Не сохранено': 'Unsaved',
  'Создать': 'Create',
  'От 1 до 100, ручной режим': 'From 1 to 100, manual mode',
  'Недавние сборки': 'Recent builds',
  'Есть несохранённые изменения': 'Unsaved changes',
  'Продолжить без сохранения': 'Continue without saving',
  'В полях есть неприменённый текст. Сохранение XML его не включает.':
      'Some fields contain unapplied text. Saving XML does not include it.',
  'Сохранить текущую сборку перед открытием другой?':
      'Save the current build before opening another?',
  'Мои сборки': 'My builds',
  'Поиск раздела': 'Find a section',
  'Поиск раздела · Ctrl+K': 'Find a section · Ctrl+K',
  'Раздел не найден': 'No matching section',
  '↑ ↓ — выбор · Enter — открыть · Esc — закрыть':
      '↑ ↓ select · Enter open · Esc close',
  'Отмена': 'Cancel',
  'Сохранить': 'Save',
  'Удалить': 'Delete',
  'Закрыть': 'Close',
  'Новый': 'New',
  'Копия': 'Duplicate',
  'Переименовать': 'Rename',
  'Сбросить': 'Reset',
  'Экспорт': 'Export',
  'Импорт сборки': 'Import build',
  'Импорт': 'Import',
  'Условия': 'Config',
  'Урон в секунду': 'Damage per second',
  'Здоровье': 'Life',
  'Мана': 'Mana',
  'Энерг. щит': 'Energy shield',
  'Дух': 'Spirit',
  'Огонь': 'Fire',
  'Холод': 'Cold',
  'Молния': 'Lightning',
  'Хаос': 'Chaos',
  'ВАША СБОРКА': 'YOUR BUILD',
  'ПУЛЬС СБОРКИ': 'BUILD PULSE',
  'Всё важное рядом': 'Everything within reach',
  'Откройте сборку': 'Open a build',
  'Основное умение': 'Main skill',
  'Активное умение': 'Active skill',
  'Открыть расчёты →': 'Open calculations →',
  'Результат оригинального движка Lua': 'Calculated by the original Lua engine',
  'Показать показатели': 'Show build stats',
  'Скрыть показатели': 'Hide build stats',
  'Уровень': 'Level',
  '◈ Мастерская сборок': '◈ Build workshop',
  'Редакторы снаряжения, умений, группы и заметок ещё переносятся из Lua.':
      'Further editors are being ported from Lua.',
  'Выбрать тему': 'Choose theme',
  'Как в системе': 'Follow system',
  'Настройки интерфейса': 'Interface settings',
  'Язык интерфейса': 'Interface language',
  'Уменьшить движение': 'Reduce motion',
  'Ширина навигации': 'Navigation width',
  'Ширина показателей': 'Stats panel width',
  'Изменить ширину панели': 'Resize panel',
  'ПЛАНИРУЙТЕ. ПРОБУЙТЕ. СРАВНИВАЙТЕ.': 'PLAN. EXPLORE. COMPARE.',
  'Оригинальные данные Lua': 'Original Lua data',
  'Редактор будет подключён на следующем этапе.':
      'Editing will be connected in a later stage.',
  'Нет данных для отображения': 'No data to display',
  'Название': 'Name',
  'Значение': 'Value',
  'Предметы текущей сборки': 'Items in this build',
  'Группы умений': 'Skill groups',
  'Отменить изменение': 'Undo build change',
  'Повторить изменение': 'Redo build change',
  'Восстановить последнюю сессию': 'Restore last session',
  'Подключение к Lua…': 'Connecting to Lua…',
  'Lua подключён': 'Lua connected',
  'Запустите из репозитория': 'Run from the repository',
  'Откройте сборку для загрузки дерева':
      'Open a build to load its passive tree',
  'Модификаторы PoB': 'PoB modifiers',
  'Применить и пересчитать': 'Apply and recalculate',
  'Полный путь XML-файла': 'Full XML file path',
  'Открыть файл': 'Open file',
  'Сохранить файл': 'Save file',
  'Укажите путь файла': 'Choose a file path',
  'Заменить существующий файл?': 'Replace the existing file?',
  'Заменить': 'Replace',
  'XML сборки': 'Build XML',
  'Открыть XML': 'Open XML',
  'Получить XML': 'Export XML',
  'Открыть эталон Fireball': 'Open Fireball reference',
  'Windows-прототип · Python + Lua. Остальные редакторы ещё не перенесены.':
      'Windows preview · Python + Lua. Further editors are still being ported.',
  'Не удалось сохранить тему: ': 'Could not save theme: ',
  'Не удалось сохранить состояние панели: ': 'Could not save panel state: ',
  'Не удалось сохранить настройки: ': 'Could not save settings: ',
  'Ошибка загрузки: ': 'Loading failed: ',
  'Не удалось рассчитать подсказку: ': 'Could not calculate tooltip: ',
  'Вернуть узел': 'Refund node',
  'Вернуть узел и зависимые узлы': 'Refund node and dependants',
  'Всё дерево': 'Fit tree',
  'Выберите атрибут': 'Choose attribute',
  'Выберите эффект мастерства': 'Choose mastery effect',
  'Дерево пустое': 'The tree is empty',
  'Дополнительное действие': 'More actions',
  'Заметка к узлу': 'Node note',
  'Интеллект': 'Intelligence',
  'Сила': 'Strength',
  'Ловкость': 'Dexterity',
  'Класс, набор и оружейные режимы': 'Class, tree set and weapon mode',
  'Назначить путь': 'Allocate path',
  'Назначить путь к узлу': 'Allocate path to node',
  'Перетаскивание · колесо / pinch zoom':
      'Drag to pan · scroll / pinch to zoom',
  'Поиск по названию и свойствам': 'Search names and properties',
  'Текстуры этой версии недоступны':
      'Textures for this version are unavailable',
  'Увеличить дерево': 'Zoom in',
  'Уменьшить дерево': 'Zoom out',
  'Удерживайте 2 / S, 3 / D или 1 / I при нажатии.\nПКМ меняет атрибут назначенного узла.': 'Hold 2 / S, 3 / D or 1 / I while clicking.\nRight-click changes an allocated attribute.',
  'ЛКМ — назначить / вернуть · ПКМ — атрибут · СКМ — перемещение · Shift — проложить путь': 'Left-click allocate / refund · Right-click attribute · Middle-click pan · Shift trace path',
  'Без сравнения': 'No comparison',
  'Восхождение': 'Ascendancy',
  'Класс': 'Class',
  'В сборке пока нет подходящих самоцветов. Вставьте текст предмета ниже.':
      'No suitable jewels in this build. Paste item text below.',
  'Все назначения будут удалены. Отмена доступна через историю сборки.':
      'All allocations will be removed. You can undo this change.',
  'Вставить в гнездо': 'Socket jewel',
  'Действие можно отменить через историю сборки.': 'You can undo this change.',
  'Изменить класс': 'Change class',
  'Можно соединить дерево со стартом нового класса или сбросить назначенные умения. Изменение сохраняется в истории отмены.': 'Connect to the new class start or reset allocated skills. You can undo this change.',
  'Набор 1': 'Set 1',
  'Набор 2': 'Set 2',
  'Набор дерева': 'Tree set',
  'Название набора': 'Set name',
  'Настройки дерева': 'Tree settings',
  'Общее': 'Shared',
  'Оружейный режим назначения': 'Weapon allocation mode',
  'Очистить гнездо': 'Clear socket',
  'Самоцвет в гнезде': 'Socketed jewel',
  'Сбросить дерево': 'Reset tree',
  'Сбросить дерево?': 'Reset the tree?',
  'Сбросить назначения': 'Reset allocations',
  'Соединить путь': 'Connect path',
  'Сравнить с набором': 'Compare with set',
  'Текст самоцвета из игры / PoB': 'Jewel text from the game / PoB',
  'Удалить набор дерева?': 'Delete this tree set?',
  'F1 — открыть полную подсказку': 'F1 — open full tooltip',
  'ЛКМ — назначить / вернуть · ПКМ — атрибут\nCtrl — скрыть · Ctrl+C — копировать · Ctrl+D — сравнение': 'Left-click allocate / refund · Right-click attribute\nCtrl hide · Ctrl+C copy · Ctrl+D compare',
};
