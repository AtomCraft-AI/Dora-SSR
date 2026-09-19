local ____exports = {}
local ____Dora = require("Dora")
local App = ____Dora.App
local Color = ____Dora.Color
local Color3 = ____Dora.Color3
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Vec2 = ____Dora.Vec2
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
--- A short, non-interactive hint; its owner removes it on any input.
function ____exports.createGestureGuide(zh)
	local node = Node()
	node.tag = "go-gesture-guide"
	local light = DrawNode()
	light:addTo(node)
	local caption = Label(goTheme.font, 12, true)
	caption.color3 = Color3(6845253)
	caption:addTo(node)
	local elapsed = 0
	node:schedule(function(dt)
		elapsed = elapsed + dt
		if elapsed >= 4.4 or App.reducedMotion then
			node:removeFromParent(true)
			return true
		end
		local phase = elapsed < 2.2 and 0 or 1
		local t = (elapsed - phase * 2.2) / 1.5
		light:clear()
		caption.visible = t > 0.2 and t < 1
		if t > 1 then
			return false
		end
		local function progress(v)
			local x = math.max(
				0,
				math.min(1, v)
			)
			return x * x * (3 - 2 * x)
		end
		local function point(v)
			return phase == 0 and Vec2(
				0,
				-62 + progress(v) * 145
			) or Vec2(
				88 - progress(v) * 176,
				12
			)
		end
		do
			local i = 10
			while i >= 0 do
				local p = point(t - i * 0.015)
				local alpha = math.floor((1 - i / 12) * math.min(1, t * 8, (1 - t) * 8) * 190)
				light:drawDot(
					p,
					i == 0 and 6 or 4 - i * 0.25,
					Color(alpha * 16777216 + 16777215)
				)
				i = i - 1
			end
		end
		local tail = point(t - 0.14)
		caption.text = phase == 0 and (zh and "下一个" or "Next") or (zh and "进入游戏" or "Play")
		caption.position = Vec2(
			tail.x + (phase == 0 and 28 or 0),
			tail.y - 22 + math.sin(math.min(1, (t - 0.2) * 4) * math.pi) * 9
		)
		return false
	end)
	return node
end
return ____exports
