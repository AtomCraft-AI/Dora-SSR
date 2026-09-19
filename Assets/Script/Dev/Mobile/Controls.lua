local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local fontName
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local ____Visual = require("Dev/Mobile/Visual")
local RoundedSurface = ____Visual.SceneSurface
local GoIcon = ____Visual.GoIcon
function ____exports.MobileButton(props)
	local height = props.height or 42
	local surfaceRenderOrder = (props.renderOrder or 0) + 1
	local ____React_createElement_3 = React.createElement
	local ____temp_1 = {
		tag = props.tag,
		x = props.x,
		y = props.y,
		anchorX = 0,
		anchorY = 0,
		width = props.width,
		height = height,
		renderOrder = props.renderOrder,
		opacity = props.disabled and 0.4 or 1,
		touchEnabled = not props.disabled,
		swallowTouches = true,
		onTapped = props.onTapped,
		onMount = pressFeedback
	}
	local ____React_createElement_result_2 = React.createElement(RoundedSurface, {
		width = props.width,
		height = height,
		radius = props.segmented and 5 or goTheme.radius,
		renderOrder = surfaceRenderOrder,
		topColor = props.segmented and (props.selected and 4294967295 or 0) or (props.danger and 4294935941 or (props.primary and goTheme.brand or goTheme.button)),
		bottomColor = props.segmented and (props.selected and 4294967295 or 0) or (props.danger and 4292824662 or (props.primary and goTheme.brand or goTheme.button)),
		borderWidth = props.segmented and 0 or 1,
		borderColor = props.danger and 4294929259 or (props.primary and 4292592477 or goTheme.buttonBorder),
		shadow = false
	})
	local ____props_icon_0
	if props.icon then
		____props_icon_0 = React.createElement(GoIcon, {name = props.icon, x = props.text == "" and (props.width - 18) / 2 or 12, y = height / 2 - (props.text == "" and 9 or 7.5), size = props.text == "" and 18 or 15})
	else
		____props_icon_0 = nil
	end
	return ____React_createElement_3(
		"node",
		____temp_1,
		____React_createElement_result_2,
		____props_icon_0,
		React.createElement("label", {
			x = props.width / 2 + (props.icon and 10 or 0),
			y = height / 2,
			fontName = fontName,
			fontSize = props.fontSize or 12,
			text = props.text,
			color3 = props.segmented and (props.selected and 4806208 or 8752761) or (props.primary and 5392671 or 6253120)
		})
	)
end
fontName = goTheme.font
function ____exports.MobileNewButton(props)
	return React.createElement(
		____exports.MobileButton,
		__TS__ObjectAssign({}, props, {width = 76, height = 32, fontSize = 11, icon = "plus"})
	)
end
function ____exports.MobileChoiceButton(props)
	local ____React_createElement_13 = React.createElement
	local ____temp_11 = {
		tag = props.tag,
		x = props.x,
		y = props.y,
		width = props.width,
		height = 40,
		anchorX = 0,
		anchorY = 0,
		renderOrder = props.renderOrder,
		opacity = props.disabled and 0.45 or 1,
		touchEnabled = not props.disabled,
		swallowTouches = true,
		onTapped = props.onTapped,
		onMount = pressFeedback
	}
	local ____React_createElement_7 = React.createElement
	local ____RoundedSurface_6 = RoundedSurface
	local ____props_width_5 = props.width
	local ____temp_4
	if props.renderOrder == nil then
		____temp_4 = nil
	else
		____temp_4 = props.renderOrder + 1
	end
	local ____React_createElement_7_result_12 = ____React_createElement_7(____RoundedSurface_6, {
		width = ____props_width_5,
		height = 40,
		radius = 12,
		renderOrder = ____temp_4,
		topColor = props.selected and goTheme.brand or goTheme.panelRaised,
		bottomColor = props.selected and goTheme.brand or goTheme.panelRaised,
		borderWidth = 1,
		borderColor = props.selected and 4292592477 or goTheme.buttonBorder
	})
	local ____React_createElement_10 = React.createElement
	local ____array_9 = __TS__SparseArrayNew(
		"draw-node",
		{tag = props.tag and props.tag .. "-radio" or nil, x = 17, y = 20},
		React.createElement("dot-shape", {radius = 7, color = props.selected and goTheme.text or goTheme.muted}),
		React.createElement("dot-shape", {radius = 5, color = props.selected and 4294954824 or goTheme.panel})
	)
	local ____props_selected_8
	if props.selected then
		____props_selected_8 = React.createElement(
			"draw-node",
			{tag = props.tag and props.tag .. "-radio-dot" or nil},
			React.createElement("dot-shape", {radius = 2.5, color = goTheme.text})
		)
	else
		____props_selected_8 = nil
	end
	__TS__SparseArrayPush(____array_9, ____props_selected_8)
	return ____React_createElement_13(
		"node",
		____temp_11,
		____React_createElement_7_result_12,
		____React_createElement_10(__TS__SparseArraySpread(____array_9)),
		React.createElement("label", {
			x = 32,
			y = 20,
			anchorX = 0,
			fontName = fontName,
			fontSize = 14,
			text = props.text,
			textWidth = props.width - 44,
			alignment = "Left",
			color3 = props.selected and 1512202 or 6253120
		})
	)
end
function ____exports.MobilePanelSurface(props)
	return React.createElement(RoundedSurface, {
		width = props.width,
		height = props.height,
		radius = 24,
		bottomRadius = 0,
		topColor = goTheme.panel,
		bottomColor = goTheme.panel,
		borderWidth = 1,
		borderColor = goTheme.border,
		shadow = true,
		renderOrder = props.renderOrder
	})
end
return ____exports
