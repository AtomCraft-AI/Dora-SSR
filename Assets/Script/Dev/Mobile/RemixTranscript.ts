import { goTheme } from "Dev/Mobile/Theme";
import { pressFeedback } from "Dev/Mobile/Motion";
import { toNode } from "DoraX";
import { RoundedStencil, SceneSurface } from "Dev/Mobile/Visual";
import { App, Color, Color3, DrawNode, Label, Node, Size, Sprite, TextAlign, Vec2 } from "Dora";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import type { AgentSessionDetailResult } from "Agent/Session";
import { safeJsonEncode } from "Agent/Utils";
import { compactAgentActivity } from "Dev/Mobile/RemixModel";
import { parseLightMarkdown } from "Dev/Mobile/LightMarkdown";
import { remixHistory, REMIX_HISTORY_ROUNDS } from "Dev/Mobile/RemixHistory";

export interface RemixTranscriptAction {
	id: "continue" | "start-development";
	text: string;
	primary?: boolean;
	onTapped(this: void): void;
}

interface Item {
	id: string;
	title: string;
	text: string;
	user: boolean;
	activity: boolean;
	actions?: RemixTranscriptAction[];
}
type Scroll = ReturnType<typeof ScrollArea> & {
	offset: Vec2.Type;
	resetSize(this: Scroll, width: number, height: number, viewWidth: number, viewHeight: number): void;
};
const font = goTheme.font;

// Snapshot only visible state, never reasoning, tool parameters, credentials or diffs.
export function remixDisplayRevision(detail: AgentSessionDetailResult): string {
	if (!detail.success) return detail.message;
	const history = remixHistory(detail);
	return (
		safeJsonEncode({
			status: detail.session.status,
			mode: detail.session.workMode,
			plan: detail.hasActivePlan,
			finalizing: detail.session.currentTaskFinalizing,
			questionnaire: detail.pendingQuestionnaire,
			currentTaskId: detail.session.currentTaskId,
			currentTaskStatus: detail.session.currentTaskStatus,
			hasEarlierMessages: history.hasEarlierMessages,
			messages: history.messages.map((m) => [m.id, m.taskId ?? 0, m.role, m.displayContent ?? m.content]),
			steps: history.steps.map((s) => [
				s.id,
				s.tool,
				s.status,
				s.reason,
				s.result?.progress,
				s.result?.stage,
				s.result?.message,
				s.result?.assets,
				s.result?.report,
				s.result?.model,
			]),
		})[0] ?? ""
	);
}

function itemsFor(detail: AgentSessionDetailResult, zh: boolean, actions: RemixTranscriptAction[]): Item[] {
	if (!detail.success) return [];
	const items: Item[] = [];
	const history = remixHistory(detail);
	if (history.hasEarlierMessages)
		items.push({
			id: "remix-history-limit",
			title: zh ? "历史记录" : "History",
			text: zh
				? `仅展示最近 ${REMIX_HISTORY_ROUNDS} 轮，更早记录可在 Web IDE 查看。`
				: `Showing the latest ${REMIX_HISTORY_ROUNDS} rounds. View earlier messages in Web IDE.`,
			user: false,
			activity: true,
		});
	const activities = history.steps.map((s) => {
		const state =
			s.status === "DONE"
				? zh
					? "已完成"
					: "Done"
				: s.status === "FAILED"
					? zh
						? "失败"
						: "Failed"
					: s.status === "STOPPED"
						? zh
							? "已停止"
							: "Stopped"
						: s.status === "PENDING"
							? zh
								? "等待中"
								: "Pending"
							: zh
								? "进行中"
								: "Working";
		const progress = s.status === "RUNNING" && typeof s.result?.progress === "number" ? ` · ${math.floor(s.result.progress * 100)}%` : "";
		const vision = s.tool === "analyze_image";
		const message = (s.status === "RUNNING" || vision) && typeof s.result?.message === "string" ? s.result.message : "";
		const report = vision && typeof s.result?.report === "string" ? s.result.report : "";
		const model = vision && typeof s.result?.model === "string" ? s.result.model : "";
		const title = compactAgentActivity(s.tool, "", zh, s.status === "RUNNING");
		return {
			id: `step-${s.id}`,
			title: `${state}${progress} · ${title}`,
			text:
				s.reason +
				(message !== "" ? `\n${message}` : "") +
				(model !== "" ? `\n${zh ? "看图模型" : "Vision model"}: ${model}` : "") +
				(report !== "" ? `\n${report}` : ""),
			user: false,
			activity: true,
		};
	});
	let inserted = false;
	for (const m of history.messages) {
		// Current task steps belong between its request and its final assistant reply.
		if (!inserted && m.role === "assistant" && m.taskId === detail.session.currentTaskId) {
			items.push(...activities);
			inserted = true;
		}
		items.push({
			id: `message-${m.id}`,
			title: m.role === "user" ? (zh ? "你" : "You") : "Dora",
			text: m.displayContent ?? m.content,
			user: m.role === "user",
			activity: false,
		});
	}
	if (!inserted) items.push(...activities);
	if (actions.length > 0) items.push({ id: "remix-terminal-actions", title: "", text: "", user: false, activity: true, actions });
	return items;
}

