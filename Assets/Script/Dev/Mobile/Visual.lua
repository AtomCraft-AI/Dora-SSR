local ____lualib = require("lualib_bundle")
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayPush = ____lualib.__TS__ArrayPush
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local ____exports = {}
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local ____Dora = require("Dora")
local Color = ____Dora.Color
local Node = ____Dora.Node
local Size = ____Dora.Size
local Vec2 = ____Dora.Vec2
local nvg = require("nvg")
--- NanoVG surface following Dora-Example/UIX's PaintNode + roundedPanel pattern.
function ____exports.RoundedSurface(props)
	local function onCreate()
		local node = Node()
		node.anchor = Vec2.zero
		node.size = Size(props.width, props.height)
		node:onRender(function()
			nvg.Save()
			nvg.ApplyTransform(node)
			local radius = math.max(
				0,
				math.min(props.radius, props.width / 2, props.height / 2)
			)
			if props.shadow then
				nvg.BeginPath()
				nvg.RoundedRect(
					2,
					-3,
					props.width,
					props.height,
					radius
				)
				nvg.FillColor(Color(1375731712))
				nvg.Fill()
			end
			nvg.BeginPath()
			nvg.RoundedRect(
				0,
				0,
				props.width,
				props.height,
				radius
			)
			if props.topColor ~= nil and props.bottomColor ~= nil then
				nvg.FillPaint(nvg.LinearGradient(
					0,
					props.height,
					0,
					0,
					Color(props.topColor),
					Color(props.bottomColor)
				))
			else
				nvg.FillColor(Color(props.fillColor or 4294967295))
			end
			nvg.Fill()
			local borderWidth = props.borderWidth or 0
			if borderWidth > 0 then
				nvg.BeginPath()
				nvg.RoundedRect(
					borderWidth / 2,
					borderWidth / 2,
					props.width - borderWidth,
					props.height - borderWidth,
					math.max(0, radius - borderWidth / 2)
				)
				nvg.StrokeWidth(borderWidth)
				nvg.StrokeColor(Color(props.borderColor or 4294967295))
				nvg.Stroke()
			end
			nvg.Restore()
			return false
		end)
		return node
	end
	return React.createElement("custom-node", {
		x = props.x or 0,
		y = props.y or 0,
		width = props.width,
		height = props.height,
		opacity = props.opacity or 1,
		renderOrder = props.renderOrder,
		onCreate = onCreate
	})
end
function ____exports.VerticalGradient(props)
	local function onCreate()
		local node = Node()
		node.anchor = Vec2.zero
		node.size = Size(props.width, props.height)
		node:onRender(function()
			nvg.Save()
			nvg.ApplyTransform(node)
			nvg.BeginPath()
			nvg.Rect(0, 0, props.width, props.height)
			nvg.FillPaint(nvg.LinearGradient(
				0,
				props.height,
				0,
				0,
				Color(props.topColor),
				Color(props.bottomColor)
			))
			nvg.Fill()
			nvg.Restore()
			return false
		end)
		return node
	end
	return React.createElement("custom-node", {
		x = props.x or 0,
		y = props.y or 0,
		width = props.width,
		height = props.height,
		onCreate = onCreate
	})
end
function ____exports.roundedRectVerts(width, height, radius, bottomRadius)
	if bottomRadius == nil then
		bottomRadius = radius
	end
	local r = math.max(
		0,
		math.min(radius, width / 2, height / 2)
	)
	local b = math.max(
		0,
		math.min(bottomRadius, width / 2, height / 2)
	)
	local verts = {}
	local corners = {{x = width - b, y = b, r = b, start = -math.pi / 2}, {x = width - r, y = height - r, r = r, start = 0}, {x = r, y = height - r, r = r, start = math.pi / 2}, {x = b, y = b, r = b, start = math.pi}}
	for ____, corner in ipairs(corners) do
		do
			local step = 0
			while step <= 12 do
				local angle = corner.start + step * math.pi / 24
				verts[#verts + 1] = Vec2(
					corner.x + math.cos(angle) * corner.r,
					corner.y + math.sin(angle) * corner.r
				)
				step = step + 1
			end
		end
	end
	return verts
end
--- Stencil-only rounded path for clipping sprites and other scene nodes.
function ____exports.RoundedStencil(props)
	return React.createElement(
		"draw-node",
		nil,
		React.createElement(
			"polygon-shape",
			{
				verts = ____exports.roundedRectVerts(props.width, props.height, props.radius),
				fillColor = 4294967295
			}
		)
	)
