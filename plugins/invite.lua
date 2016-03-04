do

local function callback(extra, success, result)
  if success == 0 then
    send_large_msg(get_receiver(extra.msg), "Failed, maby username is wrong")
  end
  local user = "user#id"..result.peer_id
  if is_banned(result.peer_id, extra.msg.to.id) then
    send_large_msg(get_receiver(extra.msg), "User is banned")
  elseif is_hammer(result.peer_id) then
    send_large_msg(get_receiver(extra.msg), "User is hammered")
  end
  if extra.msg.to.type == "channel" then
    local channel = "channel#id"..extra.msg.to.id
    channel_invite_user(channel, user, ok_cb, false)
  else 
    local chat = "chat#id"..extra.msg.to.id
	chat_add_user(chat, user, ok_cb, false)
  end
end

local function run(msg, matches)
  if not is_sudo(msg) then
    return 
  end
  local username = matches[1]
  local username = username:gsub("@", "")
  resolve_username(username, callback, {msg=msg})
end

return {
  patterns = {
    "^[/!#]invite (.*)$"
  },
  run = run 
}

end