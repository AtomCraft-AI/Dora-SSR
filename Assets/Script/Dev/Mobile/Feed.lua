local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local ____Description = require("Dev/Mobile/Description")
local Description = ____Description.Description
local ____LLMSetup = require("Dev/Mobile/LLMSetup")
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager
local isMobileLLMOpen = ____LLMSetup.isMobileLLMOpen
local getMobileLLMSelection = ____LLMSetup.getMobileLLMSelection
local ____GestureGuide = require("Dev/Mobile/GestureGuide")
local createGestureGuide = ____GestureGuide.createGestureGuide
local ____ProjectPresentation = require("Dev/Mobile/ProjectPresentation")
local projectDisplayName = ____ProjectPresentation.projectDisplayName
local ____Cartridge = require("Dev/Mobile/Cartridge")
local Cartridge = ____Cartridge.Cartridge
local CartridgeSlot = ____Cartridge.CartridgeSlot
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
local ____Dora = require("Dora")
local Spawn = ____Dora.Spawn
local Scale = ____Dora.Scale
local Angle = ____Dora.Angle
local AngleY = ____Dora.AngleY
local Opacity = ____Dora.Opacity
local Sequence = ____Dora.Sequence
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local reference = ____DoraX.reference
local toNode = ____DoraX.toNode
local ____Dora = require("Dora")
local App = ____Dora.App
local Director = ____Dora.Director
local Ease = ____Dora.Ease
local HttpServer = ____Dora.HttpServer
local Move = ____Dora.Move
local Node = ____Dora.Node
local sleep = ____Dora.sleep
local thread = ____Dora.thread
local Vec2 = ____Dora.Vec2
local ____Mascot = require("Dev/Mobile/Mascot")
local DoraMascot = ____Mascot.DoraMascot
local ____Gamepad = require("Dev/Mobile/Gamepad")
local attachGamepad = ____Gamepad.attachGamepad
local findGamepadNode = ____Gamepad.findGamepadNode
local ____FeedModel = require("Dev/Mobile/FeedModel")
local nextFeedIndex = ____FeedModel.nextFeedIndex
local visibleFeedPages = ____FeedModel.visibleFeedPages
local normalizeFeedIndex = ____FeedModel.normalizeFeedIndex
local resolveDiscoverRefreshTab = ____FeedModel.resolveDiscoverRefreshTab
local resolveFeedGesture = ____FeedModel.resolveFeedGesture
local resolveFeedLocation = ____FeedModel.resolveFeedLocation
local ____TextInput = require("Dev/Mobile/TextInput")
local createTextInput = ____TextInput.createTextInput
local ____Controls = require("Dev/Mobile/Controls")
local MobileButton = ____Controls.MobileButton
local MobileChoiceButton = ____Controls.MobileChoiceButton
local MobileNewButton = ____Controls.MobileNewButton
local MobilePanelSurface = ____Controls.MobilePanelSurface
local ____Visual = require("Dev/Mobile/Visual")
local GoIcon = ____Visual.GoIcon
local RoundedStencil = ____Visual.RoundedStencil
local RoundedSurface = ____Visual.SceneSurface
local VerticalGradient = ____Visual.VerticalGradient
local ____PackagePanel = require("Dev/Mobile/PackagePanel")
local startPackagePanel = ____PackagePanel.startPackagePanel
local ____ProjectIndex = require("Dev/Mobile/ProjectIndex")
local ProjectIndex = ____ProjectIndex.ProjectIndex
local mobileFontScale = goTheme.fontScale
local colors = goTheme
local fontName = goTheme.font
local createSheetHeight = 304
local createInputHeight = 44
local createInputTop = 140
local function conciseDescription(text, limit)
	local length = (utf8.len(text)) or 0
	if length <= limit then
		return text
	end
	local stop = utf8.offset(text, limit + 1) or #text + 1
	return string.sub(text, 1, stop - 1) .. "…"