end
--- Ordered surfaces with a subpixel alpha fringe instead of hard polygon strokes.
function ____exports.SceneSurface(props)
	local w = props.width
	local h = props.height
	local top = Color(props.topColor or props.fillColor or 4294967295)
	local bottom = Color(props.bottomColor or props.fillColor or 4294967295)
	local function shade(y)
		local t = math.max(
			0,
			math.min(
				1,
				y / math.max(1, h)
			)
		)
		return math.floor(bottom.a + (top.a - bottom.a) * t) * 16777216 + math.floor(bottom.r + (top.r - bottom.r) * t) * 65536 + math.floor(bottom.g + (top.g - bottom.g) * t) * 256 + math.floor(bottom.b + (top.b - bottom.b) * t)
	end
	local function faded(c, alpha)
		return math.floor(Color(c).a * alpha) * 16777216 + c % 16777216
	end
	local function loop(inset)
		return __TS__ArrayMap(
			____exports.roundedRectVerts(
				math.max(0, w - 2 * inset),
				math.max(0, h - 2 * inset),
				math.max(0, props.radius - inset),
				math.max(0, (props.bottomRadius or props.radius) - inset)
			),
			function(____, p) return Vec2(p.x + inset, p.y + inset) end
		)
	end
	local triangles = {}
	local function ring(outer, inner, outerColor, innerColor)
		local a = loop(outer)
		local b = loop(inner)
		do
			local i = 0
			while i < #a do
				local j = (i + 1) % #a
				__TS__ArrayPush(
					triangles,
					{
						a[i + 1],
						outerColor(a[i + 1].y)
					},
					{
						a[j + 1],
						outerColor(a[j + 1].y)
					},
					{
						b[i + 1],
						innerColor(b[i + 1].y)
					},
					{
						a[j + 1],
						outerColor(a[j + 1].y)
					},
					{
						b[j + 1],
						innerColor(b[j + 1].y)
					},
					{
						b[i + 1],
						innerColor(b[i + 1].y)
					}
				)
				i = i + 1
			end
		end
	end
	local edge = 0.6
	local inner = loop(edge)
	do
		local i = 0
		while i < #inner do
			local a = inner[i + 1]
			local b = inner[(i + 1) % #inner + 1]
			__TS__ArrayPush(
				triangles,
				{
					Vec2(w / 2, h / 2),
					shade(h / 2)
				},
				{
					a,
					shade(a.y)
				},
				{
					b,
					shade(b.y)
				}
			)
			i = i + 1
		end
	end
	ring(
		-0.2,
		edge,
		function(y) return faded(
			shade(y),
			0
		) end,
		shade
	)
	local border = props.borderWidth or 0
	local ink = props.borderColor or 4294967295
	if border > 0 then
		ring(
			-0.25,
			0.4,
			function() return faded(ink, 0) end,
			function() return ink end
		)
		if border > 0.8 then
			ring(
				0.4,
				border - 0.4,
				function() return ink end,
				function() return ink end
			)
		end
		ring(
			math.max(0.4, border - 0.4),
			border + 0.25,
			function() return ink end,
			function() return faded(ink, 0) end
		)
	end
	local faces = {}
	do
		local i = 0
		while i < #triangles do
			faces[#faces + 1] = __TS__ArraySlice(triangles, i, i + 3)
			i = i + 3
		end
	end
	return React.createElement(
		"node",
		{x = props.x or 0, y = props.y or 0, opacity = props.opacity or 1, renderOrder = props.renderOrder},
		props.shadow and __TS__ArrayMap(
			{
				5,
				4,
				3,
				2,
				1
			},
			function(____, i) return React.createElement(
				"draw-node",
				{x = 0, y = -2},
				React.createElement(
					"polygon-shape",
					{
						verts = loop(-i),
						fillColor = 37438767
					}
				)
			) end
		) or nil,
		React.createElement(
			"draw-node",
			nil,
			__TS__ArrayMap(
				faces,
				function(____, face) return React.createElement("verts-shape", {verts = face}) end
			)
		)
	)
end
function ____exports.GoIcon(props)
	local size = props.size or 20
	local color = props.color or 4284178772
	return React.createElement(
		"sprite",
		{
			file = ("Image/GoUI/icon-" .. props.name) .. ".png",
			x = (props.x or 0) + size / 2,
			y = (props.y or 0) + size / 2,
			scaleX = size / 72,
			scaleY = size / 72,
			color3 = color % 16777216,
			opacity = math.floor(color / 16777216) / 255
		}
	)
end
return ____exports
