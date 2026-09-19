local ____exports = {}
local ____Dora = require("Dora")
local App = ____Dora.App
local Ease = ____Dora.Ease
local Node = ____Dora.Node
local Scale = ____Dora.Scale
local Size = ____Dora.Size
local Vec2 = ____Dora.Vec2
--- Scale artwork around its center while keeping the control's hit area stable.
function ____exports.pressFeedback(target)
	local visual
	local function animate(pressed)
		if not visual then
			visual = Node()
			visual.tag = "go-press-visual"
			visual.size = Size(target.width, target.height)
			visual.position = Vec2(target.width / 2, target.height / 2)
			local children = {}
			target:eachChild(function(child)
				children[#children + 1] = child
				return false
			end)
			for ____, child in ipairs(children) do
				child:moveToParent(visual)
			end
			target:addChild(visual)
		end
		visual:stopAllActions()
		visual:perform(Scale(App.reducedMotion and 0 or (pressed and 0.1 or 0.18), visual.scaleX, pressed and not App.reducedMotion and 0.94 or 1, pressed and Ease.OutCubic or Ease.OutBack))
	end
	target:onTapBegan(function() return animate(true) end)
	target:onTapEnded(function() return animate(false) end)
end
return ____exports
