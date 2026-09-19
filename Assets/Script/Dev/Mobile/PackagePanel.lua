local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local ____Controls = require("Dev/Mobile/Controls")
local MobileButton = ____Controls.MobileButton
local ____Visual = require("Dev/Mobile/Visual")
local SceneSurface = ____Visual.SceneSurface
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local reference = ____DoraX.reference
local toNode = ____DoraX.toNode
local ____Dora = require("Dora")
local App = ____Dora.App
local Director = ____Dora.Director
local HttpServer = ____Dora.HttpServer
local Label = ____Dora.Label
local Node = ____Dora.Node
local thread = ____Dora.thread
local ____Gamepad = require("Dev/Mobile/Gamepad")
local attachGamepad = ____Gamepad.attachGamepad
local ____Package = require("Dev/Mobile/Package")
local discardPackage = ____Package.discardPackage
local exportPackage = ____Package.exportPackage
local inspectPackage = ____Package.inspectPackage
local installPackage = ____Package.installPackage
local function PackageSurface(props)
	return React.createElement(SceneSurface, {
		width = props.width,
		height = props.height,
		radius = props.radius,
		bottomRadius = 0,
		fillColor = props.color,
		borderWidth = 1,
		borderColor = 4292007621
	})
end
local function PackageButton(props)
	return React.createElement(
		MobileButton,
		__TS__ObjectAssign({}, props, {height = 44, fontSize = props.fontSize or 14})
	)
