# Реестр контролов и методов

Создан командой `python app/tools/flutter_inventory.py`.

Исходная ревизия: `327ca895ea765f8398fe265a3921ba5ef3994262`.

Это статическая выборка по выбранным модулям, а не доказательство полного функционального покрытия. Динамические контролы, меню, обработчики клавиш и зависимости требуют ручной проверки. Номера строк указывают первое упоминание, которое может быть обращением, а не объявлением.

## Сборка и библиотека

### `src/Modules/Build.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: back` | 110 | Не проверено |
| `controls: save` | 117 | Не проверено |
| `controls: saveAs` | 123 | Не проверено |
| `controls: buildName` | 134 | Не проверено |
| `controls: pointDisplay` | 138 | Не проверено |
| `controls: levelScalingButton` | 138 | Не проверено |
| `controls: characterLevel` | 138 | Не проверено |
| `controls: classDrop` | 246 | Не проверено |
| `controls: ascendDrop` | 273 | Не проверено |
| `controls: buildLoadouts` | 279 | Не проверено |
| `controls: modeImport` | 325 | Не проверено |
| `controls: modeNotes` | 330 | Не проверено |
| `controls: modeConfig` | 334 | Не проверено |
| `controls: modeTree` | 338 | Не проверено |
| `controls: modeSkills` | 342 | Не проверено |
| `controls: modeItems` | 346 | Не проверено |
| `controls: modeCalcs` | 350 | Не проверено |
| `controls: modeParty` | 354 | Не проверено |
| `controls: modeCompare` | 358 | Не проверено |
| `controls: mainSkillLabel` | 363 | Не проверено |
| `controls: mainSocketGroup` | 364 | Не проверено |
| `controls: mainSkill` | 376 | Не проверено |
| `controls: statSet` | 382 | Не проверено |
| `controls: mainSkillPart` | 390 | Не проверено |
| `controls: mainSkillStageCountLabel` | 397 | Не проверено |
| `controls: mainSkillStageCount` | 399 | Не проверено |
| `controls: mainSkillMineCountLabel` | 409 | Не проверено |
| `controls: mainSkillMineCount` | 411 | Не проверено |
| `controls: mainSkillMinion` | 421 | Не проверено |
| `controls: mainSkillMinionLibrary` | 462 | Не проверено |
| `controls: mainSkillBeastLibrary` | 465 | Не проверено |
| `controls: mainSkillMinionSkill` | 468 | Не проверено |
| `controls: mainSkillMinionSkillStatSet` | 475 | Не проверено |
| `controls: statBoxAnchor` | 484 | Не проверено |
| `controls: statBox` | 485 | Не проверено |
| `controls: warnings` | 488 | Не проверено |
| `controls: breakdown` | 531 | Не проверено |
| `controls: secondaryAscendDrop` | 1384 | Не проверено |
| `methods: buildMode:Init` | 34 | Не проверено |
| `methods: buildMode:SyncLoadouts` | 637 | Не проверено |
| `methods: buildMode:NewLoadout` | 779 | Не проверено |
| `methods: buildMode:CopyLoadout` | 793 | Не проверено |
| `methods: buildMode:CustomLoadout` | 809 | Не проверено |
| `methods: buildMode:DeleteLoadout` | 849 | Не проверено |
| `methods: buildMode:RenameLoadout` | 881 | Не проверено |
| `methods: buildMode:GetLoadoutByName` | 899 | Не проверено |
| `methods: buildMode:SetActiveLoadout` | 956 | Не проверено |
| `methods: buildMode:ReorderLoadout` | 982 | Не проверено |
| `methods: buildMode:EstimatePlayerProgress` | 1025 | Не проверено |
| `methods: buildMode:CanExit` | 1105 | Не проверено |
| `methods: buildMode:Shutdown` | 1113 | Не проверено |
| `methods: buildMode:GetArgs` | 1129 | Не проверено |
| `methods: buildMode:CloseBuild` | 1133 | Не проверено |
| `methods: buildMode:Load` | 1138 | Не проверено |
| `methods: buildMode:Save` | 1180 | Не проверено |
| `methods: buildMode:ResetModFlags` | 1272 | Не проверено |
| `methods: buildMode:OnFrame` | 1285 | Не проверено |
| `methods: buildMode:SetDisplayStat` | 1479 | Не проверено |
| `methods: buildMode:ClearDisplayStat` | 1513 | Не проверено |
| `methods: buildMode:UpdateClassDropdowns` | 1519 | Не проверено |
| `methods: buildMode:OpenConversionPopup` | 1543 | Не проверено |
| `methods: buildMode:OpenSavePopup` | 1570 | Не проверено |
| `methods: buildMode:OpenSaveAsPopup` | 1599 | Не проверено |
| `methods: buildMode:OpenSpectreLibrary` | 1656 | Не проверено |
| `methods: buildMode:OpenSimilarPopup` | 2017 | Не проверено |
| `methods: buildMode:RefreshSkillSelectControls` | 2059 | Не проверено |
| `methods: buildMode:FormatStat` | 2197 | Не проверено |
| `methods: buildMode:BuildBreakdownIndex` | 2226 | Не проверено |
| `methods: buildMode:GetSidebarBreakdown` | 2278 | Не проверено |
| `methods: buildMode:GetStatBreakdownKey` | 2334 | Не проверено |
| `methods: buildMode:AddDisplayStatList` | 2375 | Не проверено |
| `methods: buildMode:InsertItemWarnings` | 2513 | Не проверено |
| `methods: buildMode:RefreshStatList` | 2542 | Не проверено |
| `methods: buildMode:CompareStatList` | 2585 | Не проверено |
| `methods: buildMode:AddStatComparesToTooltip` | 2628 | Не проверено |
| `methods: buildMode:LoadDB` | 2691 | Не проверено |
| `methods: buildMode:LoadDBFile` | 2731 | Не проверено |
| `methods: buildMode:SaveDB` | 2746 | Не проверено |
| `methods: buildMode:SaveDBFile` | 2773 | Не проверено |
| `methods: buildMode:OpenBuildSetManagePopup` | 2805 | Не проверено |

### `src/Modules/BuildList.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: buildList` | 20 | Не проверено |
| `controls: ExtBuildList` | 23 | Не проверено |
| `controls: new` | 48 | Не проверено |
| `controls: newFolder` | 51 | Не проверено |
| `controls: open` | 54 | Не проверено |
| `controls: copy` | 58 | Не проверено |
| `controls: rename` | 62 | Не проверено |
| `controls: delete` | 66 | Не проверено |
| `controls: sort` | 70 | Не проверено |
| `controls: searchText` | 105 | Не проверено |
| `methods: listMode:Init` | 15 | Не проверено |
| `methods: listMode:getPublicBuilds` | 120 | Не проверено |
| `methods: listMode:Shutdown` | 137 | Не проверено |
| `methods: listMode:GetArgs` | 140 | Не проверено |
| `methods: listMode:OnFrame` | 144 | Не проверено |
| `methods: listMode:GetDestName` | 193 | Не проверено |
| `methods: listMode:BuildList` | 210 | Не проверено |
| `methods: listMode:FilterBuildList` | 216 | Не проверено |
| `methods: listMode:SortList` | 224 | Не проверено |

### `src/Classes/BuildListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: path` | 24 | Не проверено |
| `methods: BuildListClass:BuildListControl` | 16 | Не проверено |
| `methods: BuildListClass:SelByFullFileName` | 65 | Не проверено |
| `methods: BuildListClass:LoadBuild` | 78 | Не проверено |
| `methods: BuildListClass:NewFolder` | 86 | Не проверено |
| `methods: BuildListClass:RenameBuild` | 95 | Не проверено |
| `methods: BuildListClass:DeleteBuild` | 162 | Не проверено |
| `methods: BuildListClass:GetRowValue` | 191 | Не проверено |
| `methods: BuildListClass:GetDragValue` | 226 | Не проверено |
| `methods: BuildListClass:CanReceiveDrag` | 230 | Не проверено |
| `methods: BuildListClass:ReceiveDrag` | 234 | Не проверено |
| `methods: BuildListClass:CanDragToValue` | 255 | Не проверено |
| `methods: BuildListClass:OnSelClick` | 259 | Не проверено |
| `methods: BuildListClass:OnSelCopy` | 267 | Не проверено |
| `methods: BuildListClass:OnSelCut` | 272 | Не проверено |
| `methods: BuildListClass:OnSelDelete` | 277 | Не проверено |
| `methods: BuildListClass:OnSelKeyDown` | 281 | Не проверено |

### `src/Classes/BuildSetService.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: BuildSetServiceClass:BuildSetService` | 9 | Не проверено |
| `methods: BuildSetServiceClass:NewLoadout` | 14 | Не проверено |
| `methods: BuildSetServiceClass:CopyLoadout` | 18 | Не проверено |
| `methods: BuildSetServiceClass:RenameLoadout` | 22 | Не проверено |
| `methods: BuildSetServiceClass:DeleteLoadout` | 27 | Не проверено |
| `methods: BuildSetServiceClass:CustomLoadout` | 34 | Не проверено |
| `methods: BuildSetServiceClass:ReorderLoadout` | 38 | Не проверено |
| `methods: BuildSetServiceClass:SpecNameLookup` | 42 | Не проверено |

### `src/Classes/ExtBuildListProvider.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: ExtBuildListProviderClass:ExtBuildListProvider` | 16 | Не проверено |
| `methods: ExtBuildListProviderClass:GetPageUrl` | 25 | Не проверено |
| `methods: ExtBuildListProviderClass:Activate` | 29 | Не проверено |
| `methods: ExtBuildListProviderClass:SetActiveList` | 35 | Не проверено |
| `methods: ExtBuildListProviderClass:GetActiveList` | 46 | Не проверено |
| `methods: ExtBuildListProviderClass:GetListTitles` | 50 | Не проверено |
| `methods: ExtBuildListProviderClass:GetActivePageUrl` | 54 | Не проверено |
| `methods: ExtBuildListProviderClass:GetBuilds` | 58 | Не проверено |
| `methods: ExtBuildListProviderClass:SetImportCode` | 62 | Не проверено |

### `src/Classes/PoBArchivesProvider.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: PoBArchivesProviderClass:PoBArchivesProvider` | 15 | Не проверено |
| `methods: PoBArchivesProviderClass:GetApiUrl` | 27 | Не проверено |
| `methods: PoBArchivesProviderClass:GetPageUrl` | 35 | Не проверено |
| `methods: PoBArchivesProviderClass:GetRecommendations` | 51 | Не проверено |
| `methods: PoBArchivesProviderClass:ParseBuilds` | 93 | Не проверено |
| `methods: PoBArchivesProviderClass:GetBuilds` | 130 | Не проверено |

