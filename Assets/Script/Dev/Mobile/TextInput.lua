local ____lualib = require("lualib_bundle")
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____Dora = require("Dora")
local App = ____Dora.App
local ClipNode = ____Dora.ClipNode
local Color = ____Dora.Color
local Color3 = ____Dora.Color3
local DrawNode = ____Dora.DrawNode
local Keyboard = ____Dora.Keyboard
local Label = ____Dora.Label
local Node = ____Dora.Node
local Size = ____Dora.Size
local sleep = ____Dora.sleep
local thread = ____Dora.thread
local Vec2 = ____Dora.Vec2
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____Visual = require("Dev/Mobile/Visual")
local roundedRectVerts = ____Visual.roundedRectVerts
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end
____exports.inputSlice = function(text, start, ____end)
	if ____end == nil then
		____end = ____exports.inputLength(text)
	end
	local first = utf8.offset(text, start + 1) or #text + 1
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1
	return string.sub(text, first, last)
end
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end
function ____exports.layoutInput(text, width, advance)
	local x = 0
	local row = 0
	local stops = {{x = 0, row = 0}}
	local display = {}
	for ____, code in utf8.codes(text) do
		local char = utf8.char(code)
		if char == "\n" then
			display[#display + 1] = char
			row = row + 1
			x = 0
		else
			local step = advance(char)
			if x > 0 and x + step > width then
				display[#display + 1] = "\n"
				row = row + 1
				x = 0
				stops[#stops] = {x = x, row = row}
			end
			display[#display + 1] = char
			x = x + step
		end
		stops[#stops + 1] = {x = x, row = row}
	end
	return {
		text = table.concat(display, ""),
		stops = stops,
		rows = row + 1
	}
end
function ____exports.createTextInputView(input, fontSize, singleLine, background, borderless, fontName)
	if singleLine == nil then
		singleLine = false
	end
	if background == nil then
		background = 4294638581
	end
	if borderless == nil then
		borderless = false
	end
	if fontName == nil then
		fontName = goTheme.font
	end
	local fill = DrawNode()
	fill:drawPolygon(
		roundedRectVerts(input.width, input.height, 12),
		Color(background)
	)
	input:addChild(fill, -2)
	local border = DrawNode()
	border.tag = input.tag .. "-border"
	border.color3 = Color3(13160891)
	border:drawPolygon(
		roundedRectVerts(input.width, input.height, 12),
		Color(0),
		1,
		Color(4294967295)
	)
	input:addChild(border, -1)
	fill.visible = not borderless
	border.visible = not borderless
	local insetX = 12
	local insetY = 8
	local width = math.max(1, input.width - insetX * 2 - 2)
	local height = math.max(1, input.height - insetY * 2)
	local lineHeight = fontSize + 4
	local function makeLabel()
		local label = Label(fontName, fontSize, true)
		if not label then
			error(
				__TS__New(Error, "Missing mobile input font"),
				0
			)
		end
		label.alignment = "Left"
		label.anchor = Vec2(0, 1)
		label.textWidth = -1
		return label
	end
	local measure = makeLabel()
	measure.tag = "remix-input-measure"
	measure.visible = false
	input:addChild(measure)
	measure.batched = false
	measure.text = "M"
	local ____opt_0 = measure:getCharacter(1)
	local markerX = ____opt_0 and ____opt_0.x or 0
	local singleHeight = measure.height
	measure.text = "M\nM"
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight)
	local widths = {}
	local function advance(char)
		if widths[char] ~= nil then
			return widths[char]
		end
		measure.text = char .. "M"
		local ____math_max_4 = math.max
		local ____opt_2 = measure:getCharacter(2)
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX)
		widths[char] = step
		return step
	end
	local stencil = DrawNode()
	stencil:drawPolygon(
		{
			Vec2.zero,
			Vec2(width + 2, 0),
			Vec2(width + 2, height),
			Vec2(0, height)
		},
		Color(4294967295)
	)
	local clip = ClipNode(stencil)
	clip.tag = "remix-input-clip"
	clip.anchor = Vec2.zero
	clip.position = Vec2(insetX, insetY)
	clip.size = Size(width + 2, height)
	input:addChild(clip, 1)
	local content = Node()
	content.tag = "remix-input-content"
	clip:addChild(content)
	local label = makeLabel()
	label.tag = "remix-input-text"
	label.lineGap = gap
	label.color3 = Color3(3159339)
	content:addChild(label)
	local placeholder = makeLabel()
	placeholder.tag = "remix-input-placeholder"
	placeholder.lineGap = gap
	local textTop = singleLine and (height + singleHeight) / 2 or height
	placeholder.textWidth = singleLine and -1 or width
	placeholder.y = textTop
	placeholder.color3 = Color3(9147006)
	clip:addChild(placeholder)
	local caret = DrawNode()
	caret.tag = "remix-input-caret"
	caret:drawPolygon(
		{
			Vec2.zero,
			Vec2(1, 0),
			Vec2(1, fontSize + 2),
			Vec2(0, fontSize + 2)
		},
		Color(4294954035)
	)
	content:addChild(caret)
	local layout = ____exports.layoutInput("", width, advance)
	local lastText = ""
	local active = false
	local blink = 0
	local offset = 0
	local index = 0
	local function maxOffset()
		return math.max(0, singleLine and layout.stops[#layout.stops].x - width or layout.rows * lineHeight - height)
	end
	local function position()
		content.x = singleLine and -offset or 0
		content.y = singleLine and 0 or offset
		label.y = textTop
		local stop = layout.stops[index + 1]
		caret.position = Vec2(
			singleLine and stop.x or math.min(width, stop.x),
			singleLine and (height - fontSize - 2) / 2 or height - stop.row * lineHeight - fontSize - 2
		)
	end
	local function follow()
		local stop = layout.stops[index + 1]
		if singleLine then
			if stop.x < offset then
				offset = stop.x
			end
			if stop.x > offset + width then
				offset = stop.x - width
			end
		else
			local top = stop.row * lineHeight
			if top < offset then
				offset = top
			end
			if top + lineHeight > offset + height then
				offset = top + lineHeight - height
			end
		end
		offset = math.max(
			0,
			math.min(
				maxOffset(),
				offset
			)
		)
		position()
	end
	caret:schedule(function(dt)
		blink = blink + dt
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion)
		return false
	end)
	local function nearest(x, row)
		local closest = 0
		local distance = math.huge
		__TS__ArrayForEach(
			layout.stops,
			function(____, stop, i)
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x)
				if d < distance then
					distance = d
					closest = i
				end
			end
		)
		return closest
	end
	return {
		label = label,
		caret = caret,
		placeholder = placeholder,
		clip = clip,
		border = border,
		update = function(text, hint, focused, cursor)
			if singleLine then
				text = (string.gsub(text, "[\r\n]", ""))
			end
			if lastText ~= text then
				layout = ____exports.layoutInput(text, singleLine and math.huge or width, advance)
				label.text = layout.text
				lastText = text
			end
			placeholder.text = hint
			placeholder.visible = text == "" and not focused
			border.color3 = Color3(focused and 11965479 or 13160891)
			active = focused
			index = math.max(
				0,
				math.min(#layout.stops - 1, cursor)
			)
			blink = 0
			caret.visible = active
			follow()
		end,
		caretPosition = function() return Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y) end,
		indexAt = function(point) return nearest(
			point.x - insetX - content.x,
			singleLine and 0 or math.max(
				0,
				math.floor((height + offset - (point.y - insetY)) / lineHeight)
			)
		) end,
		verticalIndex = function(cursor, direction)
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1]
			return nearest(stop.x, stop.row + direction)
		end,
		scroll = function(delta)
			offset = math.max(
				0,
				math.min(
					maxOffset(),
					offset + delta
				)
			)
			position()
		end
	}
end
function ____exports.createTextInput(options)
	local node
	local view
	local focused = false
	local composition = ""
	local compositionCursor = 0
	local cursor = 0
	local revision = 0
	local dragDistance = 0
	local function normalize(text)
		return options.singleLine and (string.gsub(text, "[\r\n]", "")) or (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n"))
	end
	local function updateIMEPos(next)
		local target = node
		if not target or not view then
			return
		end
		local captured = revision
		local caret = view.caretPosition()
		target:convertToWindowSpace(
			Vec2(
				math.max(
					12,
					math.min(target.width - 12, caret.x)
				),
				math.max(
					8,
					math.min(target.height - 8, caret.y)
				)
			),
			function(pos)
				if node ~= target or captured ~= revision or not options.isEnabled() then
					return
				end
				Keyboard:updateIMEPosHint(pos)
				if next ~= nil then
					next()
				end
			end
		)
	end
	local function refresh()
		local text = options.getText()
		cursor = math.min(
			cursor,
			____exports.inputLength(text)
		)
		local editing = ____exports.insertInputText(text, cursor, composition)
		local ____this_8
		____this_8 = options
		local ____opt_7 = ____this_8.isSecure
		local display = ____opt_7 and ____opt_7(____this_8) and string.rep(
			"•",
			____exports.inputLength(editing)
		) or editing
		if view ~= nil then
			view.update(
				display,
				options.getPlaceholder(),
				focused,
				cursor + compositionCursor
			)
		end
		if focused then
			updateIMEPos()
		end
	end
	local function clearFocus()
		revision = revision + 1
		focused = false
		composition = ""
		compositionCursor = 0
		if node then
			node.keyboardEnabled = false
		end
		refresh()
	end
	local function blur()
		if focused then
			if node ~= nil then
				node:detachIME()
			end
		end
		clearFocus()
	end
	local function focus(reopen)
		if reopen == nil then
			reopen = true
		end
		if not options.isEnabled() then
			return
		end
		revision = revision + 1
		updateIMEPos(function()
			if reopen then
				if node ~= nil then
					node:detachIME()
				end
			end
			if node ~= nil then
				node:attachIME()
			end
			updateIMEPos()
		end)
	end
	local function setValue(text, at)
		options.setText(text)
		cursor = at
		refresh()
	end
	local function textInput(text)
		if not options.isEnabled() then
			return
		end
		composition = ""
		compositionCursor = 0
		local value = normalize(text)
		setValue(
			____exports.insertInputText(
				options.getText(),
				cursor,
				value
			),
			cursor + ____exports.inputLength(value)
		)
	end
	local function keyInput(key)
		if not options.isEnabled() then
			return
		end
		if key == "Escape" then
			blur()
			return
		end
		if composition ~= "" then
			return
		end
		local value = options.getText()
		if key == "BackSpace" and cursor > 0 then
			setValue(
				____exports.inputSlice(value, 0, cursor - 1) .. ____exports.inputSlice(value, cursor),
				cursor - 1
			)
		elseif key == "Delete" and cursor < ____exports.inputLength(value) then
			setValue(
				____exports.inputSlice(value, 0, cursor) .. ____exports.inputSlice(value, cursor + 1),
				cursor
			)
		elseif key == "Home" or key == "End" or key == "Left" or key == "Right" or key == "Up" or key == "Down" then
			cursor = key == "Home" and 0 or (key == "End" and ____exports.inputLength(value) or ((key == "Up" or key == "Down") and (view and view.verticalIndex(cursor, key == "Up" and -1 or 1) or cursor) or math.max(
				0,
				math.min(
					____exports.inputLength(value),
					cursor + (key == "Left" and -1 or 1)
				)
			)))
			refresh()
		elseif key == "Return" then
			local modified = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui")
			local ____opt_19 = options.onReturn
			if not (____opt_19 and ____opt_19(modified)) and not options.singleLine then
				textInput("\n")
			end
		end
	end
	local function unmount()
		blur()
		node = nil
		view = nil
	end
	return {
		refresh = refresh,
		focus = focus,
		blur = blur,
		unmount = unmount,
		pasteFromClipboard = function(replace)
			if replace == nil then
				replace = false
			end
			if not options.isEnabled() then
				return false
			end
			local value = normalize(App:getClipboardText())
			if value == "" then
				return false
			end
			if replace then
				setValue(
					value,
					____exports.inputLength(value)
				)
			else
				textInput(value)
			end
			return true
		end,
		isFocused = function() return focused end,
		isComposing = function() return composition ~= "" end,
		deferFocus = function()
			local captured = revision
			thread(function()
				sleep(0)
				if captured == revision then
					focus()
				end
			end)
		end,
		mount = function(target)
			unmount()
			node = target
			view = ____exports.createTextInputView(
				target,
				options.fontSize,
				options.singleLine,
				options.background,
				options.borderless,
				options.fontName
			)
			target.touchEnabled = true
			target.swallowTouches = true
			target:slot(
				"GamepadActivate",
				function()
					if options.isEnabled() then
						focus()
					end
				end
			)
			target:onAttachIME(function()
				focused = true
				composition = ""
				compositionCursor = 0
				target.keyboardEnabled = true
				refresh()
			end)
			target:onDetachIME(clearFocus)
			target:onTextInput(textInput)
			target:onTextEditing(function(text, start)
				if not options.isEnabled() then
					return
				end
				composition = normalize(text)
				compositionCursor = math.max(
					0,
					math.min(
						____exports.inputLength(composition),
						start or ____exports.inputLength(composition)
					)
				)
				refresh()
			end)
			target:onKeyDown(keyInput)
			target.keyboardEnabled = false
			target:onTapBegan(function()
				dragDistance = 0
			end)
			target:onTapMoved(function(touch)
				if not options.isEnabled() then
					return
				end
				dragDistance = dragDistance + (math.abs(touch.delta.x) + math.abs(touch.delta.y))
				if view ~= nil then
					view.scroll(options.singleLine and -touch.delta.x or touch.delta.y)
				end
				if focused then
					updateIMEPos()
				end
			end)
			target:onMouseWheel(function(delta)
				if not options.isEnabled() then
					return
				end
				if view ~= nil then
					view.scroll(-delta.y * 20)
				end
				if focused then
					updateIMEPos()
				end
			end)
			target:onTapped(function(touch)
				if dragDistance > 5 or not options.isEnabled() then
					return
				end
				if touch ~= nil and composition == "" then
					cursor = view and view.indexAt(touch.location) or cursor
				end
				refresh()
				if not focused then
					focus()
				end
			end)
			target:onCleanup(function()
				if node == target then
					unmount()
				end
			end)
			refresh()
		end
	}
end
return ____exports
