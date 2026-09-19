local ____exports = {}
local ____Dora = require("Dora")
local Color3 = ____Dora.Color3
local Label = ____Dora.Label
local Node = ____Dora.Node
local Size = ____Dora.Size
local Vec2 = ____Dora.Vec2
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local toNode = ____DoraX.toNode
local ScrollArea = require("UI/Control/Basic/ScrollArea")
local ____Visual = require("Dev/Mobile/Visual")
local GoIcon = ____Visual.GoIcon
local ____TextInput = require("Dev/Mobile/TextInput")
local inputLength = ____TextInput.inputLength
local inputSlice = ____TextInput.inputSlice
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
--- A one-line summary expands into a three-line, independently scrolling viewport.
function ____exports.Description(props)
	return React.createElement(
		"custom-node",
		{onCreate = function()
			local root = Node()
			root.anchor = Vec2(0, 1)
			root.position = Vec2(props.x, props.y)
			root.tag = props.active and "mobile-feed-description" or ""
			local label = Label(goTheme.font, 13, true)
			label.alignment = "Left"
			label.lineGap = 6
			label.textWidth = -1
			local singleLine = (string.gsub(props.text, "[\r\n]+", " "))
			label.text = singleLine
			local expandable = label.width > props.width - 24 or singleLine ~= props.text
			local summary = singleLine
			if expandable then
				local low = 0
				local high = inputLength(singleLine)
				while low < high do
					local mid = math.floor((low + high + 1) / 2)
					label.text = inputSlice(singleLine, 0, mid) .. "…"
					if label.width <= props.width - 28 then
						low = mid
					else
						high = mid - 1
					end
				end
				summary = inputSlice(singleLine, 0, low) .. "…"
			end
			label.text = "简\n简\n简"
			local expandedHeight = label.height
			label:cleanup()
			local expanded = false
			local render
			render = function()
				root:removeAllChildren()
				root.size = Size(props.width, expanded and expandedHeight or 21)
				local function toggle()
					if not props.active or not expandable then
						return
					end
					expanded = not expanded
					render()
					props.onExpand(expanded, expandedHeight - 21)
				end
				if expanded then
					local text = Label(goTheme.font, 13, true)
					text.color3 = Color3(8159855)
					text.textWidth = props.width - 30
					text.lineGap = 6
					text.alignment = "Left"
					text.text = props.text
					text.anchor = Vec2(0, 1)
					text.position = Vec2(0, expandedHeight)
					local scroll = ScrollArea({
						width = props.width - 30,
						height = expandedHeight,
						viewHeight = math.max(expandedHeight, text.height),
						paddingX = 0,
						paddingY = 0,
						scrollBar = false
					})
					scroll.swallowTouches = true
					scroll:slot("NoneScrollTapped", toggle)
					scroll.tag = "mobile-feed-description-scroll"
					scroll.position = Vec2((props.width - 30) / 2, expandedHeight / 2)
					scroll.view:addChild(text)
					root:addChild(scroll)
				else
					local text = toNode(React.createElement("label", {
						x = 0,
						y = 10.5,
						anchorX = 0,
						fontName = goTheme.font,
						fontSize = 13,
						text = summary,
						color3 = 8159855,
						alignment = "Left"
					}))
					if text then
						root:addChild(text)
					end
				end
				if expandable then
					local button = toNode(React.createElement(
						"node",
						{
							tag = props.active and "mobile-feed-description-toggle" or nil,
							x = expanded and props.width - 28 or 0,
							y = expanded and expandedHeight - 28 or -3,
							width = expanded and 28 or props.width,
							height = 28,
							anchorX = 0,
							anchorY = 0,
							touchEnabled = props.active,
							swallowTouches = true,
							onTapped = toggle,
							onMount = pressFeedback
						},
						React.createElement(
							"node",
							{x = expanded and 14 or props.width - 10, y = 14, angle = expanded and 180 or 0},
							React.createElement(GoIcon, {name = "dropdown", x = -7, y = -7, size = 14})
						)
					))
					if button then
						root:addChild(button)
					end
				end
			end
			render()
			return root
		end}
	)
end
return ____exports