## Дерево

### `src/Classes/TreeTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: specSelect` | 55 | Не проверено |
| `controls: compareCheck` | 122 | Не проверено |
| `controls: compareSelect` | 125 | Не проверено |
| `controls: reset` | 127 | Не проверено |
| `controls: versionText` | 172 | Не проверено |
| `controls: versionSelect` | 173 | Не проверено |
| `controls: treeSearch` | 184 | Не проверено |
| `controls: findTimelessJewel` | 193 | Не проверено |
| `controls: treeHeatMap` | 198 | Не проверено |
| `controls: treeHeatMapStatSelect` | 200 | Не проверено |
| `controls: powerReportList` | 203 | Не проверено |
| `controls: nodePowerMaxDepthSelect` | 208 | Не проверено |
| `controls: nodePowerMaxDepthCustom` | 213 | Не проверено |
| `controls: powerReport` | 268 | Не проверено |
| `controls: specConvertText` | 326 | Не проверено |
| `controls: specConvert` | 339 | Не проверено |
| `controls: specConvertAll` | 342 | Не проверено |
| `methods: TreeTabClass:TreeTab` | 38 | Не проверено |
| `methods: TreeTabClass:Draw` | 351 | Не проверено |
| `methods: TreeTabClass:GetSpecList` | 485 | Не проверено |
| `methods: TreeTabClass:Load` | 493 | Не проверено |
| `methods: TreeTabClass:PostLoad` | 522 | Не проверено |
| `methods: TreeTabClass:Save` | 528 | Не проверено |
| `methods: TreeTabClass:SetActiveSpec` | 541 | Не проверено |
| `methods: TreeTabClass:SetCompareSpec` | 581 | Не проверено |
| `methods: TreeTabClass:ConvertToVersion` | 588 | Не проверено |
| `methods: TreeTabClass:ConvertAllToVersion` | 613 | Не проверено |
| `methods: TreeTabClass:OpenSpecManagePopup` | 628 | Не проверено |
| `methods: TreeTabClass:CopyTree` | 650 | Не проверено |
| `methods: TreeTabClass:OpenVersionConvertPopup` | 662 | Не проверено |
| `methods: TreeTabClass:OpenVersionConvertAllPopup` | 681 | Не проверено |
| `methods: TreeTabClass:OpenImportPopup` | 695 | Не проверено |
| `methods: TreeTabClass:OpenExportPopup` | 822 | Не проверено |
| `methods: TreeTabClass:ModifyAttributePopup` | 851 | Не проверено |
| `methods: TreeTabClass:SaveMasteryPopup` | 878 | Не проверено |
| `methods: TreeTabClass:OpenMasteryPopup` | 897 | Не проверено |
| `methods: TreeTabClass:SetPowerCalc` | 924 | Не проверено |
| `methods: TreeTabClass:BuildPowerReportList` | 932 | Не проверено |
| `methods: TreeTabClass:FindTimelessJewel` | 1050 | Не проверено |

### `src/Classes/PassiveTreeView.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: PassiveTreeViewClass:PassiveTreeView` | 28 | Не проверено |
| `methods: PassiveTreeViewClass:Load` | 60 | Не проверено |
| `methods: PassiveTreeViewClass:Save` | 78 | Не проверено |
| `methods: PassiveTreeViewClass:GetCompareJewel` | 91 | Не проверено |
| `methods: PassiveTreeViewClass:GetJewelSocketOverlay` | 104 | Не проверено |
| `methods: PassiveTreeViewClass:GetCompareNodeColor` | 148 | Не проверено |
| `methods: PassiveTreeViewClass:Draw` | 172 | Не проверено |
| `methods: PassiveTreeViewClass:DrawAsset` | 1374 | Не проверено |
| `methods: PassiveTreeViewClass:DrawImageRotated` | 1398 | Не проверено |
| `methods: PassiveTreeViewClass:DrawQuadAndRotate` | 1459 | Не проверено |
| `methods: PassiveTreeViewClass:Zoom` | 1501 | Не проверено |
| `methods: PassiveTreeViewClass:Focus` | 1517 | Не проверено |
| `methods: PassiveTreeViewClass:DoesNodeMatchSearchParams` | 1528 | Не проверено |
| `methods: PassiveTreeViewClass:AddNodeName` | 1623 | Не проверено |
| `methods: PassiveTreeViewClass:AddNodeTooltip` | 1686 | Не проверено |
| `methods: PassiveTreeViewClass:IsConnectedToWeaponSetNodes` | 2097 | Не проверено |
| `methods: PassiveTreeViewClass:AddGlobalNodeWarningsToTooltip` | 2123 | Не проверено |
| `methods: PassiveTreeViewClass:DrawAllocMode` | 2156 | Не проверено |
| `methods: PassiveTreeViewClass:checkUnlockConstraints` | 2179 | Не проверено |

### `src/Classes/PassiveSpec.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: PassiveSpecClass:PassiveSpec` | 33 | Не проверено |
| `methods: PassiveSpecClass:Init` | 45 | Не проверено |
| `methods: PassiveSpecClass:Load` | 117 | Не проверено |
| `methods: PassiveSpecClass:Save` | 252 | Не проверено |
| `methods: PassiveSpecClass:PostLoad` | 381 | Не проверено |
| `methods: PassiveSpecClass:ImportFromNodeList` | 386 | Не проверено |
| `methods: PassiveSpecClass:AllocateDecodedNodes` | 442 | Не проверено |
| `methods: PassiveSpecClass:AllocateMasteryEffects` | 461 | Не проверено |
| `methods: PassiveSpecClass:DecodePoePlannerURL` | 505 | Не проверено |
| `methods: PassiveSpecClass:DecodeURL` | 590 | Не проверено |
| `methods: PassiveSpecClass:EncodeURL` | 637 | Не проверено |
| `methods: PassiveSpecClass:SelectClass` | 689 | Не проверено |
| `methods: PassiveSpecClass:ResetAscendClass` | 714 | Не проверено |
| `methods: PassiveSpecClass:SelectAscendClass` | 726 | Не проверено |
| `methods: PassiveSpecClass:SelectSecondaryAscendClass` | 746 | Не проверено |
| `methods: PassiveSpecClass:IsClassConnected` | 786 | Не проверено |
| `methods: PassiveSpecClass:ConnectToClass` | 810 | Не проверено |
| `methods: PassiveSpecClass:ResetNodes` | 884 | Не проверено |
| `methods: PassiveSpecClass:CanPathThroughAllocMode` | 897 | Не проверено |
| `methods: PassiveSpecClass:GetAllocationPath` | 903 | Не проверено |
| `methods: PassiveSpecClass:GetEffectiveAllocationPath` | 961 | Не проверено |
| `methods: PassiveSpecClass:AllocNode` | 988 | Не проверено |
| `methods: PassiveSpecClass:DeallocSingleNode` | 1037 | Не проверено |
| `methods: PassiveSpecClass:DeallocNode` | 1048 | Не проверено |
| `methods: PassiveSpecClass:CountAllocNodes` | 1063 | Не проверено |
| `methods: PassiveSpecClass:FindStartFromNode` | 1094 | Не проверено |
| `methods: PassiveSpecClass:GetJewel` | 1127 | Не проверено |
| `methods: PassiveSpecClass:ResolveGrantedPassiveNodes` | 1150 | Не проверено |
| `methods: PassiveSpecClass:SetGrantedPassiveNodes` | 1224 | Не проверено |
| `methods: PassiveSpecClass:CollectGrantedPassiveNodesFromItems` | 1256 | Не проверено |
| `methods: PassiveSpecClass:SetNodeDistanceToClassStart` | 1311 | Не проверено |
| `methods: PassiveSpecClass:AddMasteryEffectOptionsToNode` | 1352 | Не проверено |
| `methods: PassiveSpecClass:NodesInIntuitiveLeapLikeRadius` | 1369 | Не проверено |
| `methods: PassiveSpecClass:BuildNodePathsToRootNodes` | 1404 | Не проверено |
| `methods: PassiveSpecClass:BuildAllDependsAndPaths` | 1475 | Не проверено |
| `methods: PassiveSpecClass:ReplaceNode` | 2080 | Не проверено |
| `methods: PassiveSpecClass:ReconnectNodeToClassStart` | 2100 | Не проверено |
| `methods: PassiveSpecClass:BuildClusterJewelGraphs` | 2110 | Не проверено |
| `methods: PassiveSpecClass:BuildSubgraph` | 2175 | Не проверено |
| `methods: PassiveSpecClass:CreateUndoState` | 2597 | Не проверено |
| `methods: PassiveSpecClass:RestoreUndoState` | 2632 | Не проверено |
| `methods: PassiveSpecClass:SetWindowTitleWithBuildClass` | 2648 | Не проверено |
| `methods: PassiveSpecClass:NodeAdditionOrReplacementFromString` | 2656 | Не проверено |
| `methods: PassiveSpecClass:NodeInKeystoneRadius` | 2739 | Не проверено |
| `methods: PassiveSpecClass:SwitchAttributeNode` | 2751 | Не проверено |

### `src/Classes/PassiveTree.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: PassiveTreeClass:PassiveTree` | 59 | Не проверено |
| `methods: PassiveTreeClass:ProcessStats` | 467 | Не проверено |
| `methods: PassiveTreeClass:ProcessNode` | 547 | Не проверено |
| `methods: PassiveTreeClass:LoadImage` | 617 | Не проверено |
| `methods: PassiveTreeClass:BuildConnector` | 630 | Не проверено |
| `methods: PassiveTreeClass:BuildArc` | 746 | Не проверено |
| `methods: PassiveTreeClass:CalcOrbitAngles` | 788 | Не проверено |
| `methods: PassiveTreeClass:GetAssetByName` | 812 | Не проверено |
| `methods: PassiveTreeClass:GetNodeTargetSize` | 821 | Не проверено |

### `src/Classes/TimelessJewelListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: TimelessJewelListControlClass:TimelessJewelListControl` | 15 | Не проверено |
| `methods: TimelessJewelListControlClass:Draw` | 24 | Не проверено |
| `methods: TimelessJewelListControlClass:SetHighlightColor` | 29 | Не проверено |
| `methods: TimelessJewelListControlClass:OverrideSelectIndex` | 48 | Не проверено |
| `methods: TimelessJewelListControlClass:GetRowValue` | 59 | Не проверено |
| `methods: TimelessJewelListControlClass:AddValueTooltip` | 65 | Не проверено |
| `methods: TimelessJewelListControlClass:OnSelClick` | 96 | Не проверено |

## Снаряжение

