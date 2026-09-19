local ____lualib = require("lualib_bundle")
local __TS__Delete = ____lualib.__TS__Delete
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local ____exports = {}
local ____Build = require("Agent/Tool/Build")
local build = ____Build.build
local ____Visual = require("Dev/Mobile/Visual")
local GoIcon = ____Visual.GoIcon
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local toNode = ____DoraX.toNode
local ____Dora = require("Dora")
local App = ____Dora.App
local Color3 = ____Dora.Color3
local Content = ____Dora.Content
local HttpServer = ____Dora.HttpServer
local Director = ____Dora.Director
local Ease = ____Dora.Ease
local Label = ____Dora.Label
local Move = ____Dora.Move
local Node = ____Dora.Node
local Path = ____Dora.Path
local Vec2 = ____Dora.Vec2
local sleep = ____Dora.sleep
local thread = ____Dora.thread
local Spawn = ____Dora.Spawn
local Opacity = ____Dora.Opacity
local ScrollArea = require("UI/Control/Basic/ScrollArea")
local ____Checkpoint = require("Agent/Tool/Checkpoint")
local applyFileChanges = ____Checkpoint.applyFileChanges
local createTask = ____Checkpoint.createTask
local getTaskChangeSetDiff = ____Checkpoint.getTaskChangeSetDiff
local rollbackTaskChangeSet = ____Checkpoint.rollbackTaskChangeSet
local setTaskStatus = ____Checkpoint.setTaskStatus
local ____Workspace = require("Agent/Tool/Workspace")
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath
local ____Controls = require("Dev/Mobile/Controls")
local MobileButton = ____Controls.MobileButton
local MobilePanelSurface = ____Controls.MobilePanelSurface
local ____Visual = require("Dev/Mobile/Visual")
local SceneSurface = ____Visual.SceneSurface
local ____TextInput = require("Dev/Mobile/TextInput")
local createTextInput = ____TextInput.createTextInput
local ____ProjectPresentation = require("Dev/Mobile/ProjectPresentation")
local saveProjectDisplayName = ____ProjectPresentation.saveProjectDisplayName
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
function ____exports.startWorkspacePanel(options)
	local render
	local host = Node()
	host.tag = "go-workspace-panel"
	host.scaleX = App.devicePixelRatio
	host.scaleY = App.devicePixelRatio
	host:addTo(Director.systemUI, 2000)
	local zh = (string.match(App.locale, "^zh")) ~= nil
	local panel = options.panel
	local path = ""
	local draft = options.panel == "rename" and options.entry.title or ""
	local notice = ""
	local disposed = false
	local closing = false
	local saving = false
	local conflict = false
	local function busy()
		return saving or options.isBusy() or HttpServer.wsConnectionCount > 0
	end
	local ____options_state_0 = options.state
	local drafts = ____options_state_0.drafts
	local bases = ____options_state_0.bases
	local editor = createTextInput({
		fontSize = 13,
		fontName = options.panel == "rename" and goTheme.font or goTheme.monoFont,
		singleLine = options.panel == "rename",
		getText = function() return draft end,
		setText = function(text)
			draft = text
			if panel == "code" then
				drafts[path] = text
			end
		end,
		getPlaceholder = function() return "" end,
		isEnabled = function() return not disposed and not closing and not busy() and host.visible end
	})
	local function close()
		if closing or disposed or saving then
			return
		end
		closing = true
		editor.blur()
		host:stopAllActions()
		host:perform(Spawn(
			Opacity(0.18, host.opacity, 0),
			Move(
				App.reducedMotion and 0 or 0.18,
				host.position,
				App.reducedMotion and Vec2.zero or Vec2(0, -36),
				Ease.OutCubic
			)
		))
		thread(function()
			sleep(App.reducedMotion and 0 or 0.18)
			if not disposed then
				host:removeFromParent(true)
				options.onClose()
			end
		end)
	end
	local function switchTo(next)
		editor.blur()
		editor.unmount()
		panel = next
		notice = ""
		conflict = false
		render()
	end
	local function agentTaskId()
		local detail = options.getDetail()
		return detail.success and (detail.session.currentTaskId or 0) or 0
	end
	local function taskId()
		return options.state.manualTaskId > 0 and agentTaskId() == options.state.agentTaskAtEdit and options.state.manualTaskId or agentTaskId()
	end
	local workspace = options.entry.workDir or ""
	local function save()
		return __TS__AsyncAwaiter(function(____awaiter_resolve)
			if busy() or editor.isComposing() then
				return ____awaiter_resolve(nil)
			end
			if panel == "rename" then
				local title = (string.match((string.gsub(draft, "[%c]+", " ")), "^%s*(.-)%s*$")) or ""
				if title == "" then
					notice = zh and "请输入项目名称" or "Enter a project name"
					render()
					return ____awaiter_resolve(nil)
				end
				if workspace == "" or saveProjectDisplayName(workspace, title) then
					options.entry.title = title
					options.onChanged()
					if options.panel == "rename" then
						close()
					else
						switchTo("settings")
					end
				else
					notice = zh and "保存名称失败" or "Could not save name"
					render()
				end
				return ____awaiter_resolve(nil)
			end
			local fullPath = resolveWorkspaceFilePath(workspace, path)
			if not fullPath then
				return ____awaiter_resolve(nil)
			end
			if Content:load(fullPath) ~= bases[path] then
				conflict = true
				notice = zh and "磁盘文件已更新。保留草稿，或载入磁盘版本。" or "File changed. Keep this draft or reload from disk."
				render()
				return ____awaiter_resolve(nil)
			end
			local created = createTask(zh and "手动编辑项目文件" or "Edit project file")
			if not created.success then
				notice = created.message
				render()
				return ____awaiter_resolve(nil)
			end
			local result = applyFileChanges(created.taskId, workspace, {{path = path, op = "write", content = draft}}, {summary = "Go editor"})
			setTaskStatus(created.taskId, result.success and "DONE" or "FAILED")
			if not result.success then
				notice = result.message
				render()
				return ____awaiter_resolve(nil)
			end
			options.state.manualTaskId = created.taskId
			options.state.agentTaskAtEdit = agentTaskId()
			bases[path] = draft
			__TS__Delete(drafts, path)
			saving = true
			notice = zh and "正在检查并构建…" or "Checking and building…"
			render()
			local compiled = __TS__ArrayIndexOf(
				{
					"ts",
					"tsx",
					"lua",
					"yue",
					"tl",
					"xml",
					"yarn"
				},
				Path:getExt(path)
			) >= 0
			local ____hasReturned, ____returnValue
			local ____try = __TS__AsyncAwaiter(function()
				local checked = compiled and __TS__Await(build({
					workDir = workspace,
					path = path,
					isCancelled = function() return disposed end
				})) or ({success = true, message = ""})
				if disposed then
					____hasReturned = true
					return
				end
				options.state.buildFailed = not checked.success
				notice = checked.success and (zh and "已保存" or "Saved") or (zh and "已保存，构建失败：" or "Saved; build failed: ") .. checked.message
				local ____options_onChanged_2 = options.onChanged
				local ____checked_success_1
				if checked.success then
					____checked_success_1 = nil
				else
					____checked_success_1 = notice
				end
				____options_onChanged_2(____checked_success_1)
			end)
			____try = ____try.catch(
				____try,
				function(____, e)
					return __TS__AsyncAwaiter(function()
						if not disposed then
							options.state.buildFailed = true
							notice = tostring(e)
							options.onChanged(notice)
						end
					end)
				end
			)
			__TS__Await(____try)
			if ____hasReturned then
				return ____awaiter_resolve(nil, ____returnValue)
			end
			saving = false
			if not disposed then
				render()
			end
		end)
	end
	local function files()
		local result = {}
		local visit
		visit = function(folder, depth)
			if depth > 8 or #result >= 250 then
				return
			end
			for ____, file in ipairs(Content:getFiles(Path(workspace, folder))) do
				if #result >= 250 then
					break
				end
				if __TS__ArrayIndexOf(
					{
						"ts",
						"tsx",
						"lua",
						"yue",
						"json",
						"md",
						"txt",
						"tl",
						"xml",
						"wa"
					},
					Path:getExt(file)
				) >= 0 then
					result[#result + 1] = folder == "" and file or (folder .. "/") .. file
				end
			end
			for ____, dir in ipairs(Content:getDirs(Path(workspace, folder))) do
				if string.sub(dir, 1, 1) ~= "." and dir ~= "node_modules" and dir ~= "build" then
					visit(folder == "" and dir or (folder .. "/") .. dir, depth + 1)
				end
			end
		end
		if workspace ~= "" and Content:isdir(workspace) then
			visit("", 0)
		end
		return result
	end
	render = function()
		if disposed then
			return
		end
		local focused = editor.isFocused()
		editor.unmount()
		host:removeAllChildren()
		local safe = App.safeArea
		local ____App_visualSize_3 = App.visualSize
		local width = ____App_visualSize_3.width
		local height = ____App_visualSize_3.height
		local w = math.min(safe.width, 620)
		local h = math.min(safe.height - 20, panel == "rename" and 208 or (panel == "settings" and 260 or safe.height * 0.82))
		local left = safe.left + (safe.width - w) / 2
		local bottom = safe.bottom
		local title = panel == "code" and path or (zh and ({
			files = "项目文件",
			changes = "修改记录",
			logs = "运行日志",
			settings = "项目设置",
			rename = "项目名称",
			rollback = "回退本轮修改"
		})[panel] or panel)
		local shell = toNode(React.createElement(
			"node",
			{
				x = -width / 2,
				y = -height / 2,
				width = width,
				height = height,
				anchorX = 0,
				anchorY = 0,
				touchEnabled = true,
				swallowTouches = true
			},
			React.createElement(
				"node",
				{
					width = width,
					height = height,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true,
					onTapped = close
				},
				React.createElement(
					"draw-node",
					{x = width / 2, y = height / 2},
					React.createElement("rect-shape", {width = width, height = height, fillColor = 1716607557})
				)
			),
			React.createElement(
				"node",
				{
					tag = "workspace-sheet",
					x = left,
					y = bottom,
					width = w,
					height = h,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true
				},
				React.createElement(MobilePanelSurface, {width = w, height = h}),
				React.createElement(SceneSurface, {
					x = w / 2 - 17,
					y = h - 10,
					width = 34,
					height = 3,
					radius = 1.5,
					fillColor = goTheme.border
				}),
				React.createElement("label", {
					x = 22,
					y = h - 36,
					anchorX = 0,
					fontName = goTheme.font,
					fontSize = 16,
					text = title,
					textWidth = w - 85,
					alignment = "Left",
					color3 = 3159339
				}),
				React.createElement(
					"node",
					{
						x = w - 54,
						y = h - 54,
						width = 36,
						height = 36,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onMount = pressFeedback,
						onTapped = close
					},
					React.createElement(GoIcon, {name = "close", x = 9, y = 9, size = 18})
				)
			)
		))
		host:addChild(shell)
		local sheet = shell:getChildByTag("workspace-sheet")
		local function add(node)
			if node then
				sheet:addChild(node)
			end
		end
		if panel == "code" or panel == "rename" then
			local area = Node()
			area.tag = "workspace-editor"
			area.anchor = Vec2.zero
			area.position = Vec2(20, 80)
			area.width = w - 40
			area.height = panel == "rename" and 48 or h - 155
			sheet:addChild(area)
			editor.mount(area)
			add(toNode(React.createElement(
				MobileButton,
				{
					tag = "workspace-save",
					x = w - 110,
					y = 24,
					width = 90,
					height = 36,
					text = saving and (zh and "构建中" or "Building") or (zh and "保存" or "Save"),
					primary = true,
					disabled = busy(),
					onTapped = function()
						save()
					end
				}
			)))
			add(toNode(React.createElement(
				MobileButton,
				{
					tag = "workspace-editor-back",
					x = 20,
					y = 24,
					width = 76,
					height = 36,
					text = options.panel == "rename" and (zh and "取消" or "Cancel") or (zh and "返回" or "Back"),
					disabled = saving,
					onTapped = function()
						local ____temp_4
						if options.panel == "rename" then
							____temp_4 = close()
						else
							____temp_4 = switchTo(panel == "rename" and "settings" or "files")
						end
						return ____temp_4
					end
				}
			)))
		elseif panel == "settings" then
			local labels = zh and ({"项目名称", "模型配置", "导出项目快照"}) or ({"Project name", "Model", "Export project"})
			__TS__ArrayForEach(
				__TS__ArraySlice(labels, 0, workspace == "" and 2 or 3),
				function(____, text, i) return add(toNode(React.createElement(
					"node",
					{
						onMount = pressFeedback,
						tag = "workspace-setting-" .. tostring(i),
						x = 20,
						y = h - 115 - i * 52,
						width = w - 40,
						height = 44,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onTapped = function()
							if i == 0 then
								draft = options.entry.title
								switchTo("rename")
							else
								close()
								thread(function()
									sleep(0.2)
									if i == 1 then
										options.onModel()
									else
										options.onExport()
									end
								end)
							end
						end
					},
					React.createElement("label", {
						x = 0,
						y = 22,
						anchorX = 0,
						fontName = goTheme.font,
						fontSize = 13,
						text = text,
						color3 = 6253120,
						alignment = "Left"
					})
				))) end
			)
		elseif panel == "rollback" then
			add(toNode(React.createElement("label", {
				x = 22,
				y = h - 98,
				anchorX = 0,
				anchorY = 1,
				fontName = goTheme.font,
				fontSize = 14,
				text = zh and "恢复本轮修改前的文件，对话记录会保留。" or "Restore files before this task. Chat history stays.",
				textWidth = w - 44,
				alignment = "Left",
				color3 = 6253120
			})))
			add(toNode(React.createElement(
				MobileButton,
				{
					tag = "workspace-rollback-confirm",
					x = w - 140,
					y = 30,
					width = 120,
					text = zh and "确认回退" or "Restore",
					disabled = busy(),
					onTapped = function()
						if busy() then
							return
						end
						local r = rollbackTaskChangeSet(
							taskId(),
							workspace
						)
						notice = r.success and (zh and "已回退" or "Restored") or r.message
						if r.success then
							for ____, key in ipairs(__TS__ObjectKeys(drafts)) do
								__TS__Delete(drafts, key)
								__TS__Delete(bases, key)
							end
							saving = true
							local ____self_7 = build({
								workDir = workspace,
								path = ".",
								isCancelled = function() return disposed end
							})
							____self_7["then"](
								____self_7,
								function(____, result)
									saving = false
									if disposed then
										return
									end
									options.state.buildFailed = not result.success
									notice = result.success and (zh and "已回退并重新构建" or "Restored and rebuilt") or result.message
									local ____options_onChanged_6 = options.onChanged
									local ____result_success_5
									if result.success then
										____result_success_5 = nil
									else
										____result_success_5 = notice
									end
									____options_onChanged_6(____result_success_5)
									panel = "changes"
									render()
								end
							)
						else
							render()
						end
					end
				}
			)))
		else
			local scroll = ScrollArea({width = w - 40, height = h - 145, paddingY = 0, scrollBar = false})
			scroll.position = Vec2(w / 2, 70 + (h - 145) / 2)
			sheet:addChild(scroll)
			local y = h - 145
			local function text(value, color)
				if color == nil then
					color = 6253120
				end
				local label = Label(goTheme.font, 13, true)
				if not label then
					return
				end
				label.anchor = Vec2(0, 1)
				label.position = Vec2(0, y)
				label.textWidth = w - 48
				label.alignment = "Left"
				label.color3 = Color3(color)
				label.text = value
				scroll.view:addChild(label)
				y = y - (label.height + 14)
			end
			if panel == "files" then
				local list = files()
				if #list == 0 then
					text(zh and "还没有项目文件" or "No project files yet")
				end
				__TS__ArrayForEach(
					list,
					function(____, file)
						local node = toNode(React.createElement(
							"node",
							{
								onMount = pressFeedback,
								tag = "workspace-file-" .. file,
								x = 0,
								y = y - 40,
								width = w - 40,
								height = 40,
								anchorX = 0,
								anchorY = 0,
								touchEnabled = true,
								swallowTouches = true,
								onTapped = function()
									local resolved = resolveWorkspaceFilePath(workspace, file)
									if not resolved then
										return
									end
									local content = Content:load(resolved)
									if content == nil then
										notice = zh and "无法读取文件" or "Cannot read file"
										render()
										return
									end
									if #content > 128000 then
										notice = zh and "文件过大，请在 Web IDE 打开" or "Open large files in Web IDE"
										render()
										return
									end
									path = file
									if drafts[file] == nil then
										bases[file] = content
									end
									draft = drafts[file] or content
									switchTo("code")
								end
							},
							React.createElement("label", {
								x = 4,
								y = 20,
								anchorX = 0,
								fontName = goTheme.font,
								fontSize = 12,
								text = file,
								textWidth = w - 55,
								alignment = "Left",
								color3 = 6253120
							})
						))
						if node then
							scroll.view:addChild(node)
						end
						y = y - 44
					end
				)
			elseif panel == "changes" then
				local id = taskId()
				local diff = id > 0 and getTaskChangeSetDiff(id) or nil
				if diff and diff.success and #diff.files > 0 then
					__TS__ArrayForEach(
						diff.files,
						function(____, f)
							text(f.path, 3159339)
							text(
								"− " .. string.sub(f.beforeContent, 1, 2000),
								11036246
							)
							text(
								"+ " .. string.sub(f.afterContent, 1, 2000),
								6062163
							)
						end
					)
					add(toNode(React.createElement(
						MobileButton,
						{
							tag = "workspace-rollback",
							x = 20,
							y = 20,
							width = 150,
							height = 36,
							text = zh and "回退本轮修改" or "Restore task",
							disabled = busy(),
							onTapped = function() return switchTo("rollback") end
						}
					)))
				else
					text(zh and "当前没有待查看的修改" or "No changes to review")
				end
			else
				local detail = options.getDetail()
				if detail.success and #detail.steps > 0 then
					__TS__ArrayForEach(
						detail.steps,
						function(____, step) return text((((step.status .. " · ") .. step.tool) .. "\n") .. step.reason) end
					)
				else
					text(zh and "暂无运行记录" or "No activity yet")
				end
			end
			scroll:resetSize(
				w - 40,
				h - 145,
				w - 40,
				math.max(h - 145, h - 145 - y)
			)
		end
		if conflict and panel == "code" then
			add(toNode(React.createElement(
				MobileButton,
				{
					tag = "workspace-reload",
					x = 110,
					y = 24,
					width = 90,
					height = 36,
					text = zh and "载入磁盘" or "Reload",
					onTapped = function()
						local full = resolveWorkspaceFilePath(workspace, path)
						if not full then
							return
						end
						local content = Content:load(full)
						if content == nil then
							return
						end
						draft = content
						bases[path] = content
						__TS__Delete(drafts, path)
						conflict = false
						notice = ""
						render()
					end
				}
			)))
		end
		if focused and (panel == "code" or panel == "rename") and not busy() then
			editor.focus(false)
		end
		if notice ~= "" then
			add(toNode(React.createElement("label", {
				x = 20,
				y = 64,
				anchorX = 0,
				fontName = goTheme.font,
				fontSize = 12,
				text = notice,
				textWidth = w - 40,
				color3 = 10053197,
				alignment = "Left"
			})))
		end
	end
	host:slot("CloseWorkspace", close)
	host:slot("SuspendLocalUI", editor.blur)
	host:onAppEvent(function(event)
		if event == "WillEnterBackground" or event == "DidEnterBackground" then
			editor.blur()
		end
	end)
	host:onCleanup(function()
		disposed = true
		editor.unmount()
	end)
	host:onAppChange(function(setting)
		if setting == "Size" then
			render()
		end
	end)
	render()
	host.position = Vec2(0, App.reducedMotion and 0 or -24)
	host:perform(Spawn(
		Opacity(0.18, 0, 1),
		Move(App.reducedMotion and 0 or 0.28, host.position, Vec2.zero, Ease.OutCubic)
	))
	return host
end
return ____exports