end
function ____exports.startPackagePanel(options)
	local render
	local host = Node()
	host.tag = "mobile-package-panel"
	host.order = 20000
	host.renderGroup = true
	host:addTo(Director.systemUI)
	local active = true
	local busy = options.mode == "share" and options.entry ~= nil
	local preview
	local exported
	local detailRef = reference()
	local message = options.mode == "share" and (__TS__StringStartsWith(
		string.lower(App.locale),
		"zh"
	) and "接收者导入后可以试玩，也可以继续改编。" or "Recipients can import, play, and Remix this game.") or ""
	local failed = false
	local zh = __TS__StringStartsWith(
		string.lower(App.locale),
		"zh"
	)
	local function enabled()
		return active and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 and not busy
	end
	local function close()
		if busy or not active then
			return
		end
		active = false
		if preview then
			discardPackage(preview)
		end
		preview = nil
		host:removeFromParent(true)
		options.onClosed()
	end
	local function receive(path)
		if not active then
			return
		end
		busy = true
		failed = false
		message = zh and "正在检查作品包…" or "Checking game package…"
		render()
		thread(function()
			do
				local function ____catch(e)
					failed = true
					message = (string.match(
						tostring(e),
						":%d+: (.*)$"
					)) or tostring(e)
				end
				local ____try, ____hasReturned, ____returnValue = pcall(function()
					local result = inspectPackage(path)
					if not active or not host.parent then
						discardPackage(result)
						return true
					end
					preview = result
					message = zh and "包含代码与素材，导入后可试玩和 Remix。" or "Includes code and assets. Import to play or Remix."
				end)
				if not ____try then
					____hasReturned, ____returnValue = ____catch(____hasReturned)
				end
				do
					busy = false
					render()
				end
				if ____hasReturned then
					return ____returnValue
				end
			end
		end)
	end
	local function pick()
		if not enabled() then
			return
		end
		busy = true
		message = zh and "请选择 ZIP 作品包" or "Choose a ZIP game package"
		render()
		App:openFileDialog(
			false,
			function(path)
				busy = false
				if not active or not host.parent then
					return
				end
				if path ~= "" then
					receive(path)
				else
					message = ""
					render()
				end
			end,
			"zip"
		)
	end
	local function install(play)
		if not enabled() or not preview then
			return
		end
		do
			local function ____catch(e)
				failed = true
				message = (string.match(
					tostring(e),
					":%d+: (.*)$"
				)) or tostring(e)
				render()
			end
			local ____try, ____hasReturned = pcall(function()
				local entry = installPackage(preview)
				preview = nil
				close()
				local ____opt_0 = options.onImported
				if ____opt_0 ~= nil then
					____opt_0(entry, play)
				end
			end)
			if not ____try then
				____catch(____hasReturned)
			end
		end
	end
	render = function()
		if not active or not host.parent then
			return
		end
		host:removeAllChildren()
		host.scaleX = App.devicePixelRatio
		host.scaleY = App.devicePixelRatio
		local safe = App.safeArea
		local width = math.min(safe.width, 540)
		local title = preview and preview.title or (options.mode == "share" and (zh and "分享作品" or "Share game") or (zh and "添加作品" or "Add game"))
		local ____preview_5
		if preview then
			____preview_5 = (preview.author and preview.author .. " · " or "") .. string.format("%.1f MB", preview.bytes / 1048576)
		else
			local ____temp_4
			if options.mode == "share" then
				local ____opt_2 = options.entry
				____temp_4 = ((____opt_2 and ____opt_2.title or "") .. " · ") .. (exported and string.format("%.1f MB", exported.bytes / 1048576) or (zh and "打包中…" or "Packaging…"))
			else
				____temp_4 = ""
			end
			____preview_5 = ____temp_4
		end
		local detail = ____preview_5
		local function textHeight(text, fontSize)
			if text == "" then
				return 0
			end
			local label = Label("sarasa-mono-sc-regular", fontSize)
			label.textWidth = width - 40
			label.text = text
			local height = math.max(
				fontSize,
				math.ceil(label.height)
			)
			label:cleanup()
			return height
		end
		local titleTop = 20
		local detailTop = titleTop + textHeight(title, 22) + 12
		local ____temp_12
		if options.mode == "share" then
			local ____math_max_11 = math.max
			local ____opt_6 = options.entry
			local ____textHeight_result_10 = textHeight(((____opt_6 and ____opt_6.title or "") .. " · ") .. (zh and "打包中…" or "Packaging…"), 14)
			local ____opt_8 = options.entry
			____temp_12 = ____math_max_11(
				____textHeight_result_10,
				textHeight((____opt_8 and ____opt_8.title or "") .. " · 256.0 MB", 14)
			)
		else
			____temp_12 = textHeight(detail, 14)
		end
		local detailHeight = ____temp_12
		local messageTop = detail ~= "" and detailTop + detailHeight + 10 or detailTop
		local contentBottom = message ~= "" and messageTop + textHeight(message, 14) or (detail ~= "" and detailTop + detailHeight or detailTop - 12)
		local hasActions = options.mode == "share" or not busy
		local height = math.min(safe.height - 16, contentBottom + 20 + (hasActions and 126 or 66))
		local actionWidth = (width - 52) / 2
		local ____toNode_26 = toNode
		local ____React_createElement_25 = React.createElement
		local ____temp_23 = {
			x = -App.visualSize.width / 2,
			y = -App.visualSize.height / 2,
			anchorX = 0,
			anchorY = 0,
			width = App.visualSize.width,
			height = App.visualSize.height,
			touchEnabled = true,
			swallowTouches = true
		}
		local ____React_createElement_result_24 = React.createElement(
			"draw-node",
			nil,
			React.createElement("rect-shape", {
				centerX = App.visualSize.width / 2,
				centerY = App.visualSize.height / 2,
				width = App.visualSize.width,
				height = App.visualSize.height,
				fillColor = 2852126720
			})
		)
		local ____React_createElement_22 = React.createElement
		local ____array_21 = __TS__SparseArrayNew(
			"node",
			{
				tag = "mobile-package-sheet",
				x = safe.left + (safe.width - width) / 2,
				y = safe.bottom + 8,
				width = width,
				height = height,
				anchorX = 0,
				anchorY = 0
			},
			React.createElement(PackageSurface, {width = width, height = height, radius = 24, color = 4294638581}),
			React.createElement("label", {
				x = 20,
				y = height - titleTop,
				anchorX = 0,
				anchorY = 1,
				fontName = "sarasa-mono-sc-regular",
				fontSize = 22,
				text = title,
				textWidth = width - 40,
				alignment = "Left"
			})
		)
		local ____temp_13
		if detail == "" then
			____temp_13 = nil
		else
			____temp_13 = React.createElement("label", {
				tag = "mobile-package-detail",
				ref = detailRef,
				x = 20,
				y = height - detailTop,
				anchorX = 0,
				anchorY = 1,
				fontName = "sarasa-mono-sc-regular",
				fontSize = 14,
				text = detail,
				color3 = 8159855,
				textWidth = width - 40,
				alignment = "Left"
			})
		end
		__TS__SparseArrayPush(
			____array_21,
			____temp_13,
			React.createElement("label", {
				tag = "mobile-package-status",
				x = 20,
				y = height - messageTop,
				anchorX = 0,
				anchorY = 1,
				fontName = "sarasa-mono-sc-regular",
				fontSize = 14,
				text = message,
				color3 = failed and 16739179 or 8159855,
				textWidth = width - 40,
				alignment = "Left"
			})
		)
		local ____temp_20
		if not busy and preview then
			____temp_20 = React.createElement(
				"node",
				nil,
				React.createElement(
					PackageButton,
					{
						tag = "mobile-package-import-play",
						x = 20,
						y = 78,
						width = actionWidth,
						text = zh and "导入并试玩" or "Import & play",
						fontSize = 15,
						primary = true,
						onTapped = function() return install(true) end
					}
				),
				React.createElement(
					PackageButton,
					{
						tag = "mobile-package-import",
						x = 32 + actionWidth,
						y = 78,
						width = actionWidth,
						text = zh and "仅导入" or "Import",
						fontSize = 15,
						onTapped = function() return install(false) end
					}
				)
			)
		else
			local ____temp_19
			if options.mode == "share" then
				____temp_19 = React.createElement(
					"node",
					nil,
					React.createElement(
						PackageButton,
						{
							tag = "mobile-package-share",
							x = 20,
							y = 78,
							width = actionWidth,
							text = zh and "分享作品" or "Share game",
							fontSize = 15,
							primary = true,
							onTapped = function()
								if enabled() and exported and not App:shareFile(exported.path) then
									failed = true
									message = zh and "无法打开分享面板" or "Could not open share sheet"
									render()
								end
							end
						}
					),
					React.createElement(
						PackageButton,
						{
							tag = "mobile-package-save",
							x = 32 + actionWidth,
							y = 78,
							width = actionWidth,
							text = zh and "保存作品包" or "Save package",
							fontSize = 15,
							onTapped = function()
								if enabled() and exported and not App:saveFileDialog(exported.path) then
									failed = true
									message = zh and "无法打开保存面板" or "Could not open save dialog"
									render()
								end
							end
						}
					)
				)
			else
				local ____temp_18
				if not busy then
					local ____React_createElement_17 = React.createElement
					local ____options_onNew_16
					if options.onNew then
						____options_onNew_16 = React.createElement(
							PackageButton,
							{
								tag = "mobile-package-new",
								x = 20,
								y = 78,
								width = actionWidth,
								text = zh and "新建作品" or "New game",
								fontSize = 15,
								onTapped = function()
									if enabled() then
										close()
										local ____opt_14 = options.onNew
										if ____opt_14 ~= nil then
											____opt_14()
										end
									end
								end
							}
						)
					else
						____options_onNew_16 = nil
					end
					____temp_18 = ____React_createElement_17(
						"node",
						nil,
						____options_onNew_16,
						React.createElement(PackageButton, {
							tag = "mobile-package-pick",
							x = options.onNew and 32 + actionWidth or 20,
							y = 78,
							width = options.onNew and actionWidth or width - 40,
							text = zh and "导入作品包" or "Import package",
							fontSize = 15,
							primary = true,
							onTapped = pick
						})
					)
				else
					____temp_18 = nil
				end
				____temp_19 = ____temp_18
			end
			____temp_20 = ____temp_19
		end
		__TS__SparseArrayPush(
			____array_21,
			____temp_20,
			React.createElement(PackageButton, {
				tag = "mobile-package-close",
				x = 20,
				y = 18,
				width = width - 40,
				text = zh and "关闭" or "Close",
				onTapped = close
			})
		)
		local node = ____toNode_26(____React_createElement_25(
			"node",
			____temp_23,
			____React_createElement_result_24,
			____React_createElement_22(__TS__SparseArraySpread(____array_21))
		))
		if node then
			host:addChild(node)
		end
	end
	attachGamepad(host, {initialTag = "mobile-package-close", isEnabled = enabled, onBack = close})
	host:onAppChange(function(setting)
		if setting == "Size" then
			render()
		end
	end)
	host:onAppEvent(function(event)
		if event == "BackButton" and enabled() then
			close()
		end
	end)
	host:onCleanup(function()
		active = false
		if preview then
			discardPackage(preview)
		end
		preview = nil
	end)
	host:schedule(function()
		host.visible = HttpServer.wsConnectionCount == 0
		return false
	end)
	render()
	if options.mode == "add" and options.pickOnOpen then
		pick()
	end
	if options.mode == "receive" and options.path then
		receive(options.path)
	end
	if options.mode == "share" and options.entry then
		thread(function()
			do
				local function ____catch(e)
					failed = true
					busy = false
					message = (string.match(
						tostring(e),
						":%d+: (.*)$"
					)) or tostring(e)
					render()
				end
				local ____try, ____hasReturned = pcall(function()
					exported = exportPackage(options.entry)
					busy = false
					if active and host.parent and detailRef.current then
						detailRef.current.text = (options.entry.title .. " · ") .. string.format("%.1f MB", exported.bytes / 1048576)
					end
				end)
				if not ____try then
					____catch(____hasReturned)
				end
			end
		end)
	end
	return host
end
return ____exports
