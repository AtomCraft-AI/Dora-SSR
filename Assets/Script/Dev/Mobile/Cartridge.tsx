import { React } from "DoraX";
import { Sprite } from "Dora";
import { RoundedStencil } from "Dev/Mobile/Visual";
import { getCoverScales, type FeedEntry } from "Dev/Mobile/FeedModel";
import { goTheme } from "Dev/Mobile/Theme";

// Three-times-resolution material exported from Tools/design/go-materials.html.
// Only the molded housing is baked; artwork and all interaction remain native.
export function Cartridge(props: { entry: FeedEntry; x: number; y: number; width: number; height: number }) {
	const art = (sprite: Sprite.Type) => {
		const scale = getCoverScales(sprite.width, sprite.height, 184, 167).cover;
		sprite.scaleX = scale;
		sprite.scaleY = scale;
	};
	return (
		<node
			tag="go-cartridge"
			x={props.x}
			y={props.y}
			width={236}
			height={308}
			anchorX={0}
			anchorY={0}
			scaleX={props.width / 236}
			scaleY={props.height / 308}
		>
			<sprite file="Image/GoUI/cartridge.png" x={118} y={154} scaleX={1 / 3} scaleY={1 / 3} />
			<clip-node
				x={26}
				y={82}
				width={184}
				height={167}
				anchorX={0}
				anchorY={0}
				stencil={<RoundedStencil width={184} height={167} radius={2} />}
			>
				{props.entry.bannerFile ? (
					<sprite file={props.entry.bannerFile} x={92} y={83.5} onMount={art} />
				) : (
					<node>
						<draw-node x={92} y={83.5}>
							<rect-shape width={184} height={167} fillColor={0xffe7eadf} />
						</draw-node>
						<label x={92} y={83.5} fontName={goTheme.font} fontSize={18} text={props.entry.title} textWidth={156} color3={0x5f6a40} />
					</node>
				)}
			</clip-node>
		</node>
	);
}

export function CartridgeSlot(props: { x: number; y: number }) {
	return (
		<node x={props.x} y={props.y} width={162} height={280} anchorX={0} anchorY={0}>
			<sprite file="Image/GoUI/console.png" x={81} y={140} scaleX={1 / 3} scaleY={1 / 3} />
		</node>
	);
}