### `src/Classes/ItemsTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: setSelect` | 161 | Не проверено |
| `controls: setLabel` | 175 | Не проверено |
| `controls: setManage` | 176 | Не проверено |
| `controls: priceDisplayItem` | 181 | Не проверено |
| `controls: specSelect` | 313 | Не проверено |
| `controls: specButton` | 324 | Не проверено |
| `controls: specLabel` | 328 | Не проверено |
| `controls: slotHeader` | 346 | Не проверено |
| `controls: weaponSwap1` | 347 | Не проверено |
| `controls: weaponSwap2` | 358 | Не проверено |
| `controls: weaponSwapLabel` | 369 | Не проверено |
| `controls: itemList` | 373 | Не проверено |
| `controls: selectDBLabel` | 379 | Не проверено |
| `controls: uniqueButton` | 386 | Не проверено |
| `controls: rareButton` | 392 | Не проверено |
| `controls: uniqueDB` | 398 | Не проверено |
| `controls: rareDB` | 407 | Не проверено |
| `controls: craftDisplayItem` | 416 | Не проверено |
| `controls: newDisplayItem` | 422 | Не проверено |
| `controls: displayItemTip` | 425 | Не проверено |
| `controls: sharedItemList` | 438 | Не проверено |
| `controls: addDisplayItem` | 447 | Не проверено |
| `controls: editDisplayItem` | 453 | Не проверено |
| `controls: removeDisplayItem` | 456 | Не проверено |
| `controls: displayItemBuySimilar` | 460 | Не проверено |
| `controls: displayItemSectionVariant` | 470 | Не проверено |
| `controls: displayItemVariant` | 492 | Не проверено |
| `controls: displayItemBaseVariant` | 492 | Не проверено |
| `controls: displayItemVersion` | 504 | Не проверено |
| `controls: displayItemAltVariant` | 547 | Не проверено |
| `controls: displayItemAltVariant2` | 554 | Не проверено |
| `controls: displayItemAltVariant3` | 561 | Не проверено |
| `controls: displayItemAltVariant4` | 568 | Не проверено |
| `controls: displayItemAltVariant5` | 575 | Не проверено |
| `controls: displayItemSectionSockets` | 606 | Не проверено |
| `controls: displayItemSocketRune` | 609 | Не проверено |
| `controls: displayItemSocketRuneEdit` | 613 | Не проверено |
| `controls: displayItemSocketJewel` | 628 | Не проверено |
| `controls: displayItemSocketJewelEdit` | 629 | Не проверено |
| `controls: displayItemSectionEnchant` | 641 | Не проверено |
| `controls: displayItemAnoint` | 642 | Не проверено |
| `controls: displayItemCorrupt` | 642 | Не проверено |
| `controls: displayItemAnoint2` | 650 | Не проверено |
| `controls: displayItemAnoint3` | 657 | Не проверено |
| `controls: displayItemAnoint4` | 664 | Не проверено |
| `controls: displayItemSectionQuality` | 679 | Не проверено |
| `controls: displayItemQuality` | 680 | Не проверено |
| `controls: displayItemQualityEdit` | 680 | Не проверено |
| `controls: displayItemSectionCatalyst` | 697 | Не проверено |
| `controls: displayItemCatalyst` | 698 | Не проверено |
| `controls: displayItemCatalystQualityEdit` | 698 | Не проверено |
| `controls: displayItemSectionClusterJewel` | 756 | Не проверено |
| `controls: displayItemClusterJewelSkill` | 757 | Не проверено |
| `controls: displayItemClusterJewelNodeCountLabel` | 768 | Не проверено |
| `controls: displayItemClusterJewelNodeCount` | 769 | Не проверено |
| `controls: displayItemSectionRune` | 777 | Не проверено |
| `controls: displayItemSectionCraftingSort` | 861 | Не проверено |
| `controls: craftingSortingLabel` | 864 | Не проверено |
| `controls: craftingSorting` | 866 | Не проверено |
| `controls: displayItemSectionAffix` | 873 | Не проверено |
| `controls: displayItemSectionCustom` | 1118 | Не проверено |
| `controls: displayItemAddCustom` | 1119 | Не проверено |
| `controls: displayItemSectionRange` | 1129 | Не проверено |
| `controls: displayItemRangeLine` | 1140 | Не проверено |
| `controls: displayItemRangeSlider` | 1141 | Не проверено |
| `controls: displayItemTooltipAnchor` | 1185 | Не проверено |
| `controls: scrollBarH` | 1188 | Не проверено |
| `controls: scrollBarV` | 1189 | Не проверено |
| `methods: ItemsTabClass:ItemsTab` | 140 | Не проверено |
| `methods: ItemsTabClass:Load` | 1220 | Не проверено |
| `methods: ItemsTabClass:Save` | 1349 | Не проверено |
| `methods: ItemsTabClass:Draw` | 1441 | Не проверено |
| `methods: ItemsTabClass:CreateItemSet` | 1599 | Не проверено |
| `methods: ItemsTabClass:NewItemSet` | 1619 | Не проверено |
| `methods: ItemsTabClass:CopyItemSet` | 1626 | Не проверено |
| `methods: ItemsTabClass:RenameItemSet` | 1637 | Не проверено |
| `methods: ItemsTabClass:DeleteItemSet` | 1649 | Не проверено |
| `methods: ItemsTabClass:SetActiveItemSet` | 1656 | Не проверено |
| `methods: ItemsTabClass:EquipItemInSet` | 1701 | Не проверено |
| `methods: ItemsTabClass:PopulateSlots` | 1733 | Не проверено |
| `methods: ItemsTabClass:UpdateSockets` | 1740 | Не проверено |
| `methods: ItemsTabClass:GetSocketAndJewelForNodeID` | 1763 | Не проверено |
| `methods: ItemsTabClass:AddItem` | 1768 | Не проверено |
| `methods: ItemsTabClass:AddDisplayItem` | 1809 | Не проверено |
| `methods: ItemsTabClass:SortItemList` | 1820 | Не проверено |
| `methods: ItemsTabClass:DeleteItem` | 1857 | Не проверено |
| `methods: ItemsTabClass:CopyAnointsAndAugments` | 1914 | Не проверено |
| `methods: ItemsTabClass:CreateDisplayItemFromRaw` | 1998 | Не проверено |
| `methods: ItemsTabClass:SelectDisplayItemVariant` | 2010 | Не проверено |
| `methods: ItemsTabClass:UpdateDisplayItemVariantControls` | 2027 | Не проверено |
| `methods: ItemsTabClass:SetDisplayItem` | 2096 | Не проверено |
| `methods: ItemsTabClass:UpdateDisplayItemTooltip` | 2162 | Не проверено |
| `methods: ItemsTabClass:ToggleDisplayItemModLine` | 2168 | Не проверено |
| `methods: ItemsTabClass:UpdateClusterJewelControls` | 2183 | Не проверено |
| `methods: ItemsTabClass:CraftClusterJewel` | 2210 | Не проверено |
| `methods: ItemsTabClass:UpdateAffixControls` | 2232 | Не проверено |
| `methods: ItemsTabClass:GetValidRunesForItem` | 2285 | Не проверено |
| `methods: ItemsTabClass:IsSocketBoundRune` | 2325 | Не проверено |
| `methods: ItemsTabClass:UpdateRuneControls` | 2338 | Не проверено |
| `methods: ItemsTabClass:UpdateAffixControl` | 2368 | Не проверено |
| `methods: ItemsTabClass:UpdateCustomControls` | 2521 | Не проверено |
| `methods: ItemsTabClass:UpdateDisplayItemRangeLines` | 2564 | Не проверено |
| `methods: ItemsTabClass:AddModComparisonTooltip` | 2590 | Не проверено |
| `methods: ItemsTabClass:GetEquippedSlotForItem` | 2607 | Не проверено |
| `methods: ItemsTabClass:GetComparisonSlotNameForItem` | 2623 | Не проверено |
| `methods: ItemsTabClass:IsItemValidForSlot` | 2640 | Не проверено |
| `methods: ItemsTabClass:ValidateWeaponSlots` | 2727 | Не проверено |
| `methods: ItemsTabClass:OpenItemSetManagePopup` | 2749 | Не проверено |
| `methods: ItemsTabClass:CraftItem` | 2762 | Не проверено |
| `methods: ItemsTabClass:EditDisplayItemText` | 2871 | Не проверено |
| `methods: ItemsTabClass:getAnoint` | 2928 | Не проверено |
| `methods: ItemsTabClass:anointItem` | 2949 | Не проверено |
| `methods: ItemsTabClass:AppendAnointTooltip` | 2966 | Не проверено |
| `methods: ItemsTabClass:AppendAddedNotableTooltip` | 3009 | Не проверено |
| `methods: ItemsTabClass:AnointDisplayItem` | 3019 | Не проверено |
| `methods: ItemsTabClass:CorruptDisplayItem` | 3059 | Не проверено |
| `methods: ItemsTabClass:AddCustomModifierToDisplayItem` | 3361 | Не проверено |
| `methods: ItemsTabClass:AddItemSetTooltip` | 3660 | Не проверено |
| `methods: ItemsTabClass:SetTooltipHeaderInfluence` | 3671 | Не проверено |
| `methods: ItemsTabClass:FormatItemSource` | 3698 | Не проверено |
| `methods: ItemsTabClass:AddItemTooltip` | 3705 | Не проверено |
| `methods: ItemsTabClass:CreateUndoState` | 4549 | Не проверено |
| `methods: ItemsTabClass:RestoreUndoState` | 4566 | Не проверено |

### `src/Classes/ItemDBControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: slot` | 43 | Не проверено |
| `controls: type` | 46 | Не проверено |
| `controls: sort` | 50 | Не проверено |
| `controls: league` | 53 | Не проверено |
| `controls: requirement` | 56 | Не проверено |
| `controls: obtainable` | 59 | Не проверено |
| `controls: search` | 63 | Не проверено |
| `controls: searchMode` | 66 | Не проверено |
| `methods: ItemDBClass:ItemDBControl` | 25 | Не проверено |
| `methods: ItemDBClass:LoadLeaguesAndTypes` | 74 | Не проверено |
| `methods: ItemDBClass:DoesItemMatchFilters` | 94 | Не проверено |
| `methods: ItemDBClass:SetSortMode` | 210 | Не проверено |
| `methods: ItemDBClass:BuildSortOrder` | 216 | Не проверено |
| `methods: ItemDBClass:ListBuilder` | 242 | Не проверено |
| `methods: ItemDBClass:Draw` | 300 | Не проверено |
| `methods: ItemDBClass:GetRowValue` | 327 | Не проверено |
| `methods: ItemDBClass:AddValueTooltip` | 333 | Не проверено |
| `methods: ItemDBClass:GetDragValue` | 343 | Не проверено |
| `methods: ItemDBClass:OnSelClick` | 347 | Не проверено |
| `methods: ItemDBClass:OnSelCopy` | 384 | Не проверено |
| `methods: ItemDBClass:OnHoverKeyUp` | 388 | Не проверено |

