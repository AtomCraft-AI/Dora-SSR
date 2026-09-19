import { Description } from "Dev/Mobile/Description";
import { startMobileLLMManager, isMobileLLMOpen, getMobileLLMSelection } from "Dev/Mobile/LLMSetup";
import { createGestureGuide } from "Dev/Mobile/GestureGuide";
import { projectDisplayName } from "Dev/Mobile/ProjectPresentation";
import { Cartridge, CartridgeSlot } from "Dev/Mobile/Cartridge";
import { goTheme } from "Dev/Mobile/Theme";
import { pressFeedback } from "Dev/Mobile/Motion";
import { Spawn, Scale, Angle, AngleY, Opacity, Sequence } from "Dora";
import { React, reference, toNode } from "DoraX";
import { App, Director, Ease, HttpServer, Move, Node, sleep, TextAlign, thread, Vec2 } from "Dora";
import { DoraMascot } from "Dev/Mobile/Mascot";
import { attachGamepad, findGamepadNode } from "Dev/Mobile/Gamepad";
const mobileFontScale = goTheme.fontScale;
import {
	nextFeedIndex,
	visibleFeedPages,
	normalizeFeedIndex,
	resolveDiscoverRefreshTab,
	resolveFeedGesture,
	resolveFeedLocation,
	type FeedAction,
	type FeedEntry as ModelFeedEntry,
	type FeedTab,
} from "Dev/Mobile/FeedModel";
import { createTextInput } from "Dev/Mobile/TextInput";
import { MobileButton, MobileChoiceButton, MobileNewButton, MobilePanelSurface } from "Dev/Mobile/Controls";
import { GoIcon, RoundedStencil, SceneSurface as RoundedSurface, VerticalGradient } from "Dev/Mobile/Visual";
import { startPackagePanel } from "Dev/Mobile/PackagePanel";
import { ProjectIndex } from "Dev/Mobile/ProjectIndex";
import type { MobileProjectLanguage } from "Dev/Mobile/ProjectCreate";

interface FeedEntry extends ModelFeedEntry {
	resource?: unknown;
	catalogCommit?: string;
	launchError?: string;
}

interface MobileFeedOptions {
	initialEntry?: FeedEntry;
	initialEntries?: { local?: FeedEntry; discover?: FeedEntry };
	getLocalEntries: (this: void, dirtyProjectPath?: string) => FeedEntry[];
	takeReceivedFile?: (this: void) => string;
	getDiscoverEntries: (this: void) => FeedEntry[];
	syncDiscover?: (
		this: void,
		onProgress: (this: void, message: string) => void,
		onDone: (this: void, success: boolean, message?: string) => void,
		force?: boolean,
	) => void;
	onPlay: (this: void, entry: FeedEntry) => void;
	onRemix: (
		this: void,
		entry: FeedEntry,
		createProject?: (this: void) => { success: true; entry: FeedEntry } | { success: false; error: string },
	) => void;
	onCurrentEntryChanged?: (this: void, entry: FeedEntry) => void;
	createProject?: (
		this: void,
		name: string,
		language: MobileProjectLanguage,
	) => { success: true; entry: FeedEntry } | { success: false; error: string };
	onSwitchMode?: (this: void) => void;
	prepare: (
		this: void,
		entry: FeedEntry,
		repairIncomplete: boolean,
		onProgress: (this: void, progress: number, message: string) => void,
		onDone: (this: void, success: boolean, ready?: { fileName: string; workDir: string }, message?: string, repairable?: boolean) => void,
	) => void;
}

const colors = goTheme;

const fontName = goTheme.font;
const createSheetHeight = 304;
const createInputHeight = 44;
const createInputTop = 140;

function conciseDescription(text: string, limit: number) {
	const length = utf8.len(text)[0] ?? 0;
	if (length <= limit) return text;
	const stop = utf8.offset(text, limit + 1) ?? text.length + 1;
	return string.sub(text, 1, stop - 1) + "…";
}

