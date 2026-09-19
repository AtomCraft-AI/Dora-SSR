import { React } from "DoraX";
import { Color, Node, Size, Vec2 } from "Dora";
import * as nvg from "nvg";

interface RoundedSurfaceProps {
	x?: number;
	y?: number;
	width: number;
	height: number;
	radius: number;
	bottomRadius?: number;
	fillColor?: number;
	topColor?: number;
	bottomColor?: number;
	borderWidth?: number;
	borderColor?: number;
	shadow?: boolean;
	opacity?: number;
	renderOrder?: number;
}

/** NanoVG surface following Dora-Example/UIX's PaintNode + roundedPanel pattern. */
export function RoundedSurface(props: RoundedSurfaceProps) {
	const onCreate = () => {
		const node = Node();
		node.anchor = Vec2.zero;
		node.size = Size(props.width, props.height);
		node.onRender(() => {
			nvg.Save();
			nvg.ApplyTransform(node);
			const radius = math.max(0, math.min(props.radius, props.width / 2, props.height / 2));
			if (props.shadow) {
				nvg.BeginPath();
				nvg.RoundedRect(2, -3, props.width, props.height, radius);
				nvg.FillColor(Color(0x52000000));
				nvg.Fill();
			}
			nvg.BeginPath();
			nvg.RoundedRect(0, 0, props.width, props.height, radius);
			if (props.topColor !== undefined && props.bottomColor !== undefined) {
				nvg.FillPaint(nvg.LinearGradient(0, props.height, 0, 0, Color(props.topColor), Color(props.bottomColor)));
			} else {
				nvg.FillColor(Color(props.fillColor ?? 0xffffffff));
			}
			nvg.Fill();
			const borderWidth = props.borderWidth ?? 0;
			if (borderWidth > 0) {
				nvg.BeginPath();
				nvg.RoundedRect(
					borderWidth / 2,
					borderWidth / 2,
					props.width - borderWidth,
					props.height - borderWidth,
					math.max(0, radius - borderWidth / 2),
				);
				nvg.StrokeWidth(borderWidth);
				nvg.StrokeColor(Color(props.borderColor ?? 0xffffffff));
				nvg.Stroke();
			}
			nvg.Restore();
			return false;
		});
		return node;
	};
	return (
		<custom-node
			x={props.x ?? 0}
			y={props.y ?? 0}
			width={props.width}
			height={props.height}
			opacity={props.opacity ?? 1}
			renderOrder={props.renderOrder}
			onCreate={onCreate}
		/>
	);
}

export function VerticalGradient(props: { x?: number; y?: number; width: number; height: number; topColor: number; bottomColor: number }) {
	const onCreate = () => {
		const node = Node();
		node.anchor = Vec2.zero;
		node.size = Size(props.width, props.height);
		node.onRender(() => {
			nvg.Save();
			nvg.ApplyTransform(node);
			nvg.BeginPath();
			nvg.Rect(0, 0, props.width, props.height);
			nvg.FillPaint(nvg.LinearGradient(0, props.height, 0, 0, Color(props.topColor), Color(props.bottomColor)));
			nvg.Fill();
			nvg.Restore();
			return false;
		});
		return node;
	};
	return <custom-node x={props.x ?? 0} y={props.y ?? 0} width={props.width} height={props.height} onCreate={onCreate} />;
}

export function roundedRectVerts(width: number, height: number, radius: number, bottomRadius = radius) {
	const r = math.max(0, math.min(radius, width / 2, height / 2));
	const b = math.max(0, math.min(bottomRadius, width / 2, height / 2));
	const verts: Vec2.Type[] = [];
	const corners = [
		{ x: width - b, y: b, r: b, start: -math.pi / 2 },
		{ x: width - r, y: height - r, r, start: 0 },
		{ x: r, y: height - r, r, start: math.pi / 2 },
		{ x: b, y: b, r: b, start: math.pi },
	];
	for (const corner of corners) {
		for (let step = 0; step <= 12; step++) {
			const angle = corner.start + (step * math.pi) / 24;
			verts.push(Vec2(corner.x + math.cos(angle) * corner.r, corner.y + math.sin(angle) * corner.r));
		}
	}
	return verts;
}

/** Stencil-only rounded path for clipping sprites and other scene nodes. */
export function RoundedStencil(props: { width: number; height: number; radius: number }) {
	return (
		<draw-node>
			<polygon-shape verts={roundedRectVerts(props.width, props.height, props.radius)} fillColor={0xffffffff} />
		</draw-node>
	);
}

