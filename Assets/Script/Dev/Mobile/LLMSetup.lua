local ____lualib = require("lualib_bundle")
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local compactText, activeSetup
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
local ____Visual = require("Dev/Mobile/Visual")
local GoIcon = ____Visual.GoIcon
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local reference = ____DoraX.reference
local toNode = ____DoraX.toNode
local ____Gamepad = require("Dev/Mobile/Gamepad")
local attachGamepad = ____Gamepad.attachGamepad
local ScrollArea = require("UI/Control/Basic/ScrollArea")
local ____Dora = require("Dora")
local App = ____Dora.App
local DB = ____Dora.DB
local Director = ____Dora.Director
local HttpServer = ____Dora.HttpServer
local Label = ____Dora.Label
local Node = ____Dora.Node
local Move = ____Dora.Move
local Opacity = ____Dora.Opacity
local Spawn = ____Dora.Spawn
local Ease = ____Dora.Ease
local Vec2 = ____Dora.Vec2
local thread = ____Dora.thread
local sleep = ____Dora.sleep
local ____Controls = require("Dev/Mobile/Controls")
local MobileButton = ____Controls.MobileButton
local MobilePanelSurface = ____Controls.MobilePanelSurface
local ____TextInput = require("Dev/Mobile/TextInput")
local createTextInput = ____TextInput.createTextInput
local inputLength = ____TextInput.inputLength
local inputSlice = ____TextInput.inputSlice
local ____Visual = require("Dev/Mobile/Visual")
local RoundedSurface = ____Visual.SceneSurface
function compactText(value, limit)
	local length = (utf8.len(value)) or 0
	if length <= limit then
		return value
	end
	local stop = utf8.offset(value, limit) or #value
	return string.sub(value, 1, stop - 1) .. "…"
end
local mobileFontScale = goTheme.fontScale
local function auxiliary(body)
	return ("{\"auxiliaryOptions\":" .. body) .. "}"
end
____exports.mobileLLMPresets = {
	{
		id = "deepseek",
		name = "DeepSeek",
		url = "https://api.deepseek.com/v1/chat/completions",
		model = "deepseek-v4-pro",
		contextWindow = 1000000,
		maxTokens = 64000,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "moonshot",
		name = "Moonshot",
		url = "https://api.moonshot.cn/v1/chat/completions",
		model = "kimi-k3",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":\"low\"}")
	},
	{
		id = "qwen",
		name = "Qwen",
		url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
		model = "qwen3.7-max",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"enable_thinking\":false}")
	},
	{
		id = "openrouter",
		name = "OpenRouter",
		url = "https://openrouter.ai/api/v1/chat/completions",
		model = "~anthropic/claude-sonnet-latest",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"reasoning\":{\"effort\":\"none\"}}")
	},
	{
		id = "openai",
		name = "OpenAI",
		url = "https://api.openai.com/v1/chat/completions",
		model = "gpt-5.6",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":null,\"max_completion_tokens\":8192,\"reasoning_effort\":\"none\"}")
	},
	{
		id = "aihubmix",
		name = "AiHubMix",
		url = "https://aihubmix.com/v1/chat/completions",
		model = "gpt-5.6-luna",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":null,\"max_completion_tokens\":8192,\"reasoning_effort\":\"none\"}")
	},
	{
		id = "siliconflow",
		name = "SiliconFlow",
		url = "https://api.siliconflow.cn/v1/chat/completions",
		model = "deepseek-ai/DeepSeek-V4-Pro",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"enable_thinking\":false}")
	},
	{
		id = "volcengine",
		name = "VolcEngine",
		url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
		model = "doubao-seed-2-0-pro-260215",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "volcengine-coding-plan",
		name = "VolcEngine Coding Plan",
		url = "https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions",
		model = "ark-code-latest",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "byteplus",
		name = "BytePlus",
		url = "https://ark.ap-southeast.bytepluses.com/api/v3/chat/completions",
		model = "dola-seed-2-1-turbo-260628",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "byteplus-coding-plan",
		name = "BytePlus Coding Plan",
		url = "https://ark.ap-southeast.bytepluses.com/api/coding/v3/chat/completions",
		model = "ark-code-latest",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "minimax",
		name = "MiniMax",
		url = "https://api.minimax.io/v1/chat/completions",
		model = "MiniMax-M2.7",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null}")
	},
	{
		id = "minimax-cn",
		name = "MiniMax (CN)",
		url = "https://api.minimaxi.com/v1/chat/completions",
		model = "MiniMax-M2.7",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null}")
	},
	{
		id = "mimo",
		name = "Xiaomi MiMo",
		url = "https://api.xiaomimimo.com/v1/chat/completions",
		model = "mimo-v2.5-pro",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = "{\"max_tokens\":null,\"max_completion_tokens\":8192,\"top_p\":0.95,\"auxiliaryOptions\":{\"max_tokens\":null,\"max_completion_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}}"
	},
	{
		id = "zai",
		name = "ZAI",
		url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
		model = "glm-5.2",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "zai-coding-plan",
		name = "ZAI Coding Plan",
		url = "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions",
		model = "glm-5.2",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}")
	},
	{
		id = "ollama",
		name = "Ollama",
		url = "http://localhost:11434/v1/chat/completions",
		model = "llama3.2",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":\"none\"}")
	},
	{
		id = "vllm",
		name = "vLLM",
		url = "http://localhost:8000/v1/chat/completions",
		model = "meta-llama/Llama-3.1-8B-Instruct",
		contextWindow = 128000,
		maxTokens = 8192,
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":\"none\",\"chat_template_kwargs\":{\"enable_thinking\":false}}")
	}
}
local fontName = goTheme.font
local function trim(value)
	return (string.match(value, "^%s*(.-)%s*$")) or ""
end
____exports.isMobileLLMOpen = function() return activeSetup ~= nil and activeSetup.parent ~= nil end
local function ensureLLMConfigTable()
	DB:exec("CREATE TABLE IF NOT EXISTS LLMConfig(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL, url TEXT NOT NULL, model TEXT NOT NULL, api_key TEXT NOT NULL,\n\t\tcontext_window INTEGER NOT NULL DEFAULT 64000, temperature REAL NOT NULL DEFAULT 0.1,\n\t\tmax_tokens INTEGER NOT NULL DEFAULT 8192, reasoning_effort TEXT NOT NULL DEFAULT '',\n\t\tcustom_options TEXT NOT NULL DEFAULT '', supports_function_calling INTEGER NOT NULL DEFAULT 1,\n\t\tactive INTEGER NOT NULL DEFAULT 1, created_at INTEGER, updated_at INTEGER\n\t)")
end
local function uniqueConfigName(base)
	local rows = DB:query("select name from LLMConfig")
	local names = __TS__ArrayMap(
		rows or ({}),
		function(____, row) return tostring(row[1]) end
	)
	if __TS__ArrayIndexOf(names, base) < 0 then
		return base
	end
	local suffix = 2
	while __TS__ArrayIndexOf(
		names,
		(base .. " ") .. tostring(suffix)
	) >= 0 do
		suffix = suffix + 1
	end
	return (base .. " ") .. tostring(suffix)
end
function ____exports.hasMobileLLMConfig()
	ensureLLMConfigTable()
	local rows = DB:query("select id from LLMConfig limit 1")
	return rows ~= nil and #rows > 0