### `src/Classes/ItemListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: loadoutFilter` | 22 | Не проверено |
| `controls: sort` | 26 | Не проверено |
| `controls: deleteUnused` | 30 | Не проверено |
| `controls: deleteAll` | 53 | Не проверено |
| `controls: delete` | 76 | Не проверено |
| `methods: ItemListClass:ItemListControl` | 17 | Не проверено |
| `methods: ItemListClass:UpdateLoadoutList` | 85 | Не проверено |
| `methods: ItemListClass:UpdateList` | 119 | Не проверено |
| `methods: ItemListClass:Draw` | 194 | Не проверено |
| `methods: ItemListClass:FindSocketedJewel` | 204 | Не проверено |
| `methods: ItemListClass:FindEquippedItemSocket` | 227 | Не проверено |
| `methods: ItemListClass:GetRowValue` | 248 | Не проверено |
| `methods: ItemListClass:AddValueTooltip` | 266 | Не проверено |
| `methods: ItemListClass:GetDragValue` | 277 | Не проверено |
| `methods: ItemListClass:ReceiveDrag` | 281 | Не проверено |
| `methods: ItemListClass:OnOrderChange` | 292 | Не проверено |
| `methods: ItemListClass:OnSelClick` | 296 | Не проверено |
| `methods: ItemListClass:OnSelCopy` | 332 | Не проверено |
| `methods: ItemListClass:OnSelDelete` | 337 | Не проверено |
| `methods: ItemListClass:OnHoverKeyUp` | 377 | Не проверено |

### `src/Classes/ItemSlotControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: noteButton` | 44 | Не проверено |
| `controls: activate` | 59 | Не проверено |
| `methods: ItemSlotClass:ItemSlotControl` | 22 | Не проверено |
| `methods: ItemSlotClass:SetSelItemId` | 103 | Не проверено |
| `methods: ItemSlotClass:Populate` | 117 | Не проверено |
| `methods: ItemSlotClass:CanReceiveDrag` | 150 | Не проверено |
| `methods: ItemSlotClass:ReceiveDrag` | 154 | Не проверено |
| `methods: ItemSlotClass:Draw` | 168 | Не проверено |
| `methods: ItemSlotClass:OnKeyDown` | 187 | Не проверено |
| `methods: ItemSlotClass:OnHoverKeyUp` | 205 | Не проверено |

### `src/Classes/ItemSetService.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: ItemSetServiceClass:ItemSetService` | 12 | Не проверено |
| `methods: ItemSetServiceClass:NewItemSet` | 17 | Не проверено |
| `methods: ItemSetServiceClass:CopyItemSet` | 25 | Не проверено |
| `methods: ItemSetServiceClass:RenameItemSet` | 33 | Не проверено |
| `methods: ItemSetServiceClass:DeleteItemSet` | 40 | Не проверено |

### `src/Classes/SharedItemListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: delete` | 23 | Не проверено |
| `methods: SharedItemListClass:SharedItemListControl` | 17 | Не проверено |
| `methods: SharedItemListClass:GetRowValue` | 32 | Не проверено |
| `methods: SharedItemListClass:AddValueTooltip` | 38 | Не проверено |
| `methods: SharedItemListClass:GetDragValue` | 48 | Не проверено |
| `methods: SharedItemListClass:ReceiveDrag` | 52 | Не проверено |
| `methods: SharedItemListClass:OnSelClick` | 63 | Не проверено |
| `methods: SharedItemListClass:OnSelCopy` | 70 | Не проверено |
| `methods: SharedItemListClass:OnSelDelete` | 74 | Не проверено |

## Умения

### `src/Classes/SkillsTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: setSelect` | 85 | Не проверено |
| `controls: setLabel` | 93 | Не проверено |
| `controls: setManage` | 94 | Не проверено |
| `controls: groupList` | 99 | Не проверено |
| `controls: groupTip` | 100 | Не проверено |
| `controls: optionSection` | 113 | Не проверено |
| `controls: sortGemsByDPS` | 114 | Не проверено |
| `controls: sortGemsByDPSFieldControl` | 117 | Не проверено |
| `controls: defaultLevel` | 120 | Не проверено |
| `controls: defaultLevelLabel` | 129 | Не проверено |
| `controls: defaultQuality` | 130 | Не проверено |
| `controls: defaultQualityLabel` | 133 | Не проверено |
| `controls: showSupportGemTypes` | 134 | Не проверено |
| `controls: showSupportGemTypesLabel` | 137 | Не проверено |
| `controls: showLegacyGems` | 138 | Не проверено |
| `controls: groupLabel` | 151 | Не проверено |
| `controls: set1Enabled` | 166 | Не проверено |
| `controls: set2Enabled` | 169 | Не проверено |
| `controls: groupEnabled` | 202 | Не проверено |
| `controls: includeInFullDPS` | 220 | Не проверено |
| `controls: groupCountLabel` | 225 | Не проверено |
| `controls: groupCount` | 229 | Не проверено |
| `controls: sourceNote` | 237 | Не проверено |
| `controls: scrollBarH` | 255 | Не проверено |
| `controls: gemNameHeader` | 267 | Не проверено |
| `controls: gemLevelHeader` | 268 | Не проверено |
| `controls: gemQualityHeader` | 269 | Не проверено |
| `controls: gemCorruptHeader` | 270 | Не проверено |
| `controls: gemEnableHeader` | 271 | Не проверено |
| `controls: gemCountHeader` | 272 | Не проверено |
| `methods: SkillsTabClass:SkillsTab` | 66 | Не проверено |
| `methods: SkillsTabClass:GetCorruptIndex` | 276 | Не проверено |
| `methods: SkillsTabClass:LoadSkill` | 288 | Не проверено |
| `methods: SkillsTabClass:Load` | 401 | Не проверено |
| `methods: SkillsTabClass:Save` | 451 | Не проверено |
| `methods: SkillsTabClass:Draw` | 568 | Не проверено |
| `methods: SkillsTabClass:CopySocketGroup` | 639 | Не проверено |
| `methods: SkillsTabClass:PasteSocketGroup` | 674 | Не проверено |
| `methods: SkillsTabClass:CreateGemSlot` | 769 | Не проверено |
| `methods: SkillsTabClass:UpdateGemSlots` | 1204 | Не проверено |
| `methods: SkillsTabClass:FindSkillGem` | 1233 | Не проверено |
| `methods: SkillsTabClass:ProcessGemLevel` | 1259 | Не проверено |
| `methods: SkillsTabClass:ProcessSocketGroup` | 1297 | Не проверено |
| `methods: SkillsTabClass:IsSocketGroupWeaponSetLocked` | 1393 | Не проверено |
| `methods: SkillsTabClass:GetSocketGroupWeaponSet` | 1398 | Не проверено |
| `methods: SkillsTabClass:GetSocketGroupWeaponSetLabel` | 1407 | Не проверено |
| `methods: SkillsTabClass:CacheSocketGroupWeaponSetValidity` | 1439 | Не проверено |
| `methods: SkillsTabClass:ApplySocketGroupWeaponSetValidity` | 1458 | Не проверено |
| `methods: SkillsTabClass:ReconcileSocketGroupWeaponSets` | 1472 | Не проверено |
| `methods: SkillsTabClass:IsSocketGroupWeaponSetValid` | 1506 | Не проверено |
| `methods: SkillsTabClass:SetDisplayGroup` | 1538 | Не проверено |
| `methods: SkillsTabClass:EnsureSocketGroupDisplaySkills` | 1567 | Не проверено |
| `methods: SkillsTabClass:AddSocketGroupTooltip` | 1579 | Не проверено |
| `methods: SkillsTabClass:CreateUndoState` | 1680 | Не проверено |
| `methods: SkillsTabClass:RestoreUndoState` | 1697 | Не проверено |
| `methods: SkillsTabClass:OpenSkillSetManagePopup` | 1718 | Не проверено |
| `methods: SkillsTabClass:CreateSkillSet` | 1728 | Не проверено |
| `methods: SkillsTabClass:NewSkillSet` | 1738 | Не проверено |
| `methods: SkillsTabClass:CopySkillSet` | 1745 | Не проверено |
| `methods: SkillsTabClass:RenameSkillSet` | 1758 | Не проверено |
| `methods: SkillsTabClass:DeleteSkillSet` | 1769 | Не проверено |
| `methods: SkillsTabClass:SetActiveSkillSet` | 1776 | Не проверено |
| `methods: SkillsTabClass:UpdateGlobalGemCountAssignments` | 1805 | Не проверено |

### `src/Classes/SkillListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: delete` | 39 | Не проверено |
| `controls: deleteAll` | 45 | Не проверено |
| `controls: new` | 58 | Не проверено |
| `methods: SkillListClass:SkillListControl` | 35 | Не проверено |
| `methods: SkillListClass:GetRowValue` | 78 | Не проверено |
| `methods: SkillListClass:AddValueTooltip` | 98 | Не проверено |
| `methods: SkillListClass:OnOrderChange` | 108 | Не проверено |
| `methods: SkillListClass:OnSelect` | 129 | Не проверено |
| `methods: SkillListClass:OnSelCopy` | 133 | Не проверено |
| `methods: SkillListClass:OnSelDelete` | 139 | Не проверено |
| `methods: SkillListClass:OnHoverKeyUp` | 175 | Не проверено |
| `methods: SkillListClass:Draw` | 213 | Не проверено |
| `methods: SkillListClass:GetRowIcon` | 217 | Не проверено |

### `src/Classes/SkillsSetService.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: SkillsSetServiceClass:SkillsSetService` | 12 | Не проверено |
| `methods: SkillsSetServiceClass:NewSkillSet` | 17 | Не проверено |
| `methods: SkillsSetServiceClass:CopySkillSet` | 24 | Не проверено |
| `methods: SkillsSetServiceClass:RenameSkillSet` | 31 | Не проверено |
| `methods: SkillsSetServiceClass:DeleteSkillSet` | 37 | Не проверено |

