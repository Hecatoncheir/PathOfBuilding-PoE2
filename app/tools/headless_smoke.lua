-- Проверить настоящий расчёт через существующий wrapper.
dofile("HeadlessWrapper.lua")
assert(build, "Сборка не инициализирована")
newBuild()
build.skillsTab:PasteSocketGroup("Fireball 20/0  1")
runCallback("OnFrame")
assert(build.calcsTab.mainOutput, "Нет результата расчёта")
local output = build.calcsTab.mainOutput
print("HEADLESS_SMOKE_OK")
print("TotalDPS=" .. tostring(output.TotalDPS))
print("Life=" .. tostring(output.Life))
assert(type(output.TotalDPS) == "number" and output.TotalDPS > 0, "Урон не рассчитан")
local initialDPS = output.TotalDPS
local initialLife = output.Life
local xml = assert(build:SaveDB("headless-smoke"), "Не удалось экспортировать XML")
build.configTab.input.customMods = "100% increased Spell Damage"
build.configTab:BuildModList()
runCallback("OnFrame")
local modifiedDPS = build.calcsTab.mainOutput.TotalDPS
assert(modifiedDPS > initialDPS, "Изменение не повлияло на расчёт")
assert(math.abs(modifiedDPS - initialDPS * 2) < 0.000001, "Модификатор не удвоил урон")
loadBuildFromXML(xml, "headless-smoke")
local restored = build.calcsTab.mainOutput
assert(math.abs(restored.TotalDPS - initialDPS) < 0.000001, "DPS изменился после повторной загрузки")
assert(restored.Life == initialLife, "Здоровье изменилось после повторной загрузки")
local restoredXML = assert(build:SaveDB("headless-smoke"))
loadBuildFromXML(restoredXML, "headless-smoke")
assert(build:SaveDB("headless-smoke") == restoredXML, "XML не стабилизировался после нормализации")
assert(math.abs(build.calcsTab.mainOutput.TotalDPS - initialDPS) < 0.000001, "Повторная загрузка изменила урон")
local function write(path, text)
    local file = assert(io.open(path, "wb"))
    file:write(text)
    file:close()
end
write("../app/docs/flutter/fixtures/fireball-basic/build.xml", xml)
write("../app/docs/flutter/fixtures/fireball-basic/restored.xml", restoredXML)
local json = require("dkjson")
write("../app/docs/flutter/fixtures/fireball-basic/expected.json", json.encode({
    fixture = "fireball-basic",
    treeVersion = build.spec.treeVersion,
    targetVersion = build.targetVersion,
    skill = "Fireball 20/0",
    baseline = { TotalDPS = initialDPS, Life = initialLife },
    modified = { customMods = "100% increased Spell Damage", TotalDPS = modifiedDPS },
    tolerance = { TotalDPS = 0.000001, Life = 0 },
    xmlRoundTripExact = restoredXML == xml,
}, { indent = true }) .. "\n")
print("HEADLESS_ROUNDTRIP_OK")
print("ModifiedTotalDPS=" .. tostring(modifiedDPS))