/** Ordered surfaces with a subpixel alpha fringe instead of hard polygon strokes. */
export function SceneSurface(props: RoundedSurfaceProps) {
	const w = props.width,
		h = props.height;
	const top = Color(props.topColor ?? props.fillColor ?? 0xffffffff);
	const bottom = Color(props.bottomColor ?? props.fillColor ?? 0xffffffff);
	const shade = (y: number) => {
		const t = math.max(0, math.min(1, y / math.max(1, h)));
		return (
			math.floor(bottom.a + (top.a - bottom.a) * t) * 0x1000000 +
			math.floor(bottom.r + (top.r - bottom.r) * t) * 0x10000 +
			math.floor(bottom.g + (top.g - bottom.g) * t) * 0x100 +
			math.floor(bottom.b + (top.b - bottom.b) * t)
		);
	};
	const faded = (c: number, alpha: number) => math.floor(Color(c).a * alpha) * 0x1000000 + (c % 0x1000000);
	const loop = (inset: number) =>
		roundedRectVerts(
			math.max(0, w - 2 * inset),
			math.max(0, h - 2 * inset),
			math.max(0, props.radius - inset),
			math.max(0, (props.bottomRadius ?? props.radius) - inset),
		).map((p) => Vec2(p.x + inset, p.y + inset));
	const triangles: [Vec2.Type, number][] = [];
	const ring = (outer: number, inner: number, outerColor: (y: number) => number, innerColor: (y: number) => number) => {
		const a = loop(outer),
			b = loop(inner);
		for (let i = 0; i < a.length; i++) {
			const j = (i + 1) % a.length;
			triangles.push(
				[a[i], outerColor(a[i].y)],
				[a[j], outerColor(a[j].y)],
				[b[i], innerColor(b[i].y)],
				[a[j], outerColor(a[j].y)],
				[b[j], innerColor(b[j].y)],
				[b[i], innerColor(b[i].y)],
			);
		}
	};
	const edge = 0.6,
		inner = loop(edge);
	for (let i = 0; i < inner.length; i++) {
		const a = inner[i],
			b = inner[(i + 1) % inner.length];
		triangles.push([Vec2(w / 2, h / 2), shade(h / 2)], [a, shade(a.y)], [b, shade(b.y)]);
	}
	ring(-0.2, edge, (y) => faded(shade(y), 0), shade);
	const border = props.borderWidth ?? 0,
		ink = props.borderColor ?? 0xffffffff;
	if (border > 0) {
		ring(
			-0.25,
			0.4,
			() => faded(ink, 0),
			() => ink,
		);
		if (border > 0.8)
			ring(
				0.4,
				border - 0.4,
				() => ink,
				() => ink,
			);
		ring(
			math.max(0.4, border - 0.4),
			border + 0.25,
			() => ink,
			() => faded(ink, 0),
		);
	}
	const faces: [Vec2.Type, number][][] = [];
	for (let i = 0; i < triangles.length; i += 3) faces.push(triangles.slice(i, i + 3));
	return (
		<node x={props.x ?? 0} y={props.y ?? 0} opacity={props.opacity ?? 1} renderOrder={props.renderOrder}>
			{props.shadow
				? [5, 4, 3, 2, 1].map((i) => (
						<draw-node x={0} y={-2}>
							<polygon-shape verts={loop(-i)} fillColor={0x023b452f} />
						</draw-node>
					))
				: undefined}
			<draw-node>
				{faces.map((face) => (
					<verts-shape verts={face} />
				))}
			</draw-node>
		</node>
	);
}

export type GoIconName =
	| "settings"
	| "back"
	| "more"
	| "edit"
	| "check"
	| "down"
	| "exit"
	| "plus"
	| "code"
	| "remix"
	| "files"
	| "changes"
	| "logs"
	| "swap"
	| "close"
	| "next"
	| "up"
	| "stop"
	| "dropdown"
	| "circle"
	| "checked";

export function GoIcon(props: { name: GoIconName; x?: number; y?: number; size?: number; color?: number }) {
	const size = props.size ?? 20,
		color = props.color ?? 0xff5b6154;
	return (
		<sprite
			file={`Image/GoUI/icon-${props.name}.png`}
			x={(props.x ?? 0) + size / 2}
			y={(props.y ?? 0) + size / 2}
			scaleX={size / 72}
			scaleY={size / 72}
			color3={color % 0x1000000}
			opacity={math.floor(color / 0x1000000) / 255}
		/>
	);
}