### `src/Classes/GemSelectControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: scrollBar` | 29 | Не проверено |
| `methods: GemSelectClass:GemSelectControl` | 27 | Не проверено |
| `methods: GemSelectClass:CalcOutputWithThisGem` | 61 | Не проверено |
| `methods: GemSelectClass:PopulateGemList` | 104 | Не проверено |
| `methods: GemSelectClass:FilterSupport` | 124 | Не проверено |
| `methods: GemSelectClass:BuildList` | 135 | Не проверено |
| `methods: GemSelectClass:UpdateSortCache` | 238 | Не проверено |
| `methods: GemSelectClass:SortGemList` | 353 | Не проверено |
| `methods: GemSelectClass:SyncSelection` | 375 | Не проверено |
| `methods: GemSelectClass:SortCurrentList` | 386 | Не проверено |
| `methods: GemSelectClass:DPSBuilder` | 393 | Не проверено |
| `methods: GemSelectClass:UpdateGem` | 434 | Не проверено |
| `methods: GemSelectClass:ScrollSelIntoView` | 452 | Не проверено |
| `methods: GemSelectClass:IsMouseOver` | 460 | Не проверено |
| `methods: GemSelectClass:IsHoverSelectionReady` | 483 | Не проверено |
| `methods: GemSelectClass:Draw` | 498 | Не проверено |
| `methods: GemSelectClass:CheckSupporting` | 681 | Не проверено |
| `methods: GemSelectClass:AddGemTooltip` | 686 | Не проверено |
| `methods: GemSelectClass:OnFocusGained` | 689 | Не проверено |
| `methods: GemSelectClass:CancelSelection` | 698 | Не проверено |
| `methods: GemSelectClass:OnFocusLost` | 706 | Не проверено |
| `methods: GemSelectClass:OnKeyDown` | 712 | Не проверено |
| `methods: GemSelectClass:OnKeyUp` | 812 | Не проверено |

## Условия боя

### `src/Classes/ConfigTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: deleteBtn` | 32 | Не проверено |
| `controls: titleEdit` | 44 | Не проверено |
| `controls: addModBtn` | 51 | Не проверено |
| `controls: enableCheck` | 55 | Не проверено |
| `controls: textEdit` | 81 | Не проверено |
| `controls: sectionAnchor` | 164 | Не проверено |
| `controls: setSelect` | 167 | Не проверено |
| `controls: setLabel` | 175 | Не проверено |
| `controls: setManage` | 176 | Не проверено |
| `controls: search` | 180 | Не проверено |
| `controls: toggleConfigs` | 183 | Не проверено |
| `controls: scrollBar` | 854 | Не проверено |
| `controls: customModsAddBlock` | 856 | Не проверено |
| `methods: CustomModBlockClass:CustomModBlockControl` | 24 | Не проверено |
| `methods: CustomModBlockClass:GetSize` | 100 | Не проверено |
| `methods: CustomModBlockClass:IsMouseOver` | 106 | Не проверено |
| `methods: CustomModBlockClass:OnKeyDown` | 113 | Не проверено |
| `methods: CustomModBlockClass:Draw` | 123 | Не проверено |
| `methods: ConfigTabClass:ConfigTab` | 134 | Не проверено |
| `methods: ConfigTabClass:IsSectionCollapsed` | 874 | Не проверено |
| `methods: ConfigTabClass:Load` | 878 | Не проверено |
| `methods: ConfigTabClass:GetDefaultState` | 980 | Не проверено |
| `methods: ConfigTabClass:Save` | 1000 | Не проверено |
| `methods: ConfigTabClass:UpdateControls` | 1047 | Не проверено |
| `methods: ConfigTabClass:Draw` | 1063 | Не проверено |
| `methods: ConfigTabClass:UpdateLevel` | 1157 | Не проверено |
| `methods: ConfigTabClass:BuildModList` | 1169 | Не проверено |
| `methods: ConfigTabClass:ImportCalcSettings` | 1243 | Не проверено |
| `methods: ConfigTabClass:CreateUndoState` | 1280 | Не проверено |
| `methods: ConfigTabClass:RestoreUndoState` | 1288 | Не проверено |
| `methods: ConfigTabClass:OpenConfigSetManagePopup` | 1308 | Не проверено |
| `methods: ConfigTabClass:CreateConfigSet` | 1317 | Не проверено |
| `methods: ConfigTabClass:NewConfigSet` | 1337 | Не проверено |
| `methods: ConfigTabClass:CopyConfigSet` | 1344 | Не проверено |
| `methods: ConfigTabClass:RenameConfigSet` | 1355 | Не проверено |
| `methods: ConfigTabClass:DeleteConfigSet` | 1367 | Не проверено |
| `methods: ConfigTabClass:UpdateCustomModsControls` | 1372 | Не проверено |
| `methods: ConfigTabClass:SetActiveConfigSet` | 1407 | Не проверено |

### `src/Classes/ConfigSetService.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: ConfigSetServiceClass:ConfigSetService` | 12 | Не проверено |
| `methods: ConfigSetServiceClass:NewConfigSet` | 17 | Не проверено |
| `methods: ConfigSetServiceClass:CopyConfigSet` | 24 | Не проверено |
| `methods: ConfigSetServiceClass:RenameConfigSet` | 31 | Не проверено |
| `methods: ConfigSetServiceClass:DeleteConfigSet` | 37 | Не проверено |

## Расчёты

### `src/Classes/CalcsTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: search` | 38 | Не проверено |
| `controls: breakdown` | 193 | Не проверено |
| `controls: scrollBar` | 195 | Не проверено |
| `methods: CalcsTabClass:CalcsTab` | 22 | Не проверено |
| `methods: CalcsTabClass:Load` | 200 | Не проверено |
| `methods: CalcsTabClass:Save` | 240 | Не проверено |
| `methods: CalcsTabClass:Draw` | 263 | Не проверено |
| `methods: CalcsTabClass:NewSection` | 407 | Не проверено |
| `methods: CalcsTabClass:ClearDisplayStat` | 414 | Не проверено |
| `methods: CalcsTabClass:SetDisplayStat` | 420 | Не проверено |
| `methods: CalcsTabClass:CheckFlag` | 433 | Не проверено |
| `methods: CalcsTabClass:SearchMatch` | 481 | Не проверено |
| `methods: CalcsTabClass:BuildOutput` | 487 | Не проверено |
| `methods: CalcsTabClass:BuildPower` | 530 | Не проверено |
| `methods: CalcsTabClass:PowerBuilder` | 551 | Не проверено |
| `methods: CalcsTabClass:CalculatePowerStat` | 711 | Не проверено |
| `methods: CalcsTabClass:CalculateCombinedOffDefStat` | 717 | Не проверено |
| `methods: CalcsTabClass:GetMiscCalculator` | 729 | Не проверено |
| `methods: CalcsTabClass:CreateUndoState` | 733 | Не проверено |
| `methods: CalcsTabClass:RestoreUndoState` | 737 | Не проверено |

### `src/Classes/CalcBreakdownControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: scrollBar` | 32 | Не проверено |
| `methods: CalcBreakdownClass:CalcBreakdownControl` | 20 | Не проверено |
| `methods: CalcBreakdownClass:IsMouseOver` | 41 | Не проверено |
| `methods: CalcBreakdownClass:GetActor` | 48 | Не проверено |
| `methods: CalcBreakdownClass:SetBreakdownData` | 60 | Не проверено |
| `methods: CalcBreakdownClass:AddBreakdownSection` | 147 | Не проверено |
| `methods: CalcBreakdownClass:AddModSection` | 300 | Не проверено |
| `methods: CalcBreakdownClass:FormatModName` | 550 | Не проверено |
| `methods: CalcBreakdownClass:FormatVarNameOrList` | 554 | Не проверено |
| `methods: CalcBreakdownClass:FormatModBase` | 558 | Не проверено |
| `methods: CalcBreakdownClass:FormatModValue` | 562 | Не проверено |
| `methods: CalcBreakdownClass:DrawBreakdownTable` | 592 | Не проверено |
| `methods: CalcBreakdownClass:DrawRadiusVisual` | 676 | Не проверено |
| `methods: CalcBreakdownClass:Draw` | 711 | Не проверено |
| `methods: CalcBreakdownClass:OnKeyDown` | 776 | Не проверено |
| `methods: CalcBreakdownClass:OnKeyUp` | 800 | Не проверено |

### `src/Classes/CalcSectionControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: popOut` | 66 | Не проверено |
| `methods: CalcSectionClass:CalcSectionControl` | 20 | Не проверено |
| `methods: CalcSectionClass:IsMouseOver` | 84 | Не проверено |
| `methods: CalcSectionClass:UpdateSize` | 114 | Не проверено |
| `methods: CalcSectionClass:UpdatePos` | 165 | Не проверено |
| `methods: CalcSectionClass:FormatVal` | 187 | Не проверено |
| `methods: CalcSectionClass:FormatStr` | 191 | Не проверено |
| `methods: CalcSectionClass:Draw` | 246 | Не проверено |
| `methods: CalcSectionClass:OnKeyDown` | 260 | Не проверено |
| `methods: CalcSectionClass:OnKeyUp` | 282 | Не проверено |
| `methods: CalcSectionClass:ToggleOverlay` | 293 | Не проверено |
| `methods: CalcSectionClass:RaiseOverlay` | 312 | Не проверено |
| `methods: CalcSectionClass:IsMouseInOverlay` | 323 | Не проверено |
| `methods: CalcSectionClass:GetOverlayHeight` | 331 | Не проверено |
| `methods: CalcSectionClass:HandleOverlayClick` | 350 | Не проверено |
| `methods: CalcSectionClass:HandleOverlayRelease` | 421 | Не проверено |
| `methods: CalcSectionClass:DrawOverlay` | 427 | Не проверено |
| `methods: CalcSectionClass:SetOverlayDisplayStat` | 496 | Не проверено |
| `methods: CalcSectionClass:DrawContent` | 501 | Не проверено |

### `src/Modules/BuildDisplayStats.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |

## Сравнение и торговля

