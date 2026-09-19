import { mobileLuaProjectTemplate, mobileTypeScriptProjectTemplate, mobileTypeScriptProjectLuaTemplate } from "Dev/Mobile/ProjectCreate";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import { projectDisplayName, saveProjectDisplayName } from "Dev/Mobile/ProjectPresentation";
import { startWorkspacePanel, type WorkspaceState } from "Dev/Mobile/WorkspacePanel";
import { goTheme } from "Dev/Mobile/Theme";
import { MobileButton } from "Dev/Mobile/Controls";
import { pressFeedback } from "Dev/Mobile/Motion";
import { GoIcon } from "Dev/Mobile/Visual";
import { React, reference, toNode } from "DoraX";
import { attachGamepad } from "Dev/Mobile/Gamepad";
import { App, Content, DB, Director, Ease, HttpServer, Label, Move, Node, sleep, TextAlign, thread, Vec2 } from "Dora";
import * as AgentSession from "Agent/Session";
import { getActiveLLMConfig, getLLMConfig, getLLMConfigSummaries, safeJsonEncode } from "Agent/Utils";
import type { LLMConfig, LLMConfigSummary } from "Agent/Utils";
import type { AgentQuestionnaireAnswers } from "Agent/Questionnaire";
import {
	buildQuestionnaireAnswers,
	canLeaveRemix,
	isQuestionAnswered,
	resolveRemixThinkingStatus,
	resolveRemixWorkMode,
} from "Dev/Mobile/RemixModel";
const mobileFontScale = goTheme.fontScale;
import { resolveFeedGesture } from "Dev/Mobile/FeedModel";
import { createRemixTranscript, remixDisplayRevision, type RemixTranscriptAction } from "Dev/Mobile/RemixTranscript";
import { REMIX_HISTORY_ROUNDS } from "Dev/Mobile/RemixHistory";
import { createTextInput, inputLength, inputSlice } from "Dev/Mobile/TextInput";
import { startMobileLLMManager, isMobileLLMOpen } from "Dev/Mobile/LLMSetup";
import { startPackagePanel } from "Dev/Mobile/PackagePanel";
import { RoundedStencil, SceneSurface as RoundedSurface, VerticalGradient } from "Dev/Mobile/Visual";
import { MobileChoiceButton as ChoiceButton } from "Dev/Mobile/Controls";

interface RemixEntry {
	id: string;
	title: string;
	workDir?: string;
	fileName?: string;
}

type MobileLLMConfigResult = { success: true; id: number; config: LLMConfig } | { success: false; message: string };

export interface MobileRemixServices {
	createSession(
		this: void,
		projectRoot: string,
		title: string,
	): { success: true; session: AgentSession.AgentSessionItem } | { success: false; message: string };
	getSession(this: void, sessionId: number): AgentSession.AgentSessionDetailResult;
	setWorkMode(this: void, sessionId: number, workMode: "plan" | "code"): { success: boolean; message?: string };
	sendPrompt(
		this: void,
		sessionId: number,
		prompt: string,
		disabledAgentTools: undefined,
		workMode: "plan" | "code",
		llmConfigId: number,
		llmConfig: LLMConfig,
	): AgentSession.AgentSessionSendResult;
	respondQuestionnaire(
		this: void,
		sessionId: number,
		questionnaireId: number,
		answers: AgentQuestionnaireAnswers,
		llmConfigId: number,
	): AgentSession.AgentSessionSendResult;
	stopSessionTask(this: void, sessionId: number): unknown;
	continuePrompt?(this: void, sessionId: number, disabledAgentTools?: unknown, llmConfigId?: number): AgentSession.AgentSessionSendResult;
	getActiveLLMConfig(this: void): MobileLLMConfigResult;
	getLLMConfig(this: void, configId: number): MobileLLMConfigResult;
	getLLMConfigSummaries(this: void): LLMConfigSummary[];
}

export interface RemixOptions {
	entry: RemixEntry;
	createProject?: (this: void) => { success: true; entry: RemixEntry } | { success: false; error: string };
	onBack: (this: void) => void;
	onPlay: (this: void, entry: RemixEntry) => void;
	onProjectChanged?: (this: void, entry: RemixEntry) => void;
	services?: MobileRemixServices;
}

const fontName = goTheme.font;

// One layout rhythm for both composer rows, in logical (not framebuffer) pixels.
const composerGap = 12;
const composerBottom = 76;
const composerHeight = 60;

const modeBottom = composerBottom + composerHeight + composerGap;
const composerTop = modeBottom + 40;
const transcriptBottom = composerTop + composerGap;

const ellipsizeSingleLine = (text: string, width: number, fontSize: number) => {
	if (text === "") return "";
	const measure = Label(fontName, fontSize, true);
	if (!measure) return text;
	measure.visible = false;
	measure.textWidth = -1;
	const fits = (value: string) => {
		measure.text = value;
		return measure.width <= width;
	};
	if (fits(text)) {
		measure.cleanup();
		return text;
	}
	let low = 0,
		high = inputLength(text);
	while (low < high) {
		const middle = math.floor((low + high + 1) / 2);
		if (fits(`${inputSlice(text, 0, middle)}…`)) low = middle;
		else high = middle - 1;
	}
	const result = `${inputSlice(text, 0, low)}…`;
	measure.cleanup();
	return result;
};

const measureWrappedTextHeight = (text: string, width: number, fontSize: number) => {
	const measure = Label(fontName, fontSize, true);
	if (!measure) return fontSize;
	measure.visible = false;
	measure.textWidth = width;
	measure.alignment = TextAlign.Left;
	measure.text = text;
	const height = measure.height;
	measure.cleanup();
	return height;
};

function ActionButton(props: {
	x: number;
	y: number;
	width: number;
	height?: number;
	text: string;
	tag?: string;
	icon?: "up" | "stop";
	primary?: boolean;
	danger?: boolean;
	disabled?: boolean;
	onTapped(): void;
}) {
	return <MobileButton {...props} fontSize={13} />;
}

