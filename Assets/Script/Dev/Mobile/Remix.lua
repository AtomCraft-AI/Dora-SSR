local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local ____exports = {}
local ____ProjectCreate = require("Dev/Mobile/ProjectCreate")
local mobileLuaProjectTemplate = ____ProjectCreate.mobileLuaProjectTemplate
local mobileTypeScriptProjectTemplate = ____ProjectCreate.mobileTypeScriptProjectTemplate
local mobileTypeScriptProjectLuaTemplate = ____ProjectCreate.mobileTypeScriptProjectLuaTemplate
local ScrollArea = require("UI/Control/Basic/ScrollArea")
local ____ProjectPresentation = require("Dev/Mobile/ProjectPresentation")
local projectDisplayName = ____ProjectPresentation.projectDisplayName
local saveProjectDisplayName = ____ProjectPresentation.saveProjectDisplayName
local ____WorkspacePanel = require("Dev/Mobile/WorkspacePanel")
local startWorkspacePanel = ____WorkspacePanel.startWorkspacePanel
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____Controls = require("Dev/Mobile/Controls")
local MobileButton = ____Controls.MobileButton
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
local ____Visual = require("Dev/Mobile/Visual")
local GoIcon = ____Visual.GoIcon
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local reference = ____DoraX.reference
local toNode = ____DoraX.toNode
local ____Gamepad = require("Dev/Mobile/Gamepad")
local attachGamepad = ____Gamepad.attachGamepad
local ____Dora = require("Dora")
local App = ____Dora.App
local Content = ____Dora.Content
local DB = ____Dora.DB
local Director = ____Dora.Director
local Ease = ____Dora.Ease
local HttpServer = ____Dora.HttpServer
local Label = ____Dora.Label
local Move = ____Dora.Move
local Node = ____Dora.Node
local sleep = ____Dora.sleep
local thread = ____Dora.thread
local Vec2 = ____Dora.Vec2
local AgentSession = require("Agent/Session")
local ____Utils = require("Agent/Utils")
local getActiveLLMConfig = ____Utils.getActiveLLMConfig
local getLLMConfig = ____Utils.getLLMConfig
local getLLMConfigSummaries = ____Utils.getLLMConfigSummaries
local safeJsonEncode = ____Utils.safeJsonEncode
local ____RemixModel = require("Dev/Mobile/RemixModel")
local buildQuestionnaireAnswers = ____RemixModel.buildQuestionnaireAnswers
local canLeaveRemix = ____RemixModel.canLeaveRemix
local isQuestionAnswered = ____RemixModel.isQuestionAnswered
local resolveRemixThinkingStatus = ____RemixModel.resolveRemixThinkingStatus
local resolveRemixWorkMode = ____RemixModel.resolveRemixWorkMode
local ____FeedModel = require("Dev/Mobile/FeedModel")
local resolveFeedGesture = ____FeedModel.resolveFeedGesture
local ____RemixTranscript = require("Dev/Mobile/RemixTranscript")
local createRemixTranscript = ____RemixTranscript.createRemixTranscript
local remixDisplayRevision = ____RemixTranscript.remixDisplayRevision
local ____RemixHistory = require("Dev/Mobile/RemixHistory")
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS
local ____TextInput = require("Dev/Mobile/TextInput")
local createTextInput = ____TextInput.createTextInput
local inputLength = ____TextInput.inputLength
local inputSlice = ____TextInput.inputSlice
local ____LLMSetup = require("Dev/Mobile/LLMSetup")
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager
local isMobileLLMOpen = ____LLMSetup.isMobileLLMOpen
local ____PackagePanel = require("Dev/Mobile/PackagePanel")
local startPackagePanel = ____PackagePanel.startPackagePanel
local ____Visual = require("Dev/Mobile/Visual")
local RoundedStencil = ____Visual.RoundedStencil
local RoundedSurface = ____Visual.SceneSurface
local VerticalGradient = ____Visual.VerticalGradient
local ____Controls = require("Dev/Mobile/Controls")
local ChoiceButton = ____Controls.MobileChoiceButton
local mobileFontScale = goTheme.fontScale
local fontName = goTheme.font
local composerGap = 12
local composerBottom = 76
local composerHeight = 60
local modeBottom = composerBottom + composerHeight + composerGap
local composerTop = modeBottom + 40
local transcriptBottom = composerTop + composerGap
local function ellipsizeSingleLine(text, width, fontSize)
	if text == "" then
		return ""
	end
	local measure = Label(fontName, fontSize, true)
	if not measure then
		return text
	end
	measure.visible = false
	measure.textWidth = -1
	local function fits(value)
		measure.text = value
		return measure.width <= width
	end
	if fits(text) then
		measure:cleanup()
		return text
	end
	local low = 0
	local high = inputLength(text)
	while low < high do
		local middle = math.floor((low + high + 1) / 2)
		if fits(inputSlice(text, 0, middle) .. "…") then
			low = middle
		else
			high = middle - 1
		end
	end
	local result = inputSlice(text, 0, low) .. "…"
	measure:cleanup()
	return result
end
local function measureWrappedTextHeight(text, width, fontSize)
	local measure = Label(fontName, fontSize, true)
	if not measure then
		return fontSize
	end
	measure.visible = false
	measure.textWidth = width
	measure.alignment = "Left"
	measure.text = text
	local height = measure.height
	measure:cleanup()
	return height
end
local function ActionButton(props)
	return React.createElement(
		MobileButton,
		__TS__ObjectAssign({}, props, {fontSize = 13})
	)
