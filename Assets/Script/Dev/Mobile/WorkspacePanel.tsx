import { build } from "Agent/Tool/Build";
import { GoIcon } from "Dev/Mobile/Visual";
import { pressFeedback } from "Dev/Mobile/Motion";
import { React, toNode } from "DoraX";
import {
	App,
	Color3,
	Content,
	HttpServer,
	Director,
	Ease,
	Label,
	Move,
	Node,
	Path,
	TextAlign,
	Vec2,
	sleep,
	thread,
	Spawn,
	Opacity,
} from "Dora";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import type { AgentSessionDetailResult } from "Agent/Session";
import { applyFileChanges, createTask, getTaskChangeSetDiff, rollbackTaskChangeSet, setTaskStatus } from "Agent/Tool/Checkpoint";
import { resolveWorkspaceFilePath } from "Agent/Tool/Workspace";
import { MobileButton, MobilePanelSurface } from "Dev/Mobile/Controls";
import { SceneSurface } from "Dev/Mobile/Visual";
import { createTextInput } from "Dev/Mobile/TextInput";
import { saveProjectDisplayName } from "Dev/Mobile/ProjectPresentation";
import { goTheme } from "Dev/Mobile/Theme";

export interface WorkspaceState {
	drafts: Record<string, string>;
	bases: Record<string, string>;
	manualTaskId: number;
	buildFailed?: boolean;
	agentTaskAtEdit: number;
}