end
function ____exports.startMobileLLMSetup(options)
	local render
	if activeSetup ~= nil then
		activeSetup:removeFromParent(true)
	end
	local zh = (string.match(App.locale, "^zh")) ~= nil
	local host = Node()
	host.tag = "mobile-llm-setup"
	host.order = 10000
	host.renderGroup = true
	host.scaleX = App.devicePixelRatio
	host.scaleY = App.devicePixelRatio
	host:addTo(Director.systemUI)
	activeSetup = host
	local presetIndex = 0
	local apiKey = ""
	local ____error = ""
	local disposed = false
	local keyRef = reference()
	local function canEdit()
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0
	end
	local keyInput = createTextInput({
		fontSize = math.floor(15 * mobileFontScale),
		singleLine = true,
		isSecure = function() return true end,
		getText = function() return apiKey end,
		setText = function(value)
			apiKey = value
			____error = ""
		end,
		getPlaceholder = function() return "sk-…" end,
		isEnabled = canEdit,
		onReturn = function() return true end
	})
	local function blurInputs()
		return keyInput.blur()
	end
	local function close()
		if disposed then
			return
		end
		disposed = true
		blurInputs()
		local function finish()
			host:removeFromParent(true)
			if activeSetup == host then
				activeSetup = nil
			end
			local ____opt_2 = options.onClose
			if ____opt_2 ~= nil then
				____opt_2()
			end
		end
		if App.reducedMotion then
			finish()
		else
			host:perform(Opacity(0.16, host.opacity, 0))
			thread(function()
				sleep(0.16)
				finish()
			end)
		end
	end
	local function choose(delta)
		presetIndex = (presetIndex + delta + #____exports.mobileLLMPresets) % #____exports.mobileLLMPresets
		____error = ""
		blurInputs()
		render()
	end
	local function save()
		if not canEdit() then
			return
		end
		local preset = ____exports.mobileLLMPresets[presetIndex + 1]
		local key = trim(apiKey)
		if key == "" then
			____error = zh and "请粘贴 API Key" or "Paste an API key"
			render()
			return
		end
		ensureLLMConfigTable()
		local now = os.time()
		local name = uniqueConfigName(preset.name)
		local affected = DB:exec("insert into LLMConfig(\n\t\t\tname, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort,\n\t\t\tcustom_options, supports_function_calling, active, created_at, updated_at\n\t\t) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
			name,
			preset.url,
			preset.model,
			key,
			preset.contextWindow,
			0.1,
			preset.maxTokens,
			"",
			preset.customOptions,
			1,
			1,
			now,
			now
		})
		if affected < 0 then
			____error = zh and "配置保存失败，请重试" or "Could not save the configuration"
			render()
			return
		end
		local rows = DB:query("select last_insert_rowid()")
		local ____temp_4
		if rows and #rows > 0 then
			____temp_4 = tonumber(rows[1][1])
		else
			____temp_4 = nil
		end
		local id = ____temp_4
		if not id then
			____error = zh and "无法读取新配置" or "Could not read the new configuration"
			render()
			return
		end
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id})
		options.onSaved(id)
		close()
	end
	render = function()
		if disposed then
			return
		end
		keyInput.unmount()
		keyRef = reference()
		host:removeAllChildren()
		host.scaleX = App.devicePixelRatio
		host.scaleY = App.devicePixelRatio
		local ____App_visualSize_5 = App.visualSize
		local width = ____App_visualSize_5.width
		local height = ____App_visualSize_5.height
		local safe = App.safeArea
		local shortLandscape = safe.width >= 760 and safe.height < 500
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width
		local sheetHeight = shortLandscape and math.min(240, safe.height - 16) or math.min(300, safe.height - 20)
		local left = safe.x + (safe.width - sheetWidth) / 2
		local bottom = safe.y
		local contentWidth = sheetWidth - 40
		local fieldGap = 12
		local fieldWidth = shortLandscape and math.floor((contentWidth - fieldGap) / 2) or contentWidth
		local keyButtonWidth = 92
		local keyX = shortLandscape and 20 + fieldWidth + fieldGap or 20
		local keyWidth = fieldWidth - keyButtonWidth - fieldGap
		local providerLabelY = sheetHeight - 66
		local providerY = sheetHeight - 126
		local keyLabelY = shortLandscape and providerLabelY or sheetHeight - 150
		local keyY = shortLandscape and providerY or sheetHeight - 204
		local actionGap = 12
		local cancelWidth = math.floor((contentWidth - actionGap) * (shortLandscape and 0.34 or 0.38))
		local preset = ____exports.mobileLLMPresets[presetIndex + 1]
		local scene = toNode(React.createElement(
			"node",
			{
				order = 10000,
				x = -width / 2,
				y = -height / 2,
				width = width,
				height = height,
				anchorX = 0,
				anchorY = 0
			},
			React.createElement(
				"node",
				{
					tag = "mobile-llm-setup-backdrop",
					width = width,
					height = height,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true,
					onTapped = close
				},
				React.createElement(RoundedSurface, {
					width = width,
					height = height,
					radius = 0,
					fillColor = 942354470,
					renderOrder = 0
				})
			),
			React.createElement(
				"node",
				{
					tag = "mobile-llm-sheet",
					order = 10,
					x = left,
					y = bottom,
					width = sheetWidth,
					height = sheetHeight,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true
				},
				React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}),
				React.createElement("label", {
					x = 20,
					y = sheetHeight - 24,
					anchorX = 0,
					anchorY = 1,
					fontName = goTheme.headingFont,
					fontSize = 18,
					text = zh and "从模板新增配置" or "Add from template",
					color3 = 3159339
				}),
				React.createElement(
					"label",
					{
						x = sheetWidth - 20,
						y = sheetHeight - 24,
						anchorX = 1,
						anchorY = 1,
						fontName = fontName,
						fontSize = 12,
						text = compactText(preset.model, shortLandscape and 42 or 24),
						color3 = 8159855
					}
				),
				React.createElement("label", {
					x = 20,
					y = providerLabelY,
					anchorX = 0,
					anchorY = 1,
					fontName = fontName,
					fontSize = 14,
					text = zh and "配置模板" or "Template",
					color3 = 8159855
				}),
				React.createElement(
					MobileButton,
					{
						tag = "mobile-llm-provider-prev",
						x = 20,
						y = providerY,
						width = 48,
						text = "",
						icon = "back",
						renderOrder = 10,
						onTapped = function() return choose(-1) end
					}
				),
				React.createElement(
					MobileButton,
					{
						tag = "mobile-llm-provider",
						x = 80,
						y = providerY,
						width = fieldWidth - 120,
						text = preset.name,
						renderOrder = 10,
						onTapped = function() return choose(1) end
					}
				),
				React.createElement(
					MobileButton,
					{
						tag = "mobile-llm-provider-next",
						x = 20 + fieldWidth - 48,
						y = providerY,
						width = 48,
						text = "",
						icon = "next",
						renderOrder = 10,
						onTapped = function() return choose(1) end
					}
				),
				React.createElement("label", {
					x = keyX,
					y = keyLabelY,
					anchorX = 0,
					anchorY = 1,
					fontName = fontName,
					fontSize = 14,
					text = "API Key",
					color3 = 8159855
				}),
				React.createElement("node", {
					tag = "mobile-llm-key",
					ref = keyRef,
					renderOrder = 10,
					x = keyX,
					y = keyY,
					width = keyWidth,
					height = 44,
					anchorX = 0,
					anchorY = 0,
					onMount = keyInput.mount
				}),
				React.createElement(
					MobileButton,
					{
						tag = "mobile-llm-paste",
						x = keyX + keyWidth + fieldGap,
						y = keyY - 2,
						width = keyButtonWidth,
						text = zh and "粘贴" or "Paste",
						renderOrder = 10,
						onTapped = function()
							if not keyInput.pasteFromClipboard(true) then
								____error = zh and "剪贴板为空" or "Clipboard is empty"
							else
								____error = ""
							end
							keyInput.refresh()
						end
					}
				),
				React.createElement("label", {
					tag = "mobile-llm-error",
					x = 20,
					y = 78,
					anchorX = 0,
					fontName = fontName,
					fontSize = 12,
					text = ____error,
					textWidth = contentWidth,
					alignment = "Left",
					color3 = 16739179
				}),
				React.createElement(MobileButton, {
					tag = "mobile-llm-cancel",
					x = 20,
					y = 20,
					width = cancelWidth,
					text = zh and "返回" or "Back",
					renderOrder = 10,
					onTapped = close
				}),
				React.createElement(MobileButton, {
					tag = "mobile-llm-save",
					x = 20 + cancelWidth + actionGap,
					y = 20,
					width = contentWidth - cancelWidth - actionGap,
					text = zh and "新增并使用" or "Add and use",
					primary = true,
					renderOrder = 10,
					onTapped = save
				})
			)
		))
		if scene then
			host:addChild(scene)
		end
	end
	attachGamepad(
		host,
		{
			initialTag = "mobile-llm-provider",
			onBack = function()
				if keyInput.isFocused() then
					keyInput.blur()
				else
					close()
				end
			end
		}
	)
	host:onAppChange(function(setting)
		if setting == "Locale" then
			zh = (string.match(App.locale, "^zh")) ~= nil
		end
		if setting == "Size" or setting == "Locale" then
			render()
		end
	end)
	host:onAppEvent(function(event)
		if event == "BackButton" then
			close()
		end
	end)
	host:onCleanup(function()
		disposed = true
		if activeSetup == host then
			activeSetup = nil
		end
	end)
	render()
	if not App.reducedMotion then
		host:perform(Spawn(
			Opacity(0.18, 0, 1),
			Move(
				0.26,
				Vec2(0, -24),
				Vec2.zero,
				Ease.OutCubic
			)
		))
	end
	return host