### `src/Classes/CompareTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: subTabAnchor` | 190 | Не проверено |
| `controls: compareBuildLabel` | 218 | Не проверено |
| `controls: compareBuildSelect` | 219 | Не проверено |
| `controls: importBtn` | 230 | Не проверено |
| `controls: reimportBtn` | 235 | Не проверено |
| `controls: removeBtn` | 262 | Не проверено |
| `controls: compareSpecLabel` | 279 | Не проверено |
| `controls: compareSpecSelect` | 281 | Не проверено |
| `controls: compareSkillSetLabel` | 296 | Не проверено |
| `controls: compareSkillSetSelect` | 298 | Не проверено |
| `controls: compareItemSetLabel` | 306 | Не проверено |
| `controls: compareItemSetSelect` | 308 | Не проверено |
| `controls: compareConfigSetLabel` | 316 | Не проверено |
| `controls: compareConfigSetSelect` | 318 | Не проверено |
| `controls: cmpSkillLabel` | 335 | Не проверено |
| `controls: cmpSocketGroup` | 339 | Не проверено |
| `controls: cmpMainSkill` | 350 | Не проверено |
| `controls: cmpStatSet` | 362 | Не проверено |
| `controls: cmpSkillPart` | 375 | Не проверено |
| `controls: cmpStageCountLabel` | 392 | Не проверено |
| `controls: cmpStageCount` | 393 | Не проверено |
| `controls: cmpMineCountLabel` | 411 | Не проверено |
| `controls: cmpMineCount` | 412 | Не проверено |
| `controls: cmpMinion` | 430 | Не проверено |
| `controls: cmpMinionSkill` | 454 | Не проверено |
| `controls: cmpMinionSkillStatSet` | 471 | Не проверено |
| `controls: primCalcsSocketGroup` | 494 | Не проверено |
| `controls: primCalcsMainSkill` | 502 | Не проверено |
| `controls: primCalcsSkillPart` | 511 | Не проверено |
| `controls: primCalcsStageCount` | 524 | Не проверено |
| `controls: primCalcsMineCount` | 537 | Не проверено |
| `controls: primCalcsShowMinion` | 550 | Не проверено |
| `controls: primCalcsMinion` | 556 | Не проверено |
| `controls: primCalcsMinionSkill` | 576 | Не проверено |
| `controls: primCalcsMinionSkillStatSet` | 589 | Не проверено |
| `controls: mainSkillMinionSkill` | 589 | Не проверено |
| `controls: primCalcsStatSet` | 601 | Не проверено |
| `controls: primCalcsMode` | 612 | Не проверено |
| `controls: cmpCalcsSocketGroup` | 619 | Не проверено |
| `controls: cmpCalcsMainSkill` | 630 | Не проверено |
| `controls: cmpCalcsSkillPart` | 642 | Не проверено |
| `controls: cmpCalcsStageCount` | 658 | Не проверено |
| `controls: cmpCalcsMineCount` | 674 | Не проверено |
| `controls: cmpCalcsShowMinion` | 690 | Не проверено |
| `controls: cmpCalcsMinion` | 699 | Не проверено |
| `controls: cmpCalcsMinionSkill` | 722 | Не проверено |
| `controls: cmpCalcsMinionSkillStatSet` | 738 | Не проверено |
| `controls: cmpCalcsStatSet` | 751 | Не проверено |
| `controls: cmpCalcsMode` | 763 | Не проверено |
| `controls: calcsShowOnlyDifferencesCheck` | 772 | Не проверено |
| `controls: treeOverlayCheck` | 799 | Не проверено |
| `controls: overlayTreeSearch` | 809 | Не проверено |
| `controls: itemsExpandedCheck` | 819 | Не проверено |
| `controls: primaryItemSetLabel` | 831 | Не проверено |
| `controls: primaryItemSetSelect` | 833 | Не проверено |
| `controls: compareItemSetLabel2` | 843 | Не проверено |
| `controls: compareItemSetSelect2` | 845 | Не проверено |
| `controls: primaryTreeSetLabel` | 855 | Не проверено |
| `controls: primaryTreeSetSelect` | 857 | Не проверено |
| `controls: compareTreeSetLabel` | 869 | Не проверено |
| `controls: compareTreeSetSelect` | 871 | Не проверено |
| `controls: leftFooterAnchor` | 886 | Не проверено |
| `controls: rightFooterAnchor` | 888 | Не проверено |
| `controls: leftSpecSelect` | 892 | Не проверено |
| `controls: leftVersionSelect` | 902 | Не проверено |
| `controls: leftTreeSearch` | 910 | Не проверено |
| `controls: rightSpecSelect` | 918 | Не проверено |
| `controls: rightVersionSelect` | 932 | Не проверено |
| `controls: copySpecBtn` | 943 | Не проверено |
| `controls: copySpecUseBtn` | 952 | Не проверено |
| `controls: rightTreeSearch` | 959 | Не проверено |
| `controls: copyConfigBtn` | 968 | Не проверено |
| `controls: configToggleBtn` | 976 | Не проверено |
| `controls: configSearchEdit` | 988 | Не проверено |
| `controls: configPrimarySetLabel` | 997 | Не проверено |
| `controls: configPrimarySetSelect` | 999 | Не проверено |
| `controls: comparePowerStatSelect` | 1027 | Не проверено |
| `controls: comparePowerTreeCheck` | 1048 | Не проверено |
| `controls: comparePowerItemsCheck` | 1055 | Не проверено |
| `controls: comparePowerGemsCheck` | 1062 | Не проверено |
| `controls: comparePowerSupportGemsCheck` | 1069 | Не проверено |
| `controls: comparePowerConfigCheck` | 1076 | Не проверено |
| `controls: comparePowerReportList` | 1084 | Не проверено |
| `controls: calcsScrollBar` | 1089 | Не проверено |
| `controls: viewScrollBar` | 1096 | Не проверено |
| `controls: itemsHScrollBar` | 1106 | Не проверено |
| `controls: skillsHScrollBar` | 1113 | Не проверено |
| `controls: path` | 1659 | Не проверено |
| `controls: scrollBarV` | 1670 | Не проверено |
| `methods: CompareTabClass:CompareTab` | 121 | Не проверено |
| `methods: CompareTabClass:InitControls` | 185 | Не проверено |
| `methods: CompareTabClass:GetShortBuildName` | 1121 | Не проверено |
| `methods: CompareTabClass:PopulateSetDropdown` | 1134 | Не проверено |
| `methods: CompareTabClass:FormatConfigValue` | 1152 | Не проверено |
| `methods: CompareTabClass:NormalizeConfigVals` | 1170 | Не проверено |
| `methods: CompareTabClass:RebuildConfigControls` | 1226 | Не проверено |
| `methods: CompareTabClass:CopyCompareConfig` | 1298 | Не проверено |
| `methods: CompareTabClass:ImportBuild` | 1312 | Не проверено |
| `methods: CompareTabClass:ImportFromCode` | 1328 | Не проверено |
| `methods: CompareTabClass:RemoveBuild` | 1340 | Не проверено |
| `methods: CompareTabClass:ReimportPrimary` | 1354 | Не проверено |
| `methods: CompareTabClass:UpdateBuildSelector` | 1366 | Не проверено |
| `methods: CompareTabClass:GetActiveCompare` | 1378 | Не проверено |
| `methods: CompareTabClass:CopyCompareSpecToPrimary` | 1386 | Не проверено |
| `methods: CompareTabClass:GetJewelComparisonSlots` | 1427 | Не проверено |
| `methods: CompareTabClass:CopyCompareItemToPrimary` | 1494 | Не проверено |
| `methods: CompareTabClass:OpenImportPopup` | 1517 | Не проверено |
| `methods: CompareTabClass:OpenImportFolderPopup` | 1584 | Не проверено |
| `methods: CompareTabClass:Draw` | 1700 | Не проверено |
| `methods: CompareTabClass:DrawControlList` | 1922 | Не проверено |
| `methods: CompareTabClass:LayoutTreeView` | 1935 | Не проверено |
| `methods: CompareTabClass:LayoutConfigView` | 2097 | Не проверено |
| `methods: CompareTabClass:UpdateSetSelectors` | 2272 | Не проверено |
| `methods: CompareTabClass:RefreshCalcsSkillControls` | 2309 | Не проверено |
| `methods: CompareTabClass:LayoutCalcsSkillControls` | 2374 | Не проверено |
| `methods: CompareTabClass:HandleScrollInput` | 2468 | Не проверено |
| `methods: CompareTabClass:GetGemGrantedEffect` | 2523 | Не проверено |
| `methods: CompareTabClass:GetSocketGroupSignature` | 2531 | Не проверено |
| `methods: CompareTabClass:GetSocketGroupLabel` | 2544 | Не проверено |
| `methods: CompareTabClass:ComparePowerBuilder` | 2571 | Не проверено |
| `methods: CompareTabClass:RunComparePowerReport` | 3129 | Не проверено |
| `methods: CompareTabClass:DrawSummary` | 3162 | Не проверено |
| `methods: CompareTabClass:DrawStatList` | 3308 | Не проверено |
| `methods: CompareTabClass:DrawTree` | 3402 | Не проверено |
| `methods: CompareTabClass:DrawItemExpanded` | 3494 | Не проверено |
| `methods: CompareTabClass:ShouldShowRing3` | 3661 | Не проверено |
| `methods: CompareTabClass:DrawItems` | 3669 | Не проверено |
| `methods: CompareTabClass:DrawSkills` | 3986 | Не проверено |
| `methods: CompareTabClass:DrawCalcsTooltip` | 4386 | Не проверено |
| `methods: CompareTabClass:DrawCalcsSkillHeader` | 4399 | Не проверено |
| `methods: CompareTabClass:DrawCalcs` | 4583 | Не проверено |
| `methods: CompareTabClass:DrawConfig` | 4835 | Не проверено |

### `src/Classes/CompareBuySimilar.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: M.addModEntries` | 200 | Не проверено |
| `methods: M.openPopup` | 284 | Не проверено |

### `src/Classes/TradeQuery.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: pbNotice` | 82 | Не проверено |
| `controls: league` | 101 | Не проверено |
| `controls: setSelect` | 295 | Не проверено |
| `controls: poesessidButton` | 330 | Не проверено |
| `controls: tradeTypeSelection` | 383 | Не проверено |
| `controls: fetchCountEdit` | 392 | Не проверено |
| `controls: StatWeightMultipliersButton` | 416 | Не проверено |
| `controls: itemSortSelection` | 441 | Не проверено |
| `controls: itemSortSelectionLabel` | 456 | Не проверено |
| `controls: realmLabel` | 459 | Не проверено |
| `controls: realm` | 460 | Не проверено |
| `controls: leagueLabel` | 500 | Не проверено |
| `controls: authenticateButton` | 559 | Не проверено |
| `controls: characterImportAnchor` | 559 | Не проверено |
| `controls: sectionAnchor` | 581 | Не проверено |
| `controls: scrollBar` | 589 | Не проверено |
| `controls: otherTradesLabel` | 608 | Не проверено |
| `controls: fullPrice` | 655 | Не проверено |
| `controls: close` | 656 | Не проверено |
| `methods: TradeQueryClass:FormatOAuthLoginStatus` | 26 | Не проверено |
| `methods: TradeQueryClass:TradeQuery` | 31 | Не проверено |
| `methods: TradeQueryClass:PullLeagueList` | 77 | Не проверено |
| `methods: TradeQueryClass:ConvertCurrencyToDivs` | 111 | Не проверено |
| `methods: TradeQueryClass:PullCXData` | 124 | Не проверено |
| `methods: TradeQueryClass:PriceItem` | 277 | Не проверено |
| `methods: TradeQueryClass:SetStatWeights` | 699 | Не проверено |
| `methods: TradeQueryClass:SetNotice` | 805 | Не проверено |
| `methods: TradeQueryClass:ReduceOutput` | 815 | Не проверено |
| `methods: TradeQueryClass:ComputeStatDetails` | 854 | Не проверено |
| `methods: TradeQueryClass:GetResultScorePercent` | 872 | Не проверено |
| `methods: TradeQueryClass:GetResultEvaluation` | 887 | Не проверено |
| `methods: TradeQueryClass:UpdateDropdownList` | 936 | Не проверено |
| `methods: TradeQueryClass:ResetResultRow` | 964 | Не проверено |
| `methods: TradeQueryClass:UpdateControlsWithItems` | 972 | Не проверено |
| `methods: TradeQueryClass:SetFetchResultReturn` | 1003 | Не проверено |
| `methods: TradeQueryClass:SortFetchResults` | 1014 | Не проверено |
| `methods: TradeQueryClass:FilterToSafeItems` | 1093 | Не проверено |
| `methods: TradeQueryClass:PriceItemRowDisplay` | 1104 | Не проверено |
| `methods: TradeQueryClass:GetTotalPriceString` | 1416 | Не проверено |
| `methods: TradeQueryClass:UpdateRealms` | 1455 | Не проверено |