type Panel = "files" | "changes" | "logs" | "settings" | "code" | "rename" | "rollback";
export function startWorkspacePanel(options: {
	state: WorkspaceState;
	panel: Panel;
	entry: { title: string; workDir?: string };
	getDetail(this: void): AgentSessionDetailResult;
	isBusy(this: void): boolean;
	onModel(this: void): void;
	onExport(this: void): void;
	onChanged(this: void, message?: string): void;
	onClose(this: void): void;
}) {
	const host = Node();
	host.tag = "go-workspace-panel";
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI, 2000);
	const zh = string.match(App.locale, "^zh")[0] !== undefined;
	let panel = options.panel,
		path = "",
		draft = options.panel === "rename" ? options.entry.title : "",
		notice = "",
		disposed = false,
		closing = false,
		saving = false,
		conflict = false;
	const busy = () => saving || options.isBusy() || HttpServer.wsConnectionCount > 0;
	const { drafts, bases } = options.state;
	const editor = createTextInput({
		fontSize: 13,
		fontName: options.panel === "rename" ? goTheme.font : goTheme.monoFont,
		singleLine: options.panel === "rename",
		getText: () => draft,
		setText: (text) => {
			draft = text;
			if (panel === "code") drafts[path] = text;
		},
		getPlaceholder: () => "",
		isEnabled: () => !disposed && !closing && !busy() && host.visible,
	});
	const close = () => {
		if (closing || disposed || saving) return;
		closing = true;
		editor.blur();
		host.stopAllActions();
		host.perform(
			Spawn(
				Opacity(0.18, host.opacity, 0),
				Move(App.reducedMotion ? 0 : 0.18, host.position, App.reducedMotion ? Vec2.zero : Vec2(0, -36), Ease.OutCubic),
			),
		);
		thread(() => {
			sleep(App.reducedMotion ? 0 : 0.18);
			if (!disposed) {
				host.removeFromParent(true);
				options.onClose();
			}
		});
	};
	const switchTo = (next: Panel) => {
		editor.blur();
		editor.unmount();
		panel = next;
		notice = "";
		conflict = false;
		render();
	};
	const agentTaskId = () => {
		const detail = options.getDetail();
		return detail.success ? (detail.session.currentTaskId ?? 0) : 0;
	};
	const taskId = () =>
		options.state.manualTaskId > 0 && agentTaskId() === options.state.agentTaskAtEdit ? options.state.manualTaskId : agentTaskId();
	const workspace = options.entry.workDir ?? "";
	const save = async () => {
		if (busy() || editor.isComposing()) return;
		if (panel === "rename") {
			const title = string.match(string.gsub(draft, "[%c]+", " ")[0], "^%s*(.-)%s*$")[0] ?? "";
			if (title === "") {
				notice = zh ? "请输入项目名称" : "Enter a project name";
				render();
				return;
			}
			if (workspace === "" || saveProjectDisplayName(workspace, title)) {
				options.entry.title = title;
				options.onChanged();
				if (options.panel === "rename") close();
				else switchTo("settings");
			} else {
				notice = zh ? "保存名称失败" : "Could not save name";
				render();
			}
			return;
		}
		const fullPath = resolveWorkspaceFilePath(workspace, path);
		if (!fullPath) return;
		if (Content.load(fullPath) !== bases[path]) {
			conflict = true;
			notice = zh ? "磁盘文件已更新。保留草稿，或载入磁盘版本。" : "File changed. Keep this draft or reload from disk.";
			render();
			return;
		}
		const created = createTask(zh ? "手动编辑项目文件" : "Edit project file");
		if (!created.success) {
			notice = created.message;
			render();
			return;
		}
		const result = applyFileChanges(created.taskId, workspace, [{ path, op: "write", content: draft }], { summary: "Go editor" });
		setTaskStatus(created.taskId, result.success ? "DONE" : "FAILED");
		if (!result.success) {
			notice = result.message;
			render();
			return;
		}
		options.state.manualTaskId = created.taskId;
		options.state.agentTaskAtEdit = agentTaskId();
		bases[path] = draft;
		delete drafts[path];
		saving = true;
		notice = zh ? "正在检查并构建…" : "Checking and building…";
		render();
		const compiled = ["ts", "tsx", "lua", "yue", "tl", "xml", "yarn"].indexOf(Path.getExt(path)) >= 0;
		try {
			const checked = compiled ? await build({ workDir: workspace, path, isCancelled: () => disposed }) : { success: true, message: "" };
			if (disposed) return;
			options.state.buildFailed = !checked.success;
			notice = checked.success ? (zh ? "已保存" : "Saved") : (zh ? "已保存，构建失败：" : "Saved; build failed: ") + checked.message;
			options.onChanged(checked.success ? undefined : notice);
		} catch (e) {
			if (!disposed) {
				options.state.buildFailed = true;
				notice = tostring(e);
				options.onChanged(notice);
			}
		}
		saving = false;
		if (!disposed) render();
	};
	const files = () => {
		const result: string[] = [];
		const visit = (folder: string, depth: number) => {
			if (depth > 8 || result.length >= 250) return;
			for (const file of Content.getFiles(Path(workspace, folder))) {
				if (result.length >= 250) break;
				if (["ts", "tsx", "lua", "yue", "json", "md", "txt", "tl", "xml", "wa"].indexOf(Path.getExt(file)) >= 0)
					result.push(folder === "" ? file : folder + "/" + file);
			}
			for (const dir of Content.getDirs(Path(workspace, folder)))
				if (dir.charAt(0) !== "." && dir !== "node_modules" && dir !== "build") visit(folder === "" ? dir : folder + "/" + dir, depth + 1);
		};
		if (workspace !== "" && Content.isdir(workspace)) visit("", 0);
		return result;
	};
	const render = () => {
		if (disposed) return;
		const focused = editor.isFocused();
		editor.unmount();
		host.removeAllChildren();
		const safe = App.safeArea,
			{ width, height } = App.visualSize,
			w = math.min(safe.width, 620),
			h = math.min(safe.height - 20, panel === "rename" ? 208 : panel === "settings" ? 260 : safe.height * 0.82);
		const left = safe.left + (safe.width - w) / 2,
			bottom = safe.bottom;
		const title =
			panel === "code"
				? path
				: zh
					? {
							files: "项目文件",
							changes: "修改记录",
							logs: "运行日志",
							settings: "项目设置",
							rename: "项目名称",
							rollback: "回退本轮修改",
						}[panel]
					: panel;
		const shell = toNode(
			<node x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
				<node width={width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={close}>
					<draw-node x={width / 2} y={height / 2}>
						<rect-shape width={width} height={height} fillColor={0x66515a45} />
					</draw-node>
				</node>
				<node
					tag="workspace-sheet"
					x={left}
					y={bottom}
					width={w}
					height={h}
					anchorX={0}
					anchorY={0}
					touchEnabled={true}
					swallowTouches={true}
				>
					<MobilePanelSurface width={w} height={h} />
					<SceneSurface x={w / 2 - 17} y={h - 10} width={34} height={3} radius={1.5} fillColor={goTheme.border} />
					<label
						x={22}
						y={h - 36}
						anchorX={0}
						fontName={goTheme.font}
						fontSize={16}
						text={title}
						textWidth={w - 85}
						alignment={TextAlign.Left}
						color3={0x30352b}
					/>
					<node
						x={w - 54}
						y={h - 54}
						width={36}
						height={36}
						anchorX={0}
						anchorY={0}
						touchEnabled={true}
						swallowTouches={true}
						onMount={pressFeedback}
						onTapped={close}
					>
						<GoIcon name="close" x={9} y={9} size={18} />
					</node>
				</node>
			</node>,
		)!;
		host.addChild(shell);
		const sheet = shell.getChildByTag("workspace-sheet")!;
		const add = (node: Node.Type | undefined) => {
			if (node) sheet.addChild(node);
		};
		if (panel === "code" || panel === "rename") {
			const area = Node();
			area.tag = "workspace-editor";
			area.anchor = Vec2.zero;
			area.position = Vec2(20, 80);
			area.width = w - 40;
			area.height = panel === "rename" ? 48 : h - 155;
			sheet.addChild(area);
			editor.mount(area);
			add(
				toNode(
					<MobileButton
						tag="workspace-save"
						x={w - 110}
						y={24}
						width={90}
						height={36}
						text={saving ? (zh ? "构建中" : "Building") : zh ? "保存" : "Save"}
						primary={true}
						disabled={busy()}
						onTapped={() => {
							void save();
						}}
					/>,
				),
			);
			add(
				toNode(
					<MobileButton
						tag="workspace-editor-back"
						x={20}
						y={24}
						width={76}
						height={36}
						text={options.panel === "rename" ? (zh ? "取消" : "Cancel") : zh ? "返回" : "Back"}
						disabled={saving}
						onTapped={() => (options.panel === "rename" ? close() : switchTo(panel === "rename" ? "settings" : "files"))}
					/>,
				),
			);
		} else if (panel === "settings") {
			const labels = zh ? ["项目名称", "模型配置", "导出项目快照"] : ["Project name", "Model", "Export project"];
			labels.slice(0, workspace === "" ? 2 : 3).forEach((text, i) =>
				add(
					toNode(
						<node
							onMount={pressFeedback}
							tag={`workspace-setting-${i}`}
							x={20}
							y={h - 115 - i * 52}
							width={w - 40}
							height={44}
							anchorX={0}
							anchorY={0}
							touchEnabled={true}
							swallowTouches={true}
							onTapped={() => {
								if (i === 0) {
									draft = options.entry.title;
									switchTo("rename");
								} else {
									close();
									thread(() => {
										sleep(0.2);
										if (i === 1) options.onModel();
										else options.onExport();
									});
								}
							}}
						>
							<label
								x={0}
								y={22}
								anchorX={0}
								fontName={goTheme.font}
								fontSize={13}
								text={text}
								color3={0x5f6a40}
								alignment={TextAlign.Left}
							/>
						</node>,
					),
				),
			);
		} else if (panel === "rollback") {
			add(
				toNode(
					<label
						x={22}
						y={h - 98}
						anchorX={0}
						anchorY={1}
						fontName={goTheme.font}
						fontSize={14}
						text={zh ? "恢复本轮修改前的文件，对话记录会保留。" : "Restore files before this task. Chat history stays."}
						textWidth={w - 44}
						alignment={TextAlign.Left}
						color3={0x5f6a40}
					/>,
				),
			);
			add(
				toNode(
					<MobileButton
						tag="workspace-rollback-confirm"
						x={w - 140}
						y={30}
						width={120}
						text={zh ? "确认回退" : "Restore"}
						disabled={busy()}
						onTapped={() => {
							if (busy()) return;
							const r = rollbackTaskChangeSet(taskId(), workspace);
							notice = r.success ? (zh ? "已回退" : "Restored") : r.message;
							if (r.success) {
								for (const key of Object.keys(drafts)) {
									delete drafts[key];
									delete bases[key];
								}
								saving = true;
								void build({ workDir: workspace, path: ".", isCancelled: () => disposed }).then((result) => {
									saving = false;
									if (disposed) return;
									options.state.buildFailed = !result.success;
									notice = result.success ? (zh ? "已回退并重新构建" : "Restored and rebuilt") : result.message;
									options.onChanged(result.success ? undefined : notice);
									panel = "changes";
									render();
								});
							} else render();
						}}
					/>,
				),
			);
		} else {
			const scroll = ScrollArea({ width: w - 40, height: h - 145, paddingY: 0, scrollBar: false });
			scroll.position = Vec2(w / 2, 70 + (h - 145) / 2);
			sheet.addChild(scroll);
			let y = h - 145;
			const text = (value: string, color = 0x5f6a40) => {
				const label = Label(goTheme.font, 13, true);
				if (!label) return;
				label.anchor = Vec2(0, 1);
				label.position = Vec2(0, y);
				label.textWidth = w - 48;
				label.alignment = TextAlign.Left;
				label.color3 = Color3(color);
				label.text = value;
				scroll.view.addChild(label);
				y -= label.height + 14;
			};
			if (panel === "files") {
				const list = files();
				if (list.length === 0) text(zh ? "还没有项目文件" : "No project files yet");
				list.forEach((file) => {
					const node = toNode(
						<node
							onMount={pressFeedback}
							tag={`workspace-file-${file}`}
							x={0}
							y={y - 40}
							width={w - 40}
							height={40}
							anchorX={0}
							anchorY={0}
							touchEnabled={true}
							swallowTouches={true}
							onTapped={() => {
								const resolved = resolveWorkspaceFilePath(workspace, file);
								if (!resolved) return;
								const content = Content.load(resolved);
								if (content === undefined) {
									notice = zh ? "无法读取文件" : "Cannot read file";
									render();
									return;
								}
								if (content.length > 128000) {
									notice = zh ? "文件过大，请在 Web IDE 打开" : "Open large files in Web IDE";
									render();
									return;
								}
								path = file;
								if (drafts[file] === undefined) bases[file] = content;
								draft = drafts[file] ?? content;
								switchTo("code");
							}}
						>
							<label
								x={4}
								y={20}
								anchorX={0}
								fontName={goTheme.font}
								fontSize={12}
								text={file}
								textWidth={w - 55}
								alignment={TextAlign.Left}
								color3={0x5f6a40}
							/>
						</node>,
					);
					if (node) scroll.view.addChild(node);
					y -= 44;
				});
			} else if (panel === "changes") {
				const id = taskId();
				const diff = id > 0 ? getTaskChangeSetDiff(id) : undefined;
				if (diff?.success && diff.files.length > 0) {
					diff.files.forEach((f) => {
						text(f.path, 0x30352b);
						text("− " + f.beforeContent.slice(0, 2000), 0xa86656);
						text("+ " + f.afterContent.slice(0, 2000), 0x5c8053);
					});
					add(
						toNode(
							<MobileButton
								tag="workspace-rollback"
								x={20}
								y={20}
								width={150}
								height={36}
								text={zh ? "回退本轮修改" : "Restore task"}
								disabled={busy()}
								onTapped={() => switchTo("rollback")}
							/>,
						),
					);
				} else text(zh ? "当前没有待查看的修改" : "No changes to review");
			} else {
				const detail = options.getDetail();
				if (detail.success && detail.steps.length > 0)
					detail.steps.forEach((step) => text(`${step.status} · ${step.tool}\n${step.reason}`));
				else text(zh ? "暂无运行记录" : "No activity yet");
			}
			(scroll as typeof scroll & { resetSize(this: typeof scroll, w: number, h: number, vw: number, vh: number): void }).resetSize(
				w - 40,
				h - 145,
				w - 40,
				math.max(h - 145, h - 145 - y),
			);
		}
		if (conflict && panel === "code")
			add(
				toNode(
					<MobileButton
						tag="workspace-reload"
						x={110}
						y={24}
						width={90}
						height={36}
						text={zh ? "载入磁盘" : "Reload"}
						onTapped={() => {
							const full = resolveWorkspaceFilePath(workspace, path);
							if (!full) return;
							const content = Content.load(full);
							if (content === undefined) return;
							draft = content;
							bases[path] = content;
							delete drafts[path];
							conflict = false;
							notice = "";
							render();
						}}
					/>,
				),
			);
		if (focused && (panel === "code" || panel === "rename") && !busy()) editor.focus(false);
		if (notice !== "")
			add(
				toNode(
					<label
						x={20}
						y={64}
						anchorX={0}
						fontName={goTheme.font}
						fontSize={12}
						text={notice}
						textWidth={w - 40}
						color3={0x99664d}
						alignment={TextAlign.Left}
					/>,
				),
			);
	};
	host.slot("CloseWorkspace", close);
	host.slot("SuspendLocalUI", editor.blur);
	host.onAppEvent((event) => {
		if (event === "WillEnterBackground" || event === "DidEnterBackground") editor.blur();
	});
	host.onCleanup(() => {
		disposed = true;
		editor.unmount();
	});
	host.onAppChange((setting) => {
		if (setting === "Size") render();
	});
	render();
	host.position = Vec2(0, App.reducedMotion ? 0 : -24);
	host.perform(Spawn(Opacity(0.18, 0, 1), Move(App.reducedMotion ? 0 : 0.28, host.position, Vec2.zero, Ease.OutCubic)));
	return host;
}
