local ____lualib = require("lualib_bundle")
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt
local ____exports = {}
--- ASCII project names use A-Z; Chinese and every other leading character use #.
____exports.getFeedProjectGroup = function(title)
	local initial = (string.match(title, "^%s*([A-Za-z])"))
	return initial == nil and "#" or string.upper(initial)
end
____exports.groupFeedProjects = function(entries)
	local sorted = {table.unpack(entries)}
	__TS__ArraySort(
		sorted,
		function(____, a, b)
			local aGroup = ____exports.getFeedProjectGroup(a.title)
			local bGroup = ____exports.getFeedProjectGroup(b.title)
			if aGroup ~= bGroup then
				if aGroup == "#" then
					return 1
				end
				if bGroup == "#" then
					return -1
				end
				return aGroup < bGroup and -1 or 1
			end
			local aTitle = string.lower(a.title)
			local bTitle = string.lower(b.title)
			return aTitle == bTitle and 0 or (aTitle < bTitle and -1 or 1)
		end
	)
	local groups = {}
	for ____, entry in ipairs(sorted) do
		local key = ____exports.getFeedProjectGroup(entry.title)
		local group = groups[#groups]
		if (group and group.key) ~= key then
			group = {key = key, entries = {}}
			groups[#groups + 1] = group
		end
		local ____group_entries_2 = group.entries
		____group_entries_2[#____group_entries_2 + 1] = entry
	end
	return groups
end
____exports.normalizeFeedIndex = function(index, count)
	if count <= 0 then
		return 0
	end
	return math.max(
		0,
		math.min(
			math.floor(index),
			count - 1
		)
	)
end
--- Discovery is a circular feed; the local library retains bounded navigation.
____exports.nextFeedIndex = function(index, count, tab)
	if count <= 0 then
		return 0
	end
	return tab == "discover" and (math.floor(index) % count + count) % count or ____exports.normalizeFeedIndex(index, count)
end
____exports.visibleFeedPages = function(index, count, tab)
	local pages = {}
	if count <= 0 then
		return pages
	end
	for ____, offset in ipairs({-1, 0, 1}) do
		local target = index + offset
		if tab == "discover" or target >= 0 and target < count then
			pages[#pages + 1] = {
				index = ____exports.nextFeedIndex(target, count, tab),
				offset = offset
			}
		end
	end
	return pages
end
function ____exports.resolveFeedLocation(____local, discover, target)
	if target then
		local preferred = target.kind == "discover" and discover or ____local
		local other = target.kind == "discover" and ____local or discover
		local function match(items)
			local index = target.fileName and __TS__ArrayFindIndex(
				items,
				function(____, item) return item.fileName == target.fileName end
			) or -1
			if index < 0 and target.workDir then
				index = __TS__ArrayFindIndex(
					items,
					function(____, item) return item.workDir == target.workDir end
				)
			end
			if index < 0 then
				index = __TS__ArrayFindIndex(
					items,
					function(____, item) return item.id == target.id and item.kind == target.kind end
				)
			end
			return index
		end
		local index = match(preferred)
		if index >= 0 then
			return {tab = target.kind, index = index}
		end
		local alternate = match(other)
		if alternate >= 0 then
			return {tab = target.kind == "discover" and "local" or "discover", index = alternate}
		end
	end
	return {tab = #____local > 0 and "local" or "discover", index = 0}
end
____exports.getReusableCardIndices = function(index, count)
	if count <= 0 then
		return {}
	end
	local current = ____exports.normalizeFeedIndex(index, count)
	local result = {}
	if current > 0 then
		result[#result + 1] = current - 1
	end
	result[#result + 1] = current
	if current + 1 < count then
		result[#result + 1] = current + 1
	end
	return result
end
____exports.resolveFeedGesture = function(dx, dy, width, height, controlCaptured, velocityX)
	if controlCaptured == nil then
		controlCaptured = false
	end
	if velocityX == nil then
		velocityX = 0
	end
	if controlCaptured then
		return "none"
	end
	local absX = math.abs(dx)
	local absY = math.abs(dy)
	if absX < 18 and absY < 18 then
		return "none"
	end
	if absX > absY * 1.2 then
		if dx < -40 and velocityX < -0.55 then
			return "play"
		end
		if absX < math.min(
			96,
			math.max(64, width * 0.24)
		) then
			return "none"
		end
		return dx > 0 and "none" or "play"
	end
	if absY < math.max(72, height * 0.14) then
		return "none"
	end
	return dy > 0 and "next" or "previous"
end
____exports.stableCoverColor = function(id)
	local hash = 17
	do
		local i = 0
		while i < #id do
			hash = (hash * 31 + __TS__StringCharCodeAt(id, i)) % 9973
			i = i + 1
		end
	end
	local palette = {
		4280299593,
		4280761397,
		4282001736,
		4282790184,
		4280695880,
		4282332480
	}
	return palette[hash % #palette + 1]
end
____exports.getCoverScales = function(sourceWidth, sourceHeight, targetWidth, targetHeight)
	if sourceWidth <= 0 or sourceHeight <= 0 or targetWidth <= 0 or targetHeight <= 0 then
		return {contain = 1, cover = 1}
	end
	return {
		contain = math.min(targetWidth / sourceWidth, targetHeight / sourceHeight),
		cover = math.max(targetWidth / sourceWidth, targetHeight / sourceHeight)
	}
end
____exports.resolveDiscoverRefreshTab = function(currentTab, userSelectedTab, previousDiscoverCount, refreshedDiscoverCount, localCount)
	if localCount == nil then
		localCount = 0
	end
	return not userSelectedTab and localCount == 0 and previousDiscoverCount == 0 and refreshedDiscoverCount > 0 and "discover" or currentTab
end
return ____exports
