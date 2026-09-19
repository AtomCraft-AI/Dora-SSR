local ____exports = {}
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local ____Visual = require("Dev/Mobile/Visual")
local RoundedStencil = ____Visual.RoundedStencil
local ____FeedModel = require("Dev/Mobile/FeedModel")
local getCoverScales = ____FeedModel.getCoverScales
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
function ____exports.Cartridge(props)
	local function art(sprite)
		local scale = getCoverScales(sprite.width, sprite.height, 184, 167).cover
		sprite.scaleX = scale
		sprite.scaleY = scale
	end
	local ____React_createElement_5 = React.createElement
	local ____temp_3 = {
		tag = "go-cartridge",
		x = props.x,
		y = props.y,
		width = 236,
		height = 308,
		anchorX = 0,
		anchorY = 0,
		scaleX = props.width / 236,
		scaleY = props.height / 308
	}
	local ____React_createElement_result_4 = React.createElement("sprite", {
		file = "Image/GoUI/cartridge.png",
		x = 118,
		y = 154,
		scaleX = 1 / 3,
		scaleY = 1 / 3
	})
	local ____React_createElement_2 = React.createElement
	local ____temp_1 = {
		x = 26,
		y = 82,
		width = 184,
		height = 167,
		anchorX = 0,
		anchorY = 0,
		stencil = React.createElement(RoundedStencil, {width = 184, height = 167, radius = 2})
	}
	local ____props_entry_bannerFile_0
	if props.entry.bannerFile then
		____props_entry_bannerFile_0 = React.createElement("sprite", {file = props.entry.bannerFile, x = 92, y = 83.5, onMount = art})
	else
		____props_entry_bannerFile_0 = React.createElement(
			"node",
			nil,
			React.createElement(
				"draw-node",
				{x = 92, y = 83.5},
				React.createElement("rect-shape", {width = 184, height = 167, fillColor = 4293389023})
			),
			React.createElement("label", {
				x = 92,
				y = 83.5,
				fontName = goTheme.font,
				fontSize = 18,
				text = props.entry.title,
				textWidth = 156,
				color3 = 6253120
			})
		)
	end
	return ____React_createElement_5(
		"node",
		____temp_3,
		____React_createElement_result_4,
		____React_createElement_2("clip-node", ____temp_1, ____props_entry_bannerFile_0)
	)
end
function ____exports.CartridgeSlot(props)
	return React.createElement(
		"node",
		{
			x = props.x,
			y = props.y,
			width = 162,
			height = 280,
			anchorX = 0,
			anchorY = 0
		},
		React.createElement("sprite", {
			file = "Image/GoUI/console.png",
			x = 81,
			y = 140,
			scaleX = 1 / 3,
			scaleY = 1 / 3
		})
	)
end
return ____exports
