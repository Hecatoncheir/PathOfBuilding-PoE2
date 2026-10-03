-- Экспериментальный последовательный процесс движка для desktop.
local json = require("dkjson")
local protocolOutput = io.stdout
function print(...)
	local values = {}
	for index = 1, select("#", ...) do
		values[index] = tostring(select(index, ...))
	end
	io.stderr:write(table.concat(values, "\t"), "\n")
	io.stderr:flush()
end
dofile("HeadlessWrapper.lua")
assert(build, "Движок не инициализирован")
local revision = 0
local loaded = false
local running = true
local function fail(code, message)
	error({ code = code, message = message, recoverable = true }, 0)
end
local function snapshot()
	local values = {}
	for _, name in ipairs({ "TotalDPS", "Life", "Mana", "EnergyShield" }) do
		local value = build.calcsTab.mainOutput[name]
		if value ~= nil then
			if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then
				fail("CALCULATION_FAILED", "Некорректный показатель: " .. name)
			end
			values[name] = value
		end
	end
	return { targetVersion = build.targetVersion, treeVersion = build.spec.treeVersion, output = values }
end
local function validateXML(xml)
	if type(xml) ~= "string" or #xml > 4 * 1024 * 1024 then
		fail("INVALID_BUILD", "XML отсутствует или превышает лимит")
	end
	local parsed = common.xml.ParseXML(xml)
	if not parsed or not parsed[1] or parsed[1].elem ~= "PathOfBuilding2" then
		fail("INVALID_BUILD", "Ожидалась сборка PathOfBuilding2")
	end
end
local methods = {}
function methods.getTree()
	local nodes, edges = {}, {}
	for id, node in pairs(build.spec.nodes) do
		if type(node.x) == "number" and type(node.y) == "number" then
			nodes[#nodes + 1] = { id = id, x = node.x, y = node.y, name = node.name or "", type = node.type, icon = node.icon, allocated = node.alloc == true, stats = node.sd or {} }
			for _, other in ipairs(node.linked or {}) do
				if id < other.id then edges[#edges + 1] = { id, other.id } end
			end
		end
	end
	local backgrounds = {}
	for _, character in pairs(build.spec.tree.classes) do
		if character.name == build.spec.curClassName and character.background then
			backgrounds[#backgrounds + 1] = character.background
		end
		for _, asc in pairs(character.ascendancies or {}) do
			if asc.background then backgrounds[#backgrounds + 1] = asc.background end
		end
	end
	return { nodes = nodes, edges = edges, backgrounds = backgrounds, version = build.spec.treeVersion }
end
function methods.toggleNode(params)
	local node = build.spec.nodes[params.id]
	if not node or node.type == "ClassStart" or node.type == "AscendClassStart" or node.type == "Mastery" then
		fail("INVALID_REQUEST", "Узел недоступен для переключения")
	end
	if node.alloc then build.spec:DeallocNode(node)
	else
		if not node.path or #node.path == 0 then fail("INVALID_REQUEST", "Нет доступного пути к узлу") end
		build.spec:AllocNode(node)
	end
	build.buildFlag = true
	runCallback("OnFrame")
	return snapshot()
end
function methods.initialize()
	return { methods = { "initialize", "loadBuild", "getSnapshot", "setCustomMods", "exportBuild", "getTree", "toggleNode", "shutdown" }, platform = "windows-experimental" }
end
function methods.loadBuild(params)
	validateXML(params.xml)
	loadBuildFromXML(params.xml, "Flutter session")
	if launch.promptMsg then fail("INVALID_BUILD", tostring(launch.promptMsg)) end
	local result = snapshot()
	loaded = true
	return result
end
function methods.getSnapshot()
	return snapshot()
end
function methods.setCustomMods(params)
	if type(params.text) ~= "string" or #params.text > 65536 then
		fail("INVALID_REQUEST", "Некорректный текст модификаторов")
	end
	build.configTab.input.customMods = params.text
	build.configTab:BuildModList()
	runCallback("OnFrame")
	return snapshot()
end
function methods.exportBuild()
	return { xml = assert(build:SaveDB("Flutter session")) }
end
function methods.shutdown()
	running = false
	return { stopped = true }
end
local mutations = { loadBuild = true, setCustomMods = true, toggleNode = true }
local function dispatch(request)
	if type(request) ~= "table" or type(request.id) ~= "string" or type(request.method) ~= "string" then
		fail("INVALID_REQUEST", "Неверная структура запроса")
	end
	if request.protocol ~= 1 then fail("UNSUPPORTED_PROTOCOL", "Поддерживается protocol=1") end
	local method = methods[request.method]
	if not method then fail("UNKNOWN_METHOD", "Неизвестная команда") end
	local params = request.params or {}
	if type(params) ~= "table" then fail("INVALID_REQUEST", "params должен быть объектом") end
	local requiresBuild = request.method ~= "initialize" and request.method ~= "loadBuild" and request.method ~= "shutdown"
	if requiresBuild and not loaded then fail("INVALID_BUILD", "Сначала откройте сборку") end
	if requiresBuild and params.revision ~= revision then fail("STALE_REVISION", "Ревизия сборки устарела") end
	local previous = loaded and mutations[request.method] and build:SaveDB("rollback") or nil
	local ok, result = pcall(method, params)
	if not ok then
		if previous then
			local restored = pcall(loadBuildFromXML, previous, "Flutter session")
			if not restored then running = false; fail("CALCULATION_FAILED", "Восстановление не удалось; перезапустите процесс") end
		end
		if type(result) == "table" then error(result, 0) end
		fail("CALCULATION_FAILED", tostring(result))
	end
	if mutations[request.method] then revision = revision + 1 end
	return result
end
while running do
	local line = io.stdin:read("*l")
	if not line then break end
	local request
	local ok, result = pcall(function()
		if #line > 8 * 1024 * 1024 then fail("INVALID_REQUEST", "Запрос превышает лимит") end
		local position, decodeError
		request, position, decodeError = json.decode(line)
		if decodeError or not position or line:sub(position):match("%S") then fail("INVALID_REQUEST", "Некорректный JSON") end
		return dispatch(request)
	end)
	local response = { protocol = 1, id = type(request) == "table" and request.id or json.null, revision = revision }
	if ok then response.result = result
	else response.error = type(result) == "table" and result or { code = "CALCULATION_FAILED", message = tostring(result), recoverable = true } end
	protocolOutput:write(json.encode(response), "\n")
	protocolOutput:flush()
end
