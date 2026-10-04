-- Проверка сохранённого эталона без изменения его файлов.
local json = require("dkjson")
local fixture = "../app/docs/flutter/fixtures/fireball-basic/"

local function read(name)
	local file = assert(io.open(fixture .. name, "rb"))
	local text = file:read("*a")
	file:close()
	return text
end

local expected, _, decodeError = json.decode(read("expected.json"))
assert(expected, decodeError)
local function check(output, values)
	for name, value in pairs(values) do
		local actual = output[name]
		assert(type(actual) == "number" and actual == actual and math.abs(actual) < math.huge,
			"Некорректный показатель: " .. name)
		assert(math.abs(actual - value) <= (expected.tolerance[name] or 0),
			string.format("%s: ожидалось %.14g, получено %.14g", name, value, actual))
	end
end

dofile("HeadlessWrapper.lua")
assert(build, "Сборка не инициализирована")
local originalXML = read("build.xml")
loadBuildFromXML(originalXML, "fireball-basic")
assert(build.targetVersion == expected.targetVersion, "Изменилась целевая версия")
assert(build.spec.treeVersion == expected.treeVersion, "Изменилась версия дерева")
check(build.calcsTab.mainOutput, expected.baseline)
build.configTab.input.customMods = expected.modified.customMods
build.configTab:BuildModList()
runCallback("OnFrame")
check(build.calcsTab.mainOutput, { TotalDPS = expected.modified.TotalDPS })
loadBuildFromXML(originalXML, "fireball-basic")
check(build.calcsTab.mainOutput, expected.baseline)
-- Git может преобразовать окончания строк эталона на Windows.
local normalizedXML = read("restored.xml"):gsub("\r\n", "\n")
local exported = assert(build:SaveDB("fireball-basic")):gsub("\r\n", "\n")
assert(exported == normalizedXML, "Нормализованный экспорт отличается от эталона")
loadBuildFromXML(exported, "fireball-basic")
check(build.calcsTab.mainOutput, expected.baseline)
assert(build:SaveDB("fireball-basic"):gsub("\r\n", "\n") == normalizedXML,
	"Повторный экспорт нестабилен")
print("HEADLESS_BASELINE_OK")