export function startMobileFeed(options: MobileFeedOptions) {
	const getLocalEntries = (dirtyProjectPath?: string) =>
		options.getLocalEntries(dirtyProjectPath).map((entry) => ({ ...entry, title: projectDisplayName(entry.workDir, entry.title) }));
	const getDiscoverEntries = options.getDiscoverEntries;
	const onPlay = options.onPlay;
	const onRemix = options.onRemix;
	const prepare = options.prepare;
	const syncDiscover = options.syncDiscover;

	let zh = string.match(App.locale, "^zh")[0] !== undefined;
	let tab: FeedTab = "local";
	let index = 0;
	let drag = Vec2.zero;
	let dragAxis: "none" | "horizontal" | "vertical" = "none";
	let discoverError = "";
	let preparing = false;
	let transitioning = false;
	let prepareStatus = "";
	let prepareProgress = 0;
	let catalogSyncing = false;
	let catalogStatus = "";
	let catalogStatusView: ((message: string) => void) | undefined;
	let repairResourceId = "";
	let userSelectedTab = false;
	let active = true;
	let leaving = false;
	let packagePanel: Node.Type | undefined;
	let settingsOpen = false;
	let createOpen = false;
	let projectIndexOpen = false;
	let creating = false;
	let createName = "";
	let createLanguage: MobileProjectLanguage = "typescript";
	let dismissedCreateComposition = false;
	let createError = "";
	let gamepadUsed = false;
	let returnEntry = options.initialEntry;
	const rememberedEntries: { local?: FeedEntry; discover?: FeedEntry } = {
		local: options.initialEntries?.local,
		discover: options.initialEntries?.discover,
	};
	let cardRef = reference<Node.Type>();
	let launchRef = reference<Node.Type>();
	let slotRef = reference<Node.Type>();
	let lastTouchTime = App.runningTime;
	let guideShown = false;
	let lastTapTime = -1;
	let transitionRevision = 0;
	let guidePlayed = false;
	const cancelGuide = () => {
		lastTouchTime = App.runningTime;
		guideShown = false;
		host.getChildByTag("go-gesture-guide")?.removeFromParent(true);
	};
	let indexRef = reference<Node.Type>();
	let infoRef = reference<Node.Type>();
	const headerRef = reference<Node.Type>();
	const menuRef = reference<Node.Type>();
	const swapRef = reference<Node.Type>();
	const gearRef = reference<Node.Type>();
	let dragStartX = 0,
		dragStartY = 0;
	let dragSampleTime = 0,
		dragVelocityX = 0;
	let createInputRef = reference<Node.Type>();
	let discover = getDiscoverEntries();
	let local = getLocalEntries();

	if (discover.length === 0) {
		discoverError = zh ? "资源目录暂不可用" : "Catalog is unavailable";
	}
	const initialLocation = resolveFeedLocation(local, discover, returnEntry);
	tab = initialLocation.tab;
	index = initialLocation.index;

	const host = Node();
	host.tag = "mobile-feed";
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	// Cleanup is posted for a later frame; detachment must invalidate callbacks now.
	const isActive = () => active && !leaving && host.parent !== undefined;

	const closeSettings = () => {
		if (!settingsOpen) return;
		settingsOpen = false;
		if (gearRef.current) gearRef.current.perform(Angle(App.reducedMotion ? 0 : 0.24, gearRef.current.angle, 0, Ease.OutCubic));
		const menu = menuRef.current;
		if (!menu || App.reducedMotion) {
			render();
			return;
		}
		menu.perform(
			Spawn(
				Opacity(0.16, menu.opacity, 0),
				Scale(0.16, menu.scaleX, 0.92, Ease.OutCubic),
				Move(0.16, menu.position, Vec2(menu.x, menu.y + 6), Ease.InQuad),
			),
		);
		thread(() => {
			sleep(0.16);
			if (isActive() && menuRef.current === menu) render();
		});
	};
	const entries = () => (tab === "discover" ? discover : local);
	const current = () => entries()[normalizeFeedIndex(index, entries().length)];
	let rememberedEntryKey = "";
	const rememberCurrent = () => {
		const item = current();
		if (item === undefined || !options.onCurrentEntryChanged) return;
		const key = `${item.kind}\n${item.id}\n${item.workDir ?? ""}\n${item.fileName ?? ""}`;
		if (key === rememberedEntryKey) return;
		rememberedEntryKey = key;
		rememberedEntries[item.kind] = item;
		options.onCurrentEntryChanged(item);
	};
	const canEditCreate = () => createOpen && !creating && isActive() && host.visible && HttpServer.wsConnectionCount === 0;
	const createInput = createTextInput({
		fontSize: math.floor(16 * mobileFontScale),
		singleLine: true,
		background: colors.background,
		getText: () => createName,
		setText: (text) => {
			createName = text;
		},
		getPlaceholder: () => (zh ? "例如：星际花园" : "For example: Star Garden"),
		isEnabled: canEditCreate,
		onReturn: () => {
			submitCreate();
			return true;
		},
	});
	const blurCreateInput = createInput.blur;
	const closeCreate = () => {
		if (creating) return;
		blurCreateInput();
		createOpen = false;
		createName = "";
		createError = "";
		render();
	};
	const openCreate = () => {
		if (!options.createProject || preparing || transitioning || creating || createOpen || HttpServer.wsConnectionCount > 0) return;
		projectIndexOpen = false;
		createOpen = true;
		createLanguage = "typescript";
		createName = "";
		dismissedCreateComposition = false;
		createError = "";
		render();
		createInput.deferFocus();
	};
	const openProjectIndex = () => {
		if (preparing || transitioning || creating || createOpen || HttpServer.wsConnectionCount > 0) return;
		if (tab === "local") local = getLocalEntries();
		projectIndexOpen = true;
		render();
	};
	const createErrorText = (error: string) => {
		switch (error) {
			case "invalid-name":
				return zh ? "请输入不含路径分隔符的项目名称" : "Enter a project name without path separators";
			case "target-existed":
				return zh ? "已有同名项目，请换一个名称" : "A project with that name already exists";
			case "create-folder-failed":
				return zh ? "无法创建项目目录，请检查工作目录后重试" : "Could not create the project folder; check the workspace and retry";
			case "create-entry-failed":
				return zh ? "无法写入项目入口，未完成项目已回滚" : "Could not write the project entry; the incomplete project was rolled back";
			case "created-project-not-found":
				return zh
					? "项目已创建，但本地列表未能找到它，请返回后重试"
					: "The project was created but could not be found in Local; return and retry";
			default:
				return zh ? "创建失败，请重试" : "Project creation failed; try again";
		}
	};
	const submitCreate = () => {
		if (!options.createProject || creating || !createOpen || !isActive() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		if (createInput.isComposing()) return;
		creating = true;
		createError = "";
		blurCreateInput();
		render();
		const result = options.createProject(createName, createLanguage);
		if (!isActive()) return;
		creating = false;
		if (!result.success) {
			createError = createErrorText(result.error);
			render();
			return;
		}
		createOpen = false;
		createName = "";
		local = getLocalEntries();
		returnEntry = result.entry;
		const location = resolveFeedLocation(local, discover, result.entry);
		tab = location.tab;
		index = location.index;
		render();
		onRemix(result.entry);
	};

	const createBlank = () => {
		if (!options.createProject || !isActive() || preparing || transitioning || creating || HttpServer.wsConnectionCount > 0) return;
		const draftEntry: FeedEntry = { id: "new-project", title: zh ? "未命名游戏" : "Untitled game", kind: "local", description: "" };
		onRemix(draftEntry, () => {
			for (let suffix = 0; suffix < 100; suffix++) {
				const name = draftEntry.title + (suffix === 0 ? "" : ` ${suffix + 1}`);
				const result = options.createProject!(name, "typescript");
				if (result.success || result.error !== "target-existed") return result;
			}
			return { success: false, error: "target-existed" };
		});
	};

	const openPackage = (mode: "add" | "share" | "receive", path?: string, pickOnOpen = false) => {
		if (
			!isActive() ||
			!host.visible ||
			packagePanel ||
			preparing ||
			transitioning ||
			creating ||
			createOpen ||
			HttpServer.wsConnectionCount > 0
		)
			return;
		projectIndexOpen = false;
		packagePanel = startPackagePanel({
			mode,
			path,
			pickOnOpen,
			entry: current(),
			onNew: openCreate,
			onClosed: () => {
				packagePanel = undefined;
			},
			onImported: (entry, play) => {
				if (!isActive()) return;
				local = getLocalEntries(entry.workDir);
				const imported = local.find((item) => item.workDir === entry.workDir) ?? entry;
				returnEntry = imported;
				const location = resolveFeedLocation(local, discover, imported);
				tab = "local";
				index = location.index;
				render();
				if (play) onPlay(imported);
			},
		});
	};
	let receiveElapsed = 0;
	host.schedule((dt) => {
		receiveElapsed += dt;
		if (receiveElapsed < 0.5) return false;
		receiveElapsed = 0;
		if (
			isActive() &&
			host.visible &&
			!packagePanel &&
			!createOpen &&
			!projectIndexOpen &&
			!preparing &&
			!transitioning &&
			HttpServer.wsConnectionCount === 0
		) {
			if (
				!settingsOpen &&
				entries().length > 0 &&
				!guideShown &&
				!App.reducedMotion &&
				App.runningTime - lastTouchTime > (guidePlayed ? 30 : 2.5)
			) {
				const guide = createGestureGuide(zh);
				guide.order = 500;
				guide.position = Vec2(0, App.safeArea.height * 0.08);
				host.addChild(guide);
				guideShown = true;
				guidePlayed = true;
			}
			const path = options.takeReceivedFile ? options.takeReceivedFile() : App.takeReceivedFile();
			if (path !== "") openPackage("receive", path);
		}
		return false;
	});

	const setTab = (next: FeedTab) => {
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing || transitioning || creating) return;
		userSelectedTab = true;
		returnEntry = undefined;
		if (tab === next) return;
		if (createOpen) {
			blurCreateInput();
			createOpen = false;
			createName = "";
			createError = "";
		}
		const direction = next === "discover" ? 1 : -1;
		const outgoing = App.reducedMotion ? undefined : cardRef.current;
		outgoing?.removeFromParent(false);
		tab = next;
		const target = rememberedEntries[next];
		const location = target === undefined ? undefined : resolveFeedLocation(local, discover, target);
		index = location?.tab === next ? location.index : 0;
		render();
		if (!App.reducedMotion) {
			const incoming = launchRef.current;
			if (incoming)
				incoming.perform(
					Spawn(
						Opacity(0.24, 0, 1),
						Move(0.43, Vec2(incoming.x + direction * 52, incoming.y), incoming.position, Ease.OutBack),
						Scale(0.43, 0.93, 1, Ease.OutBack),
						Angle(0.43, direction * 1.5, 0, Ease.OutCubic),
					),
				);
			infoRef.current?.perform(Spawn(Opacity(0.31, 0, 1), Move(0.31, Vec2(0, -16), Vec2.zero, Ease.OutCubic)));
			swapRef.current?.perform(Angle(0.43, -180, 0, Ease.OutCubic));
			if (outgoing) {
				const ghost = Node();
				ghost.position = Vec2(-App.visualSize.width / 2, -App.visualSize.height / 2);
				const disable = (node: Node.Type) => {
					node.touchEnabled = false;
					node.eachChild((child) => {
						disable(child);
						return false;
					});
				};
				disable(outgoing);
				ghost.addChild(outgoing);
				host.addChild(ghost);
				outgoing.perform(Spawn(Opacity(0.19, outgoing.opacity, 0), Move(0.19, outgoing.position, Vec2(-direction * 48, 0), Ease.OutCubic)));
				thread(() => {
					sleep(0.2);
					if (ghost.parent) ghost.removeFromParent(true);
				});
			}
		}
	};
	const activate = (action: "play" | "remix") => {
		const item = current();
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || item === undefined || preparing || transitioning) return;
		item.launchError = undefined;
		const done = () => {
			returnEntry = item;
			return action === "play" ? onPlay(item) : onRemix(item);
		};
		if (item.kind === "local" || item.installed) {
			done();
			return;
		}
		preparing = true;
		prepareProgress = 0;
		prepareStatus = zh ? "准备安装…" : "Preparing install…";
		render();
		const repairIncomplete = repairResourceId === item.id;
		repairResourceId = "";
		prepare(
			item,
			repairIncomplete,
			(progress, message) => {
				if (!isActive()) return;
				prepareProgress = math.max(0, math.min(1, progress));
				prepareStatus = message;
				render();
			},
			(success, ready, message, repairable) => {
				if (!isActive()) return;
				preparing = false;
				if (!success || !ready) {
					repairResourceId = repairable ? item.id : "";
					prepareStatus = message ?? (zh ? "安装失败，点击按钮重试" : "Install failed; tap to retry");
					render();
					return;
				}
				item.fileName = ready.fileName;
				item.workDir = ready.workDir;
				item.installed = true;
				prepareStatus = "";
				if (HttpServer.wsConnectionCount === 0 && host.visible) done();
				else render();
			},
		);
	};

	const commit = (action: FeedAction) => {
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing || transitioning) return;
		if (action === "play" || action === "remix") {
			const card = cardRef.current;
			if (card) card.position = Vec2.zero;
		}
		switch (action) {
			case "previous":
			case "next": {
				returnEntry = undefined;
				const target = nextFeedIndex(index + (action === "next" ? 1 : -1), entries().length, tab);
				if (target === index && tab === "local") {
					const card = cardRef.current;
					if (card) card.perform(Move(App.reducedMotion ? 0 : 0.16, card.position, Vec2.zero, Ease.OutQuad));
					return;
				}
				const revision = ++transitionRevision;
				const duration = App.reducedMotion ? 0 : 0.32;
				const finish = () => {
					if (!isActive() || revision !== transitionRevision || !host.visible) return;
					index = target;
					transitioning = false;
					App.vibrate(0.012);
					render();
				};
				const card = cardRef.current;
				if (duration > 0 && card) {
					transitioning = true;
					card.perform(Move(duration, card.position, Vec2(0, (action === "next" ? 1 : -1) * App.safeArea.height), Ease.OutCubic));
					thread(() => {
						sleep(duration);
						finish();
					});
				} else finish();
				return;
			}
			case "play": {
				const cartridge = launchRef.current,
					slot = slotRef.current;
				if (!cartridge || App.reducedMotion) {
					activate("play");
					return;
				}
				transitioning = true;
				const revision = ++transitionRevision;
				for (const ref of [infoRef, headerRef, indexRef]) {
					const node = ref.current;
					if (node) node.perform(Opacity(0.16, node.opacity, 0));
				}
				const slotX = App.safeArea.left - 30;
				// Match the material's mouth center, with 18px of cartridge beyond it.
				const seated = Vec2(slotX + 143.5 + 18, cartridge.y);
				if (slot)
					slot.perform(Spawn(Opacity(0.24, slot.opacity, 1), Move(0.24, slot.position, Vec2(slotX, cartridge.y - 140), Ease.OutCubic)));
				cartridge.stopAllActions();
				cartridge.perform(
					Sequence(
						Spawn(
							Move(0.4, cartridge.position, Vec2(seated.x + 9, seated.y), Ease.OutCubic),
							Scale(0.4, cartridge.scaleX, 0.72, Ease.OutCubic),
							Angle(0.4, cartridge.angle, 8, Ease.OutCubic),
							AngleY(0.4, cartridge.angleY, 64, Ease.OutCubic),
						),
						Spawn(
							Move(0.16, Vec2(seated.x + 9, seated.y), seated, Ease.OutCubic),
							Angle(0.16, 8, 0, Ease.OutCubic),
							AngleY(0.16, 64, 68, Ease.OutCubic),
						),
					),
				);
				thread(() => {
					sleep(0.74);
					if (!isActive() || revision !== transitionRevision || !host.visible) return;
					transitioning = false;
					activate("play");
				});
				return;
			}
			case "remix":
				activate("remix");
				return;
			default:
				return;
		}
	};

	const openAgentConfig = () => {
		settingsOpen = false;
		render();
		startMobileLLMManager({
			coveredNode: host,
			selectedId: getMobileLLMSelection(),
			onSelected: () => {},
			onClose: () => {
				if (isActive()) render();
			},
		});
	};
	const switchMode = () => {
		if (
			!isActive() ||
			!host.visible ||
			HttpServer.wsConnectionCount > 0 ||
			preparing ||
			creating ||
			createOpen ||
			packagePanel ||
			transitioning ||
			!options.onSwitchMode
		)
			return;
		leaving = true;
		options.onSwitchMode();
	};
	host.slot("SwitchUIMode", switchMode);
	const render = () => {
		if (!isActive()) return;
		transitionRevision++;
		transitioning = false;
		catalogStatusView = undefined;
		cardRef = reference<Node.Type>();
		launchRef = reference<Node.Type>();
		slotRef = reference<Node.Type>();
		infoRef = reference<Node.Type>();
		indexRef = reference<Node.Type>();
		// Catalog updates must not replace an active IME target or discard its preedit.
		const safeContentWidth = App.safeArea.width - 40;
		const shortLandscapeInputWidth = safeContentWidth - 12 - math.min(300, math.floor(safeContentWidth * 0.42));
		const expectedInputWidth = App.safeArea.width >= 760 && App.safeArea.height < 500 ? shortLandscapeInputWidth : safeContentWidth;
		const keptInput = createOpen && createInputRef.current?.width === expectedInputWidth ? createInputRef.current : undefined;
		const restoreFocus = createInput.isFocused();
		keptInput?.removeFromParent(false);
		if (!keptInput) {
			createInput.unmount();
			createInputRef = reference<Node.Type>();
		}
		const createPanelRef = reference<Node.Type>();
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = App.safeArea;
		const left = safe.left;
		const bottom = safe.bottom;
		const usableWidth = safe.width;
		const usableHeight = safe.height;
		const wide = usableWidth >= 760;
		const compact = !wide && usableHeight < 700;
		const shortLandscape = wide && usableHeight < 500;

		const data = entries();
		index = normalizeFeedIndex(index, data.length);
		const item = current();
		rememberCurrent();
		const horizontal = usableWidth > usableHeight && usableHeight < 600;
		const infoWidth = horizontal ? usableWidth * 0.48 - 32 : math.min(usableWidth - 52, 520);
		const infoHeight = 112;
		const bottomSpace = horizontal ? 28 : math.max(48, math.min(80, usableHeight * 0.09));
		const actionsY = bottom + bottomSpace;
		const infoX = horizontal ? left + usableWidth * 0.52 : left + (usableWidth - infoWidth) / 2;
		const infoTop = horizontal ? bottom + usableHeight / 2 + 38 : actionsY + infoHeight - 24;
		const descriptionY = infoTop - 24;
		const availableHeight = horizontal ? usableHeight - 148 : bottom + usableHeight - 66 - (infoTop + 24);
		const coverScale = math.max(
			0.4,
			math.min(1.278, (horizontal ? usableWidth * 0.46 - 48 : (usableWidth - 52) * 0.9) / 236, ((availableHeight - 48) * 0.9) / 308),
		);
		const coverWidth = 236 * coverScale,
			coverHeight = 308 * coverScale;
		const coverX = horizontal ? left + (usableWidth * 0.48 - coverWidth) / 2 : left + (usableWidth - coverWidth) / 2;
		const coverY = horizontal ? bottom + (usableHeight - coverHeight) / 2 - 8 : infoTop + 24 + (availableHeight - coverHeight) / 2;
		let restCoverY = coverY + coverHeight / 2;
		const gestureHintY = bottom + 18;

		const fontScale = mobileFontScale;
		const pages = visibleFeedPages(index, data.length, tab);
		const headerRenderOrder = 1000;

		const scene = toNode(
			<node
				tag="mobile-feed-scene"
				x={-width / 2}
				y={-height / 2}
				width={width}
				height={height}
				anchorX={0}
				anchorY={0}
				touchEnabled={true}
				onTapBegan={() => {
					if (isMobileLLMOpen() || preparing || transitioning || settingsOpen || projectIndexOpen || createOpen) return;
					cancelGuide();
					drag = Vec2.zero;
					dragAxis = "none";
					dragSampleTime = App.runningTime;
					dragVelocityX = 0;
					cardRef.current?.stopAllActions();
					launchRef.current?.stopAllActions();
					slotRef.current?.stopAllActions();
					dragStartX = (launchRef.current?.x ?? coverX + coverWidth / 2) - coverX - coverWidth / 2;
					dragStartY = cardRef.current?.y ?? 0;
					if (indexRef.current) indexRef.current.opacity = 1;
				}}
				onTapMoved={(touch) => {
					if (isMobileLLMOpen() || preparing || transitioning || settingsOpen || projectIndexOpen || createOpen) return;
					drag = drag.add(touch.delta);
					const elapsed = App.runningTime - dragSampleTime;
					if (elapsed > 0) dragVelocityX = touch.delta.x / (elapsed * 1000);
					dragSampleTime = App.runningTime;
					if (dragAxis === "none" && math.max(math.abs(drag.x), math.abs(drag.y)) >= 12) {
						dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 ? "horizontal" : "vertical";
						if (dragAxis === "horizontal" && infoRef.current) infoRef.current.perform(Opacity(0.16, infoRef.current.opacity, 0.45));
					}
					if (!preparing && !transitioning && cardRef.current) {
						const offset = dragAxis === "vertical" ? Vec2(0, drag.y + dragStartY) : Vec2.zero;
						if (dragAxis === "horizontal" && slotRef.current) {
							const distance = drag.x + dragStartX / 0.3;
							const progress = math.max(0, math.min(1, -distance / 115));
							slotRef.current.opacity = math.min(1, progress * 2);
							slotRef.current.x = left - 220 + progress * 190;
							if (launchRef.current) {
								launchRef.current.x = coverX + coverWidth / 2 + (distance <= 0 ? -math.min(-distance * 0.3, 42) : distance * 0.14);
								launchRef.current.angle = App.reducedMotion ? 0 : progress * 2;
								launchRef.current.angleY = App.reducedMotion ? 0 : progress * 12;
								launchRef.current.scaleX = launchRef.current.scaleY = App.reducedMotion ? 1 : 1 - progress * 0.075;
								slotRef.current.y = launchRef.current.y - 140;
							}
						}
						cardRef.current.position = offset;
					}
				}}
				onTapEnded={() => {
					if (isMobileLLMOpen() || preparing || transitioning || settingsOpen || projectIndexOpen || createOpen) return;
					const isTap = math.abs(drag.x) < 12 && math.abs(drag.y) < 12;
					if (isTap && App.runningTime - lastTapTime < 0.3) {
						lastTapTime = -1;
						commit("remix");
						return;
					}
					lastTapTime = isTap ? App.runningTime : -1;
					const action = resolveFeedGesture(
						dragAxis === "horizontal" ? drag.x : 0,
						dragAxis === "vertical" ? drag.y : 0,
						usableWidth,
						usableHeight,
						false,
						App.runningTime - dragSampleTime < 0.08 ? dragVelocityX : 0,
					);
					drag = Vec2.zero;
					dragAxis = "none";
					if (indexRef.current) indexRef.current.opacity = 1;
					if (action !== "play") {
						const duration = App.reducedMotion ? 0 : 0.23;
						const slot = slotRef.current,
							launch = launchRef.current,
							info = infoRef.current;
						if (slot)
							slot.perform(
								Spawn(Opacity(duration, slot.opacity, 0), Move(duration, slot.position, Vec2(left - 220, slot.y), Ease.OutCubic)),
							);
						if (launch)
							launch.perform(
								Spawn(
									Move(duration, launch.position, Vec2(coverX + coverWidth / 2, restCoverY), Ease.OutCubic),
									Angle(duration, launch.angle, 0, Ease.OutCubic),
									Scale(duration, launch.scaleX, 1, Ease.OutCubic),
									AngleY(duration, launch.angleY, 0, Ease.OutCubic),
								),
							);
						if (info) info.perform(Opacity(duration, info.opacity, 1));
					}
					if (action === "none" && cardRef.current) {
						const card = cardRef.current;
						card.perform(Move(App.reducedMotion ? 0 : 0.16, card.position, Vec2.zero, Ease.OutQuad));
					}
					commit(action);
				}}
				onMouseWheel={(delta) => {
					cancelGuide();
					commit(delta.y > 0 ? "previous" : "next");
				}}
			>
				<VerticalGradient width={width} height={height} topColor={goTheme.backgroundTop} bottomColor={goTheme.background} />
				<node order={1} tag="mobile-feed-slot" ref={slotRef} x={left - 220} y={coverY + (coverHeight - 280) / 2} opacity={0}>
					<CartridgeSlot x={0} y={0} />
				</node>
				<node visible={!projectIndexOpen} order={2}>
					<node
						order={100}
						width={width}
						height={height}
						anchorX={0}
						anchorY={0}
						touchEnabled={true}
						swallowTouches={false}
						onTapFilter={(touch) => {
							touch.enabled = false;
							cancelGuide();
						}}
					/>
					{createOpen ? undefined : item !== undefined ? (
						<clip-node
							width={width}
							height={height}
							anchorX={0}
							anchorY={0}
							stencil={<RoundedStencil width={width} height={bottom + usableHeight - 76} radius={0} />}
						>
							<node tag={`mobile-feed-card-${item.id}`} ref={cardRef} key={`${tab}-${item.id}`}>
								{pages.map((page) => {
									const entry = data[page.index],
										activePage = page.offset === 0;
									const displayTitle = projectDisplayName(entry.workDir, entry.title);
									const authorRef = reference<Node.Type>();
									return (
										<node y={-page.offset * usableHeight}>
											<node
												tag={activePage ? "mobile-feed-cartridge" : undefined}
												ref={activePage ? launchRef : undefined}
												x={coverX + coverWidth / 2}
												y={coverY + coverHeight / 2}
												width={coverWidth}
												height={coverHeight}
												anchorX={0.5}
												anchorY={0.5}
											>
												<Cartridge entry={entry} x={0} y={0} width={coverWidth} height={coverHeight} />
											</node>
											{tab === "local" ? (
												<node
													tag={activePage ? "mobile-feed-index" : undefined}
													ref={activePage ? indexRef : undefined}
													x={coverX + coverWidth / 2 - 40}
													y={horizontal ? coverY - 26 : infoTop + 28}
													width={80}
													height={24}
													anchorX={0}
													anchorY={0}
													touchEnabled={activePage}
													swallowTouches={true}
													onMount={pressFeedback}
													onTapped={openProjectIndex}
												>
													<label
														x={40}
														y={12}
														fontName={fontName}
														fontSize={10}
														text={`${page.index + 1 < 10 ? "0" : ""}${page.index + 1}  /  ${data.length < 10 ? "0" : ""}${data.length}`}
														color3={0x7b7d70}
													/>
												</node>
											) : undefined}
											<node ref={activePage ? infoRef : undefined}>
												<label
													tag={activePage ? "mobile-feed-current-title" : undefined}
													x={infoX}
													y={infoTop}
													anchorX={0}
													fontName={goTheme.headingFont}
													fontSize={math.floor((compact ? 22 : 25) * fontScale)}
													text={conciseDescription(displayTitle, math.floor(infoWidth / 24))}
													textWidth={-1}
													color3={0x30352b}
													alignment={TextAlign.Left}
												/>
												<Description
													text={entry.description ?? ""}
													x={infoX}
													y={descriptionY}
													width={infoWidth}
													active={activePage}
													onExpand={(expanded, extraHeight) => {
														if (!activePage) return;
														const offset = expanded ? extraHeight : 0,
															duration = App.reducedMotion ? 0 : 0.26;
														const info = infoRef.current,
															author = authorRef.current,
															count = indexRef.current,
															cart = launchRef.current;
														if (info) info.perform(Move(duration, info.position, Vec2(0, offset), Ease.OutCubic));
														if (author)
															author.perform(
																Move(
																	duration,
																	author.position,
																	Vec2(infoX, (horizontal ? infoTop - 110 : actionsY) - offset),
																	Ease.OutCubic,
																),
															);
														if (!horizontal) {
															restCoverY = coverY + coverHeight / 2 + offset;
															if (cart) cart.perform(Move(duration, cart.position, Vec2(cart.x, restCoverY), Ease.OutCubic));
															if (count) count.perform(Move(duration, count.position, Vec2(count.x, infoTop + 28 + offset), Ease.OutCubic));
														}
													}}
												/>
												<node ref={authorRef} x={infoX} y={horizontal ? infoTop - 110 : actionsY}>
													<draw-node visible={entry.kind === "local" || entry.author !== undefined} x={13} y={16}>
														<dot-shape radius={13} color={entry.kind === "local" ? 0xff42a79e : 0xffdfaa70} />
													</draw-node>
													<label
														visible={entry.kind === "local" || entry.author !== undefined}
														x={13}
														y={16}
														fontName={fontName}
														fontSize={11}
														text={entry.kind === "local" ? (zh ? "我" : "Me") : "D"}
														color3={0xffffff}
													/>
													<label
														x={36}
														y={16}
														anchorX={0}
														fontName={fontName}
														fontSize={12}
														text={entry.author ?? (entry.kind === "local" ? (zh ? "我" : "Me") : "")}
														color3={0x30352b}
														alignment={TextAlign.Left}
													/>
													<MobileButton
														tag={activePage ? "mobile-feed-remix" : undefined}
														x={infoWidth - 76}
														y={0}
														width={76}
														height={32}
														fontSize={12}
														icon={entry.kind === "local" ? "code" : "remix"}
														text={entry.kind === "local" ? (zh ? "开发" : "Edit") : "Remix"}
														disabled={!activePage || preparing || transitioning}
														onTapped={() => activate("remix")}
													/>
												</node>
											</node>
										</node>
									);
								})}
								{prepareStatus !== "" || item.launchError || gamepadUsed ? (
									<label
										x={infoX}
										y={gestureHintY}
										anchorX={0}
										fontName={fontName}
										fontSize={11}
										text={
											item.launchError ??
											(prepareStatus !== ""
												? prepareStatus
												: zh
													? "↑↓ 浏览 · A 进入 · X 开发 · Start 列表"
													: "↑↓ Browse · A Play · X Develop · Start List")
										}
										textWidth={infoWidth}
										alignment={TextAlign.Left}
										color3={0x7c826f}
									/>
								) : undefined}
							</node>
						</clip-node>
					) : (
						<node>
							<label
								x={left + usableWidth / 2}
								y={bottom + usableHeight / 2 + 20}
								fontName={fontName}
								fontSize={22}
								text={
									tab === "discover"
										? zh
											? "暂无移动作品"
											: "No mobile games yet"
										: zh
											? "没有可运行的本地作品"
											: "No runnable local games"
								}
								color3={0x30352b}
							/>
							<label
								x={left + usableWidth / 2}
								y={bottom + usableHeight / 2 - 28}
								fontName={fontName}
								fontSize={14}
								text={tab === "discover" && discoverError !== "" ? discoverError : zh ? "切换标签或稍后重试" : "Switch tabs or retry later"}
								textWidth={usableWidth - 48}
								color3={tab === "discover" && discoverError !== "" ? 0xff6b6b : 0x7c826f}
							/>
						</node>
					)}
					{!createOpen && item === undefined && tab === "local" ? (
						<node>
							<MobileButton
								tag="mobile-empty-new"
								x={left + 20}
								y={bottom + 24}
								width={(usableWidth - 52) / 2}
								text={zh ? "新建作品" : "New game"}
								onTapped={createBlank}
							/>
							<MobileButton
								tag="mobile-empty-import"
								x={left + 32 + (usableWidth - 52) / 2}
								y={bottom + 24}
								width={(usableWidth - 52) / 2}
								text={zh ? "导入作品包" : "Import package"}
								fontSize={15}
								primary={true}
								onTapped={() => openPackage("add", undefined, true)}
							/>
						</node>
					) : undefined}
					{item === undefined && tab === "discover" && syncDiscover ? (
						<MobileButton
							tag="mobile-feed-empty-index"
							x={left + (usableWidth - 160) / 2}
							y={bottom + 24}
							width={160}
							text={zh ? "作品目录" : "Game index"}
							onTapped={openProjectIndex}
						/>
					) : undefined}
					<node tag="mobile-feed-header" ref={headerRef} order={headerRenderOrder}>
						<RoundedSurface
							x={0}
							y={bottom + usableHeight - 76}
							width={width}
							height={height - bottom - usableHeight + 76}
							radius={0}
							fillColor={goTheme.backgroundTop}
						/>
						{settingsOpen ? (
							<node
								width={width}
								height={height}
								anchorX={0}
								anchorY={0}
								touchEnabled={true}
								swallowTouches={true}
								onTapped={closeSettings}
							/>
						) : undefined}
						<node
							tag="mobile-feed-scene-toggle"
							x={left + 20}
							y={bottom + usableHeight - 58}
							width={140}
							height={40}
							anchorX={0}
							anchorY={0}
							touchEnabled={!preparing && !transitioning}
							swallowTouches={true}
							onMount={pressFeedback}
							onTapped={() => {
								local = getLocalEntries();
								setTab(tab === "local" ? "discover" : "local");
							}}
						>
							<node ref={swapRef} x={8} y={20}>
								<GoIcon name="swap" x={-8} y={-8} size={16} color={0xffb69427} />
							</node>
							<label
								x={27}
								y={20}
								anchorX={0}
								fontName={goTheme.headingFont}
								fontSize={17}
								text={tab === "local" ? (zh ? "本地" : "Local") : zh ? "发现" : "Discover"}
								color3={0x30352b}
								alignment={TextAlign.Left}
							/>
							<label
								x={zh ? 76 : 104}
								y={20}
								anchorX={0}
								fontName={fontName}
								fontSize={11}
								text={tab === "local" ? (zh ? "发现" : "Discover") : zh ? "本地" : "Local"}
								color3={0x8b927e}
								alignment={TextAlign.Left}
							/>
						</node>
						{options.createProject ? (
							<MobileNewButton
								tag="mobile-feed-create"
								x={left + usableWidth - 140}
								y={bottom + usableHeight - 54}
								text={zh ? "制造" : "Create"}
								onTapped={createBlank}
							/>
						) : undefined}
						<node
							onMount={pressFeedback}
							tag="mobile-feed-settings"
							x={left + usableWidth - 52}
							y={bottom + usableHeight - 56}
							width={36}
							height={36}
							anchorX={0}
							anchorY={0}
							touchEnabled={!preparing && !transitioning}
							swallowTouches={true}
							onTapped={() => {
								cancelGuide();
								if (settingsOpen) closeSettings();
								else {
									settingsOpen = true;
									render();
								}
							}}
						>
							<node
								ref={gearRef}
								x={18}
								y={18}
								onMount={(node) => {
									if (settingsOpen && !App.reducedMotion) node.perform(Angle(0.36, 0, 65, Ease.OutCubic));
								}}
							>
								<GoIcon name="settings" x={-10} y={-10} size={20} />
							</node>
						</node>
						{settingsOpen ? (
							<node
								ref={menuRef}
								tag="mobile-feed-settings-menu"
								x={left + usableWidth - 20}
								y={bottom + usableHeight - 64}
								width={174}
								height={102}
								anchorX={1}
								anchorY={1}
								onMount={(node) =>
									node.perform(
										Spawn(
											Opacity(App.reducedMotion ? 0 : 0.2, 0, 1),
											Scale(App.reducedMotion ? 0 : 0.29, App.reducedMotion ? 1 : 0.86, 1, Ease.OutBack),
										),
									)
								}
							>
								<RoundedSurface
									width={174}
									height={102}
									radius={12}
									fillColor={0xfffcfcf8}
									borderWidth={0.7}
									borderColor={0xffd2d3c7}
									shadow={true}
								/>
								<node
									tag="mobile-agent-config"
									x={6}
									y={54}
									width={162}
									height={42}
									anchorX={0}
									anchorY={0}
									touchEnabled={true}
									swallowTouches={true}
									onMount={pressFeedback}
									onTapped={openAgentConfig}
								>
									<GoIcon name="settings" x={10} y={12} size={18} />
									<label
										x={38}
										y={21}
										anchorX={0}
										fontName={fontName}
										fontSize={13}
										text={zh ? "Agent 配置" : "Agent settings"}
										color3={0x30352b}
										alignment={TextAlign.Left}
									/>
								</node>
								<node
									tag="mobile-ui-mode-switch"
									x={6}
									y={6}
									width={162}
									height={42}
									anchorX={0}
									anchorY={0}
									touchEnabled={true}
									swallowTouches={true}
									onMount={pressFeedback}
									onTapped={switchMode}
								>
									<GoIcon name="exit" x={10} y={12} size={18} color={0xff747b68} />
									<label
										x={38}
										y={21}
										anchorX={0}
										fontName={fontName}
										fontSize={13}
										text={zh ? "退出 Go 模式" : "Exit Go mode"}
										color3={0x30352b}
										alignment={TextAlign.Left}
									/>
								</node>
							</node>
						) : undefined}
					</node>

					{preparing ? (
						<node
							tag="mobile-feed-loading"
							order={2000}
							width={width}
							height={height}
							anchorX={0}
							anchorY={0}
							touchEnabled={true}
							swallowTouches={true}
						>
							<RoundedSurface width={width} height={height} radius={0} fillColor={goTheme.background} />
							<DoraMascot x={width / 2} y={height / 2 + 64} size={58} state="idle" />
							<label
								x={width / 2}
								y={height / 2 + 12}
								fontName={fontName}
								fontSize={16}
								text={zh ? "正在准备游戏" : "Preparing game"}
								color3={0x30352b}
							/>
							<RoundedSurface x={width / 2 - 100} y={height / 2 - 24} width={200} height={5} radius={2.5} fillColor={goTheme.border} />
							{prepareProgress > 0 ? (
								<RoundedSurface
									x={width / 2 - 100}
									y={height / 2 - 24}
									width={200 * prepareProgress}
									height={5}
									radius={2.5}
									fillColor={goTheme.brand}
								/>
							) : undefined}
							<label
								x={width / 2}
								y={height / 2 - 55}
								fontName={fontName}
								fontSize={12}
								text={`${math.floor(prepareProgress * 100)}% · ${prepareStatus}`}
								textWidth={usableWidth - 64}
								color3={0x7c826f}
							/>
						</node>
					) : undefined}
					{createOpen
						? (() => {
								const sheetHeight = math.min(createSheetHeight, usableHeight - 64);
								const sheetWidth = usableWidth;
								const contentWidth = sheetWidth - 40;
								const actionGap = 12;
								const actionsWidth = shortLandscape ? math.min(300, math.floor(contentWidth * 0.42)) : contentWidth;
								const inputWidth = shortLandscape ? contentWidth - actionGap - actionsWidth : contentWidth;
								const actionX = shortLandscape ? 20 + inputWidth + actionGap : 20;
								const actionY = shortLandscape ? sheetHeight - createInputTop - createInputHeight : 20;
								const cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape ? 0.34 : 0.38));
								return (
									<node
										tag="mobile-project-create-sheet"
										order={10000}
										width={width}
										height={height}
										anchorX={0}
										anchorY={0}
										touchEnabled={true}
										swallowTouches={true}
									>
										<node
											tag="mobile-project-create-focus-observer"
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
												if (!canEditCreate()) return;
												const input = createInputRef.current;
												const point = input?.convertToNodeSpace(touch.worldLocation);
												const inside = input && point && point.x >= 0 && point.y >= 0 && point.x <= input.width && point.y <= input.height;
												dismissedCreateComposition = !inside && createInput.isComposing();
												if (!inside) blurCreateInput();
											}}
										/>
										<draw-node
											tag="mobile-project-create-backdrop"
											order={0}
											renderOrder={0}
											x={width / 2}
											y={bottom + sheetHeight + (height - bottom - sheetHeight) / 2}
										>
											<rect-shape width={width} height={height - bottom - sheetHeight} fillColor={0x8c000000} />
										</draw-node>
										<node
											ref={createPanelRef}
											order={10}
											renderOrder={10}
											x={left}
											y={bottom}
											width={sheetWidth}
											height={sheetHeight}
											anchorX={0}
											anchorY={0}
											touchEnabled={true}
											swallowTouches={true}
										>
											<MobilePanelSurface width={sheetWidth} height={sheetHeight} renderOrder={10} />
											<label
												x={20}
												y={sheetHeight - 24}
												anchorX={0}
												anchorY={1}
												fontName={fontName}
												fontSize={22}
												text={zh ? "新建项目" : "New project"}
												color3={0x30352b}
												alignment={TextAlign.Left}
											/>
											{(["typescript", "lua"] as MobileProjectLanguage[]).map((language, i) => (
												<MobileChoiceButton
													tag={`mobile-project-create-language-${language}`}
													x={20 + i * 144}
													y={sheetHeight - 98}
													width={language === "lua" ? 84 : 132}
													text={language === "lua" ? "Lua" : "TypeScript"}
													selected={createLanguage === language}
													renderOrder={10}
													onTapped={() => {
														if (!canEditCreate()) return;
														blurCreateInput();
														createLanguage = language;
														render();
													}}
												/>
											))}
											<label
												x={20}
												y={sheetHeight - 110}
												anchorX={0}
												anchorY={1}
												fontName={fontName}
												fontSize={14}
												text={zh ? "项目名称" : "Project name"}
												color3={0x7c826f}
												alignment={TextAlign.Left}
											/>
											{keptInput ? undefined : (
												<node
													tag="mobile-project-create-input"
													ref={createInputRef}
													renderOrder={10}
													x={20}
													y={sheetHeight - createInputTop - createInputHeight}
													width={inputWidth}
													height={createInputHeight}
													anchorX={0}
													anchorY={0}
													onMount={createInput.mount}
												/>
											)}
											<label
												tag="mobile-project-create-error"
												x={20}
												y={shortLandscape ? sheetHeight - createInputTop + 12 : sheetHeight - createInputTop - createInputHeight - 12}
												anchorX={0}
												anchorY={1}
												fontName={fontName}
												fontSize={12}
												text={
													createError !== ""
														? createError
														: zh
															? `将创建可运行的 ${createLanguage === "lua" ? "Lua" : "TypeScript"} 起始项目`
															: `Creates a runnable ${createLanguage === "lua" ? "Lua" : "TypeScript"} starter project`
												}
												textWidth={inputWidth}
												alignment={TextAlign.Left}
												color3={createError !== "" ? 0xff6b6b : 0x7c826f}
											/>
											<MobileButton
												tag="mobile-project-create-cancel"
												x={actionX}
												y={actionY}
												width={cancelWidth}
												text={zh ? "取消" : "Cancel"}
												renderOrder={10}
												onTapped={closeCreate}
											/>
											<MobileButton
												tag="mobile-project-create-submit"
												x={actionX + cancelWidth + actionGap}
												y={actionY}
												width={actionsWidth - cancelWidth - actionGap}
												text={creating ? (zh ? "创建中…" : "Creating…") : zh ? "创建并进入 Remix" : "Create and Remix"}
												primary={true}
												renderOrder={10}
												onTapped={() => {
													if (!dismissedCreateComposition) submitCreate();
													dismissedCreateComposition = false;
												}}
											/>
										</node>
									</node>
								);
							})()
						: undefined}
				</node>
				{projectIndexOpen ? (
					<ProjectIndex
						entries={entries()}
						kind={tab}
						current={current()}
						x={left}
						y={bottom}
						width={usableWidth}
						height={usableHeight}
						zh={zh}
						refreshing={catalogSyncing}
						refreshStatus={catalogStatus}
						onRefresh={syncDiscover ? () => refreshDiscover(true) : undefined}
						onStatusReady={(update) => {
							catalogStatusView = update;
						}}
						onClose={() => {
							projectIndexOpen = false;
							render();
						}}
						onSelect={(entry) => {
							projectIndexOpen = false;
							const location = resolveFeedLocation(local, discover, entry);
							tab = location.tab;
							index = location.index;
							render();
						}}
					/>
				) : undefined}
			</node>,
		);
		if (scene !== undefined) host.addChild(scene);
		if (keptInput && createPanelRef.current) {
			keptInput.position = Vec2(20, math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight);
			createPanelRef.current.addChild(keptInput);
		}
		createInput.refresh();
		if (restoreFocus && !keptInput && createOpen) createInput.focus(false);
	};

	attachGamepad(host, {
		initialTag: "mobile-feed-remix",
		isEnabled: () => isActive() && !packagePanel && !preparing && !transitioning && !creating,
		onActive: () => {
			gamepadUsed = true;
			render();
		},
		onBack: () => {
			if (createInput.isFocused()) blurCreateInput();
			else if (createOpen) closeCreate();
			else if (settingsOpen) {
				settingsOpen = false;
				render();
			} else switchMode();
		},
		onActivate: (target) => {
			if (target.tag === "mobile-project-create-input") target.emit("GamepadActivate");
			else {
				if (createInput.isComposing()) {
					blurCreateInput();
					return;
				}
				blurCreateInput();
				dismissedCreateComposition = false;
				target.emit("Tapped");
			}
		},
		onButton: (button) => {
			if (createOpen || projectIndexOpen || settingsOpen) return false;
			switch (button) {
				case "dpup":
					commit("previous");
					return true;
				case "dpdown":
					commit("next");
					return true;
				case "leftshoulder":
					setTab("discover");
					return true;
				case "rightshoulder":
					setTab("local");
					return true;
				case "a":
					commit("play");
					return true;
				case "x":
					commit("remix");
					return true;
				case "y":
					findGamepadNode(host, "mobile-feed-create")?.emit("Tapped");
					return true;
				case "start":
					openProjectIndex();
					return true;
				default:
					return false;
			}
		},
	});
	host.onAppChange((setting) => {
		if (setting === "Locale") {
			const activeEntry = current();
			zh = string.match(App.locale, "^zh")[0] !== undefined;
			local = getLocalEntries();
			discover = getDiscoverEntries();
			const location = resolveFeedLocation(local, discover, activeEntry);
			tab = location.tab;
			index = location.index;
			render();
		} else if (setting === "Size") render();
	});
	host.onAppEvent((event) => {
		if (event === "BackButton") {
			if (settingsOpen) {
				settingsOpen = false;
				render();
			} else if (projectIndexOpen) {
				projectIndexOpen = false;
				render();
			} else if (createOpen && !creating) closeCreate();
		} else if (event === "WillEnterBackground" || event === "DidEnterBackground") blurCreateInput();
	});
	host.onCleanup(() => {
		blurCreateInput();
		active = false;
		packagePanel?.removeFromParent(true);
		packagePanel = undefined;
	});
	host.slot("RestoreFeedEntry", (entry: FeedEntry) => {
		if (!isActive() || HttpServer.wsConnectionCount > 0) return;
		returnEntry = entry;
		local = getLocalEntries();
		discover = getDiscoverEntries();
		const location = resolveFeedLocation(local, discover, entry);
		tab = location.tab;
		index = location.index;
		render();
	});
	host.slot("SuspendLocalUI", () => {
		if (packagePanel) packagePanel.visible = false;
		blurCreateInput();
		cancelGuide();
		transitionRevision++;
		transitioning = false;
	});
	host.slot("ResumeLocalUI", () => {
		if (packagePanel) packagePanel.visible = host.visible;
		leaving = false;
		render();
	});
	const refreshDiscover = (force: boolean) => {
		if (!syncDiscover || catalogSyncing || !isActive()) return;
		catalogSyncing = true;
		catalogStatus = zh ? "正在同步资源目录…" : "Syncing Catalog…";
		if (discover.length === 0) {
			discoverError = catalogStatus;
		}
		render();
		syncDiscover(
			(message) => {
				if (!isActive()) return;
				catalogStatus = message;
				catalogStatusView?.(message);
				if (projectIndexOpen || discover.length > 0) return;
				discoverError = message;
				render();
			},
			(success, message) => {
				if (!isActive()) return;
				catalogSyncing = false;
				catalogStatus = success
					? zh
						? "目录已更新"
						: "Catalog updated"
					: (zh ? "刷新失败：" : "Refresh failed: ") + (message ?? (zh ? "请重试" : "Try again"));
				const selected = force ? current() : (returnEntry ?? rememberedEntries[tab] ?? current());
				const previousCount = discover.length;
				discover = getDiscoverEntries();
				discoverError = success
					? discover.length === 0
						? zh
							? "目录中暂无可运行作品"
							: "No runnable Catalog games"
						: ""
					: (message ?? (zh ? "资源目录同步失败" : "Catalog sync failed"));
				// A catalog refresh updates the current list; it must not navigate to
				// Local when the old Discover entry disappeared or matches an installed copy.
				if (!force && !projectIndexOpen)
					tab = resolveDiscoverRefreshTab(tab, userSelectedTab, previousCount, discover.length, local.length);
				if (selected !== undefined) {
					const location = resolveFeedLocation(local, discover, selected);
					if (location.tab === tab) index = location.index;
				}
				index = normalizeFeedIndex(index, entries().length);
				render();
			},
			force,
		);
	};
	render();
	refreshDiscover(false);
	return host;
}