end
local function getMobileLLMConfigs()
	ensureLLMConfigTable()
	local rows = DB:query("select id, name, url, model, context_window, supports_function_calling\n\t\tfrom LLMConfig order by id asc")
	return __TS__ArrayFlatMap(
		rows or ({}),
		function(____, row)
			local id = tonumber(row[1])
			if not id then
				return {}
			end
			return {{
				id = id,
				name = tostring(row[2]),
				url = tostring(row[3]),
				model = tostring(row[4]),
				contextWindow = tonumber(row[5]) or 128000,
				supportsFunctionCalling = tonumber(row[6]) ~= 0
			}}
		end
	)
end
function ____exports.getMobileLLMSelection()
	local configs = getMobileLLMConfigs()
	local rows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1")
	local ____temp_6
	if rows and #rows > 0 then
		____temp_6 = tonumber(rows[1][1])
	else
		____temp_6 = nil
	end
	local remembered = ____temp_6
	local ____opt_7 = __TS__ArrayFind(
		configs,
		function(____, item) return item.id == remembered end
	)
	local ____temp_11 = ____opt_7 and ____opt_7.id
	if ____temp_11 == nil then
		local ____opt_9 = configs[1]
		____temp_11 = ____opt_9 and ____opt_9.id
	end
	return ____temp_11 or 0
end
local function fitConfigText(value, size, width)
	local measure = Label(fontName, size, true)
	measure.text = value
	if measure.width <= width then
		measure:cleanup()
		return value
	end
	local low = 0
	local high = inputLength(value)
	while low < high do
		local mid = math.floor((low + high + 1) / 2)
		measure.text = inputSlice(value, 0, mid) .. "…"
		if measure.width <= width then
			low = mid
		else
			high = mid - 1
		end
	end
	measure:cleanup()
	return inputSlice(value, 0, low) .. "…"