end
function ____exports.startMobileRemix(options)
	local confirmTitle, host, send, getTranscriptActions, render
	local onBack = options.onBack
	local onPlay = options.onPlay
	local packagePanel
	local workspacePanel
	local workspaceState = {drafts = {}, bases = {}, manualTaskId = 0, agentTaskAtEdit = 0}
	local services = options.services or ({
		createSession = AgentSession.createSession,
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end,
		setWorkMode = AgentSession.setWorkMode,
		sendPrompt = AgentSession.sendPrompt,
		respondQuestionnaire = AgentSession.respondQuestionnaire,
		stopSessionTask = AgentSession.stopSessionTask,
		continuePrompt = AgentSession.continuePrompt,
		getActiveLLMConfig = getActiveLLMConfig,
		getLLMConfig = getLLMConfig,
		getLLMConfigSummaries = getLLMConfigSummaries
	})
	local zh = (string.match(App.locale, "^zh")) ~= nil
	options.entry.title = projectDisplayName(options.entry.workDir, options.entry.title)
	local projectRoot = options.entry.workDir or ""
	local pendingProject = options.createProject ~= nil
	local draftWorkMode = "code"
	local created = pendingProject and ({success = false, message = ""}) or services.createSession(projectRoot, options.entry.title)
	local sessionId = created.success and created.session.id or 0
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message})
	local draft = ""
	local ____error = created.success and "" or created.message
	local backNoticeUntil = 0
	local pollElapsed = 0
	local stopRequested = false
	local selectedLLMConfigId = 0
	local questionnaireId = 0
	local questionIndex = 0
	local questionScroll
	local questionScrollKey = ""
	local llmConfigs = services.getLLMConfigSummaries()
	local taskLLMConfigId = 0
	local needsLLMSetup = false
	local questionnaireSelections = {}
	local questionnaireTexts = {}
	local inputRef = reference()
	local disposed = false
	local dismissedComposition = false
	local swipeBackPending = false
	local swipeDragging = false
	local swipeRevision = 0
	local swipeLastMotion = 0
	local projectChangeNotified = false
	local editingTitle = false
	local titleDraft = ""
	local titleError = ""
	local titleInputNode
	local titleInput = createTextInput({
		fontSize = 15,
		fontName = goTheme.headingFont,
		singleLine = true,
		getText = function() return titleDraft end,
		setText = function(value)
			titleDraft = value
		end,
		getPlaceholder = function() return zh and "项目名称" or "Project name" end,
		isEnabled = function() return editingTitle and not disposed and host.visible and not isMobileLLMOpen() and HttpServer.wsConnectionCount == 0 end,
		onReturn = function()
			confirmTitle()
			return true
		end
	})
	local function cancelTitle()
		titleInput.unmount()
		titleInputNode = nil
		editingTitle = false
		titleError = ""
		render()
	end
	confirmTitle = function()
		if not editingTitle or titleInput.isComposing() or isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		local title = (string.match(titleDraft, "^%s*(.-)%s*$")) or ""
		if title == "" then
			titleError = zh and "请输入项目名称" or "Enter a project name"
			render()
			return
		end
		if options.entry.workDir and not saveProjectDisplayName(options.entry.workDir, title) then
			titleError = zh and "保存失败，请重试" or "Could not save. Try again."
			render()
			return
		end
		options.entry.title = title
		local ____opt_0 = options.onProjectChanged
		if ____opt_0 ~= nil then
			____opt_0(options.entry)
		end
		cancelTitle()
	end
	local function currentQuestion()
		local ____detail_success_4
		if detail.success then
			local ____opt_2 = detail.pendingQuestionnaire
			____detail_success_4 = ____opt_2 and ____opt_2.schema.questions[questionIndex + 1]
		else
			____detail_success_4 = nil
		end
		return ____detail_success_4
	end
	local promptInput = createTextInput({
		borderless = true,
		fontSize = math.floor(13 * mobileFontScale),
		getText = function()
			local question = currentQuestion()
			return question and (questionnaireTexts[question.id] or "") or draft
		end,
		setText = function(text)
			local question = currentQuestion()
			if question then
				questionnaireTexts[question.id] = text
			else
				draft = text
			end
		end,
		getPlaceholder = function()
			local question = currentQuestion()
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "描述想法或修改要求…" or "Describe an idea or change…"))
		end,
		isEnabled = function() return not editingTitle and not packagePanel and not workspacePanel and not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end,
		onReturn = function(modified)
			if modified and not currentQuestion() then
				send()
				return true
			end
			return false
		end
	})
	local blurInput = promptInput.blur
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1")
	local ____temp_7
	if rememberedRows and #rememberedRows > 0 then
		____temp_7 = tonumber(rememberedRows[1][1])
	else
		____temp_7 = nil
	end
	local rememberedId = ____temp_7
	if rememberedId and __TS__ArraySome(
		llmConfigs,
		function(____, item) return item.id == rememberedId end
	) then
		selectedLLMConfigId = rememberedId
	elseif #llmConfigs > 0 then
		selectedLLMConfigId = llmConfigs[1].id
	else
		local activeConfig = services.getActiveLLMConfig()
		if activeConfig.success then
			selectedLLMConfigId = activeConfig.id
		else
			needsLLMSetup = true
		end
	end
	host = Node()
	host.tag = "mobile-remix"
	host.scaleX = App.devicePixelRatio
	host.scaleY = App.devicePixelRatio
	host:addTo(Director.systemUI)
	local transcript = createRemixTranscript()
	local displayRevision = ""
	local shellRevision = ""
	local inputLayout = ""
	local compactHeaderStatusActive = false
	local errorLabel
	local layoutTranscriptBottom = transcriptBottom
	local function getLayoutArea()
		return App.safeArea
	end
	local function getTranscriptBottom()
		return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0)
	end
	local function hasTranscriptContent()
		return detail.success and (#detail.messages > 0 or #detail.steps > 0)
	end
	local function getHeaderY(safe)
		return safe.y + safe.height - 64
	end
	local function useCompactHeaderStatus(safe)
		return safe.width >= 760 and safe.height < 500 and hasTranscriptContent()
	end
	local function getTranscriptHeight(safe)
		return math.max(
			40,
			safe.height - 112 - getTranscriptBottom()
		)
	end
	local function getShellRevision()
		local ____detail_success_11
		if detail.success then
			local ____safeJsonEncode_10 = safeJsonEncode
			local ____array_9 = __TS__SparseArrayNew(
				detail.session.status,
				detail.session.workMode,
				detail.hasActivePlan,
				detail.pendingQuestionnaire or false,
				detail.session.currentTaskStatus or ""
			)
			local ____detail_session_currentTaskFinalizing_8 = detail.session.currentTaskFinalizing
			if ____detail_session_currentTaskFinalizing_8 == nil then
				____detail_session_currentTaskFinalizing_8 = false
			end
			__TS__SparseArrayPush(
				____array_9,
				____detail_session_currentTaskFinalizing_8,
				stopRequested,
				hasTranscriptContent(),
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or ""
			)
			____detail_success_11 = (____safeJsonEncode_10({__TS__SparseArraySpread(____array_9)})) or ""
		else
			____detail_success_11 = detail.message
		end
		return ____detail_success_11
	end
	local function updateTranscript()
		local safe = getLayoutArea()
		transcript:update(
			detail,
			math.max(60, safe.width - 44),
			getTranscriptHeight(safe),
			mobileFontScale,
			zh,
			getTranscriptActions()
		)
		displayRevision = remixDisplayRevision(detail)
	end
	local function hasActiveTask()
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil)
	end
	local function hasPreview()
		local entry = options.entry.fileName
		if entry == nil or workspaceState.buildFailed then
			return false
		end
		for ____, ext in ipairs({"ts", "lua"}) do
			local file = (entry .. ".") .. ext
			if Content:exist(file) then
				local ____opt_12 = Content:load(file)
				local content = ____opt_12 and __TS__StringTrim(Content:load(file))
				if content == __TS__StringTrim(mobileTypeScriptProjectTemplate) or content == __TS__StringTrim(mobileLuaProjectTemplate) or content == __TS__StringTrim(mobileTypeScriptProjectLuaTemplate) then
					return false
				end
			end
		end
		return true
	end
	local function notifyProjectChanged()
		if projectChangeNotified or not detail.success or not options.onProjectChanged then
			return
		end
		if not __TS__ArraySome(
			detail.steps,
			function(____, step) return step.files ~= nil and #step.files > 0 end
		) then
			return
		end
		projectChangeNotified = true
		options.onProjectChanged(options.entry)
	end
	local function refresh()
		if sessionId > 0 then
			detail = services.getSession(sessionId)
		end
		if detail.success and not hasActiveTask() then
			stopRequested = false
		end
		if detail.success and detail.session.status == "DONE" and detail.session.currentTaskId ~= workspaceState.agentTaskAtEdit then
			workspaceState.buildFailed = false
		end
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then
			questionnaireId = detail.pendingQuestionnaire.id
			questionIndex = 0
		end
	end
	local function canSubmit()
		return sessionId == 0 or detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire
	end
	local function resolveLLMConfig()
		return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig()
	end
	local function configureLLM()
		titleInput.blur()
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		blurInput()
		startMobileLLMManager({
			coveredNode = host,
			selectedId = selectedLLMConfigId,
			taskRunning = hasActiveTask(),
			runningId = taskLLMConfigId,
			onSelected = function(id)
				if disposed or not host.parent then
					return
				end
				llmConfigs = services.getLLMConfigSummaries()
				selectedLLMConfigId = id
				needsLLMSetup = #llmConfigs == 0
				____error = ""
				render()
			end,
			onClose = function()
				if not disposed and host.parent then
					render()
				end
			end
		})
	end
	local function changeWorkMode(workMode)
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		refresh()
		if sessionId == 0 then
			draftWorkMode = workMode
			render()
			return
		end
		if not canSubmit() or not detail.success then
			return
		end
		if resolveRemixWorkMode(detail.session) == workMode then
			return
		end
		local result = services.setWorkMode(sessionId, workMode)
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode"))
		refresh()
		render()
	end
	send = function()
		if editingTitle then
			return
		end
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		refresh()
		if not canSubmit() or promptInput.isComposing() then
			return
		end
		local workMode = detail.success and resolveRemixWorkMode(detail.session) or draftWorkMode
		local text = (string.match(draft, "^%s*(.-)%s*$")) or ""
		if text == "" then
			return
		end
		local config = resolveLLMConfig()
		if not config.success then
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first"
			render()
			configureLLM()
			return
		end
		if pendingProject then
			local project = options.createProject()
			if not project.success then
				____error = zh and "创建项目失败，请重试" or "Could not create the project. Try again."
				render()
				return
			end
			options.entry.id = project.entry.id
			options.entry.title = project.entry.title
			options.entry.workDir = project.entry.workDir
			options.entry.fileName = project.entry.fileName
			pendingProject = false
			local ____opt_14 = options.onProjectChanged
			if ____opt_14 ~= nil then
				____opt_14(options.entry)
			end
		end
		if sessionId == 0 then
			local session = services.createSession(options.entry.workDir or "", options.entry.title)
			if not session.success then
				____error = session.message
				render()
				return
			end
			sessionId = session.session.id
		end
		selectedLLMConfigId = config.id
		local result = services.sendPrompt(
			sessionId,
			text,
			nil,
			workMode,
			config.id,
			config.config
		)
		if not result.success then
			____error = result.message
		else
			taskLLMConfigId = config.id
			draft = ""
			____error = ""
		end
		refresh()
		render()
	end
	local function continueTask()
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		refresh()
		if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then
			return
		end
		local config = resolveLLMConfig()
		if not config.success then
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first"
			render()
			configureLLM()
			return
		end
		if not services.continuePrompt then
			____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable"
			render()
			return
		end
		selectedLLMConfigId = config.id
		local result = services.continuePrompt(sessionId, nil, config.id)
		____error = result.success and "" or result.message
		if result.success then
			taskLLMConfigId = config.id
			stopRequested = false
		end
		refresh()
		render()
	end
	local function startDevelopment()
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		refresh()
		if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then
			return
		end
		local modeResult = services.setWorkMode(sessionId, "code")
		if not modeResult.success then
			____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode")
			render()
			return
		end
		local config = resolveLLMConfig()
		if not config.success then
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first"
			refresh()
			render()
			configureLLM()
			return
		end
		selectedLLMConfigId = config.id
		local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated."
		local result = services.sendPrompt(
			sessionId,
			prompt,
			nil,
			"code",
			config.id,
			config.config
		)
		____error = result.success and "" or result.message
		if result.success then
			taskLLMConfigId = config.id
		end
		refresh()
		render()
	end
	getTranscriptActions = function()
		if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery(
			detail.messages,
			function(____, message) return message.role ~= "assistant" end
		) then
			return {}
		end
		local actions = {}
		if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then
			actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask}
		end
		if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then
			actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment}
		end
		return actions
	end
	local function stop()
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		refresh()
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then
			return
		end
		local result = services.stopSessionTask(sessionId)
		if (result and result.success) == false then
			____error = result.message or (zh and "停止失败" or "Could not stop")
		else
			stopRequested = true
			____error = ""
		end
		refresh()
		render()
	end
	local function advanceQuestionnaire(skipCurrent)
		if skipCurrent == nil then
			skipCurrent = false
		end
		if isMobileLLMOpen() or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		if not detail.success or not detail.pendingQuestionnaire then
			return
		end
		local pending = detail.pendingQuestionnaire
		local questions = pending.schema.questions
		local question = questions[questionIndex + 1]
		if question == nil then
			return
		end
		local selected = questionnaireSelections[question.id] or ({})
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "")
		if skipCurrent then
			if question.required then
				return
			end
			questionnaireSelections[question.id] = {}
			questionnaireTexts[question.id] = ""
		elseif not isQuestionAnswered(question, selected, text) then
			____error = zh and "请先完成当前必答问题" or "Answer the required question first"
			render()
			return
		end
		if questionIndex + 1 < #questions then
			questionIndex = questionIndex + 1
			____error = ""
			render()
			return
		end
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts)
		if selectedLLMConfigId <= 0 then
			____error = zh and "没有可用的模型配置" or "No model configuration is available"
			render()
			return
		end
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId)
		if not result.success then
			____error = result.message
		else
			taskLLMConfigId = selectedLLMConfigId
			____error = ""
		end
		refresh()
		render()
	end
	local function goBack()
		if isMobileLLMOpen() then
			return
		end
		if editingTitle then
			cancelTitle()
			return
		end
		if packagePanel or workspacePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		if detail.success and not canLeaveRemix(detail.session.status) then
			____error = ""
			backNoticeUntil = App.runningTime + 3
			render()
			return
		end
		blurInput()
		notifyProjectChanged()
		host.visible = false
		host:removeFromParent(true)
		onBack()
	end
	local function openWorkspace(panel)
		if disposed or workspacePanel or packagePanel or not host.visible or HttpServer.wsConnectionCount > 0 then
			return
		end
		blurInput()
		if editingTitle then
			cancelTitle()
		end
		workspacePanel = startWorkspacePanel({
			state = workspaceState,
			panel = panel,
			entry = options.entry,
			getDetail = function() return detail end,
			isBusy = hasActiveTask,
			onModel = function()
				if not disposed and host.parent and host.visible then
					configureLLM()
				end
			end,
			onExport = function()
				if disposed or not host.parent or not host.visible then
					return
				end
				packagePanel = startPackagePanel({
					mode = "share",
					entry = options.entry,
					onClosed = function()
						packagePanel = nil
					end
				})
			end,
			onChanged = function(message)
				if disposed then
					return
				end
				____error = message or ""
				local ____opt_18 = options.onProjectChanged
				if ____opt_18 ~= nil then
					____opt_18(options.entry)
				end
				refresh()
				render()
			end,
			onClose = function()
				workspacePanel = nil
			end
		})
	end
	render = function()
		local oldQuestionOffset = questionScroll and questionScroll.offset.y or 0
		questionScroll = nil
		local visibleError = ____error ~= "" and ____error or (backNoticeUntil > App.runningTime and (zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back") or "")
		errorLabel = nil
		swipeRevision = swipeRevision + 1
		swipeDragging = false
		swipeBackPending = false
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height)
		local ____temp_22
		if editingTitle and layout == inputLayout then
			____temp_22 = titleInputNode
		else
			____temp_22 = nil
		end
		local keptTitleInput = ____temp_22
		local restoreTitleFocus = titleInput.isFocused()
		if keptTitleInput ~= nil then
			keptTitleInput:removeFromParent(false)
		end
		if not keptTitleInput then
			titleInput.unmount()
			titleInputNode = nil
		end
		local ____temp_27 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire)
		if ____temp_27 then
			local ____opt_25 = inputRef.current
			____temp_27 = (____opt_25 and ____opt_25.tag) == "remix-input"
		end
		local keptInput = ____temp_27 and inputRef.current or nil
		if keptInput ~= nil then
			keptInput:removeFromParent(false)
		end
		transcript.node:removeFromParent(false)
		local restoreInputFocus = promptInput.isFocused()
		if not keptInput then
			promptInput.unmount()
			inputRef = reference()
		end
		host:removeAllChildren()
		inputLayout = layout
		host.scaleX = App.devicePixelRatio
		host.scaleY = App.devicePixelRatio
		local ____App_visualSize_30 = App.visualSize
		local width = ____App_visualSize_30.width
		local height = ____App_visualSize_30.height
		local safe = getLayoutArea()
		local left = safe.x
		local bottom = safe.y
		local state = detail.success and detail.session or nil
		local workMode = state and resolveRemixWorkMode(state) or draftWorkMode
		local stopping = hasActiveTask()
		local layoutComposerBottom = 60
		local layoutComposerHeight = 54
		local layoutModeBottom = 122
		local layoutComposerTop = 164
		layoutTranscriptBottom = layoutComposerTop + 12
		local contentWidth = safe.width - 32
		local inputWidth = contentWidth - 24
		local modeStartX = left + 26
		local ____detail_success_31
		if detail.success then
			____detail_success_31 = detail.pendingQuestionnaire
		else
			____detail_success_31 = nil
		end
		local questionnaire = ____detail_success_31
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1]
		local questionPromptWidth = contentWidth - 32
		local questionPromptHeight = question and measureWrappedTextHeight(question.prompt, questionPromptWidth, 16) or 0
		local questionOptions = question and question.type ~= "text" and __TS__ArraySlice(question.options or ({}), 0, 8) or ({})
		local questionAnswerHeight = #questionOptions > 0 and 40 + 43 * (#questionOptions - 1) or 92
		local questionCardHeight = math.max(150, safe.height - 188)
		local questionBodyHeight = 36 + questionPromptHeight + 16 + questionAnswerHeight + 12
		local questionAnswerTop = questionBodyHeight - 36 - questionPromptHeight - 16
		local questionKey = (tostring(questionnaire and questionnaire.id or 0) .. ":") .. tostring(questionIndex)
		local questionOffset = questionKey == questionScrollKey and oldQuestionOffset or 0
		questionScrollKey = questionKey
		local questionHasBack = questionIndex > 0
		local questionCanSkip = question ~= nil and not question.required
		local questionActionGap = 8
		local questionBackWidth = 76
		local questionSkipWidth = 64
		local questionSkipX = 16 + (questionHasBack and questionBackWidth + questionActionGap or 0)
		local questionSubmitX = questionSkipX + (questionCanSkip and questionSkipWidth + questionActionGap or 0)
		local headerY = getHeaderY(safe)
		local compactHeaderStatus = useCompactHeaderStatus(safe)
		compactHeaderStatusActive = compactHeaderStatus
		local modelButtonWidth = math.max(
			90,
			math.min(contentWidth - 70, 180)
		)
		local headerBackX = left + 12
		local headerTitleWidth = math.max(40, safe.width - 184)
		local titleMeasure = Label(goTheme.headingFont, 15, true)
		titleMeasure.text = ellipsizeSingleLine(options.entry.title, headerTitleWidth, 15)
		local headerEditX = left + 52 + math.min(headerTitleWidth, titleMeasure.width) + 2
		titleMeasure:cleanup()
		local selectedConfig = __TS__ArrayFind(
			llmConfigs,
			function(____, item) return item.id == selectedLLMConfigId end
		)
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI")
		local modelNameLimit = 18
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 22, 11)
		local swipeStart = Vec2.zero
		local swipeAxis = "none"
		local pageRef = reference()
		local hitsTranscriptButton
		hitsTranscriptButton = function(node, world)
			if not node.visible then
				return false
			end
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then
				local p = node:convertToNodeSpace(world)
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then
					return true
				end
			end
			local hit = false
			node:eachChild(function(child)
				hit = hitsTranscriptButton(child, world)
				return hit
			end)
			return hit
		end
		local ____toNode_79 = toNode
		local ____React_createElement_78 = React.createElement
		local ____array_77 = __TS__SparseArrayNew(
			"node",
			{
				tag = "remix-scene",
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
					tag = "remix-focus-observer",
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
						if editingTitle or packagePanel or workspacePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then
							return
						end
						local input = inputRef.current
						local point = input and input:convertToNodeSpace(touch.worldLocation)
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height
						dismissedComposition = not inside and promptInput.isComposing()
						if not inside then
							blurInput()
						end
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then
							touch.enabled = true
						end
					end,
					onTapBegan = function(touch)
						swipeStart = touch.location
						swipeAxis = "none"
						swipeDragging = false
						swipeLastMotion = App.runningTime
						local ____opt_40 = pageRef.current
						if ____opt_40 ~= nil then
							____opt_40:stopAllActions()
						end
					end,
					onTapMoved = function(touch)
						swipeLastMotion = App.runningTime
						local delta = touch.location:sub(swipeStart)
						if swipeAxis == "none" and math.max(
							math.abs(delta.x),
							math.abs(delta.y)
						) >= 12 then
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical"
						end
						swipeDragging = swipeAxis == "horizontal"
						if pageRef.current and swipeDragging then
							pageRef.current.x = math.min(0, delta.x) * 0.18
						end
					end,
					onTapEnded = function(touch)
						swipeLastMotion = App.runningTime
						local delta = touch.location:sub(swipeStart)
						swipeDragging = false
						if swipeBackPending then
							return
						end
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play"
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status))
						local page = pageRef.current
						if not page or not requested and page.x == 0 then
							return
						end
						local duration = (leaving or App.reducedMotion) and 0 or 0.16
						local revision = swipeRevision
						swipeBackPending = true
						if not leaving then
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad))
						end
						thread(function()
							sleep(duration)
							if disposed or revision ~= swipeRevision or not host.parent then
								return
							end
							swipeBackPending = false
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then
								refresh()
								goBack()
							else
								page.position = Vec2.zero
							end
						end)
					end
				}
			),
			React.createElement(VerticalGradient, {width = width, height = height, topColor = goTheme.backgroundTop, bottomColor = goTheme.background})
		)
		local ____React_createElement_76 = React.createElement
		local ____array_75 = __TS__SparseArrayNew(
			"node",
			{tag = "remix-page", ref = pageRef},
			React.createElement(
				"node",
				{
					tag = "remix-back",
					x = headerBackX,
					y = headerY,
					width = 32,
					height = 44,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true,
					onMount = pressFeedback,
					onTapped = goBack
				},
				React.createElement(GoIcon, {name = "back", x = 4, y = 12, size = 20})
			)
		)
		local ____temp_42
		if not editingTitle then
			____temp_42 = React.createElement(
				"clip-node",
				{
					x = left + 52,
					y = headerY,
					width = headerTitleWidth,
					height = 44,
					anchorX = 0,
					anchorY = 0,
					stencil = React.createElement(
						"draw-node",
						{x = headerTitleWidth / 2, y = 22},
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295})
					)
				},
				React.createElement(
					"label",
					{
						tag = "remix-title",
						x = 0,
						y = 29,
						anchorX = 0,
						fontName = goTheme.headingFont,
						fontSize = 15,
						text = ellipsizeSingleLine(options.entry.title, headerTitleWidth, 15),
						color3 = 3159339,
						alignment = "Left"
					}
				),
				React.createElement("label", {
					tag = "remix-status-text",
					x = 0,
					y = 10,
					anchorX = 0,
					fontName = fontName,
					fontSize = 10,
					text = questionnaire and (zh and "等待你的回答" or "Waiting for your answer") or (stopping and (zh and "Dora 正在创作…" or "Dora is working…") or (zh and (pendingProject and "新项目" or "已保存到本地") or (pendingProject and "New project" or "Saved locally"))),
					color3 = 8159855,
					alignment = "Left"
				})
			)
		else
			____temp_42 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_42)
		local ____temp_43
		if not editingTitle then
			____temp_43 = React.createElement(
				ActionButton,
				{
					tag = "remix-play",
					x = left + safe.width - 92,
					y = headerY + 8,
					width = 70,
					height = 32,
					text = "GO!",
					primary = true,
					disabled = stopping or not hasPreview(),
					onTapped = function()
						refresh()
						if not host.visible or workspaceState.buildFailed or workspacePanel or hasActiveTask() or HttpServer.wsConnectionCount > 0 or not hasPreview() then
							return
						end
						blurInput()
						notifyProjectChanged()
						host.visible = false
						onPlay(options.entry)
					end
				}
			)
		else
			____temp_43 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_43)
		local ____temp_48
		if not editingTitle then
			____temp_48 = React.createElement(
				"node",
				{
					tag = "remix-title-edit",
					x = headerEditX,
					y = headerY + 11,
					width = 32,
					height = 36,
					anchorX = 0,
					anchorY = 0,
					touchEnabled = true,
					swallowTouches = true,
					onMount = pressFeedback,
					onTapped = function()
						if not host.visible or workspacePanel or packagePanel or isMobileLLMOpen() or HttpServer.wsConnectionCount > 0 then
							return
						end
						blurInput()
						titleDraft = options.entry.title
						titleError = ""
						editingTitle = true
						render()
						titleInput.deferFocus()
					end
				},
				React.createElement(GoIcon, {name = "edit", x = 8, y = 10, size = 16})
			)
		else
			local ____React_createElement_47 = React.createElement
			local ____temp_44
			if not keptTitleInput then
				____temp_44 = React.createElement(
					"node",
					{
						tag = "remix-title-input",
						x = left + 52,
						y = headerY + 7,
						width = safe.width - 152,
						height = 36,
						anchorX = 0,
						anchorY = 0,
						onMount = function(node)
							titleInputNode = node
							titleInput.mount(node)
						end
					}
				)
			else
				____temp_44 = nil
			end
			local ____TS__ArrayMap_result_46 = __TS__ArrayMap(
				{false, true},
				function(____, confirm) return React.createElement(
					"node",
					{
						tag = confirm and "remix-title-confirm" or "remix-title-cancel",
						x = left + safe.width - (confirm and 50 or 90),
						y = headerY + 7,
						width = 36,
						height = 36,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onMount = pressFeedback,
						onTapped = confirm and confirmTitle or cancelTitle
					},
					React.createElement(RoundedSurface, {width = 36, height = 36, radius = 10, fillColor = confirm and 4294958960 or 4293848805}),
					React.createElement(GoIcon, {name = confirm and "check" or "close", x = 9, y = 9, size = 18})
				) end
			)
			local ____temp_45
			if titleError ~= "" then
				____temp_45 = React.createElement("label", {
					x = left + 52,
					y = headerY,
					anchorX = 0,
					fontName = fontName,
					fontSize = 10,
					text = titleError,
					color3 = 10053197
				})
			else
				____temp_45 = nil
			end
			____temp_48 = ____React_createElement_47(
				"node",
				nil,
				____temp_44,
				____TS__ArrayMap_result_46,
				____temp_45
			)
		end
		__TS__SparseArrayPush(
			____array_75,
			____temp_48,
			React.createElement(RoundedSurface, {
				x = left + 22,
				y = headerY - 36,
				width = safe.width - 44,
				height = 0.6,
				radius = 0,
				fillColor = 407919929
			}),
			React.createElement(
				"node",
				{y = headerY - 34},
				__TS__ArrayMap(
					{"files", "changes", "logs"},
					function(____, name, i) return React.createElement(
						"node",
						{
							tag = "remix-tool-" .. name,
							x = left + 22 + i * 68,
							width = 62,
							height = 30,
							anchorX = 0,
							anchorY = 0,
							touchEnabled = true,
							swallowTouches = true,
							onMount = pressFeedback,
							onTapped = function() return openWorkspace(name) end
						},
						React.createElement(GoIcon, {name = name, x = 4, y = 7.5, size = 15}),
						React.createElement("label", {
							x = 24,
							y = 15,
							anchorX = 0,
							fontName = fontName,
							fontSize = 11,
							text = zh and ({"文件", "修改", "日志"})[i + 1] or ({"Files", "Changes", "Logs"})[i + 1],
							color3 = 8159855,
							alignment = "Left"
						})
					) end
				)
			)
		)
		local ____temp_49
		if not hasTranscriptContent() and not questionnaire then
			____temp_49 = React.createElement(
				"node",
				{tag = "remix-welcome", x = left + safe.width / 2, y = bottom + layoutTranscriptBottom + (safe.height - 112 - layoutTranscriptBottom) / 2},
				React.createElement(
					"clip-node",
					{
						x = -29,
						y = 7,
						width = 58,
						height = 58,
						anchorX = 0,
						anchorY = 0,
						stencil = React.createElement(RoundedStencil, {width = 58, height = 58, radius = 14})
					},
					React.createElement("sprite", {
						file = "Image/GoUI/mascot.png",
						x = 29,
						y = 29,
						scaleX = 58 / 128,
						scaleY = 58 / 128
					})
				),
				React.createElement("label", {
					x = 0,
					y = -12,
					fontName = fontName,
					fontSize = 21,
					text = zh and "从一个想法开始" or "Start with an idea",
					color3 = 4278069
				}),
				React.createElement("label", {
					x = 0,
					y = -47,
					fontName = fontName,
					fontSize = 13,
					text = zh and "你想做一款什么样的游戏？" or "What would you like to create?",
					color3 = 9147006
				})
			)
		else
			____temp_49 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_49)
		local ____temp_58
		if questionnaire and question then
			local ____React_createElement_57 = React.createElement
			local ____array_56 = __TS__SparseArrayNew(
				"node",
				{
					tag = "remix-questionnaire",
					x = left + 16,
					y = bottom + 72,
					width = contentWidth,
					height = questionCardHeight,
					anchorX = 0,
					anchorY = 0
				},
				React.createElement(RoundedSurface, {
					width = contentWidth,
					height = questionCardHeight,
					radius = 20,
					topColor = 4294638581,
					bottomColor = 4294638581,
					borderWidth = 1,
					borderColor = 4292007621,
					shadow = true
				}),
				React.createElement(
					"custom-node",
					{onCreate = function()
						local viewportHeight = questionCardHeight - 72
						local scroll = ScrollArea({
							width = contentWidth - 32,
							height = viewportHeight,
							paddingX = 0,
							paddingY = 0,
							scrollBar = false
						})
						scroll.position = Vec2(contentWidth / 2, 60 + viewportHeight / 2)
						local body = toNode(React.createElement(
							"node",
							{
								width = contentWidth - 32,
								height = questionBodyHeight,
								x = 0,
								y = viewportHeight,
								anchorX = 0,
								anchorY = 1
							},
							React.createElement(
								"label",
								{
									x = 0,
									y = questionBodyHeight - 8,
									anchorX = 0,
									anchorY = 1,
									fontName = fontName,
									fontSize = 12,
									text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title,
									textWidth = contentWidth - 32,
									alignment = "Left",
									color3 = 9072679
								}
							),
							React.createElement("label", {
								tag = "remix-question-prompt",
								x = 0,
								y = questionBodyHeight - 36,
								anchorX = 0,
								anchorY = 1,
								fontName = fontName,
								fontSize = 16,
								text = question.prompt,
								textWidth = questionPromptWidth,
								alignment = "Left",
								color3 = 3159339
							}),
							question.type ~= "text" and __TS__ArrayMap(
								questionOptions,
								function(____, option, optionIndex) return React.createElement(
									ChoiceButton,
									{
										tag = (("remix-question-" .. question.id) .. "-option-") .. option.id,
										x = 0,
										y = questionAnswerTop - 40 - optionIndex * 43,
										width = contentWidth - 32,
										text = option.label .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""),
										selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0,
										onTapped = function()
											local selected = questionnaireSelections[question.id] or ({})
											local ____question_id_53 = question.id
											local ____temp_52
											if question.type == "single_choice" then
												____temp_52 = {option.id}
											else
												local ____temp_51
												if __TS__ArrayIndexOf(selected, option.id) >= 0 then
													____temp_51 = __TS__ArrayFilter(
														selected,
														function(____, id) return id ~= option.id end
													)
												else
													local ____array_50 = __TS__SparseArrayNew(table.unpack(selected))
													__TS__SparseArrayPush(____array_50, option.id)
													____temp_51 = {__TS__SparseArraySpread(____array_50)}
												end
												____temp_52 = ____temp_51
											end
											questionnaireSelections[____question_id_53] = ____temp_52
											render()
										end
									}
								) end
							) or React.createElement("node", {
								tag = "remix-question-input",
								ref = inputRef,
								x = 0,
								y = questionAnswerTop - 92,
								width = contentWidth - 32,
								height = 92,
								anchorX = 0,
								anchorY = 0,
								onMount = promptInput.mount
							})
						))
						if body then
							scroll.view:addChild(body)
						end
						scroll:resetSize(contentWidth - 32, viewportHeight, contentWidth - 32, questionBodyHeight)
						scroll.offset = Vec2(
							0,
							math.max(
								0,
								math.min(questionOffset, questionBodyHeight - viewportHeight)
							)
						)
						scroll.view:moveAndCullItems(Vec2.zero)
						questionScroll = scroll
						return scroll
					end}
				)
			)
			local ____questionHasBack_54
			if questionHasBack then
				____questionHasBack_54 = React.createElement(
					ActionButton,
					{
						tag = "remix-question-back",
						x = 16,
						y = 12,
						width = questionBackWidth,
						text = zh and "上一步" or "Back",
						onTapped = function()
							questionIndex = questionIndex - 1
							render()
						end
					}
				)
			else
				____questionHasBack_54 = nil
			end
			__TS__SparseArrayPush(____array_56, ____questionHasBack_54)
			local ____questionCanSkip_55
			if questionCanSkip then
				____questionCanSkip_55 = React.createElement(
					ActionButton,
					{
						tag = "remix-question-skip",
						x = questionSkipX,
						y = 12,
						width = questionSkipWidth,
						text = zh and "跳过" or "Skip",
						onTapped = function() return advanceQuestionnaire(true) end
					}
				)
			else
				____questionCanSkip_55 = nil
			end
			__TS__SparseArrayPush(
				____array_56,
				____questionCanSkip_55,
				React.createElement(
					ActionButton,
					{
						tag = "remix-question-submit",
						x = questionSubmitX,
						y = 12,
						width = contentWidth - questionSubmitX - 16,
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"),
						primary = true,
						onTapped = function()
							if not dismissedComposition then
								advanceQuestionnaire()
							end
							dismissedComposition = false
						end
					}
				)
			)
			____temp_58 = ____React_createElement_57(__TS__SparseArraySpread(____array_56))
		else
			____temp_58 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_58)
		local ____temp_59
		if visibleError ~= "" then
			____temp_59 = React.createElement(
				"label",
				{
					tag = "remix-error",
					x = left + 20,
					y = bottom + (questionnaire and 58 or layoutComposerTop + composerGap),
					anchorX = 0,
					anchorY = 0,
					fontName = fontName,
					fontSize = 13,
					text = visibleError,
					textWidth = contentWidth,
					alignment = "Left",
					color3 = 16739179,
					onMount = function(label)
						errorLabel = label
					end
				}
			)
		else
			____temp_59 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_59)
		local ____temp_63
		if questionnaire == nil then
			local ____React_createElement_62 = React.createElement
			local ____array_61 = __TS__SparseArrayNew(
				"node",
				nil,
				React.createElement(RoundedSurface, {
					x = left + 16,
					y = bottom + 16,
					width = contentWidth,
					height = 148,
					radius = 18,
					fillColor = goTheme.panel,
					borderWidth = 1,
					borderColor = goTheme.border
				}),
				React.createElement(RoundedSurface, {
					x = modeStartX - 2,
					y = bottom + layoutModeBottom,
					width = 110,
					height = 30,
					radius = 7,
					fillColor = 4293717989
				}),
				React.createElement(
					MobileButton,
					{
						tag = "remix-mode-code",
						x = modeStartX,
						y = bottom + layoutModeBottom + 2,
						width = 52,
						height = 26,
						fontSize = 11,
						text = zh and "执行" or "Code",
						segmented = true,
						selected = workMode == "code",
						disabled = not canSubmit(),
						onTapped = function() return changeWorkMode("code") end
					}
				),
				React.createElement(
					MobileButton,
					{
						tag = "remix-mode-plan",
						x = modeStartX + 54,
						y = bottom + layoutModeBottom + 2,
						width = 52,
						height = 26,
						fontSize = 11,
						text = zh and "计划" or "Plan",
						segmented = true,
						selected = workMode == "plan",
						disabled = not canSubmit(),
						onTapped = function() return changeWorkMode("plan") end
					}
				)
			)
			local ____temp_60
			if not keptInput then
				____temp_60 = React.createElement("node", {
					tag = "remix-input",
					ref = inputRef,
					x = left + 28,
					y = bottom + layoutComposerBottom,
					width = inputWidth,
					height = layoutComposerHeight,
					anchorX = 0,
					anchorY = 0,
					onMount = promptInput.mount
				})
			else
				____temp_60 = nil
			end
			__TS__SparseArrayPush(
				____array_61,
				____temp_60,
				React.createElement(
					"node",
					{
						tag = "remix-model-config",
						x = left + 28,
						y = bottom + 23,
						width = modelButtonWidth,
						height = 30,
						anchorX = 0,
						anchorY = 0,
						touchEnabled = true,
						swallowTouches = true,
						onMount = pressFeedback,
						onTapped = configureLLM
					},
					React.createElement(GoIcon, {
						name = "dropdown",
						x = modelButtonWidth - 14,
						y = 8,
						size = 14,
						color = 4286349935
					}),
					React.createElement("label", {
						x = 0,
						y = 15,
						anchorX = 0,
						fontName = fontName,
						fontSize = 11,
						text = modelLabel,
						color3 = 8159855,
						alignment = "Left"
					})
				)
			)
			____temp_63 = ____React_createElement_62(__TS__SparseArraySpread(____array_61))
		else
			____temp_63 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_63)
		local ____temp_74
		if stopping or questionnaire == nil then
			local ____React_createElement_73 = React.createElement
			local ____ActionButton_72 = ActionButton
			local ____temp_67 = stopping and "remix-stop" or "remix-send"
			local ____temp_68 = left + safe.width - 60
			local ____temp_69 = bottom + 24
			local ____temp_70 = stopping and "stop" or "up"
			local ____temp_71 = not stopping
			local ____stopping_66
			if stopping then
				____stopping_66 = stopRequested or (state and state.currentTaskFinalizing) == true
			else
				____stopping_66 = not canSubmit()
			end
			____temp_74 = ____React_createElement_73(
				____ActionButton_72,
				{
					tag = ____temp_67,
					x = ____temp_68,
					y = ____temp_69,
					width = 32,
					height = 32,
					text = "",
					icon = ____temp_70,
					primary = ____temp_71,
					danger = stopping,
					disabled = ____stopping_66,
					onTapped = function()
						if stopping then
							stop()
						elseif not dismissedComposition then
							send()
						end
						dismissedComposition = false
					end
				}
			)
		else
			____temp_74 = nil
		end
		__TS__SparseArrayPush(____array_75, ____temp_74)
		__TS__SparseArrayPush(
			____array_77,
			____React_createElement_76(__TS__SparseArraySpread(____array_75))
		)
		local scene = ____toNode_79(____React_createElement_78(__TS__SparseArraySpread(____array_77)))
		if scene then
			host:addChild(scene)
			if keptInput then
				keptInput.position = Vec2(left + 28, bottom + layoutComposerBottom)
				keptInput.width = inputWidth
				keptInput.height = layoutComposerHeight
				local ____opt_80 = pageRef.current
				if ____opt_80 ~= nil then
					____opt_80:addChild(keptInput)
				end
			end
			if not questionnaire then
				transcript.node.position = Vec2(
					left + 22,
					bottom + getTranscriptBottom()
				)
				local ____opt_82 = pageRef.current
				if ____opt_82 ~= nil then
					____opt_82:addChild(transcript.node)
				end
				updateTranscript()
			end
		end
		if restoreInputFocus and inputRef.current and not keptInput then
			promptInput.focus(false)
		end
		if keptInput then
			promptInput.refresh()
		end
		if keptTitleInput then
			local ____opt_84 = pageRef.current
			if ____opt_84 ~= nil then
				____opt_84:addChild(keptTitleInput)
			end
		elseif editingTitle and restoreTitleFocus then
			titleInput.focus(false)
		end
		shellRevision = getShellRevision()
		displayRevision = remixDisplayRevision(detail)
	end
	attachGamepad(
		host,
		{
			initialTag = "remix-input",
			isEnabled = function() return not workspacePanel and not packagePanel and not disposed end,
			onBack = function()
				if editingTitle then
					cancelTitle()
				elseif promptInput.isFocused() then
					blurInput()
				else
					goBack()
				end
			end,
			onScroll = function(amount) return transcript:scrollBy(amount) end,
			onActivate = function(target)
				if target.tag == "remix-title-input" or target.tag == "remix-input" or target.tag == "remix-question-input" then
					target:emit("GamepadActivate")
				else
					if promptInput.isComposing() then
						blurInput()
						return
					end
					blurInput()
					dismissedComposition = false
					target:emit("Tapped")
				end
			end
		}
	)
	host:schedule(function(dt)
		if (swipeDragging or swipeBackPending) and App.runningTime - swipeLastMotion > 0.5 then
			swipeDragging = false
			swipeBackPending = false
			swipeRevision = swipeRevision + 1
			local ____opt_86 = host:getChildByTag("remix-scene")
			local page = ____opt_86 and ____opt_86:getChildByTag("remix-page")
			if page ~= nil then
				page:perform(Move(App.reducedMotion and 0 or 0.12, page.position, Vec2.zero, Ease.OutQuad))
			end
		end
		pollElapsed = pollElapsed + dt
		if pollElapsed < 0.25 then
			return false
		end
		if swipeDragging or swipeBackPending or transcript:isInteracting() then
			return false
		end
		pollElapsed = 0
		refresh()
		if backNoticeUntil > 0 and App.runningTime >= backNoticeUntil then
			backNoticeUntil = 0
			render()
			return false
		end
		local next = remixDisplayRevision(detail)
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then
			render()
		elseif displayRevision ~= next then
			updateTranscript()
		end
		return false
	end)
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
			if workspacePanel then
				workspacePanel:emit("CloseWorkspace")
				return
			end
			if promptInput.isFocused() then
				blurInput()
			else
				goBack()
			end
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then
			blurInput()
			titleInput.blur()
		end
	end)
	host:onCleanup(function()
		titleInput.unmount()
		if workspacePanel ~= nil then
			workspacePanel:removeFromParent(true)
		end
		workspacePanel = nil
		if packagePanel ~= nil then
			packagePanel:removeFromParent(true)
		end
		packagePanel = nil
		disposed = true
		blurInput()
	end)
	host:slot(
		"SuspendLocalUI",
		function()
			titleInput.blur()
			blurInput()
			if workspacePanel then
				workspacePanel:emit("SuspendLocalUI")
				workspacePanel.visible = false
			end
			if packagePanel then
				packagePanel.visible = false
			end
		end
	)
	host:slot(
		"ResumePreview",
		function(message)
			____error = message and (zh and "试玩失败，请修改后重试。" or "Preview failed. Update the game and try again.") or ""
			refresh()
			render()
		end
	)
	host:slot(
		"ResumeLocalUI",
		function()
			if workspacePanel then
				workspacePanel.visible = host.visible
			end
			if packagePanel then
				packagePanel.visible = host.visible
			end
			refresh()
			render()
		end
	)
	render()
	if needsLLMSetup then
		thread(function()
			sleep(0)
			if not disposed and host.parent then
				configureLLM()
			end
		end)
	end
	return host
end
return ____exports
