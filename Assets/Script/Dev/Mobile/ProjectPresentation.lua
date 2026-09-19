local ____exports = {}
local ____Dora = require("Dora")
local DB = ____Dora.DB
function ____exports.projectDisplayName(workDir, fallback)
	if not workDir then
		return fallback
	end
	local rows = DB:query("select value_str from Config where name = ? limit 1", {"goProjectTitle:" .. workDir})
	return rows and #rows > 0 and type(rows[1][1]) == "string" and rows[1][1] or fallback
end
function ____exports.saveProjectDisplayName(workDir, title)
	return DB:exec("insert or replace into Config(name,value_str) values(?,?)", {"goProjectTitle:" .. workDir, title}) >= 0
end
return ____exports
