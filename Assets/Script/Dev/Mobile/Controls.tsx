import { pressFeedback } from "Dev/Mobile/Motion";
import { goTheme } from "Dev/Mobile/Theme";
import { React } from "DoraX";
import { TextAlign } from "Dora";
import { SceneSurface as RoundedSurface, GoIcon, type GoIconName } from "Dev/Mobile/Visual";

const fontName = goTheme.font;

export function MobileNewButton(props: { tag: string; x: number; y: number; text: string; renderOrder?: number; onTapped(): void }) {
	return <MobileButton {...props} width={76} height={32} fontSize={11} icon="plus" />;
}

export function MobileButton(props: {
	tag?: string;
	x: number;
	y: number;
	width: number;
	height?: number;
	text: string;
	fontSize?: number;
	primary?: boolean;
	danger?: boolean;
	icon?: GoIconName;
	segmented?: boolean;
	selected?: boolean;
	disabled?: boolean;
	renderOrder?: number;
	onTapped(): void;
}) {
	// Explicit ordering keeps shared controls above their panel.
	const height = props.height ?? 42;
	const surfaceRenderOrder = (props.renderOrder ?? 0) + 1;
	return (
		<node
			tag={props.tag}
			x={props.x}
			y={props.y}
			anchorX={0}
			anchorY={0}
			width={props.width}
			height={height}
			renderOrder={props.renderOrder}
			opacity={props.disabled ? 0.4 : 1}
			touchEnabled={!props.disabled}
			swallowTouches={true}
			onTapped={props.onTapped}
			onMount={pressFeedback}
		>
			<RoundedSurface
				width={props.width}
				height={height}
				radius={props.segmented ? 5 : goTheme.radius}
				renderOrder={surfaceRenderOrder}
				topColor={
					props.segmented
						? props.selected
							? 0xffffffff
							: 0x00000000
						: props.danger
							? 0xffff8585
							: props.primary
								? goTheme.brand
								: goTheme.button
				}
				bottomColor={
					props.segmented
						? props.selected
							? 0xffffffff
							: 0x00000000
						: props.danger
							? 0xffdf4e56
							: props.primary
								? goTheme.brand
								: goTheme.button
				}
				borderWidth={props.segmented ? 0 : 1}
				borderColor={props.danger ? 0xffff6b6b : props.primary ? 0xffdbc35d : goTheme.buttonBorder}
				shadow={false}
			/>
			{props.icon ? (
				<GoIcon
					name={props.icon}
					x={props.text === "" ? (props.width - 18) / 2 : 12}
					y={height / 2 - (props.text === "" ? 9 : 7.5)}
					size={props.text === "" ? 18 : 15}
				/>
			) : undefined}
			<label
				x={props.width / 2 + (props.icon ? 10 : 0)}
				y={height / 2}
				fontName={fontName}
				fontSize={props.fontSize ?? 12}
				text={props.text}
				color3={props.segmented ? (props.selected ? 0x495640 : 0x858e79) : props.primary ? 0x52491f : 0x5f6a40}
			/>
		</node>
	);
}

export function MobileChoiceButton(props: {
	x: number;
	y: number;
	width: number;
	text: string;
	tag?: string;
	selected: boolean;
	disabled?: boolean;
	renderOrder?: number;
	onTapped(): void;
}) {
	return (
		<node
			tag={props.tag}
			x={props.x}
			y={props.y}
			width={props.width}
			height={40}
			anchorX={0}
			anchorY={0}
			renderOrder={props.renderOrder}
			opacity={props.disabled ? 0.45 : 1}
			touchEnabled={!props.disabled}
			swallowTouches={true}
			onTapped={props.onTapped}
			onMount={pressFeedback}
		>
			<RoundedSurface
				width={props.width}
				height={40}
				radius={12}
				renderOrder={props.renderOrder === undefined ? undefined : props.renderOrder + 1}
				topColor={props.selected ? goTheme.brand : goTheme.panelRaised}
				bottomColor={props.selected ? goTheme.brand : goTheme.panelRaised}
				borderWidth={1}
				borderColor={props.selected ? 0xffdbc35d : goTheme.buttonBorder}
			/>
			<draw-node tag={props.tag ? `${props.tag}-radio` : undefined} x={17} y={20}>
				<dot-shape radius={7} color={props.selected ? goTheme.text : goTheme.muted} />
				<dot-shape radius={5} color={props.selected ? 0xffffcf48 : goTheme.panel} />
				{props.selected ? (
					<draw-node tag={props.tag ? `${props.tag}-radio-dot` : undefined}>
						<dot-shape radius={2.5} color={goTheme.text} />
					</draw-node>
				) : undefined}
			</draw-node>
			<label
				x={32}
				y={20}
				anchorX={0}
				fontName={fontName}
				fontSize={14}
				text={props.text}
				textWidth={props.width - 44}
				alignment={TextAlign.Left}
				color3={props.selected ? 0x17130a : 0x5f6a40}
			/>
		</node>
	);
}

export function MobilePanelSurface(props: { width: number; height: number; renderOrder?: number }) {
	return (
		<RoundedSurface
			width={props.width}
			height={props.height}
			radius={24}
			bottomRadius={0}
			topColor={goTheme.panel}
			bottomColor={goTheme.panel}
			borderWidth={1}
			borderColor={goTheme.border}
			shadow={true}
			renderOrder={props.renderOrder}
		/>
	);
}
