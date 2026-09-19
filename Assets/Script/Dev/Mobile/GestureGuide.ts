import { App, Color, Color3, DrawNode, Label, Node, Vec2 } from "Dora";
import { goTheme } from "Dev/Mobile/Theme";

/** A short, non-interactive hint; its owner removes it on any input. */
export function createGestureGuide(zh: boolean) {
	const node = Node();
	node.tag = "go-gesture-guide";
	const light = DrawNode();
	light.addTo(node);
	const caption = Label(goTheme.font, 12, true)!;
	caption.color3 = Color3(0x687345);
	caption.addTo(node);
	let elapsed = 0;
	node.schedule((dt) => {
		elapsed += dt;
		if (elapsed >= 4.4 || App.reducedMotion) {
			node.removeFromParent(true);
			return true;
		}
		const phase = elapsed < 2.2 ? 0 : 1;
		const t = (elapsed - phase * 2.2) / 1.5;
		light.clear();
		caption.visible = t > 0.2 && t < 1;
		if (t > 1) return false;
		const progress = (v: number) => {
			const x = math.max(0, math.min(1, v));
			return x * x * (3 - 2 * x);
		};
		const point = (v: number) => (phase === 0 ? Vec2(0, -62 + progress(v) * 145) : Vec2(88 - progress(v) * 176, 12));
		for (let i = 10; i >= 0; i--) {
			const p = point(t - i * 0.015);
			const alpha = math.floor((1 - i / 12) * math.min(1, t * 8, (1 - t) * 8) * 190);
			light.drawDot(p, i === 0 ? 6 : 4 - i * 0.25, Color(alpha * 0x1000000 + 0xffffff));
		}
		const tail = point(t - 0.14);
		caption.text = phase === 0 ? (zh ? "下一个" : "Next") : zh ? "进入游戏" : "Play";
		caption.position = Vec2(tail.x + (phase === 0 ? 28 : 0), tail.y - 22 + math.sin(math.min(1, (t - 0.2) * 4) * math.pi) * 9);
		return false;
	});
	return node;
}