### `src/Classes/TradeQueryGenerator.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: TradeQueryGeneratorClass:TradeQueryGenerator` | 118 | Не проверено |
| `methods: TradeQueryGeneratorClass.WeightedRatioOutputs` | 164 | Не проверено |
| `methods: TradeQueryGeneratorClass:ProcessMod` | 202 | Не проверено |
| `methods: TradeQueryGeneratorClass:GenerateModData` | 368 | Не проверено |
| `methods: TradeQueryGeneratorClass:InitMods` | 374 | Не проверено |
| `methods: TradeQueryGeneratorClass:GenerateModWeights` | 642 | Не проверено |
| `methods: TradeQueryGeneratorClass:GeneratePassiveNodeWeights` | 709 | Не проверено |
| `methods: TradeQueryGeneratorClass:OnFrame` | 745 | Не проверено |
| `methods: TradeQueryGeneratorClass:StartQuery` | 774 | Не проверено |
| `methods: TradeQueryGeneratorClass:ExecuteQuery` | 881 | Не проверено |
| `methods: TradeQueryGeneratorClass:FinishQuery` | 928 | Не проверено |
| `methods: TradeQueryGeneratorClass:RequestQuery` | 1139 | Не проверено |

### `src/Classes/TradeQueryRequests.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: TradeQueryRequestsClass:TradeQueryRequests` | 15 | Не проверено |
| `methods: TradeQueryRequestsClass:ProcessQueue` | 29 | Не проверено |
| `methods: TradeQueryRequestsClass:SearchWithQuery` | 90 | Не проверено |
| `methods: TradeQueryRequestsClass:SearchWithQueryWeightAdjusted` | 110 | Не проверено |
| `methods: TradeQueryRequestsClass:PerformSearch` | 221 | Не проверено |
| `methods: TradeQueryRequestsClass:FetchResults` | 262 | Не проверено |
| `methods: TradeQueryRequestsClass:FetchResultBlock` | 288 | Не проверено |
| `methods: TradeQueryRequestsClass:SearchWithURL` | 468 | Не проверено |
| `methods: TradeQueryRequestsClass:FetchLeagues` | 522 | Не проверено |
| `methods: TradeQueryRequestsClass:buildUrl` | 551 | Не проверено |

### `src/Classes/TradeQueryRateLimiter.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: TradeQueryRateLimiterClass:TradeQueryRateLimiter` | 12 | Не проверено |
| `methods: TradeQueryRateLimiterClass:GetPolicyName` | 65 | Не проверено |
| `methods: TradeQueryRateLimiterClass:ParseHeader` | 69 | Не проверено |
| `methods: TradeQueryRateLimiterClass:ParsePolicy` | 78 | Не проверено |
| `methods: TradeQueryRateLimiterClass:UpdateFromHeader` | 116 | Не проверено |
| `methods: TradeQueryRateLimiterClass:NextRequestTime` | 156 | Не проверено |
| `methods: TradeQueryRateLimiterClass:InsertRequest` | 205 | Не проверено |
| `methods: TradeQueryRateLimiterClass:FinishRequest` | 233 | Не проверено |
| `methods: TradeQueryRateLimiterClass:AgeOutRequests` | 243 | Не проверено |
| `methods: TradeQueryRateLimiterClass:ReduceLimits` | 277 | Не проверено |

## Группа и приспешники

### `src/Classes/PartyTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: importCodeHeader` | 57 | Не проверено |
| `controls: editAurasLabel` | 57 | Не проверено |
| `controls: notesDesc` | 68 | Не проверено |
| `controls: importCodeDestination` | 83 | Не проверено |
| `controls: editPartyMemberStats` | 84 | Не проверено |
| `controls: simpleAuras` | 87 | Не проверено |
| `controls: editAuras` | 88 | Не проверено |
| `controls: simpleCurses` | 93 | Не проверено |
| `controls: editCurses` | 94 | Не проверено |
| `controls: simpleWarcries` | 99 | Не проверено |
| `controls: editWarcries` | 100 | Не проверено |
| `controls: simpleLinks` | 105 | Не проверено |
| `controls: editLinks` | 106 | Не проверено |
| `controls: simpleEnemyCond` | 111 | Не проверено |
| `controls: enemyCond` | 112 | Не проверено |
| `controls: simpleEnemyMods` | 115 | Не проверено |
| `controls: enemyMods` | 116 | Не проверено |
| `controls: importCodeIn` | 139 | Не проверено |
| `controls: appendNotReplace` | 169 | Не проверено |
| `controls: importCodeGo` | 293 | Не проверено |
| `controls: importCodeState` | 296 | Не проверено |
| `controls: clear` | 339 | Не проверено |
| `controls: ShowAdvanceTools` | 347 | Не проверено |
| `controls: removeEffects` | 353 | Не проверено |
| `controls: rebuild` | 363 | Не проверено |
| `controls: editWarcriesLabel` | 406 | Не проверено |
| `controls: editLinksLabel` | 425 | Не проверено |
| `controls: editPartyMemberStatsLabel` | 444 | Не проверено |
| `controls: enemyCondLabel` | 456 | Не проверено |
| `controls: enemyModsLabel` | 475 | Не проверено |
| `controls: editCursesLabel` | 494 | Не проверено |
| `methods: PartyTabClass:PartyTab` | 16 | Не проверено |
| `methods: PartyTabClass:Load` | 516 | Не проверено |
| `methods: PartyTabClass:Save` | 575 | Не проверено |
| `methods: PartyTabClass:Draw` | 670 | Не проверено |
| `methods: PartyTabClass:ParseBuffs` | 718 | Не проверено |
| `methods: PartyTabClass:setBuffExports` | 984 | Не проверено |
| `methods: PartyTabClass:exportBuffs` | 992 | Не проверено |

### `src/Classes/MinionListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: add` | 23 | Не проверено |
| `controls: delete` | 31 | Не проверено |
| `methods: MinionListClass:MinionListControl` | 15 | Не проверено |
| `methods: MinionListClass:AddSel` | 41 | Не проверено |
| `methods: MinionListClass:GetRowValue` | 47 | Не проверено |
| `methods: MinionListClass:AddValueTooltip` | 54 | Не проверено |
| `methods: MinionListClass:GetDragValue` | 114 | Не проверено |
| `methods: MinionListClass:CanReceiveDrag` | 118 | Не проверено |
| `methods: MinionListClass:ReceiveDrag` | 122 | Не проверено |
| `methods: MinionListClass:OnSelClick` | 126 | Не проверено |
| `methods: MinionListClass:OnSelDelete` | 132 | Не проверено |
| `methods: SpawnListClass:SpawnListControl` | 143 | Не проверено |
| `methods: SpawnListClass:GetRowValue` | 150 | Не проверено |
| `methods: SpawnListClass:AddValueTooltip` | 153 | Не проверено |

### `src/Classes/MinionSearchListControl.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: searchText` | 20 | Не проверено |
| `controls: searchModeDropDown` | 21 | Не проверено |
| `controls: sortModeDropDown` | 29 | Не проверено |
| `controls: add` | 50 | Не проверено |
| `controls: delete` | 52 | Не проверено |
| `methods: MinionSearchListClass:MinionSearchListControl` | 14 | Не проверено |
| `methods: MinionSearchListClass:DoesEntryMatchFilters` | 58 | Не проверено |
| `methods: MinionSearchListClass:ListFilterChanged` | 78 | Не проверено |
| `methods: MinionSearchListClass:sortSourceList` | 94 | Не проверено |

## Импорт и экспорт