function drawCapsule(target: DrawNode.Type, width: number, height: number, color: number, inset = 0) {
	const radius = height / 2 - inset;
	const left = height / 2;
	const right = width - height / 2;
	target.drawPolygon([Vec2(left, inset), Vec2(right, inset), Vec2(right, height - inset), Vec2(left, height - inset)], Color(color));
	target.drawDot(Vec2(left, height / 2), radius, Color(color));
	target.drawDot(Vec2(right, height / 2), radius, Color(color));
}

function makeActionRow(actions: RemixTranscriptAction[], width: number, scale: number): Node.Type {
	const card = Node();
	card.tag = "remix-terminal-actions";
	card.anchor = Vec2(0, 1);
	card.width = width;
	card.height = 44;
	const gap = 10;
	const buttonWidth = actions.length > 1 ? math.min((width - gap) / 2, 184) : math.min(width, 184);
	for (let i = 0; i < actions.length; i++) {
		const action = actions[i];
		const button = Node();
		button.tag = `remix-action-${action.id}`;
		button.anchor = Vec2.zero;
		button.position = Vec2(i * (buttonWidth + gap), 3);
		button.size = Size(buttonWidth, 38);
		button.touchEnabled = true;
		button.swallowTouches = true;
		button.onTapped(action.onTapped);
		pressFeedback(button);
		const bg = DrawNode();
		if (action.primary) drawCapsule(bg, buttonWidth, 38, 0xffffcc33);
		else {
			drawCapsule(bg, buttonWidth, 38, 0xffc8cba9);
			drawCapsule(bg, buttonWidth, 38, 0xfff7f2d9, 1);
		}
		button.addChild(bg);
		const label = Label(font, math.floor(14 * scale), true);
		if (label) {
			label.position = Vec2(buttonWidth / 2, 19);
			label.color3 = Color3(action.primary ? 0x17130a : 0x5f6a40);
			label.text = action.text;
			button.addChild(label);
		}
		card.addChild(button);
	}
	return card;
}

function makeCard(item: Item, width: number, scale: number, zh: boolean): Node.Type {
	if (item.actions) return makeActionRow(item.actions, width, scale);
	const card = Node();
	card.tag = item.id;
	card.anchor = Vec2(0, 1);
	card.width = width;
	const bubbleWidth = item.user ? width * 0.9 : width;
	const origin = item.user ? width - bubbleWidth : 0;
	const padding = item.user || item.activity ? 14 : 0;
	const labels: { label: Label.Type; top: number }[] = [];
	let top = item.user || item.activity ? 11 : 0;
	const add = (text: string, size: number, color: number, code = false) => {
		const l = Label(code ? goTheme.monoFont : font, math.floor(size * scale), true);
		if (!l) return;
		l.anchor = Vec2(0, 1);
		l.x = origin + padding;
		l.textWidth = math.max(20, bubbleWidth - padding * 2);
		l.alignment = TextAlign.Left;
		l.lineGap = 6;
		l.color3 = Color3(color);
		l.text = text;
		labels.push({ label: l, top });
		top += l.height + 9;
	};
	if (!item.user) {
		add(item.title, 11, 0x495640);
		if (!item.activity) {
			labels[0].label.x = 34;
			labels[0].top = 5;
			top = 35;
		}
	}
	for (const block of parseLightMarkdown(item.text))
		add(
			block.text,
			block.kind === "heading1" ? 17 : block.kind === "heading2" ? 15 : 13,
			block.kind === "code" ? 0x8a7027 : 0x30352b,
			block.kind === "code",
		);
	if (!item.user && !item.activity) {
		add(zh ? "复制" : "Copy", 10, 0x859075);
		const copy = labels[labels.length - 1]?.label;
		if (copy !== undefined) {
			copy.tag = "remix-copy";
			copy.touchEnabled = true;
			copy.onTapped(() => App.setClipboardText(item.text));
			pressFeedback(copy);
		}
	}
	card.height = top + (item.user ? 2 : 0);
	if (item.user || item.activity) {
		const bg = toNode(
			SceneSurface({
				x: origin,
				width: bubbleWidth,
				height: card.height,
				radius: item.user ? 15 : 10,
				fillColor: item.user ? 0xfffafbf5 : 0x35ffffff,
				borderWidth: item.user ? 0.6 : 0,
				borderColor: 0x99ffffff,
				shadow: item.user,
			}),
		);
		if (bg) card.addChild(bg);
	}
	if (!item.user && !item.activity) {
		const avatarBg = toNode(
			SceneSurface({
				x: 0,
				y: card.height - 26,
				width: 26,
				height: 26,
				radius: 9,
				fillColor: 0x88ffffff,
				borderWidth: 0.6,
				borderColor: 0xffffffff,
			}),
		);
		if (avatarBg) card.addChild(avatarBg);
		const avatarClip = toNode({
			type: "clip-node",
			children: [],
			props: {
				x: 2,
				y: card.height - 24,
				width: 22,
				height: 22,
				anchorX: 0,
				anchorY: 0,
				stencil: RoundedStencil({ width: 22, height: 22, radius: 7 }),
			},
		});
		if (avatarClip) card.addChild(avatarClip);
		const avatar = Sprite("Image/GoUI/mascot.png");
		if (avatar && avatarClip) {
			const scale = 22 / math.max(avatar.width, avatar.height);
			avatar.scaleX = scale;
			avatar.scaleY = scale;
			avatar.position = Vec2(11, 11);
			avatarClip.addChild(avatar);
		}
	}
	for (const row of labels) {
		row.label.y = card.height - row.top;
		card.addChild(row.label);
	}
	return card;
}

export function createRemixTranscript() {
	const node = Node();
	node.tag = "remix-transcript";
	node.anchor = Vec2.zero;
	const scroll = ScrollArea({ width: 1, height: 1, paddingX: 0, paddingY: 40, scrollBar: false }) as Scroll;
	scroll.tag = "remix-scroll";
	scroll.addTo(node);
	const latest = Sprite("Image/GoUI/icon-down.png")!;
	latest.scaleX = latest.scaleY = 18 / 72;
	latest.color3 = Color3(0x6c7e56);
	const latestButton = Node();
	latestButton.tag = "remix-latest";
	latestButton.size = Size(44, 44);
	latestButton.anchor = Vec2(0.5, 0.5);
	latestButton.touchEnabled = true;
	latestButton.swallowTouches = true;
	latestButton.order = 3;
	latestButton.addTo(node);
	const hintBackground = DrawNode();
	hintBackground.order = 1;
	hintBackground.addTo(latestButton);
	latest.order = 2;
	latest.addTo(latestButton);
	latest.position = Vec2(22, 22);
	pressFeedback(latestButton);
	let width = 1,
		height = 1,
		scale = 1,
		zh = true,
		total = 0;
	let following = true,
		touching = false,
		layingOut = false;
	let lastTouchMotion = 0;
	let rows: { id: string; signature: string; node: Node.Type }[] = [];
	const maxOffset = () => math.max(0, total - height);
	hintBackground.drawDot(Vec2(22, 22), 17, Color(0xffc8d1bb));
	hintBackground.drawDot(Vec2(22, 22), 16, Color(0xfffcfdf6));
	let hintVisible: boolean | undefined;
	const updateHint = () => {
		const visible = maxOffset() > 24 && !following;
		if (hintVisible === visible) return;
		hintVisible = visible;
		latestButton.visible = visible;
	};
	scroll.slot("ScrollTouchBegan", () => {
		touching = true;
		lastTouchMotion = App.runningTime;
	});
	scroll.onTapMoved(() => {
		lastTouchMotion = App.runningTime;
	});
	scroll.slot("ScrollTouchEnded", () => {
		touching = false;
		following = maxOffset() - scroll.offset.y <= 24;
		updateHint();
	});
	scroll.slot("Scrolled", () => {
		if (layingOut) return;
		following = maxOffset() - scroll.offset.y <= 24;

		updateHint();
	});
	latestButton.onTapped(() => {
		scroll.unschedule();
		touching = false;
		following = true;
		scroll.offset = Vec2(0, maxOffset());
		updateHint();
	});
	return {
		node,
		isInteracting() {
			// Missing release events must not keep the transcript in a permanent drag state.
			if (touching && App.runningTime - lastTouchMotion > 0.3) touching = false;
			return touching;
		},
		scrollBy(amount: number) {
			scroll.unschedule();
			following = false;
			scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), scroll.offset.y + amount)));
			scroll.view.moveAndCullItems(Vec2.zero);
			following = maxOffset() - scroll.offset.y <= 24;

			updateHint();
		},
		update(
			detail: AgentSessionDetailResult,
			w: number,
			h: number,
			fontScale: number,
			chinese: boolean,
			actions: RemixTranscriptAction[] = [],
		) {
			const anchor = rows.find((row) => row.node.y > 0 && row.node.y - row.node.height < height);
			const anchorY = anchor?.node.y;
			const oldOffset = scroll.offset.y;
			const layoutChanged = width !== w || height !== h || scale !== fontScale || zh !== chinese;
			width = w;
			height = h;
			scale = fontScale;
			zh = chinese;
			node.size = Size(width, height);
			scroll.position = Vec2(width / 2, height / 2);
			latestButton.position = Vec2(width / 2, 17);
			const previous = rows;
			const previousById: Record<string, (typeof rows)[number]> = {};
			const nextById: Record<string, Node.Type> = {};
			for (const row of previous) previousById[row.id] = row;
			let changed = layoutChanged;
			rows = itemsFor(detail, zh, actions).map((item) => {
				const signature =
					safeJsonEncode({
						id: item.id,
						title: item.title,
						text: item.text,
						user: item.user,
						activity: item.activity,
						actions: item.actions?.map((action) => [action.id, action.text, action.primary === true]),
					})[0] ?? "";
				const existing = previousById[item.id];
				if (!layoutChanged && existing?.signature === signature) {
					nextById[item.id] = existing.node;
					return existing;
				}
				changed = true;
				const card = makeCard(item, width, scale, zh);
				scroll.view.addChild(card);
				nextById[item.id] = card;
				return { id: item.id, signature, node: card };
			});
			for (const row of previous)
				if (nextById[row.id] !== row.node) {
					row.node.removeFromParent(true);
					changed = true;
				}
			if (!changed) return;
			layingOut = true;
			scroll.offset = Vec2.zero;
			total = 0;
			for (const row of rows) {
				row.node.position = Vec2(0, height - total);
				total += row.node.height + 22;
			}
			if (rows.length > 0) total -= 22;
			scroll.resetSize(width, height, width, total);
			const pinned = following && !touching;
			const replacement = anchor ? rows.find((row) => row.id === anchor.id) : undefined;
			const offset = pinned ? maxOffset() : replacement && anchorY !== undefined ? anchorY - replacement.node.y : oldOffset;
			scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), offset)));
			scroll.view.moveAndCullItems(Vec2.zero);
			layingOut = false;

			updateHint();
		},
	};
}
