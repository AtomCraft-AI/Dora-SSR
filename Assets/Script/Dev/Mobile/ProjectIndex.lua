local ____lualib = require("lualib_bundle")
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex
local ____exports = {}
local ____Theme = require("Dev/Mobile/Theme")
local goTheme = ____Theme.goTheme
local ____Visual = require("Dev/Mobile/Visual")
local GoIcon = ____Visual.GoIcon
local ____Motion = require("Dev/Mobile/Motion")
local pressFeedback = ____Motion.pressFeedback
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local toNode = ____DoraX.toNode
local ____Dora = require("Dora")
local Color = ____Dora.Color
local Color3 = ____Dora.Color3
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Size = ____Dora.Size
local Vec2 = ____Dora.Vec2
local ScrollArea = require("UI/Control/Basic/ScrollArea")
local ____Gamepad = require("Dev/Mobile/Gamepad")
local attachGamepad = ____Gamepad.attachGamepad
local selectGamepadNode = ____Gamepad.selectGamepadNode
local ____FeedModel = require("Dev/Mobile/FeedModel")
local groupFeedProjects = ____FeedModel.groupFeedProjects
local fontName = goTheme.font
local headerHeight = 72
local railWidth = 48
local groupHeight = 36
local rowHeight = 48
local function ellipsize(text, limit)
	local length = (utf8.len(text)) or 0
	if length <= limit then
		return text
	end
	local stop = utf8.offset(
		text,
		math.max(2, limit)
	) or #text
	return string.sub(text, 1, stop - 1) .. "…"
end
local function addLabel(parent, text, size, color, x, y, anchor)
	if anchor == nil then
		anchor = Vec2(0, 0.5)
	end
	local label = Label(fontName, size, true)
	label.text = text
	label.color3 = Color3(color)
	label.position = Vec2(x, y)
	label.anchor = anchor
	label.renderOrder = 15002
	label:addTo(parent)
	return label
end
local function roundedVerts(x, y, width, height, radius)
	local verts = {}
	local r = math.max(
		0,
		math.min(radius, width / 2, height / 2)
	)
	local corners = {{x = x + width - r, y = y + r, start = -math.pi / 2}, {x = x + width - r, y = y + height - r, start = 0}, {x = x + r, y = y + height - r, start = math.pi / 2}, {x = x + r, y = y + r, start = math.pi}}
	for ____, corner in ipairs(corners) do
		do
			local step = 0
			while step <= 6 do
				local angle = corner.start + step * math.pi / 12
				verts[#verts + 1] = Vec2(
					corner.x + math.cos(angle) * r,
					corner.y + math.sin(angle) * r
				)
				step = step + 1
			end
		end
	end
	return verts
