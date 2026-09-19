import { Color3, Label, Node, Size, TextAlign, Vec2 } from "Dora";
import { React, toNode } from "DoraX";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import { GoIcon } from "Dev/Mobile/Visual";
import { inputLength, inputSlice } from "Dev/Mobile/TextInput";
import { goTheme } from "Dev/Mobile/Theme";
import { pressFeedback } from "Dev/Mobile/Motion";

/** A one-line summary expands into a three-line, independently scrolling viewport. */
export function Description(props: {
	text: string;
	x: number;
	y: number;
	width: number;
	active: boolean;
	onExpand(this: void, expanded: boolean, extraHeight: number): void;
}) {
	return (
		<custom-node
			onCreate={() => {
				const root = Node();
				root.anchor = Vec2(0, 1);
				root.position = Vec2(props.x, props.y);
				root.tag = props.active ? "mobile-feed-description" : "";
				const label = Label(goTheme.font, 13, true)!;
				label.alignment = TextAlign.Left;
				label.lineGap = 6;
				label.textWidth = -1;
				const singleLine = string.gsub(props.text, "[\r\n]+", " ")[0];
				label.text = singleLine;
				const expandable = label.width > props.width - 24 || singleLine !== props.text;
				let summary = singleLine;
				if (expandable) {
					let low = 0,
						high = inputLength(singleLine);
					while (low < high) {
						const mid = math.floor((low + high + 1) / 2);
						label.text = inputSlice(singleLine, 0, mid) + "…";
						if (label.width <= props.width - 28) low = mid;
						else high = mid - 1;
					}
					summary = inputSlice(singleLine, 0, low) + "…";
				}
				label.text = "简\n简\n简";
				const expandedHeight = label.height;
				label.cleanup();
				let expanded = false;
				const render = () => {
					root.removeAllChildren();
					root.size = Size(props.width, expanded ? expandedHeight : 21);
					const toggle = () => {
						if (!props.active || !expandable) return;
						expanded = !expanded;
						render();
						props.onExpand(expanded, expandedHeight - 21);
					};
					if (expanded) {
						const text = Label(goTheme.font, 13, true)!;
						text.color3 = Color3(0x7c826f);
						text.textWidth = props.width - 30;
						text.lineGap = 6;
						text.alignment = TextAlign.Left;
						text.text = props.text;
						text.anchor = Vec2(0, 1);
						text.position = Vec2(0, expandedHeight);
						const scroll = ScrollArea({
							width: props.width - 30,
							height: expandedHeight,
							viewHeight: math.max(expandedHeight, text.height),
							paddingX: 0,
							paddingY: 0,
							scrollBar: false,
						});
						scroll.swallowTouches = true;
						// ScrollArea distinguishes a tap from a drag before emitting this event.
						scroll.slot("NoneScrollTapped", toggle);
						scroll.tag = "mobile-feed-description-scroll";
						scroll.position = Vec2((props.width - 30) / 2, expandedHeight / 2);
						scroll.view.addChild(text);
						root.addChild(scroll);
					} else {
						const text = toNode(
							<label
								x={0}
								y={10.5}
								anchorX={0}
								fontName={goTheme.font}
								fontSize={13}
								text={summary}
								color3={0x7c826f}
								alignment={TextAlign.Left}
							/>,
						);
						if (text) root.addChild(text);
					}
					if (expandable) {
						const button = toNode(
							<node
								tag={props.active ? "mobile-feed-description-toggle" : undefined}
								x={expanded ? props.width - 28 : 0}
								y={expanded ? expandedHeight - 28 : -3}
								width={expanded ? 28 : props.width}
								height={28}
								anchorX={0}
								anchorY={0}
								touchEnabled={props.active}
								swallowTouches={true}
								onTapped={toggle}
								onMount={pressFeedback}
							>
								<node x={expanded ? 14 : props.width - 10} y={14} angle={expanded ? 180 : 0}>
									<GoIcon name="dropdown" x={-7} y={-7} size={14} />
								</node>
							</node>,
						);
						if (button) root.addChild(button);
					}
				};
				render();
				return root;
			}}
		/>
	);
}
