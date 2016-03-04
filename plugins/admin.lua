do

local function addadmin(user_id, channel_id)
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_set_admins(channel, user, ok_cb, false)
end
local function admindem(user_id, channel_id)
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_rem_admins(channel, user, ok_cb, false)
end
local function add_dem_res(extra, success, result)
  vardump(result)
  vardump(extra)
    local member_id = result.peer_id
    local user_id = member_id
    local member = result.username
    local channel_id = extra.channel_id
    local from_id = extra.from_id
    local get_cmd = extra.get_cmd
    local receiver = "channel#"..channel_id
    if get_cmd == "admindem" then
        return admindem(member_id, channel_id)
    elseif get_cmd == "addadmin" then
        return addadmin(member_id, channel_id)
    end
end
local function run(msg, matches)
  if matches[1] == "addadmin" then
    if string.match(matches[2], '^%d+$') then
      user_id = matches[2]
      channel_id = msg.to.id
      channel_set_admins(user_id, channel_id)
    else
      local cbres_extra = {
        channel_id = msg.to.id,
        get_cmd = "addadmin",
        from_id = msg.from.id
      }
      local username = matches[2]
      local username = string.gsub(matches[2], "@", "")
      resolve_username(username, add_dem_res, cbres_extra)
        
    end
  end
  if matches[1] == "admindem" then
    if string.match(matches[2], '^%d+$') then
      user_id = matches[2]
      channel_id = msg.to.id
      admindem(user_id, channel_id)
    else
      local cbres_extra = {
        channel_id = msg.to.id,
        get_cmd = "admindem",
        from_id = msg.from.id
      }
      local username = matches[2]
      local username = string.gsub(matches[2], "@", "")
      resolve_username(username, add_rem_res, cbres_extra)
    end
  end
end

return {
  patterns = {
    "^!(addadmin) (.*)$",
    "^!(admindem) (.*)$"
  },
  run = run
}

end