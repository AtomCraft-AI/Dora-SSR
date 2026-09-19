-- [yue]: Script/Dev/Entry.yue
local _module_0 = { } -- 1
local _ENV = Dora(Dora.ImGui) -- 9
local App <const> = App -- 11
local ShowConsole <const> = ShowConsole -- 11
local _G <const> = _G -- 11
local package <const> = package -- 11
local Dora <const> = Dora -- 11
local Content <const> = Content -- 11
local Path <const> = Path -- 11
local DB <const> = DB -- 11
local type <const> = type -- 11
local math <const> = math -- 11
local View <const> = View -- 11
local Director <const> = Director -- 11
local HttpServer <const> = HttpServer -- 11
local Size <const> = Size -- 11
local Vec2 <const> = Vec2 -- 11
local Controller <const> = Controller -- 11
local Color <const> = Color -- 11
local Buffer <const> = Buffer -- 11
local thread <const> = thread -- 11
local HttpClient <const> = HttpClient -- 11
local json <const> = json -- 11
local tonumber <const> = tonumber -- 11
local os <const> = os -- 11
local yue <const> = yue -- 11
local SetDefaultFont <const> = SetDefaultFont -- 11
local table <const> = table -- 11
local Cache <const> = Cache -- 11
local Texture2D <const> = Texture2D -- 11
local pairs <const> = pairs -- 11
local tostring <const> = tostring -- 11
local string <const> = string -- 11
local print <const> = print -- 11
local xml <const> = xml -- 11
local teal <const> = teal -- 11
local wait <const> = wait -- 11
local pcall <const> = pcall -- 11
local Log <const> = Log -- 11
local tolua <const> = tolua -- 11
local Routine <const> = Routine -- 11
local Entity <const> = Entity -- 11
local Platformer <const> = Platformer -- 11
local Audio <const> = Audio -- 11
local ubox <const> = ubox -- 11
local collectgarbage <const> = collectgarbage -- 11
local Wasm <const> = Wasm -- 11
local sleep <const> = sleep -- 11
local once <const> = once -- 11
local emit <const> = emit -- 11
local Profiler <const> = Profiler -- 11
local xpcall <const> = xpcall -- 11
local debug <const> = debug -- 11
local AlignNode <const> = AlignNode -- 11
local Label <const> = Label -- 11
local Checkbox <const> = Checkbox -- 11
local SameLine <const> = SameLine -- 11
local TextColored <const> = TextColored -- 11
local IsItemHovered <const> = IsItemHovered -- 11
local BeginTooltip <const> = BeginTooltip -- 11
local PushTextWrapPos <const> = PushTextWrapPos -- 11
local Text <const> = Text -- 11
local SeparatorText <const> = SeparatorText -- 11
local Button <const> = Button -- 11
local OpenPopup <const> = OpenPopup -- 11
local SetNextWindowPosCenter <const> = SetNextWindowPosCenter -- 11
local BeginPopupModal <const> = BeginPopupModal -- 11
local TextWrapped <const> = TextWrapped -- 11
local CloseCurrentPopup <const> = CloseCurrentPopup -- 11
local Separator <const> = Separator -- 11
local SetNextWindowSize <const> = SetNextWindowSize -- 11
local PushStyleVar <const> = PushStyleVar -- 11
local Begin <const> = Begin -- 11
local TreeNode <const> = TreeNode -- 11
local BeginPopup <const> = BeginPopup -- 11
local Selectable <const> = Selectable -- 11
local BeginDisabled <const> = BeginDisabled -- 11
local setmetatable <const> = setmetatable -- 11
local ipairs <const> = ipairs -- 11
local threadLoop <const> = threadLoop -- 11
local Keyboard <const> = Keyboard -- 11
local SetNextWindowBgAlpha <const> = SetNextWindowBgAlpha -- 11
local SetNextWindowPos <const> = SetNextWindowPos -- 11
local SetWindowFocus <const> = SetWindowFocus -- 11
local ImageButton <const> = ImageButton -- 11
local ImGui <const> = ImGui -- 11
local PushStyleColor <const> = PushStyleColor -- 11
local ShowStats <const> = ShowStats -- 11
local coroutine <const> = coroutine -- 11
local Image <const> = Image -- 11
local Dummy <const> = Dummy -- 11
local SetNextItemWidth <const> = SetNextItemWidth -- 11
local InputText <const> = InputText -- 11
local Columns <const> = Columns -- 11
local GetColumnWidth <const> = GetColumnWidth -- 11
local NextColumn <const> = NextColumn -- 11
local SetNextItemOpen <const> = SetNextItemOpen -- 11
local PushID <const> = PushID -- 11
local ScrollWhenDraggingOnVoid <const> = ScrollWhenDraggingOnVoid -- 11
local rawset <const> = rawset -- 11
local getmetatable <const> = getmetatable -- 11
App.idled = true -- 13
App.devMode = true -- 14
ShowConsole(true) -- 15
local moduleCache = { } -- 17
local oldRequire = _G.require -- 18
local require -- 19
require = function(path) -- 19
	local loaded = package.loaded[path] -- 20
	if loaded == nil then -- 21
		moduleCache[#moduleCache + 1] = path -- 22
		return oldRequire(path) -- 23
	end -- 21
	return loaded -- 24
end -- 19
_G.require = require -- 25
Dora.require = require -- 26
local searchPaths = Content.searchPaths -- 28
local useChinese = (App.locale:match("^zh") ~= nil) -- 30
local updateLocale -- 31
updateLocale = function() -- 31
	useChinese = (App.locale:match("^zh") ~= nil) -- 32
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 33
	Content.searchPaths = searchPaths -- 34
end -- 31
local isDesktop -- 36
do -- 36
	local _val_0 = App.platform -- 36
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 36
end -- 36
if DB:exist("Config") then -- 38
	do -- 39
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 39
		local _type_0 = type(_exp_0) -- 40
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 40
		if _tab_0 then -- 40
			local locale -- 40
			do -- 40
				local _obj_0 = _exp_0[1] -- 40
				local _type_1 = type(_obj_0) -- 40
				if "table" == _type_1 or "userdata" == _type_1 then -- 40
					locale = _obj_0[1] -- 40
				end -- 40
			end -- 40
			if locale ~= nil then -- 40
				if App.locale ~= locale then -- 40
					App.locale = locale -- 41
					updateLocale() -- 42
				end -- 40
			end -- 40
		end -- 39
	end -- 39
	if isDesktop then -- 43
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 44
		local _type_0 = type(_exp_0) -- 45
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 45
		if _tab_0 then -- 45
			local writablePath -- 45
			do -- 45
				local _obj_0 = _exp_0[1] -- 45
				local _type_1 = type(_obj_0) -- 45
				if "table" == _type_1 or "userdata" == _type_1 then -- 45
					writablePath = _obj_0[1] -- 45
				end -- 45
			end -- 45
			if writablePath ~= nil then -- 45
				Content.writablePath = writablePath -- 46
			end -- 45
		end -- 44
	end -- 43
end -- 38
local Config = require("Config") -- 48
if App.platform == "Emscripten" then -- 50
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 50
end -- 50
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 52
config:load() -- 87
if not (config.writablePath ~= nil) then -- 89
	config.writablePath = Content.appPath -- 90
end -- 89
if not (config.webIDEConnected ~= nil) then -- 92
	config.webIDEConnected = false -- 93
end -- 92
if (config.fpsLimited ~= nil) then -- 95
	App.fpsLimited = config.fpsLimited -- 96
else -- 98
	config.fpsLimited = App.fpsLimited -- 98
end -- 95
if (config.targetFPS ~= nil) then -- 100
	App.targetFPS = math.floor(config.targetFPS) -- 101
else -- 103
	config.targetFPS = App.targetFPS -- 103
end -- 100
if (config.vsync ~= nil) then -- 105
	View.vsync = config.vsync -- 106
else -- 108
	config.vsync = View.vsync -- 108
end -- 105
if (config.fixedFPS ~= nil) then -- 110
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 111
else -- 113
	config.fixedFPS = Director.scheduler.fixedFPS -- 113
end -- 110
if not (config.showPreview ~= nil) then -- 115
	config.showPreview = true -- 116
end -- 115
if not (config.mobileFeed ~= nil) then -- 118
	local _val_0 = App.platform -- 119
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 119
end -- 118
if not (config.webIDETourCompleted ~= nil) then -- 121
	config.webIDETourCompleted = false -- 122
end -- 121
if not (config.authRequired ~= nil) then -- 124
	local _val_0 = App.platform -- 125
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 125
end -- 124
HttpServer.authRequired = config.authRequired -- 126
local showEntry = true -- 128
isDesktop = false -- 130
if (function() -- 131
	local _val_0 = App.platform -- 131
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 131
end)() then -- 131
	isDesktop = true -- 132
	if config.fullScreen then -- 133
		App.fullScreen = true -- 134
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 135
		local size = Size(config.winWidth, config.winHeight) -- 136
		if App.winSize ~= size then -- 137
			App.winSize = size -- 138
		end -- 137
		local winX, winY -- 139
		do -- 139
			local _obj_0 = App.winPosition -- 139
			winX, winY = _obj_0.x, _obj_0.y -- 139
		end -- 139
		if (config.winX ~= nil) then -- 140
			winX = config.winX -- 141
		else -- 143
			config.winX = -1 -- 143
		end -- 140
		if (config.winY ~= nil) then -- 144
			winY = config.winY -- 145
		else -- 147
			config.winY = -1 -- 147
		end -- 144
		App.winPosition = Vec2(winX, winY) -- 148
	end -- 133
	if (config.alwaysOnTop ~= nil) then -- 149
		App.alwaysOnTop = config.alwaysOnTop -- 150
	else -- 152
		config.alwaysOnTop = false -- 152
	end -- 149
	if (config.virtualGamepadEnabled ~= nil) then -- 153
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 154
	else -- 156
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 156
	end -- 153
end -- 131
if (config.themeColor ~= nil) then -- 158
	App.themeColor = Color(config.themeColor) -- 159
else -- 161
	config.themeColor = App.themeColor:toARGB() -- 161
end -- 158
if not (config.locale ~= nil) then -- 163
	config.locale = App.locale -- 164
end -- 163
local showStats = false -- 166
if (config.showStats ~= nil) then -- 167
	showStats = config.showStats -- 168
else -- 170
	config.showStats = showStats -- 170
end -- 167
local showConsole = false -- 172
if (config.showConsole ~= nil) then -- 173
	showConsole = config.showConsole -- 174
else -- 176
	config.showConsole = showConsole -- 176
end -- 173
local showFooter = true -- 178
if (config.showFooter ~= nil) then -- 179
	showFooter = config.showFooter -- 180
else -- 182
	config.showFooter = showFooter -- 182
end -- 179
local setFooterVisible -- 184
setFooterVisible = function(visible) -- 184
	if visible == nil then -- 184
		visible = true -- 184
	end -- 184
	showFooter = visible -- 185
	config.showFooter = showFooter -- 186
end -- 184
_module_0["setFooterVisible"] = setFooterVisible -- 184
local filterBuf = Buffer(20) -- 188
if (config.filter ~= nil) then -- 189
	filterBuf.text = config.filter -- 190
else -- 192
	config.filter = "" -- 192
end -- 189
local engineDev = false -- 194
if (config.engineDev ~= nil) then -- 195
	engineDev = config.engineDev -- 196
else -- 198
	config.engineDev = engineDev -- 198
end -- 195
if (config.webProfiler ~= nil) then -- 200
	Director.profilerSending = config.webProfiler -- 201
else -- 203
	config.webProfiler = true -- 203
	Director.profilerSending = true -- 204
end -- 200
if not (config.drawerWidth ~= nil) then -- 206
	config.drawerWidth = 200 -- 207
end -- 206
_module_0.getConfig = function() -- 209
	return config -- 209
end -- 209
_module_0.getEngineDev = function() -- 210
	if not App.debugging then -- 211
		return false -- 211
	end -- 211
	return config.engineDev -- 212
end -- 210
local _anon_func_0 = function() -- 217
	local _val_0 = App.platform -- 217
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 217
end -- 217
_module_0.connectWebIDE = function() -- 214
	if not config.webIDEConnected then -- 215
		config.webIDEConnected = true -- 216
		if _anon_func_0() then -- 217
			local ratio = App.winSize.width / App.visualSize.width -- 218
			App.winSize = Size(640 * ratio, 480 * ratio) -- 219
		end -- 217
	end -- 215
end -- 214
local updateCheck -- 221
updateCheck = function() -- 221
	return thread(function() -- 221
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 222
		if res then -- 222
			local data = json.decode(res) -- 223
			if data then -- 223
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 224
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 225
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 226
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 227
				if na < a then -- 228
					goto not_new_version -- 229
				end -- 228
				if na == a then -- 230
					if nb < b then -- 231
						goto not_new_version -- 232
					end -- 231
					if nb == b then -- 233
						if nc < c then -- 234
							goto not_new_version -- 235
						end -- 234
						if nc == c then -- 236
							goto not_new_version -- 237
						end -- 236
					end -- 233
				end -- 230
				config.updateNotification = true -- 238
				::not_new_version:: -- 239
				config.lastUpdateCheck = os.time() -- 240
			end -- 223
		end -- 222
	end) -- 221
end -- 221
if (config.lastUpdateCheck ~= nil) then -- 242
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 243
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 244
		updateCheck() -- 245
	end -- 244
else -- 247
	updateCheck() -- 247
end -- 242
local Set, Struct, LintYueGlobals, GSplit -- 249
do -- 249
	local _obj_0 = require("Utils") -- 249
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 249
end -- 249
local yueext = yue.options.extension -- 250
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 252
local building = false -- 254
local getAllFiles -- 256
getAllFiles = function(path, exts, recursive) -- 256
	if recursive == nil then -- 256
		recursive = true -- 256
	end -- 256
	local filters = Set(exts) -- 257
	local files -- 258
	if recursive then -- 258
		files = Content:getAllFiles(path) -- 259
	else -- 261
		files = Content:getFiles(path) -- 261
	end -- 258
	local _accum_0 = { } -- 262
	local _len_0 = 1 -- 262
	for _index_0 = 1, #files do -- 262
		local file = files[_index_0] -- 262
		if not filters[Path:getExt(file)] then -- 263
			goto _continue_0 -- 263
		end -- 263
		_accum_0[_len_0] = file -- 264
		_len_0 = _len_0 + 1 -- 263
		::_continue_0:: -- 263
	end -- 262
	return _accum_0 -- 262
end -- 256
_module_0["getAllFiles"] = getAllFiles -- 256
local getFileEntries -- 266
getFileEntries = function(path, recursive, excludeFiles) -- 266
	if recursive == nil then -- 266
		recursive = true -- 266
	end -- 266
	if excludeFiles == nil then -- 266
		excludeFiles = nil -- 266
	end -- 266
	local entries = { } -- 267
	local excludes -- 268
	if excludeFiles then -- 268
		excludes = Set(excludeFiles) -- 269
	end -- 268
	local _list_0 = getAllFiles(path, { -- 270
		"lua", -- 270
		"xml", -- 270
		yueext, -- 270
		"tl" -- 270
	}, recursive) -- 270
	for _index_0 = 1, #_list_0 do -- 270
		local file = _list_0[_index_0] -- 270
		local entryName = Path:getName(file) -- 271
		if excludes and excludes[entryName] then -- 272
			goto _continue_0 -- 273
		end -- 272
		local fileName = Path:replaceExt(file, "") -- 274
		fileName = Path(path, fileName) -- 275
		local entryAdded -- 276
		for _index_1 = 1, #entries do -- 276
			local _des_0 = entries[_index_1] -- 276
			local ename, efile = _des_0.entryName, _des_0.fileName -- 276
			if entryName == ename and efile == fileName then -- 277
				entryAdded = true -- 277
				break -- 277
			end -- 277
		end -- 276
		if entryAdded then -- 278
			goto _continue_0 -- 278
		end -- 278
		local entry = { -- 279
			entryName = entryName, -- 279
			fileName = fileName -- 279
		} -- 279
		entries[#entries + 1] = entry -- 280
		::_continue_0:: -- 271
	end -- 270
	table.sort(entries, function(a, b) -- 281
		return a.entryName < b.entryName -- 281
	end) -- 281
	return entries -- 282
end -- 266
local allEntries = { -- 284
	dirty = { }, -- 284
	hasDirty = false, -- 284
	runId = 0 -- 284
} -- 284
allEntries.scanDir = function(path, dir, noPreview) -- 286
	if noPreview == nil then -- 286
		noPreview = false -- 286
	end -- 286
	local entries = { } -- 287
	if not dir:match("^%.") then -- 288
		local _list_0 = getAllFiles(Path(path, dir), { -- 289
			"lua", -- 289
			"xml", -- 289
			yueext, -- 289
			"tl", -- 289
			"wasm" -- 289
		}) -- 289
		for _index_0 = 1, #_list_0 do -- 289
			local file = _list_0[_index_0] -- 289
			if "init" == Path:getName(file):lower() then -- 290
				local fileName = Path:replaceExt(file, "") -- 291
				fileName = Path(path, dir, fileName) -- 292
				local projectPath = Path:getPath(fileName) -- 293
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 294
				local repo = nil -- 295
				if Content:exist(repoFile) then -- 296
					local str = Content:load(repoFile) -- 297
					if str then -- 297
						repo = json.decode(str) -- 298
					end -- 297
				end -- 296
				local entryName = Path:getName(projectPath) -- 299
				local entryAdded -- 300
				for _index_1 = 1, #entries do -- 300
					local _des_0 = entries[_index_1] -- 300
					local ename, efile = _des_0.entryName, _des_0.fileName -- 300
					if entryName == ename and efile == fileName then -- 301
						entryAdded = true -- 301
						break -- 301
					end -- 301
				end -- 300
				if entryAdded then -- 302
					goto _continue_0 -- 302
				end -- 302
				local examples = { } -- 303
				local tests = { } -- 304
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 305
				if Content:exist(examplePath) then -- 306
					local _list_1 = getFileEntries(examplePath) -- 307
					for _index_1 = 1, #_list_1 do -- 307
						local _des_0 = _list_1[_index_1] -- 307
						local name, ePath = _des_0.entryName, _des_0.fileName -- 307
						local entry = { -- 309
							entryName = name, -- 309
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 310
							workDir = projectPath -- 311
						} -- 308
						examples[#examples + 1] = entry -- 313
					end -- 307
				end -- 306
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 314
				if Content:exist(testPath) then -- 315
					local _list_1 = getFileEntries(testPath) -- 316
					for _index_1 = 1, #_list_1 do -- 316
						local _des_0 = _list_1[_index_1] -- 316
						local name, tPath = _des_0.entryName, _des_0.fileName -- 316
						local entry = { -- 318
							entryName = name, -- 318
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 319
							workDir = projectPath -- 320
						} -- 317
						tests[#tests + 1] = entry -- 322
					end -- 316
				end -- 315
				local entry = { -- 323
					entryName = entryName, -- 323
					fileName = fileName, -- 323
					projectPath = projectPath, -- 323
					examples = examples, -- 323
					tests = tests, -- 323
					repo = repo -- 323
				} -- 323
				local bannerFile -- 324
				do -- 324
					local _val_0 -- 324
					repeat -- 324
						if noPreview then -- 325
							_val_0 = nil -- 325
							break -- 325
						end -- 325
						if not config.showPreview then -- 326
							_val_0 = nil -- 326
							break -- 326
						end -- 326
						local f = Path(projectPath, ".dora", "banner.jpg") -- 327
						if Content:exist(f) then -- 328
							_val_0 = f -- 328
							break -- 328
						end -- 328
						f = Path(projectPath, ".dora", "banner.png") -- 329
						if Content:exist(f) then -- 330
							_val_0 = f -- 330
							break -- 330
						end -- 330
						f = Path(projectPath, "Image", "banner.jpg") -- 331
						if Content:exist(f) then -- 332
							_val_0 = f -- 332
							break -- 332
						end -- 332
						f = Path(projectPath, "Image", "banner.png") -- 333
						if Content:exist(f) then -- 334
							_val_0 = f -- 334
							break -- 334
						end -- 334
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 335
						if Content:exist(f) then -- 336
							_val_0 = f -- 336
							break -- 336
						end -- 336
					until true -- 324
					bannerFile = _val_0 -- 324
				end -- 324
				if bannerFile then -- 338
					entry.bannerFile = bannerFile -- 341
					thread(function() -- 342
						if Cache:loadAsync(bannerFile) then -- 343
							local bannerTex = Texture2D(bannerFile) -- 344
							if bannerTex then -- 344
								entry.bannerTex = bannerTex -- 345
							end -- 344
						end -- 343
					end) -- 342
				end -- 338
				entries[#entries + 1] = entry -- 346
			end -- 290
			::_continue_0:: -- 290
		end -- 289
	end -- 288
	return entries -- 347
end -- 286
local getProjectEntries -- 349
getProjectEntries = function(path, noPreview) -- 349
	if noPreview == nil then -- 349
		noPreview = false -- 349
	end -- 349
	local entries = { } -- 350
	local _list_0 = Content:getDirs(path) -- 351
	for _index_0 = 1, #_list_0 do -- 351
		local dir = _list_0[_index_0] -- 351
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 352
		for _index_1 = 1, #_list_1 do -- 352
			local entry = _list_1[_index_1] -- 352
			entries[#entries + 1] = entry -- 353
		end -- 352
	end -- 351
	table.sort(entries, function(a, b) -- 354
		return a.entryName < b.entryName -- 354
	end) -- 354
	return entries -- 355
end -- 349
_module_0["getProjectEntries"] = getProjectEntries -- 349
local gamesInDev -- 357
local doraTools -- 358
local isToolEntry -- 360
isToolEntry = function(entry) -- 360
	do -- 361
		local _type_0 = type(entry) -- 361
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 361
		if _tab_0 then -- 361
			local categories -- 361
			do -- 361
				local _obj_0 = entry.repo -- 361
				local _type_1 = type(_obj_0) -- 361
				if "table" == _type_1 or "userdata" == _type_1 then -- 361
					categories = _obj_0.categories -- 361
				end -- 361
			end -- 361
			if categories ~= nil then -- 361
				for _index_0 = 1, #categories do -- 362
					local category = categories[_index_0] -- 362
					if "string" == type(category) and category:lower() == "tool" then -- 363
						return true -- 364
					end -- 363
				end -- 362
			end -- 361
		end -- 361
	end -- 361
	return false -- 360
end -- 360
local getEntryTitle -- 366
getEntryTitle = function(entry) -- 366
	local title -- 367
	do -- 367
		local repo = entry.repo -- 367
		if repo then -- 367
			if repo.title and "table" == type(repo.title) then -- 368
				if useChinese then -- 369
					title = repo.title.zh -- 369
				else -- 369
					title = repo.title.en -- 369
				end -- 369
			end -- 368
		end -- 367
	end -- 367
	if title ~= nil then -- 370
		return title -- 370
	else -- 370
		return entry.entryName -- 370
	end -- 370
end -- 366
allEntries.rebuildEntries = function() -- 372
	gamesInDev = { } -- 373
	do -- 374
		local _accum_0 = { } -- 374
		local _len_0 = 1 -- 374
		local _list_0 = allEntries.builtinTools -- 374
		for _index_0 = 1, #_list_0 do -- 374
			local tool = _list_0[_index_0] -- 374
			_accum_0[_len_0] = tool -- 374
			_len_0 = _len_0 + 1 -- 374
		end -- 374
		doraTools = _accum_0 -- 374
	end -- 374
	local _list_0 = allEntries.projectEntries -- 375
	for _index_0 = 1, #_list_0 do -- 375
		local entry = _list_0[_index_0] -- 375
		if isToolEntry(entry) then -- 376
			entry.kind = "tool" -- 377
			doraTools[#doraTools + 1] = entry -- 378
		else -- 380
			entry.kind = "game" -- 380
			gamesInDev[#gamesInDev + 1] = entry -- 381
		end -- 376
	end -- 375
	for i = #allEntries, 1, -1 do -- 382
		allEntries[i] = nil -- 383
	end -- 382
	for _index_0 = 1, #gamesInDev do -- 384
		local game = gamesInDev[_index_0] -- 384
		allEntries[#allEntries + 1] = game -- 385
		local examples, tests = game.examples, game.tests -- 386
		for _index_1 = 1, #examples do -- 387
			local example = examples[_index_1] -- 387
			allEntries[#allEntries + 1] = example -- 388
		end -- 387
		for _index_1 = 1, #tests do -- 389
			local test = tests[_index_1] -- 389
			allEntries[#allEntries + 1] = test -- 390
		end -- 389
	end -- 384
end -- 372
local updateEntries -- 392
updateEntries = function() -- 392
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 393
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 394
	local _list_0 = allEntries.builtinTools -- 395
	for _index_0 = 1, #_list_0 do -- 395
		local tool = _list_0[_index_0] -- 395
		tool.kind = "tool" -- 396
		tool.builtin = true -- 397
	end -- 395
	return allEntries.rebuildEntries() -- 398
end -- 392
allEntries.refreshDirtyProjects = function() -- 400
	if not allEntries.hasDirty then -- 401
		return -- 401
	end -- 401
	local dirty = allEntries.dirty -- 402
	allEntries.dirty = { } -- 403
	allEntries.hasDirty = false -- 404
	for projectPath in pairs(dirty) do -- 405
		do -- 406
			local _accum_0 = { } -- 406
			local _len_0 = 1 -- 406
			local _list_0 = allEntries.projectEntries -- 406
			for _index_0 = 1, #_list_0 do -- 406
				local entry = _list_0[_index_0] -- 406
				if entry.projectPath ~= projectPath then -- 406
					_accum_0[_len_0] = entry -- 406
					_len_0 = _len_0 + 1 -- 406
				end -- 406
			end -- 406
			allEntries.projectEntries = _accum_0 -- 406
		end -- 406
		local parentPath = Path:getPath(projectPath) -- 407
		local dir = Path:getFilename(projectPath) -- 408
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 409
		for _index_0 = 1, #_list_0 do -- 409
			local entry = _list_0[_index_0] -- 409
			if entry.projectPath == projectPath then -- 410
				do -- 411
					local _obj_0 = allEntries.projectEntries -- 411
					_obj_0[#_obj_0 + 1] = entry -- 411
				end -- 411
				break -- 412
			end -- 410
		end -- 409
	end -- 405
	table.sort(allEntries.projectEntries, function(a, b) -- 413
		return a.entryName < b.entryName -- 413
	end) -- 413
	return allEntries.rebuildEntries() -- 414
end -- 400
updateEntries() -- 416
local getLaunchEntries -- 418
getLaunchEntries = function(refresh) -- 418
	if refresh == nil then -- 418
		refresh = false -- 418
	end -- 418
	if refresh then -- 419
		updateEntries() -- 419
	end -- 419
	local toInfo -- 420
	toInfo = function(entry, kind) -- 420
		local file = entry.fileName -- 421
		local asProj = not entry.builtin -- 422
		return { -- 424
			name = getEntryTitle(entry), -- 424
			file = file, -- 425
			kind = kind, -- 426
			asProj = asProj -- 427
		} -- 423
	end -- 420
	local games -- 429
	do -- 429
		local _accum_0 = { } -- 429
		local _len_0 = 1 -- 429
		for _index_0 = 1, #gamesInDev do -- 429
			local game = gamesInDev[_index_0] -- 429
			_accum_0[_len_0] = toInfo(game, "game") -- 429
			_len_0 = _len_0 + 1 -- 429
		end -- 429
		games = _accum_0 -- 429
	end -- 429
	local tools -- 430
	do -- 430
		local _accum_0 = { } -- 430
		local _len_0 = 1 -- 430
		for _index_0 = 1, #doraTools do -- 430
			local tool = doraTools[_index_0] -- 430
			_accum_0[_len_0] = toInfo(tool, "tool") -- 430
			_len_0 = _len_0 + 1 -- 430
		end -- 430
		tools = _accum_0 -- 430
	end -- 430
	return { -- 431
		games = games, -- 431
		tools = tools -- 431
	} -- 431
end -- 418
_module_0["getLaunchEntries"] = getLaunchEntries -- 418
local _anon_func_1 = function(entry, useChinese) -- 448
	local _obj_0 = entry.repo -- 448
	if _obj_0 ~= nil then -- 448
		local _obj_1 = _obj_0.description -- 448
		if _obj_1 ~= nil then -- 448
			return _obj_1[useChinese and "zh" or "en"] -- 448
		end -- 448
		return nil -- 448
	end -- 448
	return nil -- 448
end -- 448
local getMobileFeedEntries -- 433
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 433
	if refresh == nil then -- 433
		refresh = false -- 433
	end -- 433
	if dirtyProjectPath == nil then -- 433
		dirtyProjectPath = nil -- 433
	end -- 433
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 434
		allEntries.dirty[dirtyProjectPath] = true -- 435
		allEntries.hasDirty = true -- 436
	end -- 434
	if refresh then -- 437
		allEntries.dirty = { } -- 438
		allEntries.hasDirty = false -- 439
		updateEntries() -- 440
	else -- 442
		allEntries.refreshDirtyProjects() -- 442
	end -- 437
	local items = { } -- 443
	for _index_0 = 1, #gamesInDev do -- 444
		local entry = gamesInDev[_index_0] -- 444
		items[#items + 1] = { -- 446
			id = entry.entryName, -- 446
			title = getEntryTitle(entry), -- 447
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 448
			fileName = entry.fileName, -- 449
			workDir = Path:getPath(entry.fileName), -- 450
			bannerFile = entry.bannerFile, -- 451
			kind = "local" -- 452
		} -- 445
	end -- 444
	return items -- 454
end -- 433
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 433
local doCompile -- 456
doCompile = function(minify) -- 456
	if building then -- 457
		return -- 457
	end -- 457
	building = true -- 458
	local startTime = App.runningTime -- 459
	local luaFiles = { } -- 460
	local yueFiles = { } -- 461
	local xmlFiles = { } -- 462
	local tlFiles = { } -- 463
	local writablePath = Content.writablePath -- 464
	local buildPaths = { -- 466
		{ -- 467
			Content.assetPath, -- 467
			Path(writablePath, ".build"), -- 468
			"" -- 469
		} -- 466
	} -- 465
	for _index_0 = 1, #gamesInDev do -- 472
		local _des_0 = gamesInDev[_index_0] -- 472
		local fileName = _des_0.fileName -- 472
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 473
		buildPaths[#buildPaths + 1] = { -- 475
			Path(writablePath, gamePath), -- 475
			Path(writablePath, ".build", gamePath), -- 476
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 477
			gamePath -- 478
		} -- 474
	end -- 472
	for _index_0 = 1, #buildPaths do -- 479
		local _des_0 = buildPaths[_index_0] -- 479
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 479
		if not Content:exist(inputPath) then -- 480
			goto _continue_0 -- 480
		end -- 480
		local _list_0 = getAllFiles(inputPath, { -- 482
			"lua" -- 482
		}) -- 482
		for _index_1 = 1, #_list_0 do -- 482
			local file = _list_0[_index_1] -- 482
			luaFiles[#luaFiles + 1] = { -- 484
				file, -- 484
				Path(inputPath, file), -- 485
				Path(outputPath, file), -- 486
				gamePath -- 487
			} -- 483
		end -- 482
		local _list_1 = getAllFiles(inputPath, { -- 489
			yueext -- 489
		}) -- 489
		for _index_1 = 1, #_list_1 do -- 489
			local file = _list_1[_index_1] -- 489
			yueFiles[#yueFiles + 1] = { -- 491
				file, -- 491
				Path(inputPath, file), -- 492
				Path(outputPath, Path:replaceExt(file, "lua")), -- 493
				searchPath, -- 494
				gamePath -- 495
			} -- 490
		end -- 489
		local _list_2 = getAllFiles(inputPath, { -- 497
			"xml" -- 497
		}) -- 497
		for _index_1 = 1, #_list_2 do -- 497
			local file = _list_2[_index_1] -- 497
			xmlFiles[#xmlFiles + 1] = { -- 499
				file, -- 499
				Path(inputPath, file), -- 500
				Path(outputPath, Path:replaceExt(file, "lua")), -- 501
				gamePath -- 502
			} -- 498
		end -- 497
		local _list_3 = getAllFiles(inputPath, { -- 504
			"tl" -- 504
		}) -- 504
		for _index_1 = 1, #_list_3 do -- 504
			local file = _list_3[_index_1] -- 504
			if not file:match(".*%.d%.tl$") then -- 505
				tlFiles[#tlFiles + 1] = { -- 507
					file, -- 507
					Path(inputPath, file), -- 508
					Path(outputPath, Path:replaceExt(file, "lua")), -- 509
					searchPath, -- 510
					gamePath -- 511
				} -- 506
			end -- 505
		end -- 504
		::_continue_0:: -- 480
	end -- 479
	local paths -- 513
	do -- 513
		local _tbl_0 = { } -- 513
		local _list_0 = { -- 514
			luaFiles, -- 514
			yueFiles, -- 514
			xmlFiles, -- 514
			tlFiles -- 514
		} -- 514
		for _index_0 = 1, #_list_0 do -- 514
			local files = _list_0[_index_0] -- 514
			for _index_1 = 1, #files do -- 515
				local file = files[_index_1] -- 515
				_tbl_0[Path:getPath(file[3])] = true -- 513
			end -- 513
		end -- 513
		paths = _tbl_0 -- 513
	end -- 513
	for path in pairs(paths) do -- 517
		Content:mkdir(path) -- 517
	end -- 517
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 519
	local fileCount = 0 -- 520
	local errors = { } -- 521
	for _index_0 = 1, #yueFiles do -- 522
		local _des_0 = yueFiles[_index_0] -- 522
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 522
		local filename -- 523
		if gamePath then -- 523
			filename = Path(gamePath, file) -- 523
		else -- 523
			filename = file -- 523
		end -- 523
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 524
			if not codes then -- 525
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 526
				return -- 527
			end -- 525
			local success, result = LintYueGlobals(codes, globals) -- 528
			local yueCodes -- 529
			if not success then -- 530
				yueCodes = Content:load(input) -- 531
				if yueCodes then -- 531
					local CheckTIC80Code -- 532
					do -- 532
						local _obj_0 = require("Utils") -- 532
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 532
					end -- 532
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 533
					if isTIC80 then -- 534
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 535
					end -- 534
				end -- 531
			end -- 530
			if success then -- 536
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 537
			else -- 539
				if yueCodes then -- 539
					local globalErrors = { } -- 540
					for _index_1 = 1, #result do -- 541
						local _des_1 = result[_index_1] -- 541
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 541
						local countLine = 1 -- 542
						local code = "" -- 543
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 544
							if countLine == line then -- 545
								code = lineCode -- 546
								break -- 547
							end -- 545
							countLine = countLine + 1 -- 548
						end -- 544
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 549
					end -- 541
					if #globalErrors > 0 then -- 550
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 550
					end -- 550
				else -- 552
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 552
				end -- 539
				if #errors == 0 then -- 553
					return codes -- 553
				end -- 553
			end -- 536
		end, function(success) -- 524
			if success then -- 554
				print("Yue compiled: " .. tostring(filename)) -- 554
			end -- 554
			fileCount = fileCount + 1 -- 555
		end) -- 524
	end -- 522
	thread(function() -- 557
		for _index_0 = 1, #xmlFiles do -- 558
			local _des_0 = xmlFiles[_index_0] -- 558
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 558
			local filename -- 559
			if gamePath then -- 559
				filename = Path(gamePath, file) -- 559
			else -- 559
				filename = file -- 559
			end -- 559
			local sourceCodes = Content:loadAsync(input) -- 560
			local codes, err = xml.tolua(sourceCodes) -- 561
			if not codes then -- 562
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 563
			else -- 565
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 565
				print("Xml compiled: " .. tostring(filename)) -- 566
			end -- 562
			fileCount = fileCount + 1 -- 567
		end -- 558
	end) -- 557
	thread(function() -- 569
		for _index_0 = 1, #tlFiles do -- 570
			local _des_0 = tlFiles[_index_0] -- 570
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 570
			local filename -- 571
			if gamePath then -- 571
				filename = Path(gamePath, file) -- 571
			else -- 571
				filename = file -- 571
			end -- 571
			local sourceCodes = Content:loadAsync(input) -- 572
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 573
			if not codes then -- 574
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 575
			else -- 577
				Content:saveAsync(output, codes) -- 577
				print("Teal compiled: " .. tostring(filename)) -- 578
			end -- 574
			fileCount = fileCount + 1 -- 579
		end -- 570
	end) -- 569
	return thread(function() -- 581
		wait(function() -- 582
			return fileCount == totalFiles -- 582
		end) -- 582
		if minify then -- 583
			local _list_0 = { -- 584
				yueFiles, -- 584
				xmlFiles, -- 584
				tlFiles -- 584
			} -- 584
			for _index_0 = 1, #_list_0 do -- 584
				local files = _list_0[_index_0] -- 584
				for _index_1 = 1, #files do -- 584
					local file = files[_index_1] -- 584
					local output = Path:replaceExt(file[3], "lua") -- 585
					luaFiles[#luaFiles + 1] = { -- 587
						Path:replaceExt(file[1], "lua"), -- 587
						output, -- 588
						output -- 589
					} -- 586
				end -- 584
			end -- 584
			local FormatMini -- 591
			do -- 591
				local _obj_0 = require("luaminify") -- 591
				FormatMini = _obj_0.FormatMini -- 591
			end -- 591
			for _index_0 = 1, #luaFiles do -- 592
				local _des_0 = luaFiles[_index_0] -- 592
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 592
				if Content:exist(input) then -- 593
					local sourceCodes = Content:loadAsync(input) -- 594
					local res, err = FormatMini(sourceCodes) -- 595
					if res then -- 596
						Content:saveAsync(output, res) -- 597
						print("Minify: " .. tostring(file)) -- 598
					else -- 600
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 600
					end -- 596
				else -- 602
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 602
				end -- 593
			end -- 592
			package.loaded["luaminify.FormatMini"] = nil -- 603
			package.loaded["luaminify.ParseLua"] = nil -- 604
			package.loaded["luaminify.Scope"] = nil -- 605
			package.loaded["luaminify.Util"] = nil -- 606
		end -- 583
		local errorMessage = table.concat(errors, "\n") -- 607
		if errorMessage ~= "" then -- 608
			print(errorMessage) -- 608
		end -- 608
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 609
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 610
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 611
		Content:clearPathCache() -- 612
		teal.clear() -- 613
		yue.clear() -- 614
		building = false -- 615
	end) -- 581
end -- 456
local doClean -- 617
doClean = function() -- 617
	if building then -- 618
		return -- 618
	end -- 618
	local writablePath = Content.writablePath -- 619
	local targetDir = Path(writablePath, ".build") -- 620
	Content:clearPathCache() -- 621
	if Content:remove(targetDir) then -- 622
		return print("Cleaned: " .. tostring(targetDir)) -- 623
	end -- 622
end -- 617
local screenScale = 2.0 -- 625
local scaleContent = false -- 626
local isInEntry = true -- 627
local currentEntry = nil -- 628
local footerWindow = nil -- 630
local entryWindow = nil -- 631
local testingThread = nil -- 632
local mobileMode = config.mobileFeed -- 633
local pendingUIMode = nil -- 634
local feedHost = nil -- 635
local remixHost = nil -- 636
local startMobileUI = nil -- 637
local webControlled = false -- 638
local mobileHosts = { } -- 639
local suspendedMobileHosts = { } -- 640
local trackMobileHost -- 642
trackMobileHost = function(host) -- 642
	do -- 643
		local _accum_0 = { } -- 643
		local _len_0 = 1 -- 643
		for _index_0 = 1, #mobileHosts do -- 643
			local item = mobileHosts[_index_0] -- 643
			if item.parent then -- 643
				_accum_0[_len_0] = item -- 643
				_len_0 = _len_0 + 1 -- 643
			end -- 643
		end -- 643
		mobileHosts = _accum_0 -- 643
	end -- 643
	mobileHosts[#mobileHosts + 1] = host -- 644
	return host -- 645
end -- 642
local clearMobileUI -- 647
clearMobileUI = function() -- 647
	for _index_0 = 1, #mobileHosts do -- 648
		local host = mobileHosts[_index_0] -- 648
		if host.parent then -- 649
			host:removeFromParent(true) -- 649
		end -- 649
	end -- 648
	mobileHosts = { } -- 650
	suspendedMobileHosts = { } -- 651
	feedHost = nil -- 652
	remixHost = nil -- 653
end -- 647
local syncWebIDEControl -- 655
syncWebIDEControl = function() -- 655
	local connected = HttpServer.wsConnectionCount > 0 -- 656
	if connected then -- 657
		pendingUIMode = nil -- 658
		for _index_0 = 1, #mobileHosts do -- 659
			local host = mobileHosts[_index_0] -- 659
			if not host.parent then -- 660
				goto _continue_0 -- 660
			end -- 660
			if not (suspendedMobileHosts[host] ~= nil) then -- 661
				suspendedMobileHosts[host] = host.visible -- 662
				host:emit("SuspendLocalUI") -- 663
			end -- 661
			host.visible = false -- 664
			::_continue_0:: -- 660
		end -- 659
	elseif webControlled then -- 665
		for host, visible in pairs(suspendedMobileHosts) do -- 666
			if host.parent then -- 667
				host.visible = visible -- 668
				host:emit("ResumeLocalUI") -- 669
			end -- 667
		end -- 666
		suspendedMobileHosts = { } -- 670
	end -- 657
	webControlled = connected -- 671
	return connected -- 672
end -- 655
local getUIMode -- 674
getUIMode = function() -- 674
	return mobileMode and "mobile" or "traditional" -- 674
end -- 674
_module_0["getUIMode"] = getUIMode -- 674
local setUIMode -- 675
setUIMode = function(mode) -- 675
	if not (("mobile" == mode or "traditional" == mode)) then -- 676
		return false -- 676
	end -- 676
	if HttpServer.wsConnectionCount > 0 then -- 677
		return false -- 677
	end -- 677
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 678
		return false -- 678
	end -- 678
	local wantsMobile = mode == "mobile" -- 679
	if wantsMobile == mobileMode then -- 680
		return true -- 680
	end -- 680
	if mobileMode then -- 681
		if not (feedHost and feedHost.visible) then -- 682
			return false -- 682
		end -- 682
		feedHost:emit("SwitchUIMode") -- 684
		return pendingUIMode == false -- 685
	end -- 681
	pendingUIMode = true -- 686
	return true -- 687
end -- 675
_module_0["setUIMode"] = setUIMode -- 675
local applyUIMode -- 689
applyUIMode = function(enabled) -- 689
	if HttpServer.wsConnectionCount > 0 then -- 691
		return false -- 691
	end -- 691
	if enabled then -- 692
		local ok, err = pcall(startMobileUI) -- 693
		if not ok then -- 694
			if feedHost then -- 695
				feedHost:removeFromParent(true) -- 695
			end -- 695
			feedHost = nil -- 696
			mobileMode = false -- 697
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 698
			return false -- 699
		end -- 694
	else -- 701
		clearMobileUI() -- 701
		updateEntries() -- 702
	end -- 692
	mobileMode = enabled -- 703
	config.mobileFeed = enabled -- 704
	return true -- 705
end -- 689
local setupEventHandlers = nil -- 707
local allClear -- 709
allClear = function() -- 709
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 711
		clearMobileUI() -- 711
	end -- 711
	local systemNodes = { } -- 714
	local preserveSystemNode -- 715
	preserveSystemNode = function(node) -- 715
		if systemNodes[node] then -- 716
			return -- 716
		end -- 716
		systemNodes[node] = true -- 717
		do -- 718
			local clip = tolua.cast(node, "ClipNode") -- 718
			if clip then -- 718
				if clip.stencil then -- 719
					preserveSystemNode(clip.stencil) -- 719
				end -- 719
			end -- 718
		end -- 718
		return node:eachChild(function(child) -- 720
			preserveSystemNode(child) -- 721
			return false -- 722
		end) -- 720
	end -- 715
	for _index_0 = 1, #Routine do -- 723
		local routine = Routine[_index_0] -- 723
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 725
			goto _continue_0 -- 726
		else -- 728
			Routine:remove(routine) -- 728
		end -- 724
		::_continue_0:: -- 724
	end -- 723
	for _index_0 = 1, #moduleCache do -- 729
		local module = moduleCache[_index_0] -- 729
		package.loaded[module] = nil -- 730
	end -- 729
	moduleCache = { } -- 731
	Director:cleanup() -- 732
	Entity:clear() -- 733
	Platformer.Data:clear() -- 734
	Platformer.UnitAction:clear() -- 735
	Audio:stopAll(0.2) -- 736
	Struct:clear() -- 737
	View.postEffect = nil -- 738
	View.scale = scaleContent and screenScale or 1 -- 739
	Director.clearColor = Color(0xff1a1a1a) -- 740
	teal.clear() -- 741
	yue.clear() -- 742
	preserveSystemNode(Director.systemUI) -- 745
	for _, item in pairs(ubox()) do -- 746
		local node = tolua.cast(item, "Node") -- 747
		if node then -- 747
			if not systemNodes[node] then -- 748
				node:cleanup() -- 748
			end -- 748
		end -- 747
	end -- 746
	collectgarbage() -- 749
	collectgarbage() -- 750
	Wasm:clear() -- 751
	thread(function() -- 752
		sleep() -- 753
		return Cache:removeUnused() -- 754
	end) -- 752
	setupEventHandlers() -- 755
	Content.searchPaths = searchPaths -- 756
	App.idled = true -- 757
end -- 709
_module_0["allClear"] = allClear -- 709
local clearTempFiles -- 759
clearTempFiles = function() -- 759
	local writablePath = Content.writablePath -- 760
	if Content:exist(Path(writablePath, ".upload")) then -- 761
		Content:remove(Path(writablePath, ".upload")) -- 761
	end -- 761
	if Content:exist(Path(writablePath, ".download")) then -- 762
		return Content:remove(Path(writablePath, ".download")) -- 762
	end -- 762
end -- 759
local waitForWebStart = true -- 764
thread(function() -- 765
	sleep(2) -- 766
	waitForWebStart = false -- 767
end) -- 765
local reloadDevEntry -- 769
reloadDevEntry = function() -- 769
	return thread(function() -- 769
		waitForWebStart = true -- 770
		doClean() -- 771
		allClear() -- 772
		_G.require = oldRequire -- 773
		Dora.require = oldRequire -- 774
		package.loaded["Script.Dev.Entry"] = nil -- 775
		package.loaded["Script.Dev.WebServer"] = nil -- 776
		return Director.systemScheduler:schedule(function() -- 777
			Routine:clear() -- 778
			oldRequire("Script.Dev.Entry") -- 779
			return true -- 780
		end) -- 777
	end) -- 769
end -- 769
local setWorkspace -- 782
setWorkspace = function(path) -- 782
	clearTempFiles() -- 783
	Content.writablePath = path -- 784
	config.writablePath = Content.writablePath -- 785
	return thread(function() -- 786
		sleep() -- 787
		return reloadDevEntry() -- 788
	end) -- 786
end -- 782
_module_0["setWorkspace"] = setWorkspace -- 782
local quit = false -- 790
local activeSearchId = 0 -- 792
local handleSearchFiles -- 794
handleSearchFiles = function(payload) -- 794
	if not payload then -- 795
		return -- 795
	end -- 795
	local id = payload.id -- 796
	if id == nil then -- 797
		return -- 797
	end -- 797
	activeSearchId = id -- 798
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 799
	if path == nil then -- 800
		path = "" -- 800
	end -- 800
	if exts == nil then -- 801
		exts = { } -- 801
	end -- 801
	if globs == nil then -- 802
		globs = { } -- 802
	end -- 802
	if extensionLevels == nil then -- 803
		extensionLevels = { } -- 803
	end -- 803
	if pattern == nil then -- 804
		pattern = "" -- 804
	end -- 804
	if pattern == "" then -- 806
		return -- 806
	end -- 806
	local useRegex = payload.useRegex == true -- 807
	local caseSensitive = payload.caseSensitive == true -- 808
	local includeContent = payload.includeContent ~= false -- 809
	local contentWindow = payload.contentWindow or 0 -- 810
	return Director.systemScheduler:schedule(once(function() -- 811
		local stopped = false -- 812
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 813
			if activeSearchId ~= id then -- 814
				stopped = true -- 815
				return true -- 816
			end -- 814
			emit("AppWS", "Send", json.encode({ -- 818
				name = "SearchFilesResult", -- 818
				id = id, -- 818
				result = result -- 818
			})) -- 817
			return false -- 820
		end) -- 813
		return emit("AppWS", "Send", json.encode({ -- 822
			name = "SearchFilesDone", -- 822
			id = id, -- 822
			stopped = stopped -- 822
		})) -- 821
	end)) -- 811
end -- 794
local stop -- 825
stop = function() -- 825
	if isInEntry then -- 826
		return false -- 826
	end -- 826
	allClear() -- 827
	isInEntry = true -- 828
	currentEntry = nil -- 829
	return true -- 830
end -- 825
_module_0["stop"] = stop -- 825
local getCurrentEntryStatus -- 832
getCurrentEntryStatus = function() -- 832
	local entry = currentEntry -- 833
	if not (entry and not isInEntry) then -- 834
		return { -- 834
			success = true, -- 834
			running = false, -- 834
			runId = allEntries.runId -- 834
		} -- 834
	end -- 834
	local status = { -- 836
		success = true, -- 836
		running = true, -- 837
		kind = entry.runKind or "file", -- 838
		runId = allEntries.runId, -- 839
		entryName = entry.entryName, -- 840
		fileName = entry.fileName -- 841
	} -- 835
	if entry.workDir then -- 842
		status.workDir = entry.workDir -- 842
	end -- 842
	if entry.projectRoot then -- 843
		status.projectRoot = entry.projectRoot -- 843
	end -- 843
	return status -- 844
end -- 832
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 832
local _anon_func_2 = function(_with_0) -- 863
	local _val_0 = App.platform -- 863
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 863
end -- 863
setupEventHandlers = function() -- 846
	local _with_0 = Director.postNode -- 847
	_with_0:onAppEvent(function(eventType) -- 848
		if "Quit" == eventType then -- 849
			quit = true -- 850
			allClear() -- 851
			return clearTempFiles() -- 852
		elseif "Shutdown" == eventType then -- 853
			return stop() -- 854
		end -- 848
	end) -- 848
	_with_0:onAppChange(function(settingName) -- 855
		if "Theme" == settingName then -- 856
			config.themeColor = App.themeColor:toARGB() -- 857
		elseif "Locale" == settingName then -- 858
			config.locale = App.locale -- 859
			updateLocale() -- 860
			return teal.clear(true) -- 861
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 862
			if _anon_func_2(_with_0) then -- 863
				if "FullScreen" == settingName then -- 865
					config.fullScreen = App.fullScreen -- 865
				elseif "Position" == settingName then -- 866
					local _obj_0 = App.winPosition -- 866
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 866
				elseif "Size" == settingName then -- 867
					local width, height -- 868
					do -- 868
						local _obj_0 = App.winSize -- 868
						width, height = _obj_0.width, _obj_0.height -- 868
					end -- 868
					config.winWidth = width -- 869
					config.winHeight = height -- 870
				end -- 864
			end -- 863
		end -- 855
	end) -- 855
	_with_0:onAppWS(function(event) -- 871
		if event.type == "Close" then -- 872
			if HttpServer.wsConnectionCount == 0 then -- 873
				updateEntries() -- 874
			end -- 873
			return -- 875
		end -- 872
		if not (event.type == "Receive") then -- 876
			return -- 876
		end -- 876
		local data = json.decode(event.msg) -- 877
		if not data then -- 878
			return -- 878
		end -- 878
		local _exp_0 = data.name -- 879
		if "SearchFiles" == _exp_0 then -- 880
			return handleSearchFiles(data) -- 881
		elseif "SearchFilesStop" == _exp_0 then -- 882
			if data.id == nil or data.id == activeSearchId then -- 883
				activeSearchId = 0 -- 884
			end -- 883
		end -- 879
	end) -- 871
	_with_0:slot("UpdateEntries", function() -- 885
		return updateEntries() -- 885
	end) -- 885
	return _with_0 -- 847
end -- 846
setupEventHandlers() -- 887
clearTempFiles() -- 888
local downloadFile -- 890
downloadFile = function(url, target) -- 890
	return Director.systemScheduler:schedule(once(function() -- 890
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 891
			if quit then -- 892
				return true -- 892
			end -- 892
			emit("AppWS", "Send", json.encode({ -- 894
				name = "Download", -- 894
				url = url, -- 894
				status = "downloading", -- 894
				progress = current / total -- 895
			})) -- 893
			return false -- 891
		end) -- 891
		return emit("AppWS", "Send", json.encode(success and { -- 898
			name = "Download", -- 898
			url = url, -- 898
			status = "completed", -- 898
			progress = 1.0 -- 899
		} or { -- 901
			name = "Download", -- 901
			url = url, -- 901
			status = "failed", -- 901
			progress = 0.0 -- 902
		})) -- 897
	end)) -- 890
end -- 890
_module_0["downloadFile"] = downloadFile -- 890
local _anon_func_3 = function(file, require, workDir) -- 914
	if workDir == nil then -- 914
		workDir = Path:getPath(file) -- 914
	end -- 914
	Content:insertSearchPath(1, workDir) -- 915
	local scriptPath = Path(workDir, "Script") -- 916
	if Content:exist(scriptPath) then -- 917
		Content:insertSearchPath(1, scriptPath) -- 918
	end -- 917
	local result = require(file) -- 919
	if "function" == type(result) then -- 920
		result() -- 920
	end -- 920
	return nil -- 921
end -- 914
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 950
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 950
	label.alignment = "Left" -- 951
	label.textWidth = width - fontSize -- 952
	label.text = err -- 953
	return label -- 950
end -- 950
local enterEntryAsync -- 905
enterEntryAsync = function(entry) -- 905
	allEntries.runId = allEntries.runId + 1 -- 906
	isInEntry = false -- 907
	App.idled = false -- 908
	emit(Profiler.EventName, "ClearLoader") -- 909
	currentEntry = entry -- 910
	local file, workDir = entry.fileName, entry.workDir -- 911
	sleep() -- 912
	return xpcall(_anon_func_3, function(msg) -- 921
		local err = debug.traceback(msg) -- 923
		Log("Error", err) -- 924
		allClear() -- 925
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 926
		local viewWidth, viewHeight -- 927
		do -- 927
			local _obj_0 = View.size -- 927
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 927
		end -- 927
		local width, height = viewWidth - 20, viewHeight - 20 -- 928
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 929
		Director.ui:addChild((function() -- 930
			local root = AlignNode() -- 930
			do -- 931
				local _obj_0 = App.bufferSize -- 931
				width, height = _obj_0.width, _obj_0.height -- 931
			end -- 931
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 932
			root:onAppChange(function(settingName) -- 933
				if settingName == "Size" then -- 933
					do -- 934
						local _obj_0 = App.bufferSize -- 934
						width, height = _obj_0.width, _obj_0.height -- 934
					end -- 934
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 935
				end -- 933
			end) -- 933
			root:addChild((function() -- 936
				local _with_0 = ScrollArea({ -- 937
					width = width, -- 937
					height = height, -- 938
					paddingX = 0, -- 939
					paddingY = 50, -- 940
					viewWidth = height, -- 941
					viewHeight = height -- 942
				}) -- 936
				root:onAlignLayout(function(w, h) -- 944
					_with_0.position = Vec2(w / 2, h / 2) -- 945
					w = w - 20 -- 946
					h = h - 20 -- 947
					_with_0.view.children.first.textWidth = w - fontSize -- 948
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 949
				end) -- 944
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 950
				return _with_0 -- 936
			end)()) -- 936
			return root -- 930
		end)()) -- 930
		return err -- 954
	end, file, require, workDir) -- 913
end -- 905
_module_0["enterEntryAsync"] = enterEntryAsync -- 905
local enterDemoEntry -- 956
enterDemoEntry = function(entry) -- 956
	return thread(function() -- 956
		return enterEntryAsync(entry) -- 956
	end) -- 956
end -- 956
local reloadCurrentEntry -- 958
reloadCurrentEntry = function() -- 958
	if currentEntry then -- 959
		allClear() -- 960
		return enterDemoEntry(currentEntry) -- 961
	end -- 959
end -- 958
Director.clearColor = Color(0xff1a1a1a) -- 963
local descColor = Color(0xffa1a1a1) -- 964
local extraOperations -- 966
do -- 966
	local isOSSLicenseExist = Content:exist("LICENSES") -- 967
	local ossLicenses = nil -- 968
	local ossLicenseOpen = false -- 969
	local failedSetFolder = false -- 970
	local statusFlags = { -- 971
		"NoResize", -- 971
		"NoMove", -- 971
		"NoCollapse", -- 971
		"AlwaysAutoResize", -- 971
		"NoSavedSettings" -- 971
	} -- 971
	extraOperations = function() -- 978
		local zh = useChinese -- 979
		if isDesktop then -- 980
			local alwaysOnTop = config.alwaysOnTop -- 981
			do -- 982
				local changed -- 982
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 982
				if changed then -- 982
					App.alwaysOnTop = alwaysOnTop -- 983
					config.alwaysOnTop = alwaysOnTop -- 984
				end -- 982
			end -- 982
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 985
			do -- 986
				local changed -- 986
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 986
				if changed then -- 986
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 987
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 988
				end -- 986
			end -- 986
			SameLine() -- 989
			TextColored(descColor, "(?)") -- 990
			if IsItemHovered() then -- 991
				BeginTooltip(function() -- 992
					return PushTextWrapPos(360, function() -- 993
						return Text(zh and [[键盘映射：
方向键 / WASD → 十字键
J / K / U / I → A / B / X / Y
Tab / Ctrl → Back
Q / E → LB / RB
Enter → Start

启用后，普通按键和文本输入事件都会被屏蔽；以上映射键仅作为虚拟手柄输入。]] or [[Keyboard mapping:
Arrow keys / WASD → D-pad
J / K / U / I → A / B / X / Y
Tab / Ctrl → Back
Q / E → LB / RB
Enter → Start

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 994
					end) -- 993
				end) -- 992
			end -- 991
		end -- 980
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1009
		do -- 1014
			local changed -- 1014
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1014
			if changed then -- 1014
				config.showPreview = showPreview -- 1015
				updateEntries() -- 1016
				if not showPreview then -- 1017
					thread(function() -- 1018
						collectgarbage() -- 1019
						return Cache:removeUnused("Texture") -- 1020
					end) -- 1018
				end -- 1017
			end -- 1014
		end -- 1014
		do -- 1021
			local changed -- 1021
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1021
			if changed then -- 1021
				config.authRequired = authRequired -- 1022
				HttpServer.authRequired = authRequired -- 1023
			end -- 1021
		end -- 1021
		SameLine() -- 1024
		TextColored(descColor, "(?)") -- 1025
		if IsItemHovered() then -- 1026
			BeginTooltip(function() -- 1027
				return PushTextWrapPos(280, function() -- 1028
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1029
				end) -- 1028
			end) -- 1027
		end -- 1026
		do -- 1030
			local themeColor = App.themeColor -- 1031
			local writablePath = config.writablePath -- 1032
			SeparatorText(zh and "工作目录" or "Workspace") -- 1033
			PushTextWrapPos(400, function() -- 1034
				return TextColored(themeColor, writablePath) -- 1035
			end) -- 1034
			if not isDesktop then -- 1036
				goto skipSetting -- 1036
			end -- 1036
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1037
			if Button(zh and "改变目录" or "Set Folder") then -- 1038
				App:openFileDialog(true, function(path) -- 1039
					if path == "" then -- 1040
						return -- 1040
					end -- 1040
					local relPath = Path:getRelative(Content.assetPath, path) -- 1041
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1042
						return setWorkspace(path) -- 1043
					else -- 1045
						failedSetFolder = true -- 1045
					end -- 1042
				end) -- 1039
			end -- 1038
			if failedSetFolder then -- 1046
				failedSetFolder = false -- 1047
				OpenPopup(popupName) -- 1048
			end -- 1046
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1049
			BeginPopupModal(popupName, statusFlags, function() -- 1050
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1051
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1052
					return CloseCurrentPopup() -- 1053
				end -- 1052
			end) -- 1050
			SameLine() -- 1054
			if Button(zh and "使用默认" or "Use Default") then -- 1055
				setWorkspace(Content.appPath) -- 1056
			end -- 1055
			Separator() -- 1057
			::skipSetting:: -- 1058
		end -- 1030
		if isOSSLicenseExist then -- 1059
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1060
				if not ossLicenses then -- 1061
					ossLicenses = { } -- 1062
					local licenseText = Content:load("LICENSES") -- 1063
					ossLicenseOpen = (licenseText ~= nil) -- 1064
					if ossLicenseOpen then -- 1064
						licenseText = licenseText:gsub("\r\n", "\n") -- 1065
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1066
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1067
							if name then -- 1067
								ossLicenses[#ossLicenses + 1] = { -- 1068
									name, -- 1068
									text -- 1068
								} -- 1068
							end -- 1067
						end -- 1066
					end -- 1064
				else -- 1070
					ossLicenseOpen = true -- 1070
				end -- 1061
			end -- 1060
			if ossLicenseOpen then -- 1071
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1072
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1073
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1074
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1075
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 1078
						"NoSavedSettings" -- 1078
					}, function() -- 1079
						for _index_0 = 1, #ossLicenses do -- 1079
							local _des_0 = ossLicenses[_index_0] -- 1079
							local firstLine, text = _des_0[1], _des_0[2] -- 1079
							local name, license = firstLine:match("(.+): (.+)") -- 1080
							TextColored(themeColor, name) -- 1081
							SameLine() -- 1082
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1083
								return TextWrapped(text) -- 1083
							end) -- 1083
						end -- 1079
					end) -- 1075
				end) -- 1075
			end -- 1071
		end -- 1059
		if not App.debugging then -- 1085
			return -- 1085
		end -- 1085
		return TreeNode(zh and "开发操作" or "Development", function() -- 1086
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1087
				OpenPopup("build") -- 1087
			end -- 1087
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1088
				return BeginPopup("build", function() -- 1088
					if Selectable(zh and "编译" or "Compile") then -- 1089
						doCompile(false) -- 1089
					end -- 1089
					Separator() -- 1090
					if Selectable(zh and "压缩" or "Minify") then -- 1091
						doCompile(true) -- 1091
					end -- 1091
					Separator() -- 1092
					if Selectable(zh and "清理" or "Clean") then -- 1093
						return doClean() -- 1093
					end -- 1093
				end) -- 1088
			end) -- 1088
			if isInEntry then -- 1094
				if waitForWebStart then -- 1095
					BeginDisabled(function() -- 1096
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1096
					end) -- 1096
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1097
					reloadDevEntry() -- 1098
				end -- 1095
			end -- 1094
			do -- 1099
				local changed -- 1099
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1099
				if changed then -- 1099
					View.scale = scaleContent and screenScale or 1 -- 1100
				end -- 1099
			end -- 1099
			do -- 1101
				local changed -- 1101
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1101
				if changed then -- 1101
					config.engineDev = engineDev -- 1102
				end -- 1101
			end -- 1101
			do -- 1103
				local changed -- 1103
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1103
				if changed then -- 1103
					config.webIDETourCompleted = webIDETourCompleted -- 1104
				end -- 1103
			end -- 1103
			if testingThread then -- 1105
				return BeginDisabled(function() -- 1106
					return Button(zh and "开始自动测试" or "Test automatically") -- 1106
				end) -- 1106
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1107
				testingThread = thread(function() -- 1108
					local _ <close> = setmetatable({ }, { -- 1109
						__close = function() -- 1109
							allClear() -- 1110
							testingThread = nil -- 1111
							isInEntry = true -- 1112
							currentEntry = nil -- 1113
							return print("Testing done!") -- 1114
						end -- 1109
					}) -- 1109
					for _, entry in ipairs(allEntries) do -- 1115
						allClear() -- 1116
						print("Start " .. tostring(entry.entryName)) -- 1117
						enterDemoEntry(entry) -- 1118
						sleep(2) -- 1119
						print("Stop " .. tostring(entry.entryName)) -- 1120
					end -- 1115
				end) -- 1108
			end -- 1105
		end) -- 1086
	end -- 978
end -- 966
local icon = Path("Script", "Dev", "icon_s.png") -- 1122
local iconTex = nil -- 1123
thread(function() -- 1124
	if Cache:loadAsync(icon) then -- 1124
		iconTex = Texture2D(icon) -- 1124
	end -- 1124
end) -- 1124
local webStatus = nil -- 1126
local urlClicked = nil -- 1127
local authCode = string.format("%06d", math.random(0, 999999)) -- 1129
local authCodeTTL = 30.0 -- 1131
_module_0.getAuthCode = function() -- 1132
	return authCode -- 1132
end -- 1132
_module_0.invalidateAuthCode = function() -- 1133
	authCode = string.format("%06d", math.random(0, 999999)) -- 1134
	authCodeTTL = 30.0 -- 1135
end -- 1133
local AuthSession -- 1137
do -- 1137
	local pending = nil -- 1138
	local session = nil -- 1139
	AuthSession = { -- 1141
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1141
			pending = { -- 1143
				sessionId = sessionId, -- 1143
				confirmCode = confirmCode, -- 1144
				expiresAt = expiresAt, -- 1145
				ttl = ttl, -- 1146
				approved = false -- 1147
			} -- 1142
		end, -- 1141
		getPending = function() -- 1149
			return pending -- 1149
		end, -- 1149
		approvePending = function(sessionId) -- 1151
			if pending and pending.sessionId == sessionId then -- 1152
				pending.approved = true -- 1153
				return true -- 1154
			end -- 1152
			return false -- 1155
		end, -- 1151
		clearPending = function() -- 1157
			pending = nil -- 1157
		end, -- 1157
		setSession = function(sessionId, sessionSecret) -- 1159
			session = { -- 1161
				sessionId = sessionId, -- 1161
				sessionSecret = sessionSecret -- 1162
			} -- 1160
		end, -- 1159
		getSession = function() -- 1164
			return session -- 1164
		end -- 1164
	} -- 1140
end -- 1137
_module_0["AuthSession"] = AuthSession -- 1137
local transparant = Color(0x0) -- 1167
local windowFlags = { -- 1168
	"NoTitleBar", -- 1168
	"NoResize", -- 1168
	"NoMove", -- 1168
	"NoCollapse", -- 1168
	"NoSavedSettings", -- 1168
	"NoFocusOnAppearing", -- 1168
	"NoBringToFrontOnFocus" -- 1168
} -- 1168
local statusFlags = { -- 1177
	"NoTitleBar", -- 1177
	"NoResize", -- 1177
	"NoMove", -- 1177
	"NoCollapse", -- 1177
	"AlwaysAutoResize", -- 1177
	"NoSavedSettings" -- 1177
} -- 1177
local displayWindowFlags = { -- 1185
	"NoDecoration", -- 1185
	"NoSavedSettings", -- 1185
	"NoMove", -- 1185
	"NoScrollWithMouse", -- 1185
	"AlwaysAutoResize", -- 1185
	"NoFocusOnAppearing" -- 1185
} -- 1185
local gamepadInputWindowFlags = { -- 1193
	"NoDecoration", -- 1193
	"NoSavedSettings", -- 1193
	"NoMove", -- 1193
	"NoScrollbar", -- 1193
	"NoScrollWithMouse", -- 1193
	"NoFocusOnAppearing", -- 1193
	"NoBringToFrontOnFocus" -- 1193
} -- 1193
local initFooter = true -- 1202
local gamepadInputFocused = false -- 1203
local _anon_func_5 = function(allEntries, currentIndex) -- 1249
	if currentIndex > 1 then -- 1249
		return allEntries[currentIndex - 1] -- 1250
	else -- 1252
		return allEntries[#allEntries] -- 1252
	end -- 1249
end -- 1249
local _anon_func_6 = function(allEntries, currentIndex) -- 1256
	if currentIndex < #allEntries then -- 1256
		return allEntries[currentIndex + 1] -- 1257
	else -- 1259
		return allEntries[1] -- 1259
	end -- 1256
end -- 1256
footerWindow = threadLoop(function() -- 1204
	if mobileMode then -- 1205
		return -- 1205
	end -- 1205
	local zh = useChinese -- 1206
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1207
	if authCodeTTL <= 0 then -- 1208
		authCodeTTL = 30.0 -- 1209
		authCode = string.format("%06d", math.random(0, 999999)) -- 1210
	end -- 1208
	if HttpServer.wsConnectionCount > 0 then -- 1211
		return -- 1212
	end -- 1211
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1213
		if App.platform == "Emscripten" then -- 1214
			stop() -- 1216
		else -- 1218
			allClear() -- 1218
			App.devMode = false -- 1219
			App:shutdown() -- 1220
		end -- 1214
	end -- 1213
	do -- 1221
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1222
		if ctrl and Keyboard:isKeyDown("Q") then -- 1223
			stop() -- 1224
		end -- 1223
		if ctrl and Keyboard:isKeyDown("Z") then -- 1225
			reloadCurrentEntry() -- 1226
		end -- 1225
		if ctrl and Keyboard:isKeyDown(",") then -- 1227
			if showFooter then -- 1228
				showStats = not showStats -- 1228
			else -- 1228
				showStats = true -- 1228
			end -- 1228
			showFooter = true -- 1229
			config.showFooter = showFooter -- 1230
			config.showStats = showStats -- 1231
		end -- 1227
		if ctrl and Keyboard:isKeyDown(".") then -- 1232
			if showFooter then -- 1233
				showConsole = not showConsole -- 1233
			else -- 1233
				showConsole = true -- 1233
			end -- 1233
			showFooter = true -- 1234
			config.showFooter = showFooter -- 1235
			config.showConsole = showConsole -- 1236
		end -- 1232
		if ctrl and Keyboard:isKeyDown("/") then -- 1237
			showFooter = not showFooter -- 1238
			config.showFooter = showFooter -- 1239
		end -- 1237
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1240
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1241
		local currentIndex = nil -- 1242
		for i, entry in ipairs(allEntries) do -- 1243
			if currentEntry == entry then -- 1244
				currentIndex = i -- 1245
			end -- 1244
		end -- 1243
		if left then -- 1246
			allClear() -- 1247
			if currentIndex == nil then -- 1248
				currentIndex = #allEntries + 1 -- 1248
			end -- 1248
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1249
		end -- 1246
		if right then -- 1253
			allClear() -- 1254
			if currentIndex == nil then -- 1255
				currentIndex = 0 -- 1255
			end -- 1255
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1256
		end -- 1253
	end -- 1221
	if not showEntry then -- 1260
		return -- 1260
	end -- 1260
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1262
		reloadDevEntry() -- 1266
	end -- 1262
	if initFooter then -- 1267
		initFooter = false -- 1268
	end -- 1267
	local width, height -- 1270
	do -- 1270
		local _obj_0 = App.visualSize -- 1270
		width, height = _obj_0.width, _obj_0.height -- 1270
	end -- 1270
	if isInEntry then -- 1271
		gamepadInputFocused = false -- 1272
	else -- 1274
		SetNextWindowBgAlpha(0.0) -- 1274
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1275
		SetNextWindowPos(Vec2.zero, "Always") -- 1276
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1277
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1278
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1279
					if not gamepadInputFocused then -- 1280
						SetWindowFocus("DoraGamepadInput") -- 1281
						gamepadInputFocused = true -- 1282
					end -- 1280
				end) -- 1279
			end) -- 1278
		end) -- 1277
	end -- 1271
	if isInEntry or showFooter then -- 1284
		SetNextWindowSize(Vec2(width, 50)) -- 1285
		SetNextWindowPos(Vec2(0, height - 50)) -- 1286
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1287
			return PushStyleVar("WindowRounding", 0, function() -- 1288
				return Begin("Footer", windowFlags, function() -- 1289
					Separator() -- 1290
					if iconTex then -- 1291
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1292
							showStats = not showStats -- 1293
							config.showStats = showStats -- 1294
						end -- 1292
						SameLine() -- 1295
						if Button(">_", Vec2(30, 30)) then -- 1296
							showConsole = not showConsole -- 1297
							config.showConsole = showConsole -- 1298
						end -- 1296
					end -- 1291
					if isInEntry and config.updateNotification then -- 1299
						SameLine() -- 1300
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1301
							allClear() -- 1302
							config.updateNotification = false -- 1303
							enterDemoEntry({ -- 1305
								entryName = "SelfUpdater", -- 1305
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1306
							}) -- 1304
						end -- 1301
					end -- 1299
					if not isInEntry then -- 1307
						SameLine() -- 1308
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1309
						local currentIndex = nil -- 1310
						for i, entry in ipairs(allEntries) do -- 1311
							if currentEntry == entry then -- 1312
								currentIndex = i -- 1313
							end -- 1312
						end -- 1311
						if currentIndex then -- 1314
							if currentIndex > 1 then -- 1315
								SameLine() -- 1316
								if Button("<<", Vec2(30, 30)) then -- 1317
									allClear() -- 1318
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1319
								end -- 1317
							end -- 1315
							if currentIndex < #allEntries then -- 1320
								SameLine() -- 1321
								if Button(">>", Vec2(30, 30)) then -- 1322
									allClear() -- 1323
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1324
								end -- 1322
							end -- 1320
						end -- 1314
						SameLine() -- 1325
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1326
							reloadCurrentEntry() -- 1327
						end -- 1326
						if back then -- 1328
							allClear() -- 1329
							isInEntry = true -- 1330
							currentEntry = nil -- 1331
						end -- 1328
					end -- 1307
				end) -- 1289
			end) -- 1288
		end) -- 1287
	end -- 1284
	if isInEntry then -- 1333
		local showURL = true -- 1334
		local webIDEWidth -- 1335
		do -- 1335
			local base -- 1336
			if config.updateNotification then -- 1336
				base = 460 -- 1336
			else -- 1336
				base = 360 -- 1336
			end -- 1336
			local extra -- 1337
			if config.authRequired then -- 1337
				extra = 35 -- 1337
			else -- 1337
				extra = 0 -- 1337
			end -- 1337
			webIDEWidth = base + extra -- 1338
		end -- 1335
		if width < webIDEWidth then -- 1339
			showURL = false -- 1339
		end -- 1339
		SetNextWindowBgAlpha(0.0) -- 1340
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1341
		Begin("Web IDE", displayWindowFlags, function() -- 1342
			local pending = AuthSession.getPending() -- 1343
			local hovered = false -- 1344
			if not pending and showURL then -- 1345
				do -- 1346
					local url -- 1346
					if webStatus ~= nil then -- 1346
						url = webStatus.url -- 1346
					end -- 1346
					if url then -- 1346
						if isDesktop and not config.fullScreen then -- 1347
							if urlClicked then -- 1348
								BeginDisabled(function() -- 1349
									return Button(url) -- 1349
								end) -- 1349
							elseif Button(url) then -- 1350
								urlClicked = once(function() -- 1351
									return sleep(5) -- 1351
								end) -- 1351
								App:openURL("http://localhost:8866") -- 1352
							end -- 1348
						else -- 1354
							TextColored(descColor, url) -- 1354
						end -- 1347
					else -- 1356
						TextColored(descColor, zh and '不可用' or 'not available') -- 1356
					end -- 1346
				end -- 1346
				hovered = IsItemHovered() -- 1357
			else -- 1359
				TextColored(descColor, "(?)") -- 1359
				hovered = IsItemHovered() -- 1360
			end -- 1345
			SameLine() -- 1361
			local themeColor = App.themeColor -- 1362
			if pending then -- 1363
				if not pending.approved then -- 1364
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1365
					local ttl = pending.ttl or 1 -- 1366
					PushStyleColor("Text", themeColor, function() -- 1367
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1368
						hovered = hovered or IsItemHovered() -- 1369
					end) -- 1367
					SameLine() -- 1370
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1371
						AuthSession.approvePending(pending.sessionId) -- 1372
					end -- 1371
					if hovered then -- 1373
						return BeginTooltip(function() -- 1374
							return PushTextWrapPos(280, function() -- 1375
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1376
							end) -- 1375
						end) -- 1374
					end -- 1373
				end -- 1364
			else -- 1378
				if config.authRequired then -- 1378
					PushStyleColor("Text", themeColor, function() -- 1379
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1380
						hovered = hovered or IsItemHovered() -- 1381
					end) -- 1379
					if hovered then -- 1382
						return BeginTooltip(function() -- 1383
							return PushTextWrapPos(280, function() -- 1384
								local url -- 1385
								if webStatus ~= nil then -- 1385
									url = webStatus.url -- 1385
								end -- 1385
								if url then -- 1385
									local address -- 1386
									if showURL then -- 1386
										address = "Web IDE" -- 1386
									else -- 1386
										address = url -- 1386
									end -- 1386
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1387
								else -- 1389
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1389
								end -- 1385
							end) -- 1384
						end) -- 1383
					end -- 1382
				else -- 1391
					if hovered then -- 1391
						return BeginTooltip(function() -- 1392
							return PushTextWrapPos(280, function() -- 1393
								local url -- 1394
								if webStatus ~= nil then -- 1394
									url = webStatus.url -- 1394
								end -- 1394
								if url then -- 1394
									local address -- 1395
									if showURL then -- 1395
										address = "Web IDE" -- 1395
									else -- 1395
										address = url -- 1395
									end -- 1395
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1396
								else -- 1398
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1398
								end -- 1394
							end) -- 1393
						end) -- 1392
					end -- 1391
				end -- 1378
			end -- 1363
		end) -- 1342
	end -- 1333
	if not isInEntry then -- 1400
		SetNextWindowSize(Vec2(50, 50)) -- 1401
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1402
		PushStyleColor("WindowBg", transparant, function() -- 1403
			return Begin("Show", displayWindowFlags, function() -- 1403
				if width >= 370 then -- 1404
					local changed -- 1405
					changed, showFooter = Checkbox("##dev", showFooter) -- 1405
					if changed then -- 1405
						config.showFooter = showFooter -- 1406
					end -- 1405
				end -- 1404
			end) -- 1403
		end) -- 1403
	end -- 1400
	if isInEntry or showFooter then -- 1408
		if showStats then -- 1409
			PushStyleVar("WindowRounding", 0, function() -- 1410
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1411
				SetNextWindowSize(Vec2(0, height - 50)) -- 1412
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1413
				config.showStats = showStats -- 1414
			end) -- 1410
		end -- 1409
		if showConsole then -- 1415
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1416
			return PushStyleVar("WindowRounding", 6, function() -- 1417
				return ShowConsole() -- 1418
			end) -- 1417
		end -- 1415
	end -- 1408
end) -- 1204
local MaxWidth <const> = 960 -- 1420
local toolOpen = false -- 1422
local filterText = nil -- 1423
allEntries.anyEntryMatched = false -- 1424
allEntries.match = function(name) -- 1425
	local res = not filterText or name:lower():match(filterText) -- 1426
	if res then -- 1427
		allEntries.anyEntryMatched = true -- 1427
	end -- 1427
	return res -- 1428
end -- 1425
allEntries.thinSep = function() -- 1430
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1430
		return SeparatorText("") -- 1430
	end) -- 1430
end -- 1430
entryWindow = threadLoop(function() -- 1432
	local connected = syncWebIDEControl() -- 1433
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1435
		if not allEntries.pendingPackagePath then -- 1436
			local path = App:takeReceivedFile() -- 1437
			if path ~= "" then -- 1438
				allEntries.pendingPackagePath = path -- 1438
			end -- 1438
		end -- 1436
		if allEntries.pendingPackagePath then -- 1439
			pendingUIMode = true -- 1439
		end -- 1439
	end -- 1435
	if (pendingUIMode ~= nil) then -- 1441
		local nextMode = pendingUIMode -- 1442
		pendingUIMode = nil -- 1443
		applyUIMode(nextMode) -- 1444
	end -- 1441
	if mobileMode and not connected then -- 1445
		if isInEntry and not feedHost then -- 1446
			applyUIMode(true) -- 1446
		end -- 1446
		return -- 1447
	end -- 1445
	if App.fpsLimited ~= config.fpsLimited then -- 1448
		config.fpsLimited = App.fpsLimited -- 1449
	end -- 1448
	if App.targetFPS ~= config.targetFPS then -- 1450
		config.targetFPS = App.targetFPS -- 1451
	end -- 1450
	if View.vsync ~= config.vsync then -- 1452
		config.vsync = View.vsync -- 1453
	end -- 1452
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1454
		config.fixedFPS = Director.scheduler.fixedFPS -- 1455
	end -- 1454
	if Director.profilerSending ~= config.webProfiler then -- 1456
		config.webProfiler = Director.profilerSending -- 1457
	end -- 1456
	if urlClicked then -- 1458
		local _, result = coroutine.resume(urlClicked) -- 1459
		if result then -- 1460
			coroutine.close(urlClicked) -- 1461
			urlClicked = nil -- 1462
		end -- 1460
	end -- 1458
	if not isInEntry then -- 1463
		return -- 1463
	end -- 1463
	local zh = useChinese -- 1464
	local themeColor = App.themeColor -- 1465
	if connected then -- 1466
		local width, height -- 1467
		do -- 1467
			local _obj_0 = App.visualSize -- 1467
			width, height = _obj_0.width, _obj_0.height -- 1467
		end -- 1467
		SetNextWindowBgAlpha(0.5) -- 1468
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1469
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1470
			Separator() -- 1471
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1472
			if iconTex then -- 1473
				Image(icon, Vec2(24, 24)) -- 1474
				SameLine() -- 1475
			end -- 1473
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1476
			TextColored(descColor, slogon) -- 1477
			return Separator() -- 1478
		end) -- 1470
		return -- 1479
	end -- 1466
	if not showEntry then -- 1480
		return -- 1480
	end -- 1480
	local fullWidth, height -- 1482
	do -- 1482
		local _obj_0 = App.visualSize -- 1482
		fullWidth, height = _obj_0.width, _obj_0.height -- 1482
	end -- 1482
	local width = math.min(MaxWidth, fullWidth) -- 1483
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1484
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1485
	SetNextWindowPos(Vec2.zero) -- 1486
	SetNextWindowBgAlpha(0) -- 1487
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1488
	do -- 1489
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1490
			return Begin("Dora Dev", windowFlags, function() -- 1491
				Dummy(Vec2(fullWidth - 20, 0)) -- 1492
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1493
				SameLine() -- 1494
				if Button(zh and "Go 模式" or "Go Mode") then -- 1495
					setUIMode("mobile") -- 1496
				end -- 1495
				if fullWidth >= 540 then -- 1497
					SameLine() -- 1498
					Dummy(Vec2(fullWidth - 540, 0)) -- 1499
					SameLine() -- 1500
					SetNextItemWidth(zh and -95 or -140) -- 1501
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1502
						"AutoSelectAll" -- 1502
					}) then -- 1502
						config.filter = filterBuf.text -- 1503
					end -- 1502
					SameLine() -- 1504
					if Button(zh and '下载' or 'Download') then -- 1505
						allClear() -- 1506
						enterDemoEntry({ -- 1508
							entryName = "ResourceDownloader", -- 1508
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1509
						}) -- 1507
					end -- 1505
				end -- 1497
				return Separator() -- 1510
			end) -- 1491
		end) -- 1490
	end -- 1489
	allEntries.anyEntryMatched = false -- 1512
	SetNextWindowPos(Vec2(0, 50)) -- 1513
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1514
	do -- 1515
		return PushStyleColor("WindowBg", transparant, function() -- 1516
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1517
				return PushStyleVar("Alpha", 1, function() -- 1518
					return Begin("Content", windowFlags, function() -- 1519
						local DemoViewWidth <const> = 220 -- 1520
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1521
						if filterText then -- 1522
							filterText = filterText:lower() -- 1522
						end -- 1522
						if App.platform == "Emscripten" then -- 1523
							Dora.globals.webProjects.draw(zh, themeColor) -- 1524
							allEntries.anyEntryMatched = true -- 1525
						end -- 1523
						if #gamesInDev > 0 then -- 1526
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1527
							Columns(columns, false) -- 1528
							local realViewWidth = GetColumnWidth() - 50 -- 1529
							for _index_0 = 1, #gamesInDev do -- 1530
								local game = gamesInDev[_index_0] -- 1530
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1531
								local displayName -- 1540
								if repo then -- 1540
									if zh then -- 1541
										displayName = repo.title.zh -- 1541
									else -- 1541
										displayName = repo.title.en -- 1541
									end -- 1541
								end -- 1540
								if displayName == nil then -- 1542
									displayName = gameName -- 1542
								end -- 1542
								if allEntries.match(displayName) then -- 1543
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1544
									SameLine() -- 1545
									TextWrapped(displayName) -- 1546
									if columns > 1 then -- 1547
										if bannerFile and bannerTex then -- 1548
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1549
											local displayWidth <const> = realViewWidth -- 1550
											texHeight = displayWidth * texHeight / texWidth -- 1551
											texWidth = displayWidth -- 1552
											Dummy(Vec2.zero) -- 1553
											SameLine() -- 1554
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1555
										end -- 1548
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1556
											enterDemoEntry(game) -- 1557
										end -- 1556
									else -- 1559
										if bannerFile and bannerTex then -- 1559
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1560
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1561
											local sizing = 0.8 -- 1562
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1563
											texWidth = displayWidth * sizing -- 1564
											if texWidth > 500 then -- 1565
												sizing = 0.6 -- 1566
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1567
												texWidth = displayWidth * sizing -- 1568
											end -- 1565
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1569
											Dummy(Vec2(padding, 0)) -- 1570
											SameLine() -- 1571
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1572
										end -- 1559
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1573
											enterDemoEntry(game) -- 1574
										end -- 1573
									end -- 1547
									if #tests == 0 and #examples == 0 then -- 1575
										allEntries.thinSep() -- 1576
									end -- 1575
									NextColumn() -- 1577
								end -- 1543
								local showSep = false -- 1578
								if #examples > 0 then -- 1579
									local showExample = false -- 1580
									for _index_1 = 1, #examples do -- 1581
										local _des_0 = examples[_index_1] -- 1581
										local entryName = _des_0.entryName -- 1581
										if allEntries.match(entryName) then -- 1582
											showExample = true -- 1582
											break -- 1582
										end -- 1582
									end -- 1581
									if showExample then -- 1583
										showSep = true -- 1584
										Columns(1, false) -- 1585
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1586
										SameLine() -- 1587
										local opened -- 1588
										if (filterText ~= nil) then -- 1588
											opened = showExample -- 1588
										else -- 1588
											opened = false -- 1588
										end -- 1588
										if game.exampleOpen == nil then -- 1589
											game.exampleOpen = opened -- 1589
										end -- 1589
										SetNextItemOpen(game.exampleOpen) -- 1590
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1591
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1592
												Columns(maxColumns, false) -- 1593
												for _index_1 = 1, #examples do -- 1594
													local example = examples[_index_1] -- 1594
													local entryName = example.entryName -- 1595
													if not allEntries.match(entryName) then -- 1596
														goto _continue_0 -- 1596
													end -- 1596
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1597
														if Button(entryName, Vec2(-1, 40)) then -- 1598
															enterDemoEntry(example) -- 1599
														end -- 1598
														return NextColumn() -- 1600
													end) -- 1597
													opened = true -- 1601
													::_continue_0:: -- 1595
												end -- 1594
											end) -- 1592
										end) -- 1591
										game.exampleOpen = opened -- 1602
									end -- 1583
								end -- 1579
								if #tests > 0 then -- 1603
									local showTest = false -- 1604
									for _index_1 = 1, #tests do -- 1605
										local _des_0 = tests[_index_1] -- 1605
										local entryName = _des_0.entryName -- 1605
										if allEntries.match(entryName) then -- 1606
											showTest = true -- 1606
											break -- 1606
										end -- 1606
									end -- 1605
									if showTest then -- 1607
										showSep = true -- 1608
										Columns(1, false) -- 1609
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1610
										SameLine() -- 1611
										local opened -- 1612
										if (filterText ~= nil) then -- 1612
											opened = showTest -- 1612
										else -- 1612
											opened = false -- 1612
										end -- 1612
										if game.testOpen == nil then -- 1613
											game.testOpen = opened -- 1613
										end -- 1613
										SetNextItemOpen(game.testOpen) -- 1614
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1615
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1616
												Columns(maxColumns, false) -- 1617
												for _index_1 = 1, #tests do -- 1618
													local test = tests[_index_1] -- 1618
													local entryName = test.entryName -- 1619
													if not allEntries.match(entryName) then -- 1620
														goto _continue_0 -- 1620
													end -- 1620
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1621
														if Button(entryName, Vec2(-1, 40)) then -- 1622
															enterDemoEntry(test) -- 1623
														end -- 1622
														return NextColumn() -- 1624
													end) -- 1621
													opened = true -- 1625
													::_continue_0:: -- 1619
												end -- 1618
											end) -- 1616
										end) -- 1615
										game.testOpen = opened -- 1626
									end -- 1607
								end -- 1603
								if showSep then -- 1627
									Columns(1, false) -- 1628
									allEntries.thinSep() -- 1629
									Columns(columns, false) -- 1630
								end -- 1627
							end -- 1530
						end -- 1526
						if #doraTools > 0 then -- 1631
							local showTool = false -- 1632
							for _index_0 = 1, #doraTools do -- 1633
								local _des_0 = doraTools[_index_0] -- 1633
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1633
								local displayName -- 1634
								if repo then -- 1634
									if zh then -- 1635
										displayName = repo.title.zh -- 1635
									else -- 1635
										displayName = repo.title.en -- 1635
									end -- 1635
								end -- 1634
								if displayName == nil then -- 1636
									displayName = entryName -- 1636
								end -- 1636
								if allEntries.match(displayName) then -- 1637
									showTool = true -- 1637
									break -- 1637
								end -- 1637
							end -- 1633
							if not showTool then -- 1638
								goto endEntry -- 1638
							end -- 1638
							Columns(1, false) -- 1639
							TextColored(themeColor, "Dora SSR:") -- 1640
							SameLine() -- 1641
							Text(zh and "开发支持" or "Development Support") -- 1642
							Separator() -- 1643
							if #doraTools > 0 then -- 1644
								local opened -- 1645
								if (filterText ~= nil) then -- 1645
									opened = showTool -- 1645
								else -- 1645
									opened = false -- 1645
								end -- 1645
								SetNextItemOpen(toolOpen) -- 1646
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1647
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1648
										Columns(maxColumns, false) -- 1649
										for _index_0 = 1, #doraTools do -- 1650
											local tool = doraTools[_index_0] -- 1650
											local entryName, repo = tool.entryName, tool.repo -- 1651
											local displayName -- 1652
											if repo then -- 1652
												if zh then -- 1653
													displayName = repo.title.zh -- 1653
												else -- 1653
													displayName = repo.title.en -- 1653
												end -- 1653
											end -- 1652
											if displayName == nil then -- 1654
												displayName = entryName -- 1654
											end -- 1654
											if not allEntries.match(displayName) then -- 1655
												goto _continue_0 -- 1655
											end -- 1655
											if Button(displayName, Vec2(-1, 40)) then -- 1656
												enterDemoEntry(tool) -- 1657
											end -- 1656
											NextColumn() -- 1658
											::_continue_0:: -- 1651
										end -- 1650
										Columns(1, false) -- 1659
										opened = true -- 1660
									end) -- 1648
								end) -- 1647
								toolOpen = opened -- 1661
							end -- 1644
						end -- 1631
						::endEntry:: -- 1662
						if not allEntries.anyEntryMatched then -- 1663
							SetNextWindowBgAlpha(0) -- 1664
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1665
							Begin("Entries Not Found", displayWindowFlags, function() -- 1666
								Separator() -- 1667
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1668
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1669
								return Separator() -- 1670
							end) -- 1666
						end -- 1663
						Columns(1, false) -- 1671
						Dummy(Vec2(100, 80)) -- 1672
						return ScrollWhenDraggingOnVoid() -- 1673
					end) -- 1519
				end) -- 1518
			end) -- 1517
		end) -- 1516
	end -- 1515