end
function ____exports.startMobileFeed(options)
	local host, submitCreate, render, refreshDiscover
	local function getLocalEntries(dirtyProjectPath)
		return __TS__ArrayMap(
			options.getLocalEntries(dirtyProjectPath),
			function(____, entry) return __TS__ObjectAssign(
				{},
				entry,
				{title = projectDisplayName(entry.workDir, entry.title)}
			) end
		)
	end
	local getDiscoverEntries = options.getDiscoverEntries
	local onPlay = options.onPlay
	local onRemix = options.onRemix
	local prepare = options.prepare
	local syncDiscover = options.syncDiscover
	local zh = (string.match(App.locale, "^zh")) ~= nil
	local tab = "local"
	local index = 0
	local drag = Vec2.zero
	local dragAxis = "none"
	local discoverError = ""
	local preparing = false
	local transitioning = false
	local prepareStatus = ""
	local prepareProgress = 0
	local catalogSyncing = false
	local catalogStatus = ""
	local catalogStatusView
	local repairResourceId = ""
	local userSelectedTab = false
	local active = true
	local leaving = false
	local packagePanel
	local settingsOpen = false
	local createOpen = false
	local projectIndexOpen = false
	local creating = false
	local createName = ""
	local createLanguage = "typescript"
	local dismissedCreateComposition = false
	local createError = ""
	local gamepadUsed = false
	local returnEntry = options.initialEntry
	local ____opt_0 = options.initialEntries
	local ____temp_4 = ____opt_0 and ____opt_0["local"]
	local ____opt_2 = options.initialEntries
	local rememberedEntries = {["local"] = ____temp_4, discover = ____opt_2 and ____opt_2.discover}
	local cardRef = reference()
	local launchRef = reference()
	local slotRef = reference()
	local lastTouchTime = App.runningTime
	local guideShown = false
	local lastTapTime = -1
	local transitionRevision = 0
	local guidePlayed = false
	local function cancelGuide()
		lastTouchTime = App.runningTime
		guideShown = false
		local ____opt_5 = host:getChildByTag("go-gesture-guide")
		if ____opt_5 ~= nil then
			____opt_5:removeFromParent(true)
		end
	end
	local indexRef = reference()
	local infoRef = reference()
	local headerRef = reference()
	local menuRef = reference()
	local swapRef = reference()
	local gearRef = reference()
	local dragStartX = 0
	local dragStartY = 0
	local dragSampleTime = 0
	local dragVelocityX = 0
	local createInputRef = reference()
	local discover = getDiscoverEntries()
	local ____local = getLocalEntries()
	if #discover == 0 then
		discoverError = zh and "资源目录暂不可用" or "Catalog is unavailable"
	end
	local initialLocation = resolveFeedLocation(____local, discover, returnEntry)
	tab = initialLocation.tab
	index = initialLocation.index
	host = Node()
	host.tag = "mobile-feed"
	host.scaleX = App.devicePixelRatio
	host.scaleY = App.devicePixelRatio
	host:addTo(Director.systemUI)
	local function isActive()
		return active and not leaving and host.parent ~= nil
	end
	local function closeSettings()
		if not settingsOpen then
			return
		end
		settingsOpen = false
		if gearRef.current then
			gearRef.current:perform(Angle(App.reducedMotion and 0 or 0.24, gearRef.current.angle, 0, Ease.OutCubic))
		end
		local menu = menuRef.current
		if not menu or App.reducedMotion then
			render()
			return
		end
		menu:perform(Spawn(
			Opacity(0.16, menu.opacity, 0),
			Scale(0.16, menu.scaleX, 0.92, Ease.OutCubic),
			Move(
				0.16,
				menu.position,
				Vec2(menu.x, menu.y + 6),
				Ease.InQuad
			)
		))
		thread(function()
			sleep(0.16)
			if isActive() and menuRef.current == menu then
				render()
			end
		end)
	end
	local function entries()
		return tab == "discover" and discover or ____local
	end
	local function current()
		return entries()[normalizeFeedIndex(
			index,
			#entries()
		) + 1]
	end
	local rememberedEntryKey = ""
	local function rememberCurrent()
		local item = current()
		if item == nil or not options.onCurrentEntryChanged then
			return
		end
		local key = (((((item.kind .. "\n") .. item.id) .. "\n") .. (item.workDir or "")) .. "\n") .. (item.fileName or "")
		if key == rememberedEntryKey then
			return
		end
		rememberedEntryKey = key
		rememberedEntries[item.kind] = item
		options.onCurrentEntryChanged(item)
	end
	local function canEditCreate()
		return createOpen and not creating and isActive() and host.visible and HttpServer.wsConnectionCount == 0
	end
	local createInput = createTextInput({
		fontSize = math.floor(16 * mobileFontScale),
		singleLine = true,
		background = colors.background,
		getText = function() return createName end,
		setText = function(text)
			createName = text
		end,
		getPlaceholder = function() return zh and "例如：星际花园" or "For example: Star Garden" end,
		isEnabled = canEditCreate,
		onReturn = function()
			submitCreate()
			return true
		end
	})
	local blurCreateInput = createInput.blur
	local function closeCreate()
		if creating then
			return
		end
		blurCreateInput()
		createOpen = false
		createName = ""
		createError = ""
		render()
	end
	local function openCreate()
		if not options.createProject or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then
			return
		end
		projectIndexOpen = false
		createOpen = true
		createLanguage = "typescript"
		createName = ""
		dismissedCreateComposition = false
		createError = ""
		render()
		createInput.deferFocus()
	end
	local function openProjectIndex()
		if preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then
			return
		end
		if tab == "local" then
			____local = getLocalEntries()
		end
		projectIndexOpen = true
		render()
	end
	local function createErrorText(____error)
		repeat
			local ____switch34 = ____error
			local ____cond34 = ____switch34 == "invalid-name"
			if ____cond34 then
				return zh and "请输入不含路径分隔符的项目名称" or "Enter a project name without path separators"
			end
			____cond34 = ____cond34 or ____switch34 == "target-existed"
			if ____cond34 then
				return zh and "已有同名项目，请换一个名称" or "A project with that name already exists"
			end
			____cond34 = ____cond34 or ____switch34 == "create-folder-failed"
			if ____cond34 then
				return zh and "无法创建项目目录，请检查工作目录后重试" or "Could not create the project folder; check the workspace and retry"
			end
			____cond34 = ____cond34 or ____switch34 == "create-entry-failed"
			if ____cond34 then
				return zh and "无法写入项目入口，未完成项目已回滚" or "Could not write the project entry; the incomplete project was rolled back"
			end
			____cond34 = ____cond34 or ____switch34 == "created-project-not-found"
			if ____cond34 then
				return zh and "项目已创建，但本地列表未能找到它，请返回后重试" or "The project was created but could not be found in Local; return and retry"
			end
			do
				return zh and "创建失败，请重试" or "Project creation failed; try again"
			end
		until true
	end
	submitCreate = function()
		if not options.createProject or creating or not createOpen or not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		if createInput.isComposing() then
			return
		end
		creating = true
		createError = ""
		blurCreateInput()
		render()
		local result = options.createProject(createName, createLanguage)
		if not isActive() then
			return
		end
		creating = false
		if not result.success then
			createError = createErrorText(result.error)
			render()
			return
		end
		createOpen = false
		createName = ""
		____local = getLocalEntries()
		returnEntry = result.entry
		local location = resolveFeedLocation(____local, discover, result.entry)
		tab = location.tab
		index = location.index
		render()
		onRemix(result.entry)
	end
	local function createBlank()
		if not options.createProject or not isActive() or preparing or transitioning or creating or HttpServer.wsConnectionCount > 0 then
			return
		end
		local draftEntry = {id = "new-project", title = zh and "未命名游戏" or "Untitled game", kind = "local", description = ""}
		onRemix(
			draftEntry,
			function()
				do
					local suffix = 0
					while suffix < 100 do
						local name = draftEntry.title .. (suffix == 0 and "" or " " .. tostring(suffix + 1))
						local result = options.createProject(name, "typescript")
						if result.success or result.error ~= "target-existed" then
							return result
						end
						suffix = suffix + 1
					end
				end
				return {success = false, error = "target-existed"}
			end
		)
	end
	local function openPackage(mode, path, pickOnOpen)
		if pickOnOpen == nil then
			pickOnOpen = false
		end
		if not isActive() or not host.visible or packagePanel or preparing or transitioning or creating or createOpen or HttpServer.wsConnectionCount > 0 then
			return
		end
		projectIndexOpen = false
		packagePanel = startPackagePanel({
			mode = mode,
			path = path,
			pickOnOpen = pickOnOpen,
			entry = current(),
			onNew = openCreate,
			onClosed = function()
				packagePanel = nil
			end,
			onImported = function(entry, play)
				if not isActive() then
					return
				end
				____local = getLocalEntries(entry.workDir)
				local imported = __TS__ArrayFind(
					____local,
					function(____, item) return item.workDir == entry.workDir end
				) or entry
				returnEntry = imported
				local location = resolveFeedLocation(____local, discover, imported)
				tab = "local"
				index = location.index
				render()
				if play then
					onPlay(imported)
				end
			end
		})
	end
	local receiveElapsed = 0
	host:schedule(function(dt)
		receiveElapsed = receiveElapsed + dt
		if receiveElapsed < 0.5 then
			return false
		end
		receiveElapsed = 0
		if isActive() and host.visible and not packagePanel and not createOpen and not projectIndexOpen and not preparing and not transitioning and HttpServer.wsConnectionCount == 0 then
			if not settingsOpen and #entries() > 0 and not guideShown and not App.reducedMotion and App.runningTime - lastTouchTime > (guidePlayed and 30 or 2.5) then
				local guide = createGestureGuide(zh)
				guide.order = 500
				guide.position = Vec2(0, App.safeArea.height * 0.08)
				host:addChild(guide)
				guideShown = true
				guidePlayed = true
			end
			local path = options.takeReceivedFile and options.takeReceivedFile() or App:takeReceivedFile()
			if path ~= "" then
				openPackage("receive", path)
			end
		end
		return false
	end)
	local function setTab(next)
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning or creating then
			return
		end
		userSelectedTab = true
		returnEntry = nil
		if tab == next then
			return
		end
		if createOpen then
			blurCreateInput()
			createOpen = false
			createName = ""
			createError = ""
		end
		local direction = next == "discover" and 1 or -1
		local ____App_reducedMotion_7
		if App.reducedMotion then
			____App_reducedMotion_7 = nil
		else
			____App_reducedMotion_7 = cardRef.current
		end
		local outgoing = ____App_reducedMotion_7
		if outgoing ~= nil then
			outgoing:removeFromParent(false)
		end
		tab = next
		local target = rememberedEntries[next]
		local ____temp_10
		if target == nil then
			____temp_10 = nil
		else
			____temp_10 = resolveFeedLocation(____local, discover, target)
		end
		local location = ____temp_10
		index = (location and location.tab) == next and location.index or 0
		render()
		if not App.reducedMotion then
			local incoming = launchRef.current
			if incoming then
				incoming:perform(Spawn(
					Opacity(0.24, 0, 1),
					Move(
						0.43,
						Vec2(incoming.x + direction * 52, incoming.y),
						incoming.position,
						Ease.OutBack
					),
					Scale(0.43, 0.93, 1, Ease.OutBack),
					Angle(0.43, direction * 1.5, 0, Ease.OutCubic)
				))
			end
			local ____opt_13 = infoRef.current
			if ____opt_13 ~= nil then
				____opt_13:perform(Spawn(
					Opacity(0.31, 0, 1),
					Move(
						0.31,
						Vec2(0, -16),
						Vec2.zero,
						Ease.OutCubic
					)
				))
			end
			local ____opt_15 = swapRef.current
			if ____opt_15 ~= nil then
				____opt_15:perform(Angle(0.43, -180, 0, Ease.OutCubic))
			end
			if outgoing then
				local ghost = Node()
				ghost.position = Vec2(-App.visualSize.width / 2, -App.visualSize.height / 2)
				local disable
				disable = function(node)
					node.touchEnabled = false
					node:eachChild(function(child)
						disable(child)
						return false
					end)
				end
				disable(outgoing)
				ghost:addChild(outgoing)
				host:addChild(ghost)
				outgoing:perform(Spawn(
					Opacity(0.19, outgoing.opacity, 0),
					Move(
						0.19,
						outgoing.position,
						Vec2(-direction * 48, 0),
						Ease.OutCubic
					)
				))
				thread(function()
					sleep(0.2)
					if ghost.parent then
						ghost:removeFromParent(true)
					end
				end)
			end
		end
	end
	local function activate(action)
		local item = current()
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or item == nil or preparing or transitioning then
			return
		end
		item.launchError = nil
		local function done()
			returnEntry = item
			local ____temp_17
			if action == "play" then
				____temp_17 = onPlay(item)
			else
				____temp_17 = onRemix(item)
			end
			return ____temp_17
		end
		if item.kind == "local" or item.installed then
			done()
			return
		end
		preparing = true
		prepareProgress = 0
		prepareStatus = zh and "准备安装…" or "Preparing install…"
		render()
		local repairIncomplete = repairResourceId == item.id
		repairResourceId = ""
		prepare(
			item,
			repairIncomplete,
			function(progress, message)
				if not isActive() then
					return
				end
				prepareProgress = math.max(
					0,
					math.min(1, progress)
				)
				prepareStatus = message
				render()
			end,
			function(success, ready, message, repairable)
				if not isActive() then
					return
				end
				preparing = false
				if not success or not ready then
					repairResourceId = repairable and item.id or ""
					prepareStatus = message or (zh and "安装失败，点击按钮重试" or "Install failed; tap to retry")
					render()
					return
				end
				item.fileName = ready.fileName
				item.workDir = ready.workDir
				item.installed = true
				prepareStatus = ""
				if HttpServer.wsConnectionCount == 0 and host.visible then
					done()
				else
					render()
				end
			end
		)
	end
	local function commit(action)
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or transitioning then
			return
		end
		if action == "play" or action == "remix" then
			local card = cardRef.current
			if card then
				card.position = Vec2.zero
			end
		end
		repeat
			local ____switch84 = action
			local ____cond84 = ____switch84 == "previous" or ____switch84 == "next"
			if ____cond84 then
				do
					returnEntry = nil
					local target = nextFeedIndex(
						index + (action == "next" and 1 or -1),
						#entries(),
						tab
					)
					if target == index and tab == "local" then
						local card = cardRef.current
						if card then
							card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad))
						end
						return
					end
					transitionRevision = transitionRevision + 1
					local revision = transitionRevision
					local duration = App.reducedMotion and 0 or 0.32
					local function finish()
						if not isActive() or revision ~= transitionRevision or not host.visible then
							return
						end
						index = target
						transitioning = false
						App:vibrate(0.012)
						render()
					end
					local card = cardRef.current
					if duration > 0 and card then
						transitioning = true
						card:perform(Move(
							duration,
							card.position,
							Vec2(0, (action == "next" and 1 or -1) * App.safeArea.height),
							Ease.OutCubic
						))
						thread(function()
							sleep(duration)
							finish()
						end)
					else
						finish()
					end
					return
				end
			end
			____cond84 = ____cond84 or ____switch84 == "play"
			if ____cond84 then
				do
					local cartridge = launchRef.current
					local slot = slotRef.current
					if not cartridge or App.reducedMotion then
						activate("play")
						return
					end
					transitioning = true
					transitionRevision = transitionRevision + 1
					local revision = transitionRevision
					for ____, ref in ipairs({infoRef, headerRef, indexRef}) do
						local node = ref.current
						if node then
							node:perform(Opacity(0.16, node.opacity, 0))
						end
					end
					local slotX = App.safeArea.left - 30
					local seated = Vec2(slotX + 143.5 + 18, cartridge.y)
					if slot then
						slot:perform(Spawn(
							Opacity(0.24, slot.opacity, 1),
							Move(
								0.24,
								slot.position,
								Vec2(slotX, cartridge.y - 140),
								Ease.OutCubic
							)
						))
					end
					cartridge:stopAllActions()
					cartridge:perform(Sequence(
						Spawn(
							Move(
								0.4,
								cartridge.position,
								Vec2(seated.x + 9, seated.y),
								Ease.OutCubic
							),
							Scale(0.4, cartridge.scaleX, 0.72, Ease.OutCubic),
							Angle(0.4, cartridge.angle, 8, Ease.OutCubic),
							AngleY(0.4, cartridge.angleY, 64, Ease.OutCubic)
						),
						Spawn(
							Move(
								0.16,
								Vec2(seated.x + 9, seated.y),
								seated,
								Ease.OutCubic
							),
							Angle(0.16, 8, 0, Ease.OutCubic),
							AngleY(0.16, 64, 68, Ease.OutCubic)
						)
					))
					thread(function()
						sleep(0.74)
						if not isActive() or revision ~= transitionRevision or not host.visible then
							return
						end
						transitioning = false
						activate("play")
					end)
					return
				end
			end
			____cond84 = ____cond84 or ____switch84 == "remix"
			if ____cond84 then
				activate("remix")
				return
			end
			do
				return
			end
		until true
	end
	local function openAgentConfig()
		settingsOpen = false
		render()
		startMobileLLMManager({
			coveredNode = host,
			selectedId = getMobileLLMSelection(),
			onSelected = function()
			end,
			onClose = function()
				if isActive() then
					render()
				end
			end
		})
	end
	local function switchMode()
		if not isActive() or not host.visible or HttpServer.wsConnectionCount > 0 or preparing or creating or createOpen or packagePanel or transitioning or not options.onSwitchMode then
			return
		end
		leaving = true
		options.onSwitchMode()
	end
	host:slot("SwitchUIMode", switchMode)
	render = function()
		if not isActive() then
			return
		end
		transitionRevision = transitionRevision + 1
		transitioning = false
		catalogStatusView = nil
		cardRef = reference()
		launchRef = reference()
		slotRef = reference()
		infoRef = reference()
		indexRef = reference()
		local safeContentWidth = App.safeArea.width - 40
		local shortLandscapeInputWidth = safeContentWidth - 12 - math.min(
			300,
			math.floor(safeContentWidth * 0.42)
		)
		local expectedInputWidth = App.safeArea.width >= 760 and App.safeArea.height < 500 and shortLandscapeInputWidth or safeContentWidth
		local ____createOpen_20 = createOpen
		if ____createOpen_20 then
			local ____opt_18 = createInputRef.current
			____createOpen_20 = (____opt_18 and ____opt_18.width) == expectedInputWidth
		end
		local keptInput = ____createOpen_20 and createInputRef.current or nil
		local restoreFocus = createInput.isFocused()
		if keptInput ~= nil then
			keptInput:removeFromParent(false)
		end
		if not keptInput then
			createInput.unmount()
			createInputRef = reference()
		end
		local createPanelRef = reference()
		host:removeAllChildren()
		host.scaleX = App.devicePixelRatio
		host.scaleY = App.devicePixelRatio
		local ____App_visualSize_23 = App.visualSize
		local width = ____App_visualSize_23.width
		local height = ____App_visualSize_23.height
		local safe = App.safeArea
		local left = safe.left
		local bottom = safe.bottom
		local usableWidth = safe.width
		local usableHeight = safe.height
		local wide = usableWidth >= 760
		local compact = not wide and usableHeight < 700
		local shortLandscape = wide and usableHeight < 500
		local data = entries()
		index = normalizeFeedIndex(index, #data)
		local item = current()
		rememberCurrent()
		local horizontal = usableWidth > usableHeight and usableHeight < 600
		local infoWidth = horizontal and usableWidth * 0.48 - 32 or math.min(usableWidth - 52, 520)
		local infoHeight = 112
		local bottomSpace = horizontal and 28 or math.max(
			48,
			math.min(80, usableHeight * 0.09)
		)
		local actionsY = bottom + bottomSpace
		local infoX = horizontal and left + usableWidth * 0.52 or left + (usableWidth - infoWidth) / 2
		local infoTop = horizontal and bottom + usableHeight / 2 + 38 or actionsY + infoHeight - 24
		local descriptionY = infoTop - 24
		local availableHeight = horizontal and usableHeight - 148 or bottom + usableHeight - 66 - (infoTop + 24)
		local coverScale = math.max(
			0.4,
			math.min(1.278, (horizontal and usableWidth * 0.46 - 48 or (usableWidth - 52) * 0.9) / 236, (availableHeight - 48) * 0.9 / 308)
		)
		local coverWidth = 236 * coverScale
		local coverHeight = 308 * coverScale
		local coverX = horizontal and left + (usableWidth * 0.48 - coverWidth) / 2 or left + (usableWidth - coverWidth) / 2
		local coverY = horizontal and bottom + (usableHeight - coverHeight) / 2 - 8 or infoTop + 24 + (availableHeight - coverHeight) / 2
		local restCoverY = coverY + coverHeight / 2
		local gestureHintY = bottom + 18
		local fontScale = mobileFontScale
		local pages = visibleFeedPages(index, #data, tab)
		local headerRenderOrder = 1000
		local ____toNode_72 = toNode
		local ____React_createElement_71 = React.createElement
		local ____array_70 = __TS__SparseArrayNew(
			"node",
			{
				tag = "mobile-feed-scene",
				x = -width / 2,
				y = -height / 2,
				width = width,
				height = height,
				anchorX = 0,
				anchorY = 0,
				touchEnabled = true,
				onTapBegan = function()
					if isMobileLLMOpen() or preparing or transitioning or settingsOpen or projectIndexOpen or createOpen then
						return
					end
					cancelGuide()
					drag = Vec2.zero
					dragAxis = "none"
					dragSampleTime = App.runningTime
					dragVelocityX = 0
					local ____opt_24 = cardRef.current
					if ____opt_24 ~= nil then
						____opt_24:stopAllActions()
					end
					local ____opt_26 = launchRef.current
					if ____opt_26 ~= nil then
						____opt_26:stopAllActions()
					end
					local ____opt_28 = slotRef.current
					if ____opt_28 ~= nil then
						____opt_28:stopAllActions()
					end
					local ____opt_30 = launchRef.current
					dragStartX = (____opt_30 and ____opt_30.x or coverX + coverWidth / 2) - coverX - coverWidth / 2
					local ____opt_32 = cardRef.current
					dragStartY = ____opt_32 and ____opt_32.y or 0
					if indexRef.current then
						indexRef.current.opacity = 1
					end
				end,
				onTapMoved = function(touch)
					if isMobileLLMOpen() or preparing or transitioning or settingsOpen or projectIndexOpen or createOpen then
						return
					end
					drag = drag:add(touch.delta)
					local elapsed = App.runningTime - dragSampleTime
					if elapsed > 0 then
						dragVelocityX = touch.delta.x / (elapsed * 1000)
					end
					dragSampleTime = App.runningTime
					if dragAxis == "none" and math.max(
						math.abs(drag.x),
						math.abs(drag.y)
					) >= 12 then
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 and "horizontal" or "vertical"
						if dragAxis == "horizontal" and infoRef.current then
							infoRef.current:perform(Opacity(0.16, infoRef.current.opacity, 0.45))
						end
					end
					if not preparing and not transitioning and cardRef.current then
						local offset = dragAxis == "vertical" and Vec2(0, drag.y + dragStartY) or Vec2.zero
						if dragAxis == "horizontal" and slotRef.current then
							local distance = drag.x + dragStartX / 0.3
							local progress = math.max(
								0,
								math.min(1, -distance / 115)
							)
							slotRef.current.opacity = math.min(1, progress * 2)
							slotRef.current.x = left - 220 + progress * 190
							if launchRef.current then
								launchRef.current.x = coverX + coverWidth / 2 + (distance <= 0 and -math.min(-distance * 0.3, 42) or distance * 0.14)
								launchRef.current.angle = App.reducedMotion and 0 or progress * 2
								launchRef.current.angleY = App.reducedMotion and 0 or progress * 12
								local ____launchRef_current_35 = launchRef.current
								local ____temp_34 = App.reducedMotion and 1 or 1 - progress * 0.075
								launchRef.current.scaleY = ____temp_34
								____launchRef_current_35.scaleX = ____temp_34
								slotRef.current.y = launchRef.current.y - 140
							end
						end
						cardRef.current.position = offset
					end
				end,
				onTapEnded = function()
					if isMobileLLMOpen() or preparing or transitioning or settingsOpen or projectIndexOpen or createOpen then
						return
					end
					local isTap = math.abs(drag.x) < 12 and math.abs(drag.y) < 12
					if isTap and App.runningTime - lastTapTime < 0.3 then
						lastTapTime = -1
						commit("remix")
						return
					end
					lastTapTime = isTap and App.runningTime or -1
					local action = resolveFeedGesture(
						dragAxis == "horizontal" and drag.x or 0,
						dragAxis == "vertical" and drag.y or 0,
						usableWidth,
						usableHeight,
						false,
						App.runningTime - dragSampleTime < 0.08 and dragVelocityX or 0
					)
					drag = Vec2.zero
					dragAxis = "none"
					if indexRef.current then
						indexRef.current.opacity = 1
					end
					if action ~= "play" then
						local duration = App.reducedMotion and 0 or 0.23
						local slot = slotRef.current
						local launch = launchRef.current
						local info = infoRef.current
						if slot then
							slot:perform(Spawn(
								Opacity(duration, slot.opacity, 0),
								Move(
									duration,
									slot.position,
									Vec2(left - 220, slot.y),
									Ease.OutCubic
								)
							))
						end
						if launch then
							launch:perform(Spawn(
								Move(
									duration,
									launch.position,
									Vec2(coverX + coverWidth / 2, restCoverY),
									Ease.OutCubic
								),
								Angle(duration, launch.angle, 0, Ease.OutCubic),
								Scale(duration, launch.scaleX, 1, Ease.OutCubic),
								AngleY(duration, launch.angleY, 0, Ease.OutCubic)
							))
						end
						if info then
							info:perform(Opacity(duration, info.opacity, 1))
						end
					end
					if action == "none" and cardRef.current then
						local card = cardRef.current
						card:perform(Move(App.reducedMotion and 0 or 0.16, card.position, Vec2.zero, Ease.OutQuad))
					end
					commit(action)
				end,
				onMouseWheel = function(delta)
					cancelGuide()
					commit(delta.y > 0 and "previous" or "next")
				end
			},
			React.createElement(VerticalGradient, {width = width, height = height, topColor = goTheme.backgroundTop, bottomColor = goTheme.background}),
			React.createElement(
				"node",
				{
					order = 1,
					tag = "mobile-feed-slot",
					ref = slotRef,
					x = left - 220,
					y = coverY + (coverHeight - 280) / 2,
					opacity = 0
				},
				React.createElement(CartridgeSlot, {x = 0, y = 0})
			)
		)
		local ____React_createElement_68 = React.createElement
		local ____array_67 = __TS__SparseArrayNew(
			"node",
			{visible = not projectIndexOpen, order = 2},
			React.createElement(
				"node",
				{
					order = 100,
					width = width,
					height = height,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = false,
					onTapFilter = function(touch)
						touch.enabled = false
						cancelGuide()
					end
				}
			)
		)
		local ____createOpen_47
		if createOpen then
			____createOpen_47 = nil
		else
			local ____temp_46
			if item ~= nil then
				local ____React_createElement_45 = React.createElement
				local ____temp_44 = {
					width = width,
					height = height,
					anchorX = 0,
					anchorY = 0,
					stencil = React.createElement(RoundedStencil, {width = width, height = bottom + usableHeight - 76, radius = 0})
				}
				local ____React_createElement_43 = React.createElement
				local ____temp_41 = {tag = "mobile-feed-card-" .. item.id, ref = cardRef, key = (tab .. "-") .. item.id}
				local ____TS__ArrayMap_result_42 = __TS__ArrayMap(
					pages,
					function(____, page)
						local entry = data[page.index + 1]
						local activePage = page.offset == 0
						local displayTitle = projectDisplayName(entry.workDir, entry.title)
						local authorRef = reference()
						local ____React_createElement_39 = React.createElement
						local ____temp_37 = {y = -page.offset * usableHeight}
						local ____React_createElement_result_38 = React.createElement(
							"node",
							{
								tag = activePage and "mobile-feed-cartridge" or nil,
								ref = activePage and launchRef or nil,
								x = coverX + coverWidth / 2,
								y = coverY + coverHeight / 2,
								width = coverWidth,
								height = coverHeight,
								anchorX = 0.5,
								anchorY = 0.5
							},
							React.createElement(Cartridge, {
								entry = entry,
								x = 0,
								y = 0,
								width = coverWidth,
								height = coverHeight
							})
						)
						local ____temp_36
						if tab == "local" then
							____temp_36 = React.createElement(
								"node",
								{
									tag = activePage and "mobile-feed-index" or nil,
									ref = activePage and indexRef or nil,
									x = coverX + coverWidth / 2 - 40,
									y = horizontal and coverY - 26 or infoTop + 28,
									width = 80,
									height = 24,
									anchorX = 0,
									anchorY = 0,
									touchEnabled = activePage,
									swallowTouches = true,
									onMount = pressFeedback,
									onTapped = openProjectIndex
								},
								React.createElement(
									"label",
									{
										x = 40,
										y = 12,
										fontName = fontName,
										fontSize = 10,
										text = ((((page.index + 1 < 10 and "0" or "") .. tostring(page.index + 1)) .. "  /  ") .. (#data < 10 and "0" or "")) .. tostring(#data),
										color3 = 8093040
									}
								)
							)
						else
							____temp_36 = nil
						end
						return ____React_createElement_39(
							"node",
							____temp_37,
							____React_createElement_result_38,
							____temp_36,
							React.createElement(
								"node",
								{ref = activePage and infoRef or nil},
								React.createElement(
									"label",
									{
										tag = activePage and "mobile-feed-current-title" or nil,
										x = infoX,
										y = infoTop,
										anchorX = 0,
										fontName = goTheme.headingFont,
										fontSize = math.floor((compact and 22 or 25) * fontScale),
										text = conciseDescription(
											displayTitle,
											math.floor(infoWidth / 24)
										),
										textWidth = -1,
										color3 = 3159339,
										alignment = "Left"
									}
								),
								React.createElement(
									Description,
									{
										text = entry.description or "",
										x = infoX,
										y = descriptionY,
										width = infoWidth,
										active = activePage,
										onExpand = function(expanded, extraHeight)
											if not activePage then
												return
											end
											local offset = expanded and extraHeight or 0
											local duration = App.reducedMotion and 0 or 0.26
											local info = infoRef.current
											local author = authorRef.current
											local count = indexRef.current
											local cart = launchRef.current
											if info then
												info:perform(Move(
													duration,
													info.position,
													Vec2(0, offset),
													Ease.OutCubic
												))
											end
											if author then
												author:perform(Move(
													duration,
													author.position,
													Vec2(infoX, (horizontal and infoTop - 110 or actionsY) - offset),
													Ease.OutCubic
												))
											end
											if not horizontal then
												restCoverY = coverY + coverHeight / 2 + offset
												if cart then
													cart:perform(Move(
														duration,
														cart.position,
														Vec2(cart.x, restCoverY),
														Ease.OutCubic
													))
												end
												if count then
													count:perform(Move(
														duration,
														count.position,
														Vec2(count.x, infoTop + 28 + offset),
														Ease.OutCubic
													))
												end
											end
										end
									}
								),
								React.createElement(
									"node",
									{ref = authorRef, x = infoX, y = horizontal and infoTop - 110 or actionsY},
									React.createElement(
										"draw-node",
										{visible = entry.kind == "local" or entry.author ~= nil, x = 13, y = 16},
										React.createElement("dot-shape", {radius = 13, color = entry.kind == "local" and 4282558366 or 4292848240})
									),
									React.createElement("label", {
										visible = entry.kind == "local" or entry.author ~= nil,
										x = 13,
										y = 16,
										fontName = fontName,
										fontSize = 11,
										text = entry.kind == "local" and (zh and "我" or "Me") or "D",
										color3 = 16777215
									}),
									React.createElement("label", {
										x = 36,
										y = 16,
										anchorX = 0,
										fontName = fontName,
										fontSize = 12,
										text = entry.author or (entry.kind == "local" and (zh and "我" or "Me") or ""),
										color3 = 3159339,
										alignment = "Left"
									}),
									React.createElement(
										MobileButton,
										{
											tag = activePage and "mobile-feed-remix" or nil,
											x = infoWidth - 76,
											y = 0,
											width = 76,
											height = 32,
											fontSize = 12,
											icon = entry.kind == "local" and "code" or "remix",
											text = entry.kind == "local" and (zh and "开发" or "Edit") or "Remix",
											disabled = not activePage or preparing or transitioning,
											onTapped = function() return activate("remix") end
										}
									)
								)
							)
						)
					end
				)
				local ____temp_40
				if prepareStatus ~= "" or item.launchError or gamepadUsed then
					____temp_40 = React.createElement("label", {
						x = infoX,
						y = gestureHintY,
						anchorX = 0,
						fontName = fontName,
						fontSize = 11,
						text = item.launchError or (prepareStatus ~= "" and prepareStatus or (zh and "↑↓ 浏览 · A 进入 · X 开发 · Start 列表" or "↑↓ Browse · A Play · X Develop · Start List")),
						textWidth = infoWidth,
						alignment = "Left",
						color3 = 8159855
					})
				else
					____temp_40 = nil
				end
				____temp_46 = ____React_createElement_45(
					"clip-node",
					____temp_44,
					____React_createElement_43("node", ____temp_41, ____TS__ArrayMap_result_42, ____temp_40)
				)
			else
				____temp_46 = React.createElement(
					"node",
					nil,
					React.createElement("label", {
						x = left + usableWidth / 2,
						y = bottom + usableHeight / 2 + 20,
						fontName = fontName,
						fontSize = 22,
						text = tab == "discover" and (zh and "暂无移动作品" or "No mobile games yet") or (zh and "没有可运行的本地作品" or "No runnable local games"),
						color3 = 3159339
					}),
					React.createElement("label", {
						x = left + usableWidth / 2,
						y = bottom + usableHeight / 2 - 28,
						fontName = fontName,
						fontSize = 14,
						text = tab == "discover" and discoverError ~= "" and discoverError or (zh and "切换标签或稍后重试" or "Switch tabs or retry later"),
						textWidth = usableWidth - 48,
						color3 = tab == "discover" and discoverError ~= "" and 16739179 or 8159855
					})
				)
			end
			____createOpen_47 = ____temp_46
		end
		__TS__SparseArrayPush(____array_67, ____createOpen_47)
		local ____temp_48
		if not createOpen and item == nil and tab == "local" then
			____temp_48 = React.createElement(
				"node",
				nil,
				React.createElement(MobileButton, {
					tag = "mobile-empty-new",
					x = left + 20,
					y = bottom + 24,
					width = (usableWidth - 52) / 2,
					text = zh and "新建作品" or "New game",
					onTapped = createBlank
				}),
				React.createElement(
					MobileButton,
					{
						tag = "mobile-empty-import",
						x = left + 32 + (usableWidth - 52) / 2,
						y = bottom + 24,
						width = (usableWidth - 52) / 2,
						text = zh and "导入作品包" or "Import package",
						fontSize = 15,
						primary = true,
						onTapped = function() return openPackage("add", nil, true) end
					}
				)
			)
		else
			____temp_48 = nil
		end
		__TS__SparseArrayPush(____array_67, ____temp_48)
		local ____temp_49
		if item == nil and tab == "discover" and syncDiscover then
			____temp_49 = React.createElement(MobileButton, {
				tag = "mobile-feed-empty-index",
				x = left + (usableWidth - 160) / 2,
				y = bottom + 24,
				width = 160,
				text = zh and "作品目录" or "Game index",
				onTapped = openProjectIndex
			})
		else
			____temp_49 = nil
		end
		__TS__SparseArrayPush(____array_67, ____temp_49)
		local ____React_createElement_54 = React.createElement
		local ____array_53 = __TS__SparseArrayNew(
			"node",
			{tag = "mobile-feed-header", ref = headerRef, order = headerRenderOrder},
			React.createElement(RoundedSurface, {
				x = 0,
				y = bottom + usableHeight - 76,
				width = width,
				height = height - bottom - usableHeight + 76,
				radius = 0,
				fillColor = goTheme.backgroundTop
			})
		)
		local ____settingsOpen_50
		if settingsOpen then
			____settingsOpen_50 = React.createElement("node", {
				width = width,
				height = height,
				anchorX = 0,
				anchorY = 0,
				touchEnabled = true,
				swallowTouches = true,
				onTapped = closeSettings
			})
		else
			____settingsOpen_50 = nil
		end
		__TS__SparseArrayPush(
			____array_53,
			____settingsOpen_50,
			React.createElement(
				"node",
				{
					tag = "mobile-feed-scene-toggle",
					x = left + 20,
					y = bottom + usableHeight - 58,
					width = 140,
					height = 40,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = not preparing and not transitioning,
					swallowTouches = true,
					onMount = pressFeedback,
					onTapped = function()
						____local = getLocalEntries()
						setTab(tab == "local" and "discover" or "local")
					end
				},
				React.createElement(
					"node",
					{ref = swapRef, x = 8, y = 20},
					React.createElement(GoIcon, {
						name = "swap",
						x = -8,
						y = -8,
						size = 16,
						color = 4290155559
					})
				),
				React.createElement("label", {
					x = 27,
					y = 20,
					anchorX = 0,
					fontName = goTheme.headingFont,
					fontSize = 17,
					text = tab == "local" and (zh and "本地" or "Local") or (zh and "发现" or "Discover"),
					color3 = 3159339,
					alignment = "Left"
				}),
				React.createElement("label", {
					x = zh and 76 or 104,
					y = 20,
					anchorX = 0,
					fontName = fontName,
					fontSize = 11,
					text = tab == "local" and (zh and "发现" or "Discover") or (zh and "本地" or "Local"),
					color3 = 9147006,
					alignment = "Left"
				})
			)
		)
		local ____options_createProject_51
		if options.createProject then
			____options_createProject_51 = React.createElement(MobileNewButton, {
				tag = "mobile-feed-create",
				x = left + usableWidth - 140,
				y = bottom + usableHeight - 54,
				text = zh and "制造" or "Create",
				onTapped = createBlank
			})
		else
			____options_createProject_51 = nil
		end
		__TS__SparseArrayPush(
			____array_53,
			____options_createProject_51,
			React.createElement(
				"node",
				{
					onMount = pressFeedback,
					tag = "mobile-feed-settings",
					x = left + usableWidth - 52,
					y = bottom + usableHeight - 56,
					width = 36,
					height = 36,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = not preparing and not transitioning,
					swallowTouches = true,
					onTapped = function()
						cancelGuide()
						if settingsOpen then
							closeSettings()
						else
							settingsOpen = true
							render()
						end
					end
				},
				React.createElement(
					"node",
					{
						ref = gearRef,
						x = 18,
						y = 18,
						onMount = function(node)
							if settingsOpen and not App.reducedMotion then
								node:perform(Angle(0.36, 0, 65, Ease.OutCubic))
							end
						end
					},
					React.createElement(GoIcon, {name = "settings", x = -10, y = -10, size = 20})
				)
			)
		)
		local ____settingsOpen_52
		if settingsOpen then
			____settingsOpen_52 = React.createElement(
				"node",
				{
					ref = menuRef,
					tag = "mobile-feed-settings-menu",
					x = left + usableWidth - 20,
					y = bottom + usableHeight - 64,
					width = 174,
					height = 102,
					anchorX = 1,
					anchorY = 1,
					onMount = function(node) return node:perform(Spawn(
						Opacity(App.reducedMotion and 0 or 0.2, 0, 1),
						Scale(App.reducedMotion and 0 or 0.29, App.reducedMotion and 1 or 0.86, 1, Ease.OutBack)
					)) end
				},
				React.createElement(RoundedSurface, {
					width = 174,
					height = 102,
					radius = 12,
					fillColor = 4294769912,
					borderWidth = 0.7,
					borderColor = 4292006855,
					shadow = true
				}),
				React.createElement(
					"node",
					{
						tag = "mobile-agent-config",
						x = 6,
						y = 54,
						width = 162,
						height = 42,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onMount = pressFeedback,
						onTapped = openAgentConfig
					},
					React.createElement(GoIcon, {name = "settings", x = 10, y = 12, size = 18}),
					React.createElement("label", {
						x = 38,
						y = 21,
						anchorX = 0,
						fontName = fontName,
						fontSize = 13,
						text = zh and "Agent 配置" or "Agent settings",
						color3 = 3159339,
						alignment = "Left"
					})
				),
				React.createElement(
					"node",
					{
						tag = "mobile-ui-mode-switch",
						x = 6,
						y = 6,
						width = 162,
						height = 42,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onMount = pressFeedback,
						onTapped = switchMode
					},
					React.createElement(GoIcon, {
						name = "exit",
						x = 10,
						y = 12,
						size = 18,
						color = 4285823848
					}),
					React.createElement("label", {
						x = 38,
						y = 21,
						anchorX = 0,
						fontName = fontName,
						fontSize = 13,
						text = zh and "退出 Go 模式" or "Exit Go mode",
						color3 = 3159339,
						alignment = "Left"
					})
				)
			)
		else
			____settingsOpen_52 = nil
		end
		__TS__SparseArrayPush(____array_53, ____settingsOpen_52)
		__TS__SparseArrayPush(
			____array_67,
			____React_createElement_54(__TS__SparseArraySpread(____array_53))
		)
		local ____preparing_58
		if preparing then
			local ____React_createElement_57 = React.createElement
			local ____array_56 = __TS__SparseArrayNew(
				"node",
				{
					tag = "mobile-feed-loading",
					order = 2000,
					width = width,
					height = height,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true
				},
				React.createElement(RoundedSurface, {width = width, height = height, radius = 0, fillColor = goTheme.background}),
				React.createElement(DoraMascot, {x = width / 2, y = height / 2 + 64, size = 58, state = "idle"}),
				React.createElement("label", {
					x = width / 2,
					y = height / 2 + 12,
					fontName = fontName,
					fontSize = 16,
					text = zh and "正在准备游戏" or "Preparing game",
					color3 = 3159339
				}),
				React.createElement(RoundedSurface, {
					x = width / 2 - 100,
					y = height / 2 - 24,
					width = 200,
					height = 5,
					radius = 2.5,
					fillColor = goTheme.border
				})
			)
			local ____temp_55
			if prepareProgress > 0 then
				____temp_55 = React.createElement(RoundedSurface, {
					x = width / 2 - 100,
					y = height / 2 - 24,
					width = 200 * prepareProgress,
					height = 5,
					radius = 2.5,
					fillColor = goTheme.brand
				})
			else
				____temp_55 = nil
			end
			__TS__SparseArrayPush(
				____array_56,
				____temp_55,
				React.createElement(
					"label",
					{
						x = width / 2,
						y = height / 2 - 55,
						fontName = fontName,
						fontSize = 12,
						text = (tostring(math.floor(prepareProgress * 100)) .. "% · ") .. prepareStatus,
						textWidth = usableWidth - 64,
						color3 = 8159855
					}
				)
			)
			____preparing_58 = ____React_createElement_57(__TS__SparseArraySpread(____array_56))
		else
			____preparing_58 = nil
		end
		__TS__SparseArrayPush(____array_67, ____preparing_58)
		local ____createOpen_66
		if createOpen then
			____createOpen_66 = (function()
				local sheetHeight = math.min(createSheetHeight, usableHeight - 64)
				local sheetWidth = usableWidth
				local contentWidth = sheetWidth - 40
				local actionGap = 12
				local actionsWidth = shortLandscape and math.min(
					300,
					math.floor(contentWidth * 0.42)
				) or contentWidth
				local inputWidth = shortLandscape and contentWidth - actionGap - actionsWidth or contentWidth
				local actionX = shortLandscape and 20 + inputWidth + actionGap or 20
				local actionY = shortLandscape and sheetHeight - createInputTop - createInputHeight or 20
				local cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape and 0.34 or 0.38))
				local ____React_createElement_65 = React.createElement
				local ____array_64 = __TS__SparseArrayNew(
					"node",
					{
						tag = "mobile-project-create-sheet",
						order = 10000,
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
							tag = "mobile-project-create-focus-observer",
							order = 1000,
							width = width,
							height = height,
							anchorX = 0,
							anchorY = 0,
							touchEnabled = true,
							swallowTouches = false,
							swallowMouseWheel = false,
							onTapFilter = function(touch)
								touch.enabled = false
								if not canEditCreate() then
									return
								end
								local input = createInputRef.current
								local point = input and input:convertToNodeSpace(touch.worldLocation)
								local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height
								dismissedCreateComposition = not inside and createInput.isComposing()
								if not inside then
									blurCreateInput()
								end
							end
						}
					),
					React.createElement(
						"draw-node",
						{
							tag = "mobile-project-create-backdrop",
							order = 0,
							renderOrder = 0,
							x = width / 2,
							y = bottom + sheetHeight + (height - bottom - sheetHeight) / 2
						},
						React.createElement("rect-shape", {width = width, height = height - bottom - sheetHeight, fillColor = 2348810240})
					)
				)
				local ____React_createElement_63 = React.createElement
				local ____array_62 = __TS__SparseArrayNew(
					"node",
					{
						ref = createPanelRef,
						order = 10,
						renderOrder = 10,
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
						fontName = fontName,
						fontSize = 22,
						text = zh and "新建项目" or "New project",
						color3 = 3159339,
						alignment = "Left"
					}),
					__TS__ArrayMap(
						{"typescript", "lua"},
						function(____, language, i) return React.createElement(
							MobileChoiceButton,
							{
								tag = "mobile-project-create-language-" .. language,
								x = 20 + i * 144,
								y = sheetHeight - 98,
								width = language == "lua" and 84 or 132,
								text = language == "lua" and "Lua" or "TypeScript",
								selected = createLanguage == language,
								renderOrder = 10,
								onTapped = function()
									if not canEditCreate() then
										return
									end
									blurCreateInput()
									createLanguage = language
									render()
								end
							}
						) end
					),
					React.createElement("label", {
						x = 20,
						y = sheetHeight - 110,
						anchorX = 0,
						anchorY = 1,
						fontName = fontName,
						fontSize = 14,
						text = zh and "项目名称" or "Project name",
						color3 = 8159855,
						alignment = "Left"
					})
				)
				local ____keptInput_61
				if keptInput then
					____keptInput_61 = nil
				else
					____keptInput_61 = React.createElement("node", {
						tag = "mobile-project-create-input",
						ref = createInputRef,
						renderOrder = 10,
						x = 20,
						y = sheetHeight - createInputTop - createInputHeight,
						width = inputWidth,
						height = createInputHeight,
						anchorX = 0,
						anchorY = 0,
						onMount = createInput.mount
					})
				end
				__TS__SparseArrayPush(
					____array_62,
					____keptInput_61,
					React.createElement("label", {
						tag = "mobile-project-create-error",
						x = 20,
						y = shortLandscape and sheetHeight - createInputTop + 12 or sheetHeight - createInputTop - createInputHeight - 12,
						anchorX = 0,
						anchorY = 1,
						fontName = fontName,
						fontSize = 12,
						text = createError ~= "" and createError or (zh and ("将创建可运行的 " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " 起始项目" or ("Creates a runnable " .. (createLanguage == "lua" and "Lua" or "TypeScript")) .. " starter project"),
						textWidth = inputWidth,
						alignment = "Left",
						color3 = createError ~= "" and 16739179 or 8159855
					}),
					React.createElement(MobileButton, {
						tag = "mobile-project-create-cancel",
						x = actionX,
						y = actionY,
						width = cancelWidth,
						text = zh and "取消" or "Cancel",
						renderOrder = 10,
						onTapped = closeCreate
					}),
					React.createElement(
						MobileButton,
						{
							tag = "mobile-project-create-submit",
							x = actionX + cancelWidth + actionGap,
							y = actionY,
							width = actionsWidth - cancelWidth - actionGap,
							text = creating and (zh and "创建中…" or "Creating…") or (zh and "创建并进入 Remix" or "Create and Remix"),
							primary = true,
							renderOrder = 10,
							onTapped = function()
								if not dismissedCreateComposition then
									submitCreate()
								end
								dismissedCreateComposition = false
							end
						}
					)
				)
				__TS__SparseArrayPush(
					____array_64,
					____React_createElement_63(__TS__SparseArraySpread(____array_62))
				)
				return ____React_createElement_65(__TS__SparseArraySpread(____array_64))
			end)()
		else
			____createOpen_66 = nil
		end
		__TS__SparseArrayPush(____array_67, ____createOpen_66)
		__TS__SparseArrayPush(
			____array_70,
			____React_createElement_68(__TS__SparseArraySpread(____array_67))
		)
		local ____projectIndexOpen_69
		if projectIndexOpen then
			____projectIndexOpen_69 = React.createElement(
				ProjectIndex,
				{
					entries = entries(),
					kind = tab,
					current = current(),
					x = left,
					y = bottom,
					width = usableWidth,
					height = usableHeight,
					zh = zh,
					refreshing = catalogSyncing,
					refreshStatus = catalogStatus,
					onRefresh = syncDiscover and (function() return refreshDiscover(true) end) or nil,
					onStatusReady = function(____, update)
						catalogStatusView = update
					end,
					onClose = function()
						projectIndexOpen = false
						render()
					end,
					onSelect = function(____, entry)
						projectIndexOpen = false
						local location = resolveFeedLocation(____local, discover, entry)
						tab = location.tab
						index = location.index
						render()
					end
				}
			)
		else
			____projectIndexOpen_69 = nil
		end
		__TS__SparseArrayPush(____array_70, ____projectIndexOpen_69)
		local scene = ____toNode_72(____React_createElement_71(__TS__SparseArraySpread(____array_70)))
		if scene ~= nil then
			host:addChild(scene)
		end
		if keptInput and createPanelRef.current then
			keptInput.position = Vec2(
				20,
				math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight
			)
			createPanelRef.current:addChild(keptInput)
		end
		createInput.refresh()
		if restoreFocus and not keptInput and createOpen then
			createInput.focus(false)
		end
	end
	attachGamepad(
		host,
		{
			initialTag = "mobile-feed-remix",
			isEnabled = function() return isActive() and not packagePanel and not preparing and not transitioning and not creating end,
			onActive = function()
				gamepadUsed = true
				render()
			end,
			onBack = function()
				if createInput.isFocused() then
					blurCreateInput()
				elseif createOpen then
					closeCreate()
				elseif settingsOpen then
					settingsOpen = false
					render()
				else
					switchMode()
				end
			end,
			onActivate = function(target)
				if target.tag == "mobile-project-create-input" then
					target:emit("GamepadActivate")
				else
					if createInput.isComposing() then
						blurCreateInput()
						return
					end
					blurCreateInput()
					dismissedCreateComposition = false
					target:emit("Tapped")
				end
			end,
			onButton = function(button)
				if createOpen or projectIndexOpen or settingsOpen then
					return false
				end
				repeat
					local ____switch178 = button
					local ____cond178 = ____switch178 == "dpup"
					if ____cond178 then
						commit("previous")
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "dpdown"
					if ____cond178 then
						commit("next")
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "leftshoulder"
					if ____cond178 then
						setTab("discover")
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "rightshoulder"
					if ____cond178 then
						setTab("local")
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "a"
					if ____cond178 then
						commit("play")
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "x"
					if ____cond178 then
						commit("remix")
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "y"
					if ____cond178 then
						local ____opt_73 = findGamepadNode(host, "mobile-feed-create")
						if ____opt_73 ~= nil then
							____opt_73:emit("Tapped")
						end
						return true
					end
					____cond178 = ____cond178 or ____switch178 == "start"
					if ____cond178 then
						openProjectIndex()
						return true
					end
					do
						return false
					end
				until true
			end
		}
	)
	host:onAppChange(function(setting)
		if setting == "Locale" then
			local activeEntry = current()
			zh = (string.match(App.locale, "^zh")) ~= nil
			____local = getLocalEntries()
			discover = getDiscoverEntries()
			local location = resolveFeedLocation(____local, discover, activeEntry)
			tab = location.tab
			index = location.index
			render()
		elseif setting == "Size" then
			render()
		end
	end)
	host:onAppEvent(function(event)
		if event == "BackButton" then
			if settingsOpen then
				settingsOpen = false
				render()
			elseif projectIndexOpen then
				projectIndexOpen = false
				render()
			elseif createOpen and not creating then
				closeCreate()
			end
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then
			blurCreateInput()
		end
	end)
	host:onCleanup(function()
		blurCreateInput()
		active = false
		if packagePanel ~= nil then
			packagePanel:removeFromParent(true)
		end
		packagePanel = nil
	end)
	host:slot(
		"RestoreFeedEntry",
		function(entry)
			if not isActive() or HttpServer.wsConnectionCount > 0 then
				return
			end
			returnEntry = entry
			____local = getLocalEntries()
			discover = getDiscoverEntries()
			local location = resolveFeedLocation(____local, discover, entry)
			tab = location.tab
			index = location.index
			render()
		end
	)
	host:slot(
		"SuspendLocalUI",
		function()
			if packagePanel then
				packagePanel.visible = false
			end
			blurCreateInput()
			cancelGuide()
			transitionRevision = transitionRevision + 1
			transitioning = false
		end
	)
	host:slot(
		"ResumeLocalUI",
		function()
			if packagePanel then
				packagePanel.visible = host.visible
			end
			leaving = false
			render()
		end
	)
	refreshDiscover = function(force)
		if not syncDiscover or catalogSyncing or not isActive() then
			return
		end
		catalogSyncing = true
		catalogStatus = zh and "正在同步资源目录…" or "Syncing Catalog…"
		if #discover == 0 then
			discoverError = catalogStatus
		end
		render()
		syncDiscover(
			function(message)
				if not isActive() then
					return
				end
				catalogStatus = message
				if catalogStatusView ~= nil then
					catalogStatusView(message)
				end
				if projectIndexOpen or #discover > 0 then
					return
				end
				discoverError = message
				render()
			end,
			function(success, message)
				if not isActive() then
					return
				end
				catalogSyncing = false
				catalogStatus = success and (zh and "目录已更新" or "Catalog updated") or (zh and "刷新失败：" or "Refresh failed: ") .. (message or (zh and "请重试" or "Try again"))
				local selected = force and current() or (returnEntry or rememberedEntries[tab] or current())
				local previousCount = #discover
				discover = getDiscoverEntries()
				discoverError = success and (#discover == 0 and (zh and "目录中暂无可运行作品" or "No runnable Catalog games") or "") or (message or (zh and "资源目录同步失败" or "Catalog sync failed"))
				if not force and not projectIndexOpen then
					tab = resolveDiscoverRefreshTab(
						tab,
						userSelectedTab,
						previousCount,
						#discover,
						#____local
					)
				end
				if selected ~= nil then
					local location = resolveFeedLocation(____local, discover, selected)
					if location.tab == tab then
						index = location.index
					end
				end
				index = normalizeFeedIndex(
					index,
					#entries()
				)
				render()
			end,
			force
		)
	end
	render()
	refreshDiscover(false)
	return host
end
return ____exports