### `src/Classes/ImportTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: sectionCharImport` | 35 | Не проверено |
| `controls: charImportStatusLabel` | 36 | Не проверено |
| `controls: logoutApiButton` | 40 | Не проверено |
| `controls: characterImportAnchor` | 55 | Не проверено |
| `controls: authenticateButton` | 59 | Не проверено |
| `controls: accountNameHeader` | 84 | Не проверено |
| `controls: accountRealm` | 88 | Не проверено |
| `controls: accountNameGo` | 91 | Не проверено |
| `controls: charSelectHeader` | 96 | Не проверено |
| `controls: charSelectLeagueLabel` | 100 | Не проверено |
| `controls: charSelectLeague` | 101 | Не проверено |
| `controls: charSelect` | 104 | Не проверено |
| `controls: charImportHeader` | 108 | Не проверено |
| `controls: charImportTree` | 109 | Не проверено |
| `controls: charImportTreeClearJewels` | 121 | Не проверено |
| `controls: charImportItems` | 122 | Не проверено |
| `controls: charImportItemsClearSkills` | 128 | Не проверено |
| `controls: charImportItemsClearItems` | 129 | Не проверено |
| `controls: charImportItemsIgnoreWeaponSwap` | 130 | Не проверено |
| `controls: sectionBuild` | 133 | Не проверено |
| `controls: generateCodeLabel` | 134 | Не проверено |
| `controls: generateCode` | 135 | Не проверено |
| `controls: generateCodeOut` | 136 | Не проверено |
| `controls: enablePartyExportBuffs` | 138 | Не проверено |
| `controls: generateCodeCopy` | 146 | Не проверено |
| `controls: exportFrom` | 166 | Не проверено |
| `controls: generateCodeByLink` | 171 | Не проверено |
| `controls: generateCodeNote` | 203 | Не проверено |
| `controls: importCodeHeader` | 204 | Не проверено |
| `controls: importCodeMode` | 218 | Не проверено |
| `controls: importCodeIn` | 230 | Не проверено |
| `controls: importCodeGo` | 305 | Не проверено |
| `controls: importCodeState` | 308 | Не проверено |
| `controls: poe2ExportPath` | 357 | Не проверено |
| `controls: buildPlannerBuildName` | 358 | Не проверено |
| `controls: sectionPoE2Export` | 362 | Не проверено |
| `controls: poe2ExportDesc` | 363 | Не проверено |
| `controls: poe2ExportDesc2` | 364 | Не проверено |
| `controls: buildPlannerAuthorName` | 370 | Не проверено |
| `controls: buildPlannerTreeLabel` | 372 | Не проверено |
| `controls: buildPlannerSkillLabel` | 373 | Не проверено |
| `controls: buildPlannerItemLabel` | 374 | Не проверено |
| `controls: buildPlannerSpec` | 375 | Не проверено |
| `controls: buildPlannerSkillSet` | 379 | Не проверено |
| `controls: buildPlannerItemSet` | 382 | Не проверено |
| `controls: buildPlannerUseGeneratedItemText` | 385 | Не проверено |
| `controls: buildPlannerDescLabel` | 391 | Не проверено |
| `controls: buildPlannerDescription` | 392 | Не проверено |
| `controls: poe2ExportShowPath` | 395 | Не проверено |
| `controls: poe2ExportPathDisplay` | 396 | Не проверено |
| `controls: poe2ExportOpenFolder` | 403 | Не проверено |
| `controls: poe2ExportSave` | 413 | Не проверено |
| `controls: poe2ExportSaveAll` | 440 | Не проверено |
| `controls: accountName` | 569 | Не проверено |
| `methods: ImportTabClass:ImportTab` | 23 | Не проверено |
| `methods: ImportTabClass:GetBuildPlannerMetadata` | 484 | Не проверено |
| `methods: ImportTabClass:RefreshBuildPlannerSets` | 494 | Не проверено |
| `methods: ImportTabClass:RefreshAuthStatus` | 532 | Не проверено |
| `methods: ImportTabClass:SaveApiSettings` | 549 | Не проверено |
| `methods: ImportTabClass:Load` | 556 | Не проверено |
| `methods: ImportTabClass:Save` | 576 | Не проверено |
| `methods: ImportTabClass:Draw` | 594 | Не проверено |
| `methods: ImportTabClass:DownloadCharacterList` | 607 | Не проверено |
| `methods: ImportTabClass:BuildCharacterList` | 722 | Не проверено |
| `methods: ImportTabClass:DownloadCharacter` | 767 | Не проверено |
| `methods: ImportTabClass:DownloadPassiveTree` | 817 | Не проверено |
| `methods: ImportTabClass:DownloadItems` | 823 | Не проверено |
| `methods: ImportTabClass:ImportQuestRewardConfig` | 829 | Не проверено |
| `methods: ImportTabClass:ImportPassiveTreeAndJewels` | 927 | Не проверено |
| `methods: ImportTabClass:ImportItemsAndSkills` | 1097 | Не проверено |
| `methods: ImportTabClass:ImportItem` | 1336 | Не проверено |
| `methods: ImportTabClass:ImportSocketedItems` | 1618 | Не проверено |
| `methods: ImportTabClass:GuessMainSocketGroup` | 1638 | Не проверено |
| `methods: HexToChar` | 1650 | Не проверено |
| `methods: UrlDecode` | 1654 | Не проверено |

### `src/Classes/PoEAPI.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: PoEAPIClass:PoEAPI` | 17 | Не проверено |
| `methods: PoEAPIClass:ValidateAuth` | 31 | Не проверено |
| `methods: PoEAPIClass:ResetDetails` | 69 | Не проверено |
| `methods: PoEAPIClass:UpdateMain` | 77 | Не проверено |
| `methods: PoEAPIClass:FetchAuthToken` | 85 | Не проверено |
| `methods: PoEAPIClass:DownloadWithRefresh` | 147 | Не проверено |
| `methods: PoEAPIClass:DownloadWithRateLimit` | 185 | Не проверено |
| `methods: PoEAPIClass:DownloadCharacterList` | 209 | Не проверено |
| `methods: PoEAPIClass:DownloadCharacter` | 218 | Не проверено |

### `src/Modules/BuildExportPoE2.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: M.DefaultDir` | 31 | Не проверено |
| `methods: M.BuildPath` | 38 | Не проверено |
| `methods: M.DisplayPath` | 43 | Не проверено |
| `methods: M.LoadoutPath` | 54 | Не проверено |
| `methods: M.ItemAdditionalText` | 203 | Не проверено |
| `methods: M.ResolveSelection` | 255 | Не проверено |
| `methods: M.GetLoadouts` | 264 | Не проверено |
| `methods: M.BuildTable` | 286 | Не проверено |
| `methods: M.Export` | 305 | Не проверено |
| `methods: M.WriteFile` | 316 | Не проверено |
| `methods: M.WriteAllLoadouts` | 330 | Не проверено |

## Заметки

### `src/Classes/NotesTab.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: notesDesc` | 23 | Не проверено |
| `controls: normal` | 24 | Не проверено |
| `controls: magic` | 25 | Не проверено |
| `controls: rare` | 26 | Не проверено |
| `controls: unique` | 27 | Не проверено |
| `controls: fire` | 28 | Не проверено |
| `controls: cold` | 29 | Не проверено |
| `controls: lightning` | 30 | Не проверено |
| `controls: chaos` | 31 | Не проверено |
| `controls: strength` | 32 | Не проверено |
| `controls: dexterity` | 33 | Не проверено |
| `controls: intelligence` | 34 | Не проверено |
| `controls: default` | 35 | Не проверено |
| `controls: edit` | 37 | Не проверено |
| `controls: toggleColorCodes` | 45 | Не проверено |
| `methods: NotesTabClass:NotesTab` | 11 | Не проверено |
| `methods: NotesTabClass:SetShowColorCodes` | 53 | Не проверено |
| `methods: NotesTabClass:SetColor` | 64 | Не проверено |
| `methods: NotesTabClass:Load` | 75 | Не проверено |
| `methods: NotesTabClass:Save` | 84 | Не проверено |
| `methods: NotesTabClass:Draw` | 90 | Не проверено |

## Запуск и настройки

### `src/Launch.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `methods: launch:OnInit` | 22 | Не проверено |
| `methods: launch:CanExit` | 91 | Не проверено |
| `methods: launch:OnExit` | 104 | Не проверено |
| `methods: launch:OnFrame` | 110 | Не проверено |
| `methods: launch:OnKeyDown` | 140 | Не проверено |
| `methods: launch:OnKeyUp` | 174 | Не проверено |
| `methods: launch:OnChar` | 185 | Не проверено |
| `methods: launch:OnSubCall` | 198 | Не проверено |
| `methods: launch:OnSubError` | 207 | Не проверено |
| `methods: launch:OnSubFinished` | 220 | Не проверено |
| `methods: launch:RegisterSubScript` | 243 | Не проверено |
| `methods: launch:DownloadPage` | 256 | Не проверено |
| `methods: launch:ApplyUpdate` | 323 | Не проверено |
| `methods: launch:CheckForUpdate` | 337 | Не проверено |
| `methods: launch:ShowPrompt` | 356 | Не проверено |
| `methods: launch:ShowErrMsg` | 379 | Не проверено |
| `methods: launch:RunPromptFunc` | 388 | Не проверено |
| `methods: launch:DrawPopup` | 398 | Не проверено |

### `src/Modules/Main.lua`

| Элемент | Первая строка | Проверка переноса |
| --- | --- | --- |
| `controls: options` | 221 | Не проверено |
| `controls: about` | 224 | Не проверено |
| `controls: applyUpdate` | 227 | Не проверено |
| `controls: checkUpdate` | 233 | Не проверено |
| `controls: forkLabel` | 245 | Не проверено |
| `controls: versionLabel` | 249 | Не проверено |
| `controls: devMode` | 253 | Не проверено |
| `controls: dismissToast` | 257 | Не проверено |
| `methods: main:Init` | 52 | Не проверено |
| `methods: main:DetectUnicodeSupport` | 305 | Не проверено |
| `methods: main:SaveModCache` | 313 | Не проверено |
| `methods: main:LoadTree` | 348 | Не проверено |
| `methods: main:CanExit` | 361 | Не проверено |
| `methods: main:Shutdown` | 370 | Не проверено |
| `methods: main:OnFrame` | 375 | Не проверено |
| `methods: main:OnKeyDown` | 524 | Не проверено |
| `methods: main:OnKeyUp` | 528 | Не проверено |
| `methods: main:OnChar` | 532 | Не проверено |
| `methods: main:SetMode` | 536 | Не проверено |
| `methods: main:CallMode` | 541 | Не проверено |
| `methods: main:LoadSettings` | 548 | Не проверено |
| `methods: main:LoadSharedItems` | 710 | Не проверено |
| `methods: main:SaveSettings` | 765 | Не проверено |
| `methods: main:OpenPathPopup` | 846 | Не проверено |
| `methods: main:ChangeUserPath` | 881 | Не проверено |
| `methods: main:OpenOptionsPopup` | 892 | Не проверено |
| `methods: main:SetManifestBranch` | 1339 | Не проверено |
| `methods: main:OpenUpdatePopup` | 1359 | Не проверено |
| `methods: main:OpenAboutPopup` | 1395 | Не проверено |
| `methods: main:DrawBackground` | 1508 | Не проверено |
| `methods: main:DrawArrow` | 1516 | Не проверено |
| `methods: main:DrawCheckMark` | 1534 | Не проверено |
| `methods: main:RenderCircle` | 1558 | Не проверено |
| `methods: main:RenderRing` | 1581 | Не проверено |
| `methods: main:StatColor` | 1593 | Не проверено |
| `methods: main:MoveFolder` | 1603 | Не проверено |
| `methods: main:CopyFolder` | 1644 | Не проверено |
| `methods: main:OpenPopup` | 1679 | Не проверено |
| `methods: main:ClosePopup` | 1685 | Не проверено |
| `methods: main:OpenMessagePopup` | 1689 | Не проверено |
| `methods: main:OpenConfirmPopup` | 1702 | Не проверено |
| `methods: main:OpenNoteEditPopup` | 1767 | Не проверено |
| `methods: main:OpenNewFolderPopup` | 1839 | Не проверено |
| `methods: main:OpenCloudErrorPopup` | 1869 | Не проверено |
| `methods: main:SetWindowTitleSubtext` | 1896 | Не проверено |
