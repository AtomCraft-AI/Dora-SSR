-- Run from the repository root with Lua 5.4 or later.
local directory = "Assets/Doc/skills/atompie-submission/"
local clientName = "Doc.skills.atompie-submission.client"
local null = {}
local now = 1000
local requests = {}
local picture = "\255\216\255fixture"
local content = {
	loadAsync = function(_, path)
		assert(path == "test-project/.dora/banner.jpg")
		return picture
	end,
}
local token = "credential stays in module"
local origin = "https://atompie.osgame.org"
local grant = {
	device_code = "private-device-code", user_code = "ABCD-1234",
	verification_uri_complete = origin .. "/dora/authorize?user_code=ABCD-1234", interval = 5,
}
local publisher = {id = 7, full_name = "Fixture Publisher", can_publish = true, organizations = {{id = 9, name = "Fixture Org"}}}
local current = {id = 17, organization_id = 9, lock_version = 5}
local lostWrite = true
local function post(_, url, headers, fields)
	local path = assert(url:match("^https://atompie%.osgame%.org/api/v1/dora(/.*)$"))
	requests[#requests + 1] = {path = path, fields = fields}
	if path == "/device" then return grant end
	if path == "/token" then
		assert(fields.device_code == grant.device_code)
		return {status = "authorized", access_token = token, refresh_token = "discard", expires_in = 60}
	end
	assert(headers[3] == "Authorization: Bearer " .. token)
	if path == "/me" then return publisher end
	if path == "/drafts" then return current end
	if path == "/drafts/17/read" then return current end
	if path == "/drafts/17/cover" then return {id = 17, lock_version = 6, cover_file_id = 23} end
	if path == "/drafts/17/submit" then
		if lostWrite then lostWrite = false return nil end
		return {submission_id = 42, committed_version = 6}
	end
	error("Unexpected request: " .. path)
end
package.preload.Dora = function()
	return {json = {encode = function(v) return v end, decode = function(v) return v end, null = null},
		HttpClient = {postAsync = post}, Content = content, Path = function(...) return table.concat({...}, "/") end}
end
package.preload.mime = function()
	return {b64 = function(data) assert(data == picture) return "mock-base64" end}
end
package.preload[clientName] = assert(loadfile(directory .. "client.lua"))
os.time = function() return now end
local function call(action, fields, project)
	-- execute_command reloads this entry point between calls.
	local atompie = assert(loadfile(directory .. "atompie.lua"))()
	return atompie(project or "test-project", action, fields)
end
assert(call("account").code == "expired" and #requests == 0)
local begin = call("begin")
assert(begin.success and begin.user_code == grant.user_code and not begin.device_code)
assert(call("poll", {user_code = begin.user_code}).status == "authorization_pending" and #requests == 1)
now = now + 5
local auth = call("poll", {user_code = begin.user_code})
assert(auth.status == "authorized" and not auth.access_token and not auth.refresh_token)
assert(call("account", {}, "other-project").code == "expired")
assert(call("account").account.id == publisher.id)

local fields = {
	account_id = 7, organization_id = 9, idempotency_key = "draft-fixture-01234",
	title = "Fixture", short_description = "Summary", long_description = "Readme", version = "1.0.0",
	repository_url = "https://github.com/example/fixture.git", tags = {"demo"},
	game_metadata = {engine = "dora_ssr", play_modes = {"single_player"}, platforms = {"pc"}},
}
assert(call("create", fields).data.id == current.id)
assert(requests[#requests].fields.repository_url == "https://github.com/example/fixture")
local owner = {account_id = 7, organization_id = 9, draft_id = 17}
assert(call("read", owner).data.lock_version == current.lock_version)
assert(call("read", {account_id = 7, draft_id = 17}).code == "publisher_changed")
assert(call("read", {account_id = 8, organization_id = 9, draft_id = 17}).code == "publisher_changed")
owner.expected_version = 5
owner.cover_path = "../banner.jpg"
assert(call("cover", owner).code == "arguments")
owner.cover_path = ".dora/banner.jpg"
assert(call("cover", owner).data.cover_file_id == 23)
assert(requests[#requests].fields.expected_file_id == null and requests[#requests].fields.data_base64 == "mock-base64")

owner.idempotency_key = "review-fixture-01234"
owner.expected_version = 6
assert(call("submit", owner).code == "upstream")
local first = requests[#requests].fields
assert(call("submit", owner).data.submission_id == 42)
assert(first.idempotency_key == requests[#requests].fields.idempotency_key
	and first.expected_version == requests[#requests].fields.expected_version)
assert(call("disconnect").success and call("account").code == "expired")
print("PASS: on-demand AtomPie authorization, publisher checks, cover and review replay")
