import { App, Ease, Node, Scale, Size, Vec2 } from "Dora";

/** Scale artwork around its center while keeping the control's hit area stable. */
export function pressFeedback(target: Node.Type) {
	let visual: Node.Type | undefined;
	const animate = (pressed: boolean) => {
		// DoraX onMount runs before child elements are attached.
		if (!visual) {
			visual = Node();
			visual.tag = "go-press-visual";
			visual.size = Size(target.width, target.height);
			visual.position = Vec2(target.width / 2, target.height / 2);
			const children: Node.Type[] = [];
			target.eachChild((child) => {
				children.push(child);
				return false;
			});
			for (const child of children) {
				child.moveToParent(visual);
			}
			target.addChild(visual);
		}
		visual.stopAllActions();
		visual.perform(
			Scale(
				App.reducedMotion ? 0 : pressed ? 0.1 : 0.18,
				visual.scaleX,
				pressed && !App.reducedMotion ? 0.94 : 1,
				pressed ? Ease.OutCubic : Ease.OutBack,
			),
		);
	};
	target.onTapBegan(() => animate(true));
	target.onTapEnded(() => animate(false));
}