end
function ____exports.ProjectIndex(props)
	local function onCreate()
		local root = Node()
		root.tag = "mobile-project-index"
		root.anchor = Vec2.zero
		root.size = Size(props.width, props.height)
		root.renderGroup = true
		root.renderOrder = 15000
		root.touchEnabled = true
		root.swallowTouches = true
		local discover = props.kind == "discover"
		local canRefresh = discover and props.onRefresh ~= nil
		local footerHeight = canRefresh and 64 or 36
		addLabel(
			root,
			((discover and (props.zh and "发现作品" or "DISCOVER") or (props.zh and "本地作品" or "LOCAL")) .. " · ") .. tostring(#props.entries),
			18,
			4281349419,
			16,
			props.height - 34
		)
		local back = Node()
		back.tag = "mobile-project-index-back"
		back.anchor = Vec2.zero
		back.position = Vec2(props.width - 96, props.height - 62)
		back.size = Size(80, 44)
		back.touchEnabled = true
		back.swallowTouches = true
		local backIcon = toNode(GoIcon({name = "next", x = 68, y = 13, size = 18}))
		if backIcon then
			back:addChild(backIcon)
		end
		pressFeedback(back)
		back:onTapped(props.onClose)
		back:addTo(root)
		addLabel(
			back,
			props.zh and "返回" or "Back",
			14,
			4287788327,
			60,
			22,
			Vec2(1, 0.5)
		)
		local groups = groupFeedProjects(props.entries)
		local listX = railWidth + 8
		local listWidth = math.max(40, props.width - listX - 14)
		local listHeight = math.max(40, props.height - headerHeight - footerHeight)
		local scroll = ScrollArea({
			width = listWidth,
			height = listHeight,
			paddingX = 0,
			paddingY = 28,
			scrollBar = false
		})
		scroll.tag = "mobile-project-index-scroll"
		scroll.position = Vec2(listX + listWidth / 2, footerHeight + listHeight / 2)
		scroll:addTo(root)
		local flat = {}
		local groupOffsets = {}
		local total = 0
		do
			local groupIndex = 0
			while groupIndex < #groups do
				local group = groups[groupIndex + 1]
				groupOffsets[#groupOffsets + 1] = total
				local heading = Node()
				heading.tag = "mobile-project-index-group-" .. group.key
				heading.anchor = Vec2(0, 1)
				heading.position = Vec2(0, listHeight - total)
				heading.size = Size(listWidth, groupHeight)
				heading:addTo(scroll.view)
				local groupTitle = group.key == "#" and (props.zh and "其它" or "Other") or group.key
				local headingBg = DrawNode()
				headingBg:drawSegment(
					Vec2(38, 18),
					Vec2(listWidth - 4, 18),
					0.5,
					Color(4292007621)
				)
				headingBg:addTo(heading)
				addLabel(
					heading,
					groupTitle,
					12,
					4287788327,
					8,
					18
				)
				total = total + groupHeight
				for ____, entry in ipairs(group.entries) do
					local row = Node()
					row.tag = "mobile-project-index-entry-" .. tostring(#flat)
					row.anchor = Vec2(0, 1)
					row.position = Vec2(0, listHeight - total)
					row.size = Size(listWidth, rowHeight)
					pressFeedback(row)
					row.touchEnabled = true
					row.swallowTouches = true
					row:onTapped(function() return props:onSelect(entry) end)
					row:addTo(scroll.view)
					local ____temp_4 = entry == props.current
					if not ____temp_4 then
						local ____temp_3 = entry.fileName ~= nil
						if ____temp_3 then
							local ____entry_fileName_2 = entry.fileName
							local ____opt_0 = props.current
							____temp_3 = ____entry_fileName_2 == (____opt_0 and ____opt_0.fileName)
						end
						____temp_4 = ____temp_3
					end
					local ____temp_4_9 = ____temp_4
					if not ____temp_4_9 then
						local ____temp_8 = entry.workDir ~= nil
						if ____temp_8 then
							local ____entry_workDir_7 = entry.workDir
							local ____opt_5 = props.current
							____temp_8 = ____entry_workDir_7 == (____opt_5 and ____opt_5.workDir)
						end
						____temp_4_9 = ____temp_8
					end
					local selected = ____temp_4_9
					local rowBg = DrawNode()
					rowBg:drawSegment(
						Vec2(8, 1),
						Vec2(listWidth - 8, 1),
						0.5,
						Color(4292007621)
					)
					if selected then
						rowBg:drawSegment(
							Vec2(5, 13),
							Vec2(5, rowHeight - 13),
							1.5,
							Color(4287788327)
						)
					end
					rowBg:addTo(row)
					addLabel(
						row,
						ellipsize(
							entry.title,
							math.max(
								8,
								math.floor((listWidth - 54) / 9)
							)
						),
						14,
						selected and 4287788327 or 4281349419,
						16,
						rowHeight / 2
					)
					flat[#flat + 1] = {entry = entry, node = row, groupIndex = groupIndex, centerFromTop = total + rowHeight / 2}
					total = total + rowHeight
				end
				groupIndex = groupIndex + 1
			end
		end
		if #groups == 0 then
			addLabel(
				scroll.view,
				discover and (props.zh and "暂无发现作品" or "No discovered games yet") or (props.zh and "还没有本地作品" or "No local games yet"),
				14,
				4286349935,
				listWidth / 2,
				listHeight / 2,
				Vec2(0.5, 0.5)
			)
		end
		scroll:resetSize(listWidth, listHeight, listWidth, total)
		local function maxOffset()
			return math.max(0, total - listHeight)
		end
		local function scrollTo(centerFromTop)
			scroll:unschedule()
			scroll.offset = Vec2(
				0,
				math.max(
					0,
					math.min(
						maxOffset(),
						centerFromTop - listHeight / 2
					)
				)
			)
			scroll.view:moveAndCullItems(Vec2.zero)
		end
		local selectedIndex = math.max(
			0,
			__TS__ArrayFindIndex(
				flat,
				function(____, item)
					local ____temp_14 = item.entry == props.current
					if not ____temp_14 then
						local ____temp_13 = item.entry.fileName ~= nil
						if ____temp_13 then
							local ____item_entry_fileName_12 = item.entry.fileName
							local ____opt_10 = props.current
							____temp_13 = ____item_entry_fileName_12 == (____opt_10 and ____opt_10.fileName)
						end
						____temp_14 = ____temp_13
					end
					local ____temp_14_19 = ____temp_14
					if not ____temp_14_19 then
						local ____temp_18 = item.entry.workDir ~= nil
						if ____temp_18 then
							local ____item_entry_workDir_17 = item.entry.workDir
							local ____opt_15 = props.current
							____temp_18 = ____item_entry_workDir_17 == (____opt_15 and ____opt_15.workDir)
						end
						____temp_14_19 = ____temp_18
					end
					return ____temp_14_19
				end
			)
		)
		if flat[selectedIndex + 1] ~= nil then
			scrollTo(flat[selectedIndex + 1].centerFromTop)
		end
		local popup = Node()
		popup.visible = false
		popup.position = Vec2(railWidth + 48, props.height / 2)
		popup:addTo(root)
		local popupShape = DrawNode()
		popupShape:drawPolygon(
			roundedVerts(
				-28,
				-28,
				56,
				56,
				16
			),
			Color(4294638581),
			1,
			Color(4291349417)
		)
		popupShape:addTo(popup)
		local popupLabel = addLabel(
			popup,
			"",
			18,
			4287788327,
			0,
			0,
			Vec2(0.5, 0.5)
		)
		popupLabel.tag = "mobile-project-index-popup-label"
		local rail = Node()
		rail.tag = "mobile-project-index-rail"
		rail.anchor = Vec2.zero
		rail.position = Vec2(0, footerHeight)
		rail.size = Size(railWidth, listHeight)
		rail.touchEnabled = #groups > 0
		rail.swallowTouches = true
		rail:addTo(root)
		local railLabels = {}
		do
			local i = 0
			while i < #groups do
				local y = listHeight - (i + 0.5) * listHeight / #groups
				railLabels[#railLabels + 1] = addLabel(
					rail,
					groups[i + 1].key,
					#groups > 20 and 9 or 11,
					4286349935,
					railWidth / 2,
					y,
					Vec2(0.5, 0.5)
				)
				i = i + 1
			end
		end
		local ____opt_20 = flat[selectedIndex + 1]
		local activeGroup = ____opt_20 and ____opt_20.groupIndex or 0
		local function selectGroup(groupIndex, showPopup, jump)
			if jump == nil then
				jump = true
			end
			if #groups == 0 then
				return
			end
			activeGroup = math.max(
				0,
				math.min(#groups - 1, groupIndex)
			)
			if jump then
				scroll:unschedule()
				scroll.offset = Vec2(
					0,
					math.max(
						0,
						math.min(
							maxOffset(),
							groupOffsets[activeGroup + 1]
						)
					)
				)
				scroll.view:moveAndCullItems(Vec2.zero)
			end
			do
				local i = 0
				while i < #railLabels do
					railLabels[i + 1].color3 = Color3(i == activeGroup and 4287788327 or 8159855)
					i = i + 1
				end
			end
			popupLabel.text = groups[activeGroup + 1].key == "#" and (props.zh and "其它" or "Other") or groups[activeGroup + 1].key
			popup.visible = showPopup
		end
		selectGroup(activeGroup, false, false)
		local function groupAt(worldLocation)
			if #groups == 0 then
				return 0
			end
			local point = rail:convertToNodeSpace(worldLocation)
			popup.y = footerHeight + math.max(
				32,
				math.min(listHeight - 32, point.y)
			)
			return math.max(
				0,
				math.min(
					#groups - 1,
					math.floor((listHeight - point.y) / listHeight * #groups)
				)
			)
		end
		rail:onTapBegan(function(touch) return selectGroup(
			groupAt(touch.worldLocation),
			true
		) end)
		rail:onTapMoved(function(touch) return selectGroup(
			groupAt(touch.worldLocation),
			true
		) end)
		rail:onTapEnded(function()
			popup.visible = false
		end)
		local hint = props.zh and "拖动左侧刻度快速定位" or "Drag the index to jump"
		if canRefresh then
			local refresh = Node()
			refresh.tag = "mobile-project-index-refresh"
			refresh.anchor = Vec2.zero
			refresh.position = Vec2(16, 10)
			refresh.size = Size(76, 44)
			refresh.touchEnabled = not props.refreshing
			refresh.swallowTouches = true
			pressFeedback(refresh)
			refresh:onTapped(function()
				if not props.refreshing then
					local ____this_23
					____this_23 = props
					local ____opt_22 = ____this_23.onRefresh
					if ____opt_22 ~= nil then
						____opt_22(____this_23)
					end
				end
			end)
			refresh:addTo(root)
			local border = DrawNode()
			border.renderOrder = 15001
			border:drawPolygon(
				roundedVerts(
					0,
					6,
					76,
					32,
					16
				),
				Color(0),
				0.5,
				Color(props.refreshing and 4292007621 or 4291349417)
			)
			border:addTo(refresh)
			addLabel(
				refresh,
				props.refreshing and (props.zh and "刷新中…" or "Syncing…") or (props.zh and "刷新" or "Refresh"),
				12,
				props.refreshing and 4286349935 or 4287788327,
				38,
				22,
				Vec2(0.5, 0.5)
			)
			local status = addLabel(
				root,
				"",
				11,
				4286349935,
				104,
				32
			)
			status.tag = "mobile-project-index-refresh-status"
			local function update(message)
				status.text = ellipsize(
					(string.gsub(message ~= "" and message or hint, "[\r\n]+", " ")),
					math.max(
						4,
						math.floor((props.width - 120) / 11)
					)
				)
			end
			update(props.refreshStatus or "")
			local ____this_25
			____this_25 = props
			local ____opt_24 = ____this_25.onStatusReady
			if ____opt_24 ~= nil then
				____opt_24(____this_25, update)
			end
		else
			addLabel(
				root,
				hint,
				9,
				4286349935,
				props.width / 2,
				footerHeight / 2,
				Vec2(0.5, 0.5)
			)
		end
		local function moveSelection(delta)
			if #flat == 0 then
				return
			end
			selectedIndex = math.max(
				0,
				math.min(#flat - 1, selectedIndex + delta)
			)
			activeGroup = flat[selectedIndex + 1].groupIndex
			scrollTo(flat[selectedIndex + 1].centerFromTop)
			selectGroup(activeGroup, false, false)
			selectGamepadNode(root, flat[selectedIndex + 1].node.tag)
		end
		local ____opt_26 = flat[selectedIndex + 1]
		local gamepadOptions = {
			initialTag = ____opt_26 and ____opt_26.node.tag or "mobile-project-index-back",
			onBack = function() return props:onClose() end,
			onScroll = function(amount)
				scroll:unschedule()
				scroll.offset = Vec2(
					0,
					math.max(
						0,
						math.min(
							maxOffset(),
							scroll.offset.y + amount
						)
					)
				)
				scroll.view:moveAndCullItems(Vec2.zero)
			end,
			onButton = function(button)
				if button == "x" and canRefresh then
					if not props.refreshing then
						local ____this_29
						____this_29 = props
						local ____opt_28 = ____this_29.onRefresh
						if ____opt_28 ~= nil then
							____opt_28(____this_29)
						end
					end
					return true
				end
				if button == "dpup" then
					moveSelection(-1)
					return true
				end
				if button == "dpdown" then
					moveSelection(1)
					return true
				end
				if button == "dpleft" or button == "dpright" then
					local nextGroup = math.max(
						0,
						math.min(#groups - 1, activeGroup + (button == "dpright" and 1 or -1))
					)
					local next = __TS__ArrayFindIndex(
						flat,
						function(____, item) return item.groupIndex == nextGroup end
					)
					if next >= 0 then
						selectedIndex = next
						moveSelection(0)
					end
					return true
				end
				if button == "a" and flat[selectedIndex + 1] then
					props:onSelect(flat[selectedIndex + 1].entry)
					return true
				end
				return false
			end
		}
		root:schedule(function()
			attachGamepad(root, gamepadOptions)
			return true
		end)
		return root
	end
	return React.createElement("custom-node", {
		tag = "mobile-project-index-container",
		x = props.x,
		y = props.y,
		width = props.width,
		height = props.height,
		order = 15000,
		renderOrder = 15000,
		onCreate = onCreate
	})
end
return ____exports
