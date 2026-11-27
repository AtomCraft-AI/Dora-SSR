local Dora = require("Dora")
local mime = require("mime")
local origin = "https://atompie.osgame.org"
local sessions = {}
local coverPaths = {
	[".dora/banner.jpg"] = "image/jpeg",
	[".dora/banner.png"] = "image/png",
	["Image/banner.jpg"] = "image/jpeg",
	["Image/banner.png"] = "image/png",
}

local function failure(code, message)
	return {success = false, code = code, message = message}
end

local function request(path, fields, token)
	local headers = {"Content-Type: application/json", "X-Dora-Transport: json-post-v1"}
	if token then headers[#headers + 1] = "Authorization: Bearer " .. token end
	local body = next(fields) and Dora.json.encode(fields) or "{}"
	local raw = Dora.HttpClient:postAsync(origin .. "/api/v1/dora" .. path, headers, body, 30)
	local ok, result = pcall(Dora.json.decode, raw or "")
	if not ok or type(result) ~= "table" then
		return nil, failure("upstream", "No valid AtomPie response. The operation may have reached the service.")
	end
	local code = result.code
	if result.error or (type(code) == "number" and (code < 200 or code >= 300)) then
		local safeCode = type(result.error) == "string" and result.error:match("^[a-z_]+$") and result.error or code
		return nil, failure(safeCode or "rejected", "AtomPie rejected the request.")
	end
	return result.data or result
end

local function positiveId(value)
	return type(value) == "number" and math.tointeger(value) ~= nil and value > 0
end

local function idempotencyKey(value)
	return type(value) == "string" and #value >= 16 and #value <= 64 and value:match("^[%w_-]+$")
end

local function repository(value)
	if type(value) ~= "string" then return end
	local host, owner, name = value:match("^https://([%w.]+)/([%w_.-]+)/([%w_.-]+)/?$")
	if host ~= "github.com" and host ~= "atomgit.com" and host ~= "gitee.com" then return end
	name = name and name:gsub("%.git$", "")
	if owner and name and name ~= "" and owner ~= "." and owner ~= ".." and name ~= "." and name ~= ".." then
		return "https://" .. host .. "/" .. owner .. "/" .. name
	end
end

local function run(project, action, args)
	local session = sessions[project]
	local now = os.time()
	if action == "begin" then
		for key, previous in pairs(sessions) do
			if previous.expires <= now then sessions[key] = nil end
		end
		if session and session.expires > now then
			return failure("active_session", "Disconnect the existing AtomPie session before connecting again.")
		end
		local grant, err = request("/device", {})
		if not grant then return err end
		local url = grant.verification_uri_complete or grant.verification_uri
		local authorize = origin .. "/dora/authorize"
		local validUrl = type(url) == "string" and (url == authorize or url:sub(1, #authorize + 1) == authorize .. "?")
		if not validUrl or type(grant.device_code) ~= "string" or type(grant.user_code) ~= "string" then
			return failure("invalid_grant", "AtomPie returned invalid device authorization.")
		end
		local interval = math.max(1, tonumber(grant.interval) or 5)
		sessions[project] = {device = grant.device_code, code = grant.user_code, interval = interval,
			nextPoll = now + interval, expires = now + (tonumber(grant.expires_in) or 600)}
		return {success = true, authorization_url = url, user_code = grant.user_code, interval = interval}
	end
	if not session or session.expires <= now then
		sessions[project] = nil
		return failure("expired", "Start a new AtomPie authorization.")
	end
	if action == "disconnect" then
		-- The short-lived access token is discarded. No refresh token is retained.
		sessions[project] = nil
		return {success = true}
	end
	if action == "poll" then
		if not session.device or session.code ~= args.user_code then
			return failure("invalid_grant", "The AtomPie matching code has changed.")
		end
		if now < session.nextPoll then
			return {success = true, status = "authorization_pending", interval = session.nextPoll - now}
		end
		session.nextPoll = now + session.interval
		local result, err = request("/token", {device_code = session.device})
		if not result then return err end
		if result.status == "authorized" and type(result.access_token) == "string" then
			sessions[project] = {token = result.access_token, expires = now + (tonumber(result.expires_in) or 300)}
			return {success = true, status = "authorized"}
		end
		if result.status == "access_denied" or result.status == "expired_token" then sessions[project] = nil end
		if result.status == "slow_down" then
			session.interval = math.max(session.interval + 5, tonumber(result.interval) or 0)
			session.nextPoll = now + session.interval
		end
		return {success = true, status = result.status, interval = session.interval}
	end
	if not session.token then return failure("pending", "Complete browser authorization first.") end
	local account, err = request("/me", {}, session.token)
	if not account then
		if err.code == "invalid_token" or err.code == 401 then sessions[project] = nil end
		return err
	end
	if action == "account" then
		local organizations = {}
		for _, org in ipairs(account.organizations or {}) do
			organizations[#organizations + 1] = {id = org.id, name = org.name}
		end
		return {success = true, account = {id = account.id, full_name = account.full_name,
			can_publish = account.can_publish, organizations = organizations}}
	end
	if not account.can_publish or not positiveId(args.account_id) or account.id ~= args.account_id then
		return failure("publisher_changed", "Confirm the current publishing account and developer access.")
	end
	if args.organization_id ~= nil then
		local found = false
		for _, org in ipairs(account.organizations or {}) do
			if org.id == args.organization_id then found = true break end
		end
		if not found then return failure("publisher_changed", "Confirm the current publishing organization.") end
	end

	local path, payload
	if action == "create" then
		if not idempotencyKey(args.idempotency_key) then return failure("arguments", "Supply a stable draft key.") end
		path = "/drafts"
	else
		if not positiveId(args.draft_id) then return failure("arguments", "Supply a valid draft ID.") end
		path = "/drafts/" .. math.tointeger(args.draft_id) .. "/" .. action
		local version = args.expected_version
		if action ~= "read" and (type(version) ~= "number" or not math.tointeger(version) or version < 0) then
			return failure("arguments", "Supply the last confirmed draft version.")
		end
	end
	if action == "create" or action == "update" then
		local url = repository(args.repository_url)
		if not url then return failure("arguments", "Supply a supported public HTTPS repository root.") end
		for _, key in ipairs({"title", "short_description", "long_description", "version"}) do
			if type(args[key]) ~= "string" or not args[key]:match("%S") then
				return failure("arguments", "Missing field: " .. key)
			end
		end
		local metadata = args.game_metadata
		if type(args.tags) ~= "table" or #args.tags == 0 or type(metadata) ~= "table"
			or type(metadata.engine) ~= "string" or type(metadata.play_modes) ~= "table" or #metadata.play_modes == 0
			or type(metadata.platforms) ~= "table" or #metadata.platforms == 0 then
			return failure("arguments", "Supply tags, engine, play modes and supported platforms.")
		end
		payload = {title = args.title, short_description = args.short_description, long_description = args.long_description,
			repository_url = url, version = args.version, video_url = args.video_url or Dora.json.null, tags = args.tags,
			game_metadata = {engine = metadata.engine, play_modes = metadata.play_modes, platforms = metadata.platforms},
			organization_id = args.organization_id or Dora.json.null, expected_version = args.expected_version, idempotency_key = args.idempotency_key}
	elseif action == "cover" then
		local contentType = coverPaths[args.cover_path]
		if not contentType then return failure("arguments", "Select a supported project cover path.") end
		local bytes = Dora.Content:loadAsync(Dora.Path(project, args.cover_path))
		if type(bytes) ~= "string" or #bytes == 0 or #bytes > 8 * 1024 * 1024 then
			return failure("cover_file", "Select a readable JPEG or PNG cover of at most 8 MiB.")
		end
		local jpeg = bytes:sub(1, 3) == "\255\216\255"
		local png = bytes:sub(1, 8) == "\137PNG\r\n\26\n"
		if (contentType == "image/jpeg" and not jpeg) or (contentType == "image/png" and not png) then
			return failure("cover_file", "The cover contents do not match its file extension.")
		end
		payload = {expected_version = args.expected_version, expected_file_id = args.expected_file_id or Dora.json.null,
			content_type = contentType, data_base64 = assert(mime.b64(bytes))}
	elseif action == "submit" then
		if not idempotencyKey(args.idempotency_key) then return failure("arguments", "Supply a stable review key.") end
		payload = {idempotency_key = args.idempotency_key, expected_version = args.expected_version}
	else
		payload = {}
	end
	-- Check the actual draft owner before writing an existing draft. Version
	-- checks stay on the write so a lost submit can replay its original key.
	if action ~= "create" then
		local current, readError = request("/drafts/" .. math.tointeger(args.draft_id) .. "/read", {}, session.token)
		if not current then return readError end
		if current.id ~= args.draft_id or (current.organization_id or Dora.json.null) ~= (args.organization_id or Dora.json.null) then
			return failure("publisher_changed", "The draft belongs to a different publisher.")
		end
		if action == "read" then return {success = true, data = current} end
	end
	local result, requestError = request(path, payload, session.token)
	if not result then return requestError end
	if action ~= "submit" and (not positiveId(result.id) or type(result.lock_version) ~= "number") then
		return failure("upstream", "No draft version was returned. Confirm the outcome before continuing.")
	end
	if action == "submit" and (not positiveId(result.submission_id) or type(result.committed_version) ~= "number") then
		return failure("upstream", "No review receipt was returned. Retry the same version and review key.")
	end
	return {success = true, data = result, submissions_url = origin .. "/my-assets?view=mine"}
end

local actions = {begin = true, poll = true, disconnect = true, account = true, create = true, read = true,
	update = true, cover = true, submit = true}
local busy = {}

return function(project, action, args)
	if type(project) ~= "string" or project == "" or not actions[action] then
		return failure("arguments", "Choose an AtomPie action in the current project.")
	end
	if busy[project] then return failure("busy", "Another AtomPie operation is in progress for this project.") end
	busy[project] = true
	local lock <close> = setmetatable({}, {__close = function() busy[project] = nil end})
	local ok, result = pcall(run, project, action, args or {})
	return ok and result or failure("local_error", "Could not complete the AtomPie operation.")
end