end) -- 1432
if not (App.platform == "Emscripten") then -- 1678
	local sceneModuleCache = moduleCache -- 1679
	moduleCache = { } -- 1680
	webStatus = oldRequire("Script.Dev.WebServer") -- 1681
	moduleCache = sceneModuleCache -- 1682
end -- 1678
local _anon_func_7 = function(saved) -- 1705
	local _val_0 = saved.kind -- 1705
	return "local" == _val_0 or "discover" == _val_0 -- 1705
end -- 1705
local _anon_func_8 = function(saved) -- 1709
	local _val_0 = saved.activeTab -- 1709
	return "local" == _val_0 or "discover" == _val_0 -- 1709
end -- 1709
startMobileUI = function() -- 1684
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1685
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1686
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1687
	local getMobileFeedResources -- 1688
	do -- 1688
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1688
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1688
	end -- 1688
	local loadCachedCatalog -- 1689
	do -- 1689
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1689
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1689
	end -- 1689
	local getResourceInstallPath -- 1690
	do -- 1690
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1690
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1690
	end -- 1690
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1691
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1692
	local feedOptions = nil -- 1693
	local mobileLaunchErrors = { } -- 1694
	local withMobileLaunchErrors -- 1695
	withMobileLaunchErrors = function(items) -- 1695
		for _index_0 = 1, #items do -- 1696
			local item = items[_index_0] -- 1696
			item.launchError = mobileLaunchErrors[item.id] -- 1697
		end -- 1696
		return items -- 1698
	end -- 1695
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1699
	local loadRememberedMobileFeedState -- 1700
	loadRememberedMobileFeedState = function() -- 1700
		local raw = rememberedMobileFeedData -- 1701
		if not (type(raw) == "string" and raw ~= "") then -- 1702
			return -- 1702
		end -- 1702
		local ok, saved = pcall(json.decode, raw) -- 1703
		if not (ok and type(saved) == "table") then -- 1704
			return -- 1704
		end -- 1704
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1705
			local state = { -- 1706
				activeTab = saved.kind -- 1706
			} -- 1706
			state[saved.kind] = saved -- 1707
			return state -- 1708
		end -- 1705
		local state = { -- 1709
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1709
		} -- 1709
		local _list_0 = { -- 1710
			"local", -- 1710
			"discover" -- 1710
		} -- 1710
		for _index_0 = 1, #_list_0 do -- 1710
			local kind = _list_0[_index_0] -- 1710
			local entry = saved[kind] -- 1711
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1712
				state[kind] = entry -- 1712
			end -- 1712
		end -- 1710
		return state -- 1713
	end -- 1700
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1714
		activeTab = "local" -- 1714
	} -- 1714
	local rememberMobileFeedEntry -- 1715
	rememberMobileFeedEntry = function(entry) -- 1715
		rememberedMobileFeedState.activeTab = entry.kind -- 1716
		rememberedMobileFeedState[entry.kind] = { -- 1718
			id = entry.id, -- 1718
			kind = entry.kind, -- 1719
			workDir = entry.workDir, -- 1720
			fileName = entry.fileName -- 1721
		} -- 1717
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1723
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1724
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1725
			rememberedMobileFeedData -- 1725
		}) -- 1725
	end -- 1715
	local restartMobileFeed -- 1726
	restartMobileFeed = function(entry) -- 1726
		if feedHost then -- 1727
			feedHost:removeFromParent(true) -- 1727
		end -- 1727
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1728
		local initialEntries = { } -- 1729
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1730
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1731
		feedOptions.initialEntries = initialEntries -- 1732
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1733
	end -- 1726
	local startMobilePlay -- 1734
	startMobilePlay = function(entry, resumeRemix) -- 1734
		if resumeRemix == nil then -- 1734
			resumeRemix = false -- 1734
		end -- 1734
		if HttpServer.wsConnectionCount > 0 then -- 1735
			return -- 1735
		end -- 1735
		local originFeed = feedHost -- 1736
		local originRemix = resumeRemix and remixHost or nil -- 1737
		if originRemix then -- 1738
			originRemix.visible = false -- 1739
		else -- 1741
			if remixHost then -- 1741
				remixHost:removeFromParent(true) -- 1741
			end -- 1741
			remixHost = nil -- 1742
		end -- 1738
		mobileLaunchErrors[entry.id] = nil -- 1743
		entry.launchError = nil -- 1744
		local playActive = true -- 1745
		local restoreMobileFeed -- 1746
		restoreMobileFeed = function() -- 1746
			if not playActive then -- 1747
				return -- 1747
			end -- 1747
			playActive = false -- 1748
			allClear() -- 1749
			isInEntry = true -- 1750
			currentEntry = nil -- 1751
			if originRemix and originRemix.parent and mobileMode then -- 1752
				originRemix.visible = true -- 1753
				return originRemix:emit("ResumePreview", mobileLaunchErrors[entry.id]) -- 1754
			else -- 1756
				return restartMobileFeed(entry) -- 1756
			end -- 1752
		end -- 1746
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1758
			onExit = function() -- 1758
				return restoreMobileFeed() -- 1758
			end, -- 1758
			onRuntimeError = function() -- 1759
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1760
				return restoreMobileFeed() -- 1761
			end -- 1759
		})) -- 1757
		return thread(function() -- 1763
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1767
			if not playActive then -- 1768
				return -- 1768
			end -- 1768
			if success then -- 1769
				if originFeed and originFeed.parent then -- 1770
					originFeed.visible = false -- 1770
				end -- 1770
				return -- 1771
			end -- 1769
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1772
			return restoreMobileFeed() -- 1773
		end) -- 1763
	end -- 1734
	feedOptions = { -- 1775
		takeReceivedFile = function() -- 1775
			if allEntries.pendingPackagePath then -- 1776
				local path = allEntries.pendingPackagePath -- 1777
				allEntries.pendingPackagePath = nil -- 1778
				return path -- 1779
			end -- 1776
			return App:takeReceivedFile() -- 1780
		end, -- 1775
		onSwitchMode = function() -- 1781
			if HttpServer.wsConnectionCount == 0 then -- 1781
				pendingUIMode = false -- 1781
			end -- 1781
		end, -- 1781
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1782
		getLocalEntries = function(importedProjectPath) -- 1783
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1784
			feedOptions.dirtyProjectPath = nil -- 1785
			return withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1786
		end, -- 1783
		syncDiscover = function(onProgress, onDone, force) -- 1787
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1787
		end, -- 1787
		getDiscoverEntries = function() -- 1788
			local cached = loadCachedCatalog() -- 1789
			if not (cached.success and cached.snapshot) then -- 1790
				return { } -- 1790
			end -- 1790
			local items = { } -- 1791
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1792
			for _index_0 = 1, #_list_0 do -- 1792
				local resource = _list_0[_index_0] -- 1792
				local installed = lifecycle.isMobileResourceReady(resource) -- 1793
				local installPath = getResourceInstallPath(resource.id) -- 1794
				items[#items + 1] = { -- 1796
					id = resource.id, -- 1796
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1797
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1798
					kind = "discover", -- 1799
					bannerFile = resource.bannerPath, -- 1800
					workDir = installed and installPath or nil, -- 1801
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1802
					installed = installed, -- 1803
					resource = resource, -- 1804
					catalogCommit = cached.snapshot.commit, -- 1805
					launchError = mobileLaunchErrors[resource.id] -- 1806
				} -- 1795
			end -- 1792
			return items -- 1808
		end, -- 1788
		prepare = function(entry, repairIncomplete, onProgress, onDone) -- 1809
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1810
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1811
			end), repairIncomplete) -- 1810
		end, -- 1809
		createProject = function(name, language) -- 1813
			local result = projectCreate.createMobileProject(name, language) -- 1814
			if not result.success then -- 1815
				return result -- 1815
			end -- 1815
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1816
			for _index_0 = 1, #_list_0 do -- 1816
				local entry = _list_0[_index_0] -- 1816
				if entry.workDir == result.workDir then -- 1817
					return { -- 1818
						success = true, -- 1818
						entry = entry -- 1818
					} -- 1818
				end -- 1817
			end -- 1816
			return { -- 1819
				success = false, -- 1819
				error = "created-project-not-found" -- 1819
			} -- 1819
		end, -- 1813
		onPlay = function(entry) -- 1820
			return startMobilePlay(entry) -- 1820
		end, -- 1820
		onRemix = function(entry, createProject) -- 1821
			if HttpServer.wsConnectionCount > 0 then -- 1822
				return -- 1822
			end -- 1822
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1823
			local originFeed = feedHost -- 1824
			feedHost.visible = false -- 1825
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1827
				entry = entry, -- 1827
				createProject = createProject, -- 1828
				onProjectChanged = function(current) -- 1829
					feedOptions.dirtyProjectPath = current.workDir -- 1829
				end, -- 1829
				onBack = function() -- 1830
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1831
						if entry.workDir then -- 1832
							originFeed:emit("RestoreFeedEntry", entry) -- 1832
						end -- 1832
						originFeed.visible = true -- 1833
					end -- 1831
				end, -- 1830
				onPlay = function(current) -- 1834
					return startMobilePlay(current, true) -- 1834
				end -- 1834
			})) -- 1826
		end -- 1821
	} -- 1774
	return restartMobileFeed() -- 1837
end -- 1684
if mobileMode then -- 1839
	applyUIMode(true) -- 1839
end -- 1839
return _module_0 -- 1