end
function ____exports.startMobileLLMManager(options)
	local render
	local configs = getMobileLLMConfigs()
	if #configs == 0 then
		return ____exports.startMobileLLMSetup({coveredNode = options.coveredNode, onSaved = options.onSelected, onClose = options.onClose})
	end
	if activeSetup ~= nil then
		activeSetup:removeFromParent(true)
	end
	local coveredNode = options.coveredNode
	local zh = (string.match(App.locale, "^zh")) ~= nil
	local host = Node()
	host.tag = "mobile-llm-manager"
	host.order = 10000
	host.renderGroup = true
	host.scaleX = App.devicePixelRatio
	host.scaleY = App.devicePixelRatio
	host:addTo(Director.systemUI)
	activeSetup = host
	local detailId = 0
	local detailMode = "view"
	local detailKey = ""
	local detailError = ""
	local selectedId = options.selectedId
	local disposed = false
	local detailKeyRef = reference()
	local function canEdit()
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0
	end
	local detailKeyInput = createTextInput({
		fontSize = math.floor(15 * mobileFontScale),
		singleLine = true,
		isSecure = function() return true end,
		getText = function() return detailKey end,
		setText = function(value)
			detailKey = value
			detailError = ""
		end,
		getPlaceholder = function() return zh and "粘贴新的 API Key" or "Paste a new API key" end,
		isEnabled = canEdit,
		onReturn = function() return true end
	})
	local function close(notify)
		if notify == nil then
			notify = true
		end
		if disposed then
			return
		end
		disposed = true
		detailKeyInput.blur()
		local function finish()
			host:removeFromParent(true)
			if activeSetup == host then
				activeSetup = nil
			end
			if notify then
				local ____opt_14 = options.onClose
				if ____opt_14 ~= nil then
					____opt_14()
				end
			end
		end
		if not notify or App.reducedMotion then
			finish()
		else
			host:perform(Opacity(0.16, host.opacity, 0))
			thread(function()
				sleep(0.16)
				finish()
			end)
		end
	end
	local function select(id)
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id})
		options.onSelected(id)
		close()
	end
	local function openDetail(id)
		detailId = id
		detailMode = "view"
		detailKey = ""
		detailError = ""
		render()
	end
	local function saveDetailKey()
		if not canEdit() or detailId <= 0 then
			return
		end
		local key = trim(detailKey)
		if key == "" then
			detailError = zh and "请粘贴新的 API Key" or "Paste a new API key"
			render()
			return
		end
		local affected = DB:exec(
			"update LLMConfig set api_key = ?, updated_at = ? where id = ?",
			{
				key,
				os.time(),
				detailId
			}
		)
		if affected <= 0 then
			detailError = zh and "API Key 保存失败" or "Could not save the API key"
			render()
			return
		end
		detailKeyInput.blur()
		detailKey = ""
		detailError = zh and "API Key 已更新" or "API key updated"
		detailMode = "view"
		render()
	end
	local function deleteDetail()
		if not canEdit() or detailId <= 0 then
			return
		end
		local deletingId = detailId
		local affected = DB:exec("delete from LLMConfig where id = ?", {deletingId})
		if affected <= 0 then
			detailError = zh and "删除失败，请重试" or "Could not delete the configuration"
			render()
			return
		end
		configs = getMobileLLMConfigs()
		if selectedId == deletingId then
			local ____opt_16 = configs[1]
			selectedId = ____opt_16 and ____opt_16.id or 0
			if selectedId > 0 then
				DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {selectedId})
			else
				DB:exec("delete from Config where name = 'mobileRemixLLMConfigId'")
			end
			options.onSelected(selectedId)
		end
		detailId = 0
		detailMode = "view"
		detailKey = ""
		detailError = ""
		if #configs > 0 then
			render()
		else
			close(false)
			____exports.startMobileLLMSetup({coveredNode = coveredNode, onSaved = options.onSelected, onClose = options.onClose})
		end
	end
	local function add()
		close(false)
		local saved = false
		____exports.startMobileLLMSetup({
			coveredNode = coveredNode,
			onSaved = function(id)
				saved = true
				options.onSelected(id)
			end,
			onClose = function()
				if saved then
					local ____opt_18 = options.onClose
					if ____opt_18 ~= nil then
						____opt_18()
					end
				else
					____exports.startMobileLLMManager(options)
				end
			end
		})
	end
	render = function()
		if disposed then
			return
		end
		detailKeyInput.unmount()
		detailKeyRef = reference()
		host:removeAllChildren()
		host.scaleX = App.devicePixelRatio
		host.scaleY = App.devicePixelRatio
		local ____App_visualSize_20 = App.visualSize
		local width = ____App_visualSize_20.width
		local height = ____App_visualSize_20.height
		local safe = App.safeArea
		local shortLandscape = safe.width >= 760 and safe.height < 500
		local listHeight = math.min(
			#configs * 68,
			math.max(
				68,
				math.min(420, safe.height * 0.62 - 110)
			)
		)
		local desiredHeight = detailId > 0 and 410 or 154 + listHeight
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width
		local sheetHeight = math.min(desiredHeight, safe.height - (shortLandscape and 16 or 20))
		local left = safe.x + (safe.width - sheetWidth) / 2
		local bottom = safe.y
		local contentWidth = sheetWidth - 40
		local detail = __TS__ArrayFind(
			configs,
			function(____, item) return item.id == detailId end
		)
		local switchPending = options.taskRunning and (options.runningId or selectedId) ~= selectedId
		local ____toNode_38 = toNode
		local ____React_createElement_37 = React.createElement
		local ____temp_35 = {
			order = 10000,
			x = -width / 2,
			y = -height / 2,
			width = width,
			height = height,
			anchorX = 0,
			anchorY = 0
		}
		local ____React_createElement_result_36 = React.createElement(
			"node",
			{
				tag = "mobile-llm-manager-backdrop",
				width = width,
				height = height,
				anchorX = 0,
				anchorY = 0,
				touchEnabled = true,
				swallowTouches = true,
				onTapped = function() return close() end
			},
			React.createElement(RoundedSurface, {
				width = width,
				height = height,
				radius = 0,
				fillColor = 942354470,
				renderOrder = 0
			})
		)
		local ____React_createElement_34 = React.createElement
		local ____temp_32 = {
			tag = "mobile-llm-sheet",
			order = 10,
			x = left,
			y = bottom,
			width = sheetWidth,
			height = sheetHeight,
			anchorX = 0,
			anchorY = 0,
			touchEnabled = true,
			swallowTouches = true
		}
		local ____React_createElement_result_33 = React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10})
		local ____detail_31
		if detail then
			local ____temp_26
			if detailMode == "key" then
				____temp_26 = React.createElement(
					"node",
					{tag = "mobile-llm-detail-key"},
					React.createElement("label", {
						x = 20,
						y = sheetHeight - 24,
						anchorX = 0,
						anchorY = 1,
						fontName = goTheme.headingFont,
						fontSize = 18,
						text = zh and "修改 API Key" or "Update API key",
						color3 = 3159339
					}),
					React.createElement(
						"label",
						{
							x = 20,
							y = sheetHeight - 66,
							anchorX = 0,
							anchorY = 1,
							fontName = fontName,
							fontSize = 13,
							text = compactText(detail.name, shortLandscape and 44 or 28),
							color3 = 8159855
						}
					),
					React.createElement("label", {
						x = 20,
						y = sheetHeight - 104,
						anchorX = 0,
						anchorY = 1,
						fontName = fontName,
						fontSize = 13,
						text = zh and "原 Key 不会显示，保存后立即替换" or "The current key stays hidden and will be replaced",
						color3 = 8159855
					}),
					React.createElement("node", {
						tag = "mobile-llm-detail-key-input",
						ref = detailKeyRef,
						renderOrder = 10,
						x = 20,
						y = sheetHeight - 166,
						width = contentWidth - 104,
						height = 44,
						anchorX = 0,
						anchorY = 0,
						onMount = detailKeyInput.mount
					}),
					React.createElement(
						MobileButton,
						{
							tag = "mobile-llm-detail-key-paste",
							x = contentWidth - 72,
							y = sheetHeight - 168,
							width = 92,
							text = zh and "粘贴" or "Paste",
							renderOrder = 10,
							onTapped = function()
								if not detailKeyInput.pasteFromClipboard(true) then
									detailError = zh and "剪贴板为空" or "Clipboard is empty"
								else
									detailError = ""
								end
								detailKeyInput.refresh()
							end
						}
					),
					React.createElement("label", {
						x = 20,
						y = 82,
						anchorX = 0,
						fontName = fontName,
						fontSize = 12,
						text = detailError,
						textWidth = contentWidth,
						alignment = "Left",
						color3 = 16739179
					}),
					React.createElement(
						MobileButton,
						{
							tag = "mobile-llm-detail-key-cancel",
							x = 20,
							y = 20,
							width = math.floor((contentWidth - 12) * 0.36),
							text = zh and "取消" or "Cancel",
							renderOrder = 10,
							onTapped = function()
								detailKeyInput.blur()
								detailMode = "view"
								detailKey = ""
								detailError = ""
								render()
							end
						}
					),
					React.createElement(
						MobileButton,
						{
							tag = "mobile-llm-detail-key-save",
							x = 32 + math.floor((contentWidth - 12) * 0.36),
							y = 20,
							width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36),
							text = zh and "保存新 Key" or "Save new key",
							primary = true,
							renderOrder = 10,
							onTapped = saveDetailKey
						}
					)
				)
			else
				local ____temp_25
				if detailMode == "delete" then
					____temp_25 = React.createElement(
						"node",
						{tag = "mobile-llm-detail-delete"},
						React.createElement("label", {
							x = 20,
							y = sheetHeight - 24,
							anchorX = 0,
							anchorY = 1,
							fontName = goTheme.headingFont,
							fontSize = 18,
							text = zh and "删除这个配置？" or "Delete this configuration?",
							color3 = 3159339
						}),
						React.createElement(
							"label",
							{
								x = 20,
								y = sheetHeight - 78,
								anchorX = 0,
								anchorY = 1,
								fontName = fontName,
								fontSize = 16,
								text = compactText(detail.name, shortLandscape and 52 or 32),
								color3 = 4294935941
							}
						),
						React.createElement("label", {
							x = 20,
							y = sheetHeight - 120,
							anchorX = 0,
							anchorY = 1,
							fontName = fontName,
							fontSize = 13,
							text = zh and "删除后无法恢复；若它是当前配置，将自动切换到下一项。" or "This cannot be undone. The next configuration will become active.",
							textWidth = contentWidth,
							alignment = "Left",
							color3 = 8159855
						}),
						React.createElement("label", {
							x = 20,
							y = 82,
							anchorX = 0,
							fontName = fontName,
							fontSize = 12,
							text = detailError,
							textWidth = contentWidth,
							alignment = "Left",
							color3 = 16739179
						}),
						React.createElement(
							MobileButton,
							{
								tag = "mobile-llm-detail-delete-cancel",
								x = 20,
								y = 20,
								width = math.floor((contentWidth - 12) * 0.42),
								text = zh and "保留配置" or "Keep it",
								renderOrder = 10,
								onTapped = function()
									detailMode = "view"
									detailError = ""
									render()
								end
							}
						),
						React.createElement(
							MobileButton,
							{
								tag = "mobile-llm-detail-delete-confirm",
								x = 32 + math.floor((contentWidth - 12) * 0.42),
								y = 20,
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.42),
								text = zh and "确认删除" or "Delete",
								danger = true,
								renderOrder = 10,
								onTapped = deleteDetail
							}
						)
					)
				else
					local ____React_createElement_24 = React.createElement
					local ____temp_22 = {tag = "mobile-llm-detail"}
					local ____React_createElement_result_23 = React.createElement(
						"label",
						{
							x = 20,
							y = sheetHeight - 24,
							anchorX = 0,
							anchorY = 1,
							fontName = goTheme.headingFont,
							fontSize = 18,
							text = compactText(detail.name, 28),
							color3 = 3159339
						}
					)
					local ____temp_21
					if detailError ~= "" then
						____temp_21 = React.createElement("label", {
							x = sheetWidth - 20,
							y = sheetHeight - 25,
							anchorX = 1,
							anchorY = 1,
							fontName = fontName,
							fontSize = 12,
							text = detailError,
							color3 = 4286505640
						})
					else
						____temp_21 = nil
					end
					____temp_25 = ____React_createElement_24(
						"node",
						____temp_22,
						____React_createElement_result_23,
						____temp_21,
						React.createElement("label", {
							x = 20,
							y = sheetHeight - 68,
							anchorX = 0,
							anchorY = 1,
							fontName = fontName,
							fontSize = 13,
							text = zh and "模型" or "Model",
							color3 = 8159855
						}),
						React.createElement(
							"label",
							{
								x = 20,
								y = sheetHeight - 94,
								anchorX = 0,
								anchorY = 1,
								fontName = fontName,
								fontSize = 15,
								text = compactText(detail.model, shortLandscape and 56 or 38),
								color3 = 3159339
							}
						),
						React.createElement("label", {
							x = 20,
							y = sheetHeight - 132,
							anchorX = 0,
							anchorY = 1,
							fontName = fontName,
							fontSize = 13,
							text = "API URL",
							color3 = 8159855
						}),
						React.createElement(
							"label",
							{
								x = 20,
								y = sheetHeight - 158,
								anchorX = 0,
								anchorY = 1,
								fontName = fontName,
								fontSize = 13,
								text = compactText(detail.url, shortLandscape and 72 or 42),
								color3 = 3159339
							}
						),
						React.createElement(
							"label",
							{
								x = 20,
								y = sheetHeight - 200,
								anchorX = 0,
								anchorY = 1,
								fontName = fontName,
								fontSize = 13,
								text = ((((zh and "上下文" or "Context") .. "  ") .. tostring(detail.contextWindow)) .. "   ·   Function Call  ") .. (detail.supportsFunctionCalling and (zh and "支持" or "On") or (zh and "不支持" or "Off")),
								color3 = 8159855
							}
						),
						React.createElement(
							MobileButton,
							{
								tag = "mobile-llm-detail-key-edit",
								x = 20,
								y = 76,
								width = math.floor((contentWidth - 12) * 0.62),
								text = zh and "修改 API Key" or "Update API key",
								renderOrder = 10,
								onTapped = function()
									detailMode = "key"
									detailKey = ""
									detailError = ""
									render()
								end
							}
						),
						React.createElement(
							MobileButton,
							{
								tag = "mobile-llm-detail-delete",
								x = 32 + math.floor((contentWidth - 12) * 0.62),
								y = 76,
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.62),
								text = zh and "删除" or "Delete",
								danger = true,
								renderOrder = 10,
								onTapped = function()
									detailMode = "delete"
									detailError = ""
									render()
								end
							}
						),
						React.createElement(
							MobileButton,
							{
								tag = "mobile-llm-detail-back",
								x = 20,
								y = 20,
								width = math.floor((contentWidth - 12) * 0.36),
								text = zh and "返回列表" or "Back",
								renderOrder = 10,
								onTapped = function()
									detailId = 0
									render()
								end
							}
						),
						React.createElement(
							MobileButton,
							{
								tag = "mobile-llm-detail-select",
								x = 32 + math.floor((contentWidth - 12) * 0.36),
								y = 20,
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36),
								text = detail.id == selectedId and (switchPending and (zh and "下一轮使用" or "Use next") or (options.taskRunning and (zh and "本轮使用" or "In this run") or (zh and "当前使用" or "In use"))) or (zh and "切换到此配置" or "Use this config"),
								primary = detail.id ~= selectedId,
								renderOrder = 10,
								onTapped = function() return select(detail.id) end
							}
						)
					)
				end
				____temp_26 = ____temp_25
			end
			____detail_31 = ____temp_26
		else
			____detail_31 = React.createElement(
				"node",
				{tag = "mobile-llm-list"},
				React.createElement("label", {
					x = 20,
					y = sheetHeight - 24,
					anchorX = 0,
					anchorY = 1,
					fontName = goTheme.headingFont,
					fontSize = 18,
					text = zh and "Agent 配置" or "Agent settings",
					color3 = 3159339
				}),
				React.createElement("label", {
					x = 20,
					y = sheetHeight - 58,
					anchorX = 0,
					anchorY = 1,
					fontName = fontName,
					fontSize = 13,
					text = options.taskRunning and (zh and "切换将在下一轮生效" or "Changes apply to the next run") or (zh and "选择模型，或管理 API Key" or "Choose a model or manage API keys"),
					color3 = 8159855
				}),
				React.createElement(
					"node",
					{
						tag = "mobile-llm-manager-close",
						x = sheetWidth - 52,
						y = sheetHeight - 50,
						width = 36,
						height = 36,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onMount = pressFeedback,
						onTapped = function() return close() end
					},
					React.createElement(GoIcon, {name = "close", x = 9, y = 9, size = 18})
				),
				React.createElement(
					"custom-node",
					{onCreate = function()
						local scroll = ScrollArea({
							width = contentWidth,
							height = listHeight,
							viewHeight = #configs * 68,
							paddingX = 0,
							paddingY = 0,
							scrollBar = false
						})
						scroll.swallowTouches = true
						scroll.tag = "mobile-llm-config-scroll"
						scroll.position = Vec2(sheetWidth / 2, 74 + listHeight / 2)
						local rows = __TS__ArrayMap(
							configs,
							function(____, item, index)
								local y = listHeight - 60 - index * 68
								local selected = item.id == selectedId
								local ____toNode_30 = toNode
								local ____React_createElement_29 = React.createElement
								local ____array_28 = __TS__SparseArrayNew(
									"node",
									{
										key = tostring(item.id),
										tag = "mobile-llm-config-" .. tostring(item.id),
										x = 0,
										y = y,
										width = contentWidth,
										height = 54,
										anchorX = 0,
										anchorY = 0,
										touchEnabled = true,
										swallowTouches = true,
										onTapped = function() return select(item.id) end
									},
									React.createElement(RoundedSurface, {
										width = contentWidth,
										height = 54,
										radius = 10,
										fillColor = selected and 4294439641 or 0,
										borderWidth = selected and 1 or 0,
										borderColor = 4292134804
									}),
									React.createElement(GoIcon, {
										name = selected and "checked" or "circle",
										x = 11,
										y = 18,
										size = 18,
										color = selected and 4288444956 or 4288323212
									}),
									React.createElement(
										"label",
										{
											x = 38,
											y = 34,
											anchorX = 0,
											fontName = fontName,
											fontSize = 14,
											text = fitConfigText(item.name, 14, contentWidth - (selected and 128 or 88)),
											color3 = 3159339
										}
									),
									React.createElement(
										"label",
										{
											x = 38,
											y = 15,
											anchorX = 0,
											fontName = fontName,
											fontSize = 11,
											text = fitConfigText(item.model, 11, contentWidth - 88),
											color3 = 8159855
										}
									)
								)
								local ____selected_27
								if selected then
									____selected_27 = React.createElement("label", {
										x = contentWidth - 54,
										y = 27,
										anchorX = 1,
										fontName = fontName,
										fontSize = 11,
										text = switchPending and (zh and "下一轮" or "Next") or (options.taskRunning and (zh and "本轮" or "Running") or (zh and "当前" or "Current")),
										color3 = 9598247
									})
								else
									____selected_27 = nil
								end
								__TS__SparseArrayPush(
									____array_28,
									____selected_27,
									React.createElement(
										"node",
										{
											onMount = pressFeedback,
											tag = "mobile-llm-detail-" .. tostring(item.id),
											x = contentWidth - 44,
											y = 0,
											width = 44,
											height = 54,
											anchorX = 0,
											anchorY = 0,
											touchEnabled = true,
											swallowTouches = true,
											onTapped = function() return openDetail(item.id) end
										},
										React.createElement(GoIcon, {name = "next", x = 17, y = 18, size = 18})
									)
								)
								return ____toNode_30(____React_createElement_29(__TS__SparseArraySpread(____array_28)))
							end
						)
						for ____, row in ipairs(rows) do
							scroll.view:addChild(row)
						end
						return scroll
					end}
				),
				React.createElement(MobileButton, {
					tag = "mobile-llm-add",
					x = 20,
					y = 20,
					width = contentWidth,
					icon = "plus",
					text = zh and "添加配置" or "Add configuration",
					renderOrder = 10,
					onTapped = add
				})
			)
		end
		local scene = ____toNode_38(____React_createElement_37(
			"node",
			____temp_35,
			____React_createElement_result_36,
			____React_createElement_34("node", ____temp_32, ____React_createElement_result_33, ____detail_31)
		))
		if scene then
			host:addChild(scene)
		end
	end
	local ____attachGamepad_41 = attachGamepad
	local ____opt_39 = __TS__ArrayFind(
		configs,
		function(____, item) return item.id == selectedId end
	)
	____attachGamepad_41(
		host,
		{
			initialTag = "mobile-llm-config-" .. tostring(____opt_39 and ____opt_39.id or selectedId),
			onBack = function()
				if detailKeyInput.isFocused() then
					detailKeyInput.blur()
				elseif detailMode ~= "view" then
					detailMode = "view"
					detailKey = ""
					detailError = ""
					render()
				elseif detailId > 0 then
					detailId = 0
					render()
				else
					close()
				end
			end
		}
	)
	host:onAppChange(function(setting)
		if setting == "Locale" then
			zh = (string.match(App.locale, "^zh")) ~= nil
		end
		if setting == "Size" or setting == "Locale" then
			render()
		end
	end)
	host:onAppEvent(function(event)
		if event == "BackButton" then
			if detailId > 0 then
				detailId = 0
				render()
			else
				close()
			end
		end
	end)
	host:onCleanup(function()
		disposed = true
		if activeSetup == host then
			activeSetup = nil
		end
	end)
	render()
	if not App.reducedMotion then
		host:perform(Spawn(
			Opacity(0.18, 0, 1),
			Move(
				0.26,
				Vec2(0, -24),
				Vec2.zero,
				Ease.OutCubic
			)
		))
	end
	return host
end
return ____exports