export function startMobileRemix(options: RemixOptions) {
	const onBack = options.onBack;
	const onPlay = options.onPlay;
	let packagePanel: Node.Type | undefined;
	let workspacePanel: Node.Type | undefined;
	const workspaceState: WorkspaceState = { drafts: {}, bases: {}, manualTaskId: 0, agentTaskAtEdit: 0 };
	const services: MobileRemixServices = options.services ?? {
		createSession: AgentSession.createSession,
		getSession: (id) => AgentSession.getSession(id, { recentRounds: REMIX_HISTORY_ROUNDS, currentTaskStepsOnly: true }),
		setWorkMode: AgentSession.setWorkMode,
		sendPrompt: AgentSession.sendPrompt,
		respondQuestionnaire: AgentSession.respondQuestionnaire,
		stopSessionTask: AgentSession.stopSessionTask,
		continuePrompt: AgentSession.continuePrompt,
		getActiveLLMConfig,
		getLLMConfig,
		getLLMConfigSummaries,
	};
	let zh = string.match(App.locale, "^zh")[0] !== undefined;
	options.entry.title = projectDisplayName(options.entry.workDir, options.entry.title);
	const projectRoot = options.entry.workDir ?? "";
	let pendingProject = options.createProject !== undefined;
	let draftWorkMode: "plan" | "code" = "code";
	const created = pendingProject ? { success: false as const, message: "" } : services.createSession(projectRoot, options.entry.title);
	let sessionId = created.success ? created.session.id : 0;
	let detail: AgentSession.AgentSessionDetailResult =
		sessionId > 0 ? services.getSession(sessionId) : { success: false, message: created.success ? "session unavailable" : created.message };
	let draft = "";
	let error = created.success ? "" : created.message;
	let backNoticeUntil = 0;
	let pollElapsed = 0;
	let stopRequested = false;
	let selectedLLMConfigId = 0;
	let questionnaireId = 0;
	let questionIndex = 0;
	let questionScroll: (ReturnType<typeof ScrollArea> & { offset: Vec2.Type }) | undefined;
	let questionScrollKey = "";
	let llmConfigs = services.getLLMConfigSummaries();
	let taskLLMConfigId = 0;
	let needsLLMSetup = false;
	const questionnaireSelections: Record<string, string[]> = {};
	const questionnaireTexts: Record<string, string> = {};
	let inputRef = reference<Node.Type>();
	let disposed = false;
	let dismissedComposition = false;
	let swipeBackPending = false;
	let swipeDragging = false;
	let swipeRevision = 0;
	let swipeLastMotion = 0;
	let projectChangeNotified = false;
	let editingTitle = false;
	let titleDraft = "";
	let titleError = "";
	let titleInputNode: Node.Type | undefined;
	const titleInput = createTextInput({
		fontSize: 15,
		fontName: goTheme.headingFont,
		singleLine: true,
		getText: () => titleDraft,
		setText: (value) => {
			titleDraft = value;
		},
		getPlaceholder: () => (zh ? "项目名称" : "Project name"),
		isEnabled: () => editingTitle && !disposed && host.visible && !isMobileLLMOpen() && HttpServer.wsConnectionCount === 0,
		onReturn: () => {
			confirmTitle();
			return true;
		},
	});
	const cancelTitle = () => {
		titleInput.unmount();
		titleInputNode = undefined;
		editingTitle = false;
		titleError = "";
		render();
	};
	const confirmTitle = () => {
		if (!editingTitle || titleInput.isComposing() || isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		const title = string.match(titleDraft, "^%s*(.-)%s*$")[0] ?? "";
		if (title === "") {
			titleError = zh ? "请输入项目名称" : "Enter a project name";
			render();
			return;
		}
		if (options.entry.workDir && !saveProjectDisplayName(options.entry.workDir, title)) {
			titleError = zh ? "保存失败，请重试" : "Could not save. Try again.";
			render();
			return;
		}
		options.entry.title = title;
		options.onProjectChanged?.(options.entry);
		cancelTitle();
	};
	const currentQuestion = () => (detail.success ? detail.pendingQuestionnaire?.schema.questions[questionIndex] : undefined);
	const promptInput = createTextInput({
		borderless: true,
		fontSize: math.floor(13 * mobileFontScale),
		getText: () => {
			const question = currentQuestion();
			return question ? (questionnaireTexts[question.id] ?? "") : draft;
		},
		setText: (text) => {
			const question = currentQuestion();
			if (question) questionnaireTexts[question.id] = text;
			else draft = text;
		},
		getPlaceholder: () => {
			const question = currentQuestion();
			return (
				question?.placeholder ??
				(question ? (zh ? "输入回答…" : "Type an answer…") : zh ? "描述想法或修改要求…" : "Describe an idea or change…")
			);
		},
		isEnabled: () =>
			!editingTitle &&
			!packagePanel &&
			!workspacePanel &&
			!disposed &&
			host.parent !== undefined &&
			host.visible &&
			HttpServer.wsConnectionCount === 0,
		onReturn: (modified) => {
			if (modified && !currentQuestion()) {
				send();
				return true;
			}
			return false;
		},
	});
	const blurInput = promptInput.blur;
	const rememberedRows = DB.query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") as unknown[][] | undefined;
	const rememberedId = rememberedRows && rememberedRows.length > 0 ? tonumber(rememberedRows[0][0]) : undefined;
	if (rememberedId && llmConfigs.some((item) => item.id === rememberedId)) selectedLLMConfigId = rememberedId;
	else if (llmConfigs.length > 0) selectedLLMConfigId = llmConfigs[0].id;
	else {
		const activeConfig = services.getActiveLLMConfig();
		if (activeConfig.success) selectedLLMConfigId = activeConfig.id;
		else needsLLMSetup = true;
	}

	const host = Node();
	host.tag = "mobile-remix";
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	const transcript = createRemixTranscript();
	let displayRevision = "";
	let shellRevision = "";
	let inputLayout = "";

	let compactHeaderStatusActive = false;
	let errorLabel: Label.Type | undefined;
	let layoutTranscriptBottom = transcriptBottom;
	const getLayoutArea = () => App.safeArea;
	const getTranscriptBottom = () => layoutTranscriptBottom + (errorLabel ? errorLabel.height + composerGap : 0);
	const hasTranscriptContent = () => detail.success && (detail.messages.length > 0 || detail.steps.length > 0);
	const getHeaderY = (safe: { x: number; y: number; width: number; height: number }) => {
		return safe.y + safe.height - 64;
	};
	const useCompactHeaderStatus = (safe: { width: number; height: number }) =>
		safe.width >= 760 && safe.height < 500 && hasTranscriptContent();

	const getTranscriptHeight = (safe: { x: number; y: number; width: number; height: number }) =>
		math.max(40, safe.height - 112 - getTranscriptBottom());
	const getShellRevision = () =>
		detail.success
			? (safeJsonEncode([
					detail.session.status,
					detail.session.workMode,
					detail.hasActivePlan,
					detail.pendingQuestionnaire ?? false,
					detail.session.currentTaskStatus ?? "",
					detail.session.currentTaskFinalizing ?? false,
					stopRequested,
					hasTranscriptContent(),
					resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) ?? "",
				])[0] ?? "")
			: detail.message;
	const updateTranscript = () => {
		const safe = getLayoutArea();
		transcript.update(detail, math.max(60, safe.width - 44), getTranscriptHeight(safe), mobileFontScale, zh, getTranscriptActions());
		displayRevision = remixDisplayRevision(detail);
	};

	const hasActiveTask = () =>
		detail.success &&
		(detail.session.status === "RUNNING" ||
			detail.session.status === "WAITING_USER" ||
			detail.session.currentTaskStatus === "RUNNING" ||
			detail.session.currentTaskStatus === "WAITING_USER" ||
			detail.session.currentTaskFinalizing === true ||
			detail.pendingQuestionnaire !== undefined);
	const hasPreview = () => {
		const entry = options.entry.fileName;
		if (entry === undefined || workspaceState.buildFailed) return false;
		for (const ext of ["ts", "lua"]) {
			const file = entry + "." + ext;
			if (Content.exist(file)) {
				const content = Content.load(file)?.trim();
				if (
					content === mobileTypeScriptProjectTemplate.trim() ||
					content === mobileLuaProjectTemplate.trim() ||
					content === mobileTypeScriptProjectLuaTemplate.trim()
				)
					return false;
			}
		}
		return true;
	};
	const notifyProjectChanged = () => {
		if (projectChangeNotified || !detail.success || !options.onProjectChanged) return;
		if (!detail.steps.some((step) => step.files !== undefined && step.files.length > 0)) return;
		projectChangeNotified = true;
		options.onProjectChanged(options.entry);
	};
	const refresh = () => {
		if (sessionId > 0) detail = services.getSession(sessionId);
		if (detail.success && !hasActiveTask()) stopRequested = false;
		if (detail.success && detail.session.status === "DONE" && detail.session.currentTaskId !== workspaceState.agentTaskAtEdit)
			workspaceState.buildFailed = false;
		if (detail.success && detail.pendingQuestionnaire && detail.pendingQuestionnaire.id !== questionnaireId) {
			questionnaireId = detail.pendingQuestionnaire.id;
			questionIndex = 0;
		}
	};
	const canSubmit = () =>
		sessionId === 0 ||
		(detail.success &&
			canLeaveRemix(detail.session.status) &&
			detail.session.currentTaskStatus !== "RUNNING" &&
			detail.session.currentTaskStatus !== "WAITING_USER" &&
			!detail.session.currentTaskFinalizing &&
			!detail.pendingQuestionnaire);
	const resolveLLMConfig = () => (selectedLLMConfigId > 0 ? services.getLLMConfig(selectedLLMConfigId) : services.getActiveLLMConfig());
	const configureLLM = () => {
		titleInput.blur();
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		blurInput();
		startMobileLLMManager({
			coveredNode: host,
			selectedId: selectedLLMConfigId,
			taskRunning: hasActiveTask(),
			runningId: taskLLMConfigId,
			onSelected: (id) => {
				if (disposed || !host.parent) return;
				llmConfigs = services.getLLMConfigSummaries();
				selectedLLMConfigId = id;
				needsLLMSetup = llmConfigs.length === 0;
				error = "";
				render();
			},
			onClose: () => {
				if (!disposed && host.parent) render();
			},
		});
	};
	const changeWorkMode = (workMode: "plan" | "code") => {
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (sessionId === 0) {
			draftWorkMode = workMode;
			render();
			return;
		}
		if (!canSubmit() || !detail.success) return;
		if (resolveRemixWorkMode(detail.session) === workMode) return;
		const result = services.setWorkMode(sessionId, workMode);
		error = result.success ? "" : (result.message ?? (zh ? "切换模式失败" : "Could not change mode"));
		refresh();
		render();
	};
	const send = () => {
		if (editingTitle) return;
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (!canSubmit() || promptInput.isComposing()) return;
		const workMode = detail.success ? resolveRemixWorkMode(detail.session) : draftWorkMode;
		// Lua's generated JS trim includes multibyte whitespace in a byte character
		// class and can strip trailing Chinese bytes. Trim ASCII whitespace only.
		const text = string.match(draft, "^%s*(.-)%s*$")[0] ?? "";
		if (text === "") return;
		const config = resolveLLMConfig();
		if (!config.success) {
			error = zh ? "请先完成 AI 快速配置" : "Complete the quick AI setup first";
			render();
			configureLLM();
			return;
		}
		if (pendingProject) {
			const project = options.createProject!();
			if (!project.success) {
				error = zh ? "创建项目失败，请重试" : "Could not create the project. Try again.";
				render();
				return;
			}
			options.entry.id = project.entry.id;
			options.entry.title = project.entry.title;
			options.entry.workDir = project.entry.workDir;
			options.entry.fileName = project.entry.fileName;
			pendingProject = false;
			options.onProjectChanged?.(options.entry);
		}
		if (sessionId === 0) {
			const session = services.createSession(options.entry.workDir ?? "", options.entry.title);
			if (!session.success) {
				error = session.message;
				render();
				return;
			}
			sessionId = session.session.id;
		}
		selectedLLMConfigId = config.id;
		const result = services.sendPrompt(sessionId, text, undefined, workMode, config.id, config.config);
		if (!result.success) error = result.message;
		else {
			taskLLMConfigId = config.id;
			draft = "";
			error = "";
		}
		refresh();
		render();
	};
	const continueTask = () => {
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (
			!detail.success ||
			hasActiveTask() ||
			(detail.session.currentTaskStatus !== "FAILED" && detail.session.currentTaskStatus !== "STOPPED") ||
			detail.session.currentTaskId === undefined
		)
			return;
		const config = resolveLLMConfig();
		if (!config.success) {
			error = zh ? "请先完成 AI 快速配置" : "Complete the quick AI setup first";
			render();
			configureLLM();
			return;
		}
		if (!services.continuePrompt) {
			error = zh ? "当前版本不支持继续会话" : "Continuing this session is unavailable";
			render();
			return;
		}
		selectedLLMConfigId = config.id;
		const result = services.continuePrompt(sessionId, undefined, config.id);
		error = result.success ? "" : result.message;
		if (result.success) {
			taskLLMConfigId = config.id;
			stopRequested = false;
		}
		refresh();
		render();
	};
	const startDevelopment = () => {
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (!detail.success || hasActiveTask() || detail.session.workMode !== "plan" || !detail.hasActivePlan) return;
		const modeResult = services.setWorkMode(sessionId, "code");
		if (!modeResult.success) {
			error = modeResult.message ?? (zh ? "切换执行模式失败" : "Could not switch to Code mode");
			render();
			return;
		}
		const config = resolveLLMConfig();
		if (!config.success) {
			error = zh ? "请先完成 AI 快速配置" : "Complete the quick AI setup first";
			refresh();
			render();
			configureLLM();
			return;
		}
		selectedLLMConfigId = config.id;
		const prompt = zh
			? "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。"
			: "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated.";
		const result = services.sendPrompt(sessionId, prompt, undefined, "code", config.id, config.config);
		error = result.success ? "" : result.message;
		if (result.success) taskLLMConfigId = config.id;
		refresh();
		render();
	};
	const getTranscriptActions = (): RemixTranscriptAction[] => {
		if (!detail.success || !hasTranscriptContent() || hasActiveTask() || detail.messages.every((message) => message.role !== "assistant"))
			return [];
		const actions: RemixTranscriptAction[] = [];
		if (
			(detail.session.currentTaskStatus === "FAILED" || detail.session.currentTaskStatus === "STOPPED") &&
			detail.session.currentTaskId !== undefined
		)
			actions.push({ id: "continue", text: zh ? "继续" : "Continue", onTapped: continueTask });
		if (detail.session.kind === "main" && detail.session.workMode === "plan" && detail.hasActivePlan)
			actions.push({ id: "start-development", text: zh ? "开始开发" : "Start development", primary: true, onTapped: startDevelopment });
		return actions;
	};
	const stop = () => {
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		// A stale Stop control must never submit the draft after a task finishes.
		if (!hasActiveTask() || !detail.success || detail.session.currentTaskFinalizing || stopRequested) return;
		const result = services.stopSessionTask(sessionId) as { success?: boolean; message?: string } | undefined;
		if (result?.success === false) error = result.message ?? (zh ? "停止失败" : "Could not stop");
		else {
			stopRequested = true;
			error = "";
		}
		refresh();
		render();
	};
	const advanceQuestionnaire = (skipCurrent = false) => {
		if (isMobileLLMOpen() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		if (!detail.success || !detail.pendingQuestionnaire) return;
		const pending = detail.pendingQuestionnaire;
		const questions = pending.schema.questions;
		const question = questions[questionIndex];
		if (question === undefined) return;
		const selected = questionnaireSelections[question.id] ?? [];
		const text = (questionnaireTexts[question.id] ?? "").trim();
		if (skipCurrent) {
			if (question.required) return;
			questionnaireSelections[question.id] = [];
			questionnaireTexts[question.id] = "";
		} else if (!isQuestionAnswered(question, selected, text)) {
			error = zh ? "请先完成当前必答问题" : "Answer the required question first";
			render();
			return;
		}
		if (questionIndex + 1 < questions.length) {
			questionIndex++;
			error = "";
			render();
			return;
		}
		const answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts);
		if (selectedLLMConfigId <= 0) {
			error = zh ? "没有可用的模型配置" : "No model configuration is available";
			render();
			return;
		}
		const result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId);
		if (!result.success) error = result.message;
		else {
			taskLLMConfigId = selectedLLMConfigId;
			error = "";
		}
		refresh();
		render();
	};
	const goBack = () => {
		if (isMobileLLMOpen()) return;
		if (editingTitle) {
			cancelTitle();
			return;
		}
		if (packagePanel || workspacePanel || swipeBackPending || !host.visible || HttpServer.wsConnectionCount > 0) return;
		if (detail.success && !canLeaveRemix(detail.session.status)) {
			error = "";
			backNoticeUntil = App.runningTime + 3;
			render();
			return;
		}
		blurInput();
		notifyProjectChanged();
		host.visible = false;
		host.removeFromParent(true);
		onBack();
	};

	const openWorkspace = (panel: "files" | "changes" | "logs") => {
		if (disposed || workspacePanel || packagePanel || !host.visible || HttpServer.wsConnectionCount > 0) return;
		blurInput();
		if (editingTitle) cancelTitle();
		workspacePanel = startWorkspacePanel({
			state: workspaceState,
			panel,
			entry: options.entry,
			getDetail: () => detail,
			isBusy: hasActiveTask,
			onModel: () => {
				if (!disposed && host.parent && host.visible) configureLLM();
			},
			onExport: () => {
				if (disposed || !host.parent || !host.visible) return;
				packagePanel = startPackagePanel({
					mode: "share",
					entry: options.entry,
					onClosed: () => {
						packagePanel = undefined;
					},
				});
			},
			onChanged: (message) => {
				if (disposed) return;
				error = message ?? "";
				options.onProjectChanged?.(options.entry);
				refresh();
				render();
			},
			onClose: () => {
				workspacePanel = undefined;
			},
		});
	};
	const render = () => {
		const oldQuestionOffset = questionScroll?.offset.y ?? 0;
		questionScroll = undefined;
		const visibleError =
			error !== ""
				? error
				: backNoticeUntil > App.runningTime
					? zh
						? "Agent 工作中，请先停止再返回"
						: "Stop the Agent before going back"
					: "";
		errorLabel = undefined;
		// Resizing/rebuilding cancels any old gesture and its delayed completion.
		swipeRevision++;
		swipeDragging = false;
		swipeBackPending = false;
		const layout = `${App.safeArea.width}:${App.safeArea.height}`;
		const keptTitleInput = editingTitle && layout === inputLayout ? titleInputNode : undefined;
		const restoreTitleFocus = titleInput.isFocused();
		keptTitleInput?.removeFromParent(false);
		if (!keptTitleInput) {
			titleInput.unmount();
			titleInputNode = undefined;
		}
		// Work/status updates must not detach the active IME node or discard composition.
		const keptInput =
			layout === inputLayout && !(detail.success && detail.pendingQuestionnaire) && inputRef.current?.tag === "remix-input"
				? inputRef.current
				: undefined;
		keptInput?.removeFromParent(false);
		transcript.node.removeFromParent(false);
		const restoreInputFocus = promptInput.isFocused();
		if (!keptInput) {
			promptInput.unmount();
			inputRef = reference<Node.Type>();
		}
		host.removeAllChildren();
		inputLayout = layout;
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = getLayoutArea();
		const left = safe.x;
		const bottom = safe.y;

		const state = detail.success ? detail.session : undefined;
		const workMode = state ? resolveRemixWorkMode(state) : draftWorkMode;
		const stopping = hasActiveTask();
		const layoutComposerBottom = 60;
		const layoutComposerHeight = 54;
		const layoutModeBottom = 122;
		const layoutComposerTop = 164;
		layoutTranscriptBottom = layoutComposerTop + 12;
		const contentWidth = safe.width - 32;
		const inputWidth = contentWidth - 24;

		const modeStartX = left + 26;

		const questionnaire = detail.success ? detail.pendingQuestionnaire : undefined;
		const question = questionnaire?.schema.questions[questionIndex];
		const questionPromptWidth = contentWidth - 32;
		const questionPromptHeight = question ? measureWrappedTextHeight(question.prompt, questionPromptWidth, 16) : 0;
		const questionOptions = question && question.type !== "text" ? (question.options ?? []).slice(0, 8) : [];
		const questionAnswerHeight = questionOptions.length > 0 ? 40 + 43 * (questionOptions.length - 1) : 92;
		const questionCardHeight = math.max(150, safe.height - 188);
		const questionBodyHeight = 36 + questionPromptHeight + 16 + questionAnswerHeight + 12;
		const questionAnswerTop = questionBodyHeight - 36 - questionPromptHeight - 16;
		const questionKey = `${questionnaire?.id ?? 0}:${questionIndex}`;
		const questionOffset = questionKey === questionScrollKey ? oldQuestionOffset : 0;
		questionScrollKey = questionKey;
		const questionHasBack = questionIndex > 0;
		const questionCanSkip = question !== undefined && !question.required;
		const questionActionGap = 8;
		const questionBackWidth = 76;
		const questionSkipWidth = 64;
		const questionSkipX = 16 + (questionHasBack ? questionBackWidth + questionActionGap : 0);
		const questionSubmitX = questionSkipX + (questionCanSkip ? questionSkipWidth + questionActionGap : 0);

		const headerY = getHeaderY(safe);
		const compactHeaderStatus = useCompactHeaderStatus(safe);
		compactHeaderStatusActive = compactHeaderStatus;

		const modelButtonWidth = math.max(90, math.min(contentWidth - 70, 180));

		const headerBackX = left + 12;
		const headerTitleWidth = math.max(40, safe.width - 184);
		const titleMeasure = Label(goTheme.headingFont, 15, true)!;
		titleMeasure.text = ellipsizeSingleLine(options.entry.title, headerTitleWidth, 15);
		const headerEditX = left + 52 + math.min(headerTitleWidth, titleMeasure.width) + 2;
		titleMeasure.cleanup();
		const selectedConfig = llmConfigs.find((item) => item.id === selectedLLMConfigId);
		const switchPending = hasActiveTask() && taskLLMConfigId > 0 && taskLLMConfigId !== selectedLLMConfigId;
		const modelName = selectedConfig?.name ?? (zh ? "配置 AI" : "Set up AI");
		const modelNameLimit = 18;
		const shortModelName = inputLength(modelName) > modelNameLimit ? `${inputSlice(modelName, 0, modelNameLimit)}…` : modelName;
		const modelLabel = ellipsizeSingleLine(
			`${switchPending ? (zh ? "下一轮·" : "Next·") : ""}${shortModelName}`,
			modelButtonWidth - 22,
			11,
		);

		let swipeStart = Vec2.zero;
		let swipeAxis: "none" | "horizontal" | "vertical" = "none";
		const pageRef = reference<Node.Type>();
		const hitsTranscriptButton = (node: Node.Type, world: Vec2.Type): boolean => {
			if (!node.visible) return false;
			if (
				node.tag === "remix-copy" ||
				node.tag === "remix-latest" ||
				node.tag === "remix-action-continue" ||
				node.tag === "remix-action-start-development"
			) {
				const p = node.convertToNodeSpace(world);
				if (p.x >= 0 && p.y >= 0 && p.x <= node.width && p.y <= node.height) return true;
			}
			let hit = false;
			node.eachChild((child) => {
				hit = hitsTranscriptButton(child, world);
				return hit;
			});
			return hit;
		};
		const scene = toNode(
			<node tag="remix-scene" x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0}>
				{/* Observe before swallowing children, without consuming their first tap/drag. */}
				<node
					tag="remix-focus-observer"
					order={1000}
					width={width}
					height={height}
					anchorX={0}
					anchorY={0}
					touchEnabled={true}
					swallowTouches={false}
					swallowMouseWheel={false}
					onTapFilter={(touch) => {
						touch.enabled = false;
						if (editingTitle || packagePanel || workspacePanel || swipeBackPending || !host.visible || HttpServer.wsConnectionCount > 0)
							return;
						const input = inputRef.current;
						const point = input?.convertToNodeSpace(touch.worldLocation);
						const inside = input && point && point.x >= 0 && point.y >= 0 && point.x <= input.width && point.y <= input.height;
						dismissedComposition = !inside && promptInput.isComposing();
						if (!inside) blurInput();
						// Do not turn input editing, header/button taps, or questionnaires into navigation.
						if (
							!inside &&
							!questionnaire &&
							touch.first !== false &&
							touch.location.y >= bottom + layoutTranscriptBottom &&
							touch.location.y < bottom + safe.height - 64 &&
							!hitsTranscriptButton(transcript.node, touch.worldLocation)
						) {
							touch.enabled = true;
						}
					}}
					onTapBegan={(touch) => {
						swipeStart = touch.location;
						swipeAxis = "none";
						swipeDragging = false;
						swipeLastMotion = App.runningTime;
						pageRef.current?.stopAllActions();
					}}
					onTapMoved={(touch) => {
						swipeLastMotion = App.runningTime;
						const delta = touch.location.sub(swipeStart);
						if (swipeAxis === "none" && math.max(math.abs(delta.x), math.abs(delta.y)) >= 12)
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 ? "horizontal" : "vertical";
						// Vertical scrolling belongs to ScrollArea and must never latch the navigation lock.
						swipeDragging = swipeAxis === "horizontal";
						// The observer stays stationary, so moving the page never changes gesture coordinates.
						if (pageRef.current && swipeDragging) pageRef.current.x = math.min(0, delta.x) * 0.18;
					}}
					onTapEnded={(touch) => {
						swipeLastMotion = App.runningTime;
						const delta = touch.location.sub(swipeStart);
						swipeDragging = false;
						if (swipeBackPending) return;
						const requested = swipeAxis !== "vertical" && resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) === "play";
						const leaving = requested && (!detail.success || canLeaveRemix(detail.session.status));
						const page = pageRef.current;
						if (!page || (!requested && page.x === 0)) return;
						const duration = leaving || App.reducedMotion ? 0 : 0.16;
						const revision = swipeRevision;
						swipeBackPending = true;
						// Hold the release offset until removal; resetting before the deferred switch flashes a rebound frame.
						if (!leaving) page.perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad));
						// Also defer zero-duration completion: native TapEnded is followed by Tapped on this node.
						thread(() => {
							sleep(duration);
							if (disposed || revision !== swipeRevision || !host.parent) return;
							swipeBackPending = false;
							if (requested && host.visible && HttpServer.wsConnectionCount === 0) {
								refresh();
								goBack();
							} else page.position = Vec2.zero;
						});
					}}
				/>
				<VerticalGradient width={width} height={height} topColor={goTheme.backgroundTop} bottomColor={goTheme.background} />
				<node tag="remix-page" ref={pageRef}>
					<node
						tag="remix-back"
						x={headerBackX}
						y={headerY}
						width={32}
						height={44}
						anchorX={0}
						anchorY={0}
						touchEnabled={true}
						swallowTouches={true}
						onMount={pressFeedback}
						onTapped={goBack}
					>
						<GoIcon name="back" x={4} y={12} size={20} />
					</node>
					{!editingTitle ? (
						<clip-node
							x={left + 52}
							y={headerY}
							width={headerTitleWidth}
							height={44}
							anchorX={0}
							anchorY={0}
							stencil={
								<draw-node x={headerTitleWidth / 2} y={22}>
									<rect-shape width={headerTitleWidth} height={44} fillColor={0xffffffff} />
								</draw-node>
							}
						>
							<label
								tag="remix-title"
								x={0}
								y={29}
								anchorX={0}
								fontName={goTheme.headingFont}
								fontSize={15}
								text={ellipsizeSingleLine(options.entry.title, headerTitleWidth, 15)}
								color3={0x30352b}
								alignment={TextAlign.Left}
							/>
							<label
								tag="remix-status-text"
								x={0}
								y={10}
								anchorX={0}
								fontName={fontName}
								fontSize={10}
								text={
									questionnaire
										? zh
											? "等待你的回答"
											: "Waiting for your answer"
										: stopping
											? zh
												? "Dora 正在创作…"
												: "Dora is working…"
											: zh
												? pendingProject
													? "新项目"
													: "已保存到本地"
												: pendingProject
													? "New project"
													: "Saved locally"
								}
								color3={0x7c826f}
								alignment={TextAlign.Left}
							/>
						</clip-node>
					) : undefined}
					{!editingTitle ? (
						<ActionButton
							tag="remix-play"
							x={left + safe.width - 92}
							y={headerY + 8}
							width={70}
							height={32}
							text="GO!"
							primary={true}
							disabled={stopping || !hasPreview()}
							onTapped={() => {
								refresh();
								if (
									!host.visible ||
									workspaceState.buildFailed ||
									workspacePanel ||
									hasActiveTask() ||
									HttpServer.wsConnectionCount > 0 ||
									!hasPreview()
								)
									return;
								blurInput();
								notifyProjectChanged();
								host.visible = false;
								onPlay(options.entry);
							}}
						/>
					) : undefined}
					{!editingTitle ? (
						<node
							tag="remix-title-edit"
							x={headerEditX}
							y={headerY + 11}
							width={32}
							height={36}
							anchorX={0}
							anchorY={0}
							touchEnabled={true}
							swallowTouches={true}
							onMount={pressFeedback}
							onTapped={() => {
								if (!host.visible || workspacePanel || packagePanel || isMobileLLMOpen() || HttpServer.wsConnectionCount > 0) return;
								blurInput();
								titleDraft = options.entry.title;
								titleError = "";
								editingTitle = true;
								render();
								titleInput.deferFocus();
							}}
						>
							<GoIcon name="edit" x={8} y={10} size={16} />
						</node>
					) : (
						<node>
							{!keptTitleInput ? (
								<node
									tag="remix-title-input"
									x={left + 52}
									y={headerY + 7}
									width={safe.width - 152}
									height={36}
									anchorX={0}
									anchorY={0}
									onMount={(node) => {
										titleInputNode = node;
										titleInput.mount(node);
									}}
								/>
							) : undefined}
							{[false, true].map((confirm) => (
								<node
									tag={confirm ? "remix-title-confirm" : "remix-title-cancel"}
									x={left + safe.width - (confirm ? 50 : 90)}
									y={headerY + 7}
									width={36}
									height={36}
									anchorX={0}
									anchorY={0}
									touchEnabled={true}
									swallowTouches={true}
									onMount={pressFeedback}
									onTapped={confirm ? confirmTitle : cancelTitle}
								>
									<RoundedSurface width={36} height={36} radius={10} fillColor={confirm ? 0xffffdf70 : 0xffeeeee5} />
									<GoIcon name={confirm ? "check" : "close"} x={9} y={9} size={18} />
								</node>
							))}
							{titleError !== "" ? (
								<label x={left + 52} y={headerY} anchorX={0} fontName={fontName} fontSize={10} text={titleError} color3={0x99664d} />
							) : undefined}
						</node>
					)}
					<RoundedSurface x={left + 22} y={headerY - 36} width={safe.width - 44} height={0.6} radius={0} fillColor={0x18505d39} />
					<node y={headerY - 34}>
						{["files", "changes", "logs"].map((name, i) => (
							<node
								tag={`remix-tool-${name}`}
								x={left + 22 + i * 68}
								width={62}
								height={30}
								anchorX={0}
								anchorY={0}
								touchEnabled={true}
								swallowTouches={true}
								onMount={pressFeedback}
								onTapped={() => openWorkspace(name as "files" | "changes" | "logs")}
							>
								<GoIcon name={name as "files" | "changes" | "logs"} x={4} y={7.5} size={15} />
								<label
									x={24}
									y={15}
									anchorX={0}
									fontName={fontName}
									fontSize={11}
									text={zh ? ["文件", "修改", "日志"][i] : ["Files", "Changes", "Logs"][i]}
									color3={0x7c826f}
									alignment={TextAlign.Left}
								/>
							</node>
						))}
					</node>
					{!hasTranscriptContent() && !questionnaire ? (
						<node
							tag="remix-welcome"
							x={left + safe.width / 2}
							y={bottom + layoutTranscriptBottom + (safe.height - 112 - layoutTranscriptBottom) / 2}
						>
							<clip-node
								x={-29}
								y={7}
								width={58}
								height={58}
								anchorX={0}
								anchorY={0}
								stencil={<RoundedStencil width={58} height={58} radius={14} />}
							>
								<sprite file="Image/GoUI/mascot.png" x={29} y={29} scaleX={58 / 128} scaleY={58 / 128} />
							</clip-node>
							<label
								x={0}
								y={-12}
								fontName={fontName}
								fontSize={21}
								text={zh ? "从一个想法开始" : "Start with an idea"}
								color3={0x414735}
							/>
							<label
								x={0}
								y={-47}
								fontName={fontName}
								fontSize={13}
								text={zh ? "你想做一款什么样的游戏？" : "What would you like to create?"}
								color3={0x8b927e}
							/>
						</node>
					) : undefined}
					{questionnaire && question ? (
						<node
							tag="remix-questionnaire"
							x={left + 16}
							y={bottom + 72}
							width={contentWidth}
							height={questionCardHeight}
							anchorX={0}
							anchorY={0}
						>
							<RoundedSurface
								width={contentWidth}
								height={questionCardHeight}
								radius={20}
								topColor={0xfffafbf5}
								bottomColor={0xfffafbf5}
								borderWidth={1}
								borderColor={0xffd2d6c5}
								shadow={true}
							/>
							<custom-node
								onCreate={() => {
									const viewportHeight = questionCardHeight - 72;
									const scroll = ScrollArea({
										width: contentWidth - 32,
										height: viewportHeight,
										paddingX: 0,
										paddingY: 0,
										scrollBar: false,
									}) as ReturnType<typeof ScrollArea> & {
										offset: Vec2.Type;
										resetSize(this: Node.Type, w: number, h: number, vw: number, vh: number): void;
									};
									scroll.position = Vec2(contentWidth / 2, 60 + viewportHeight / 2);
									const body = toNode(
										<node width={contentWidth - 32} height={questionBodyHeight} x={0} y={viewportHeight} anchorX={0} anchorY={1}>
											<label
												x={0}
												y={questionBodyHeight - 8}
												anchorX={0}
												anchorY={1}
												fontName={fontName}
												fontSize={12}
												text={`${questionIndex + 1} / ${questionnaire.schema.questions.length} · ${questionnaire.schema.title}`}
												textWidth={contentWidth - 32}
												alignment={TextAlign.Left}
												color3={0x8a7027}
											/>
											<label
												tag="remix-question-prompt"
												x={0}
												y={questionBodyHeight - 36}
												anchorX={0}
												anchorY={1}
												fontName={fontName}
												fontSize={16}
												text={question.prompt}
												textWidth={questionPromptWidth}
												alignment={TextAlign.Left}
												color3={0x30352b}
											/>
											{question.type !== "text" ? (
												questionOptions.map((option, optionIndex) => (
													<ChoiceButton
														tag={`remix-question-${question.id}-option-${option.id}`}
														x={0}
														y={questionAnswerTop - 40 - optionIndex * 43}
														width={contentWidth - 32}
														text={`${option.label}${option.recommended ? (zh ? "（推荐）" : " (recommended)") : ""}`}
														selected={(questionnaireSelections[question.id] ?? []).indexOf(option.id) >= 0}
														onTapped={() => {
															const selected = questionnaireSelections[question.id] ?? [];
															questionnaireSelections[question.id] =
																question.type === "single_choice"
																	? [option.id]
																	: selected.indexOf(option.id) >= 0
																		? selected.filter((id) => id !== option.id)
																		: [...selected, option.id];
															render();
														}}
													/>
												))
											) : (
												<node
													tag="remix-question-input"
													ref={inputRef}
													x={0}
													y={questionAnswerTop - 92}
													width={contentWidth - 32}
													height={92}
													anchorX={0}
													anchorY={0}
													onMount={promptInput.mount}
												/>
											)}
										</node>,
									);
									if (body) scroll.view.addChild(body);
									scroll.resetSize(contentWidth - 32, viewportHeight, contentWidth - 32, questionBodyHeight);
									scroll.offset = Vec2(0, math.max(0, math.min(questionOffset, questionBodyHeight - viewportHeight)));
									scroll.view.moveAndCullItems(Vec2.zero);
									questionScroll = scroll;
									return scroll;
								}}
							/>

							{questionHasBack ? (
								<ActionButton
									tag="remix-question-back"
									x={16}
									y={12}
									width={questionBackWidth}
									text={zh ? "上一步" : "Back"}
									onTapped={() => {
										questionIndex--;
										render();
									}}
								/>
							) : undefined}
							{questionCanSkip ? (
								<ActionButton
									tag="remix-question-skip"
									x={questionSkipX}
									y={12}
									width={questionSkipWidth}
									text={zh ? "跳过" : "Skip"}
									onTapped={() => advanceQuestionnaire(true)}
								/>
							) : undefined}
							<ActionButton
								tag="remix-question-submit"
								x={questionSubmitX}
								y={12}
								width={contentWidth - questionSubmitX - 16}
								text={questionIndex + 1 === questionnaire.schema.questions.length ? (zh ? "提交回答" : "Submit") : zh ? "下一步" : "Next"}
								primary={true}
								onTapped={() => {
									if (!dismissedComposition) advanceQuestionnaire();
									dismissedComposition = false;
								}}
							/>
						</node>
					) : undefined}
					{visibleError !== "" ? (
						<label
							tag="remix-error"
							x={left + 20}
							y={bottom + (questionnaire ? 58 : layoutComposerTop + composerGap)}
							anchorX={0}
							anchorY={0}
							fontName={fontName}
							fontSize={13}
							text={visibleError}
							textWidth={contentWidth}
							alignment={TextAlign.Left}
							color3={0xff6b6b}
							onMount={(label) => {
								errorLabel = label;
							}}
						/>
					) : undefined}
					{questionnaire === undefined ? (
						<node>
							<RoundedSurface
								x={left + 16}
								y={bottom + 16}
								width={contentWidth}
								height={148}
								radius={18}
								fillColor={goTheme.panel}
								borderWidth={1}
								borderColor={goTheme.border}
							/>
							<RoundedSurface x={modeStartX - 2} y={bottom + layoutModeBottom} width={110} height={30} radius={7} fillColor={0xffecefe5} />
							<MobileButton
								tag="remix-mode-code"
								x={modeStartX}
								y={bottom + layoutModeBottom + 2}
								width={52}
								height={26}
								fontSize={11}
								text={zh ? "执行" : "Code"}
								segmented={true}
								selected={workMode === "code"}
								disabled={!canSubmit()}
								onTapped={() => changeWorkMode("code")}
							/>
							<MobileButton
								tag="remix-mode-plan"
								x={modeStartX + 54}
								y={bottom + layoutModeBottom + 2}
								width={52}
								height={26}
								fontSize={11}
								text={zh ? "计划" : "Plan"}
								segmented={true}
								selected={workMode === "plan"}
								disabled={!canSubmit()}
								onTapped={() => changeWorkMode("plan")}
							/>
							{!keptInput ? (
								<node
									tag="remix-input"
									ref={inputRef}
									x={left + 28}
									y={bottom + layoutComposerBottom}
									width={inputWidth}
									height={layoutComposerHeight}
									anchorX={0}
									anchorY={0}
									onMount={promptInput.mount}
								/>
							) : undefined}
							<node
								tag="remix-model-config"
								x={left + 28}
								y={bottom + 23}
								width={modelButtonWidth}
								height={30}
								anchorX={0}
								anchorY={0}
								touchEnabled={true}
								swallowTouches={true}
								onMount={pressFeedback}
								onTapped={configureLLM}
							>
								<GoIcon name="dropdown" x={modelButtonWidth - 14} y={8} size={14} color={0xff7c826f} />
								<label
									x={0}
									y={15}
									anchorX={0}
									fontName={fontName}
									fontSize={11}
									text={modelLabel}
									color3={0x7c826f}
									alignment={TextAlign.Left}
								/>
							</node>
						</node>
					) : undefined}
					{stopping || questionnaire === undefined ? (
						<ActionButton
							tag={stopping ? "remix-stop" : "remix-send"}
							x={left + safe.width - 60}
							y={bottom + 24}
							width={32}
							height={32}
							text=""
							icon={stopping ? "stop" : "up"}
							primary={!stopping}
							danger={stopping}
							disabled={stopping ? stopRequested || state?.currentTaskFinalizing === true : !canSubmit()}
							onTapped={() => {
								if (stopping) stop();
								else if (!dismissedComposition) send();
								dismissedComposition = false;
							}}
						/>
					) : undefined}
				</node>
			</node>,
		);
		if (scene) {
			host.addChild(scene);
			if (keptInput) {
				keptInput.position = Vec2(left + 28, bottom + layoutComposerBottom);
				keptInput.width = inputWidth;
				keptInput.height = layoutComposerHeight;
				pageRef.current?.addChild(keptInput);
			}
			if (!questionnaire) {
				transcript.node.position = Vec2(left + 22, bottom + getTranscriptBottom());
				pageRef.current?.addChild(transcript.node);
				updateTranscript();
			}
		}
		if (restoreInputFocus && inputRef.current && !keptInput) promptInput.focus(false);
		if (keptInput) promptInput.refresh();
		if (keptTitleInput) pageRef.current?.addChild(keptTitleInput);
		else if (editingTitle && restoreTitleFocus) titleInput.focus(false);
		shellRevision = getShellRevision();
		displayRevision = remixDisplayRevision(detail);
	};

	attachGamepad(host, {
		initialTag: "remix-input",
		isEnabled: () => !workspacePanel && !packagePanel && !disposed,
		onBack: () => {
			if (editingTitle) cancelTitle();
			else if (promptInput.isFocused()) blurInput();
			else goBack();
		},
		onScroll: (amount) => transcript.scrollBy(amount),
		onActivate: (target) => {
			if (target.tag === "remix-title-input" || target.tag === "remix-input" || target.tag === "remix-question-input")
				target.emit("GamepadActivate");
			else {
				if (promptInput.isComposing()) {
					blurInput();
					return;
				}
				blurInput();
				dismissedComposition = false;
				target.emit("Tapped");
			}
		},
	});
	host.schedule((dt) => {
		// A swallowed release or a pointer leaving the window must not suspend polling forever.
		if ((swipeDragging || swipeBackPending) && App.runningTime - swipeLastMotion > 0.5) {
			swipeDragging = false;
			swipeBackPending = false;
			swipeRevision++;
			const page = host.getChildByTag("remix-scene")?.getChildByTag("remix-page");
			page?.perform(Move(App.reducedMotion ? 0 : 0.12, page.position, Vec2.zero, Ease.OutQuad));
		}
		pollElapsed += dt;
		if (pollElapsed < 0.25) return false;
		if (swipeDragging || swipeBackPending || transcript.isInteracting()) return false;
		pollElapsed = 0;
		refresh();
		if (backNoticeUntil > 0 && App.runningTime >= backNoticeUntil) {
			backNoticeUntil = 0;
			render();
			return false;
		}
		const next = remixDisplayRevision(detail);
		if (shellRevision !== getShellRevision() || compactHeaderStatusActive !== useCompactHeaderStatus(getLayoutArea())) render();
		else if (displayRevision !== next) updateTranscript();
		return false;
	});
	host.onAppChange((setting) => {
		if (setting === "Locale") zh = string.match(App.locale, "^zh")[0] !== undefined;
		if (setting === "Size" || setting === "Locale") render();
	});
	host.onAppEvent((event) => {
		if (event === "BackButton") {
			if (workspacePanel) {
				workspacePanel.emit("CloseWorkspace");
				return;
			}
			if (promptInput.isFocused()) blurInput();
			else goBack();
		} else if (event === "WillEnterBackground" || event === "DidEnterBackground") {
			blurInput();
			titleInput.blur();
		}
	});
	host.onCleanup(() => {
		titleInput.unmount();
		workspacePanel?.removeFromParent(true);
		workspacePanel = undefined;
		packagePanel?.removeFromParent(true);
		packagePanel = undefined;
		disposed = true;
		blurInput();
	});
	host.slot("SuspendLocalUI", () => {
		titleInput.blur();
		blurInput();
		if (workspacePanel) {
			workspacePanel.emit("SuspendLocalUI");
			workspacePanel.visible = false;
		}
		if (packagePanel) packagePanel.visible = false;
	});
	host.slot("ResumePreview", (message?: string) => {
		error = message ? (zh ? "试玩失败，请修改后重试。" : "Preview failed. Update the game and try again.") : "";
		refresh();
		render();
	});
	host.slot("ResumeLocalUI", () => {
		if (workspacePanel) workspacePanel.visible = host.visible;
		if (packagePanel) packagePanel.visible = host.visible;
		refresh();
		render();
	});
	render();
	if (needsLLMSetup)
		thread(() => {
			sleep(0);
			if (!disposed && host.parent) configureLLM();
		});
	return host;
}
