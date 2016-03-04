do

local function kick_user(user_id, channel_id)
  local hash = 'kicked:'..channel_id
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_kick_user(channel, user, ok_cb, true)
  redis:sadd(hash, user_id)
end

local function ban_user(user_id, channel_id)
  if tonumber(user_id) == tonumber(our_id) then -- Ignore bot
    return
  end
  if is_admin2(user_id) then -- Ignore admins
    return
  end
  -- Save to redis
  local hash =  'banned:'..channel_id
  redis:sadd(hash, user_id)
  -- Kick from chat
  kick_user(user_id, channel_id)
end
function hammer_user(user_id)
if tonumber(user_id) == tonumber(our_id) then -- Ignore bot
    return
  end
  if is_admin2(user_id) then -- Ignore admins
    return
  end
  -- Save to redis
  local hash =  'hammer'
  redis:sadd(hash, user_id)
end
local function unhammer_user(user_id)
  local hash = 'hammer'
  redis:srem(hash, user_id)
end
function is_hammer(user_id)
  local hash =  'hammer'
  local banned = redis:sismember(hash, user_id)
  return banned or false
end
function is_banned(user_id, channel_id)
  --Save on redis  
  local hash =  'banned:'..channel_id
  local banned = redis:sismember(hash, user_id)
  return banned or false
end
--Ban by reply for admins
local function ban_by_reply(extra, success, result)
  vardump(result)
    if result.to.peer_type == 'channel' or result.to.peer_type == "chat" then
		local chat = get_receiver(result)
		if tonumber(result.from.peer_id) == tonumber(our_id) then -- Ignore bot
			return "I won't ban myself"
		end
		if is_momod2(result.from.peer_id, result.to.peer_id) then -- Ignore mods,owner,admin
			return "you can't kick mods,owner and admins"
		end
		ban_user(result.from.peer_id, result.to.peer_id)
		send_large_msg(chat, "User "..result.from.peer_id.." Banned")
    else
		return 'Use This in Your Groups'
	end
end
-- Unban by reply
local function unban_by_reply(extra, success, result)
  vardump(result) 
	if result.to.peer_type == 'channel' or result.to.peer_type == "chat" then
		local chat = get_receiver(result)
		if tonumber(result.from.peer_id) == tonumber(our_id) then -- Ignore bot
			return "I won't unban myself"
		end
		send_large_msg(chat, "User "..result.from.peer_id.." Unbanned")
		-- Save on redis
		local hash =  'banned:'..result.to.peer_id
		redis:srem(hash, result.from.peer_id)
	else
		return 'Use This in Your Groups'
	end
end
local function block_by_reply(extra, success, result)
  vardump(result)
    if result.to.peer_type == "channel" then
        local channel = "channel#id"..result.to.peer_id
        channel_kick_user(channel, "user#id"..result.from.peer_id, ok_cb, false)
    else
        return "use in group."
    end
end

local function hammer_by_reply(extra, success, result)
  vardump(result)
	if result.to.peer_type == "channel"  or result.to.peer_type == "chat" then
		if tonumber(result.from.peer_id) == tonumber(our_id) then
			return "I won't hammer myself"
		end
		hammer_user(result.from.peer_id)
		send_large_msg(get_receiver(result), "User "..result.from.peer_id.." ("..('@'..result.from.username or result.from.print_name)..") hammered")
		if result.to.peer_type == "channel" then
		  channel_kick_user("channel#id"..result.to.peer_id, "user#"..result.from.peer_id, ok_cb, false)
		else
		  chat_del_user("chat#id"..result.to.peer_id, "user#id"..result.from.peer_id, ok_cb, false)
		end
	else
		return "User in group."
	end
end
local function hammer_by_fwd(extra, success, result)
  vardump(result)
	if result.to.peer_type == "channel" or result.to.type == "chat" then
		if tonumber(result.fwd_from.peer_id) == tonumber(our_id) then
			return "I won't hammer myself"
		end
		local receiver = get_receiver(result)
		hammer_user(result.fwd_from.peer_id)
		send_large_msg(receiver, "User "..result.fwd_from.peer_id.." ("..('@'..result.fwd_from.username or result.fwd_from.print_name)..") hammered")
	else
		return "User in group."
	end
end
local function cb_res(extra, success, result)
 -- vardump(result)
  --vardump(extra)
    local member_id = result.peer_id
    local user_id = member_id
    local member = result.username
	local name = result.print_name
    local channel_id = extra.channel_id
    local from_id = extra.from_id
	local msg = extra.msg
    local get_cmd = extra.get_cmd
    local receiver = extra.receiver
	if get_cmd == "block" then
		if member_id == from_id then
			return send_large_msg(receiver, "You can't kick yourself!")
		end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			return send_large_msg(receiver, "You can't kick mods/owner/admins!")
		end
		return kick_user(member_id, channel_id)
	elseif get_cmd == "hammer" then
		if member_id == from_id then
			return reply_msg(msg, "You can't hammer yourself!", ok_cb, false)
		end
		if is_hammer(member_id) then
			return send_large_msg(receiver, "User "..name.. " ("..(member_id or '@'..member)..") is already hammered")
		end
		send_large_msg(receiver, "User "..name.." @"..member.." ["..member_id.."] hammered")
		return hammer_user(member_id)
	elseif get_cmd == "unhammer" then
		if not is_hammer(member_id) then
			return send_large_msg(receiver, "User is not hammered")
		end
		send_large_msg(receiver, "User "..name.." @"..member.." ["..member_id.."] unhammered")
		unhammer_user(member_id)
	elseif get_cmd == "id" then
		send_large_msg(receiver, member_id)
	elseif get_cmd == "ban" then
		if is_momod2(member_id, channel_id) then
            return send_large_msg(receiver, "You can't ban mods/owner/admins")
        end
		if member_id == from_id then
			return "You can't ban yourself"
		end
		send_large_msg(receiver, 'User @'..member..' ['..member_id..'] banned')
        return ban_user(member_id, channel_id)
	elseif get_cmd == "unban" then
		if not is_banned(member_id, channel_id) then
			return send_large_msg(receiver, "User is not banned!")
		end
		if is_momod2(member_id, channel_id) then
			send_large_msg(receiver, "You can't ban mods/owner/admins")
		end
		local hash = 'banned:'..channel_id
		redis:srem(hash, member_id)
		return send_large_msg(receiver, "User "..member_id.." unbanned")
	end
end
local function pre_process(msg)
  if msg.action and msg.action.type then
    local action = msg.action.type
    if msg.action.type == 'chat_add_user_link' then
      local user_id = msg.from.id
	  local channel_id = msg.to.id
      if is_hammer(user_id) or is_banned(user_id, channel_id) then
        kick_user(user_id, msg.to.id)
      end
    end
    if msg.action.type == "chat_add_user" or "chat_add_user_link" then
      local user_id = msg.action.user.id
	  if is_admin2(user_id) then
	    if msg.action.type == "chat_add_user" or msg.action.type == "chat_add_user_link" then
		  if msg.to.type == "channel" then
	        channel_set_admin("channel#id"..msg.to.id, "user#id"..user_id, ok_cb, true)
	        send_large_msg("channel#id"..msg.to.id, "🔱Admin joined. ")
		  end
		end
	  end
      if is_hammer(user_id) or is_banned(user_id, msg.to.id) then
        kick_user(user_id, msg.to.id)
      end
    end
    if string.len(msg.action.user.print_name) > 50 then
      local data = load_data(_config.moderation.data)
      local spam = data[tostring(msg.to.id)]['settings']['lock_spam']
      local strict = data[tostring(msg.to.id)]['settings']['strict']
	  if msg.action.type == "chat_add_user" or msg.action.type == "chat_add_user_link" then
	    if spam == "yes" then
	      if stirct == "yes" then
		    channel_kick_user("channel#id"..msg.to.id, "user#id"..msg.action.user.id, ok_cb, true)
	   	  delete_msg(msg.id, ok_cb, true)
     		else
	    	  delete_msg(msg.id, ok_cb, true)
	    	end
		end
	  end
    end
  end
  if msg.to.type == "channel" then
    local user_id = msg.from.id
    local channel_id = msg.to.id
    if is_hammer(user_id) or is_banned(user_id, msg.to.id) then
      kick_user(user_id, channel_id)
      msg.text = ''
    end
  end
  return msg
end

local function run(msg, matches)
  if matches[1]:lower() == "id" and matches[2] then
    local cb_extra = {receiver = get_receiver(msg), get_cmd = "id"}
    local username = matches[2]
    local username = string.gsub(matches[2], "@", "")
    resolve_username(username, cb_res, cb_extra)
  end
  if matches[1]:lower() == "block" and is_sudo(msg) then
    if type(msg.reply_id)~= "nil" then
      msgr = get_message(msg.reply_id, block_by_reply, false)
    end
    if string.match(matches[2], '^%d+$') then
      local user_id = matches[2]
      local channel_id = msg.to.id
      kick_user(user_id, channel_id)
    else
      local cbres_extra = {
        receiver = get_receiver(msg),
		channel_id = msg.to.id,
        get_cmd = "block",
        from_id = msg.from.id
      }     
      local username = matches[2]
      local username = string.gsub(matches[2], "@", "")
      resolve_username(username, cb_res, cbres_extra)
    end
  end
  if matches[1]:lower() == "ban" and is_momod(msg) then
    if type(msg.reply_id)~="nil" then
	  msgr = get_message(msg.reply_id, ban_by_reply, false)
	end
    if string.match(matches[2], '^%d+$') then
	  local user_id = matches[2]
	  local channel_id = msg.to.id
	  ban_user(user_id, channel_id)
	  if msg.to.type == "chat" then
	    chat_del_user("chat#id"..channel, "user#id"..user, ok_cb, false)
      end
	else
	  local cb_extra = {
	    receiver = get_receiver(msg),
		channel_id = msg.to.id,
		get_cmd = 'ban',
		from_id = msg.from.id
	  }
	  local username = matches[2]
	  local username = string.gsub(matches[2], "@", "")
	  resolve_username(username, cb_res, cb_extra)
	end
  end
  if matches[1]:lower() == "unban" and is_momod(msg) then
    if type(msg.reply_id)~="nil" then
	  msgr = get_message(msg.reply_id, unban_by_reply, false)
	end
    if string.match(matches[2], '^%d+$') then
	  local user_id = matches[2]
	  local channel_id = msg.to.id
	  local hash = 'banned:'..channel_id
	  redis:srem(hash, user_id)
	else
	  local cb_extra = {
	    receiver = get_receiver(msg),
		channel_id = msg.to.id,
		get_cmd = 'unban',
		from_id = msg.from.id
	  }
	  local username = matches[2]
	  local username = string.gsub(matches[2], "@", "")
	  resolve_username(username, cb_res, cb_extra)
	end
  end
  if matches[1]:lower() == "hammer" and is_admin(msg) then
    if type(msg.reply_id)~="nil" then
	  if msg.fwd_from then
	    local msgr = get_message(msg.reply_id, hammer_by_fwd, false)
	  else
	    msgr = get_message(msg.reply_id, hammer_by_reply, false)
	  end
	end
    if string.match(matches[2], '^%d+$') then
	  local user_id = matches[2]
	  hammer_user(user_id)
	  return "User ["..user_id.."] hammered"
	else 
	  local cb_extra = {receiver = get_receiver(msg), get_cmd = "hammer",from_id = msg.from.id, msg = msg.id}
	  local username = matches[2]
	  local username = string.gsub(matches[2], "@", "")
	  resolve_username(username, cb_res, cb_extra)
	end
  end
  if matches[1]:lower() == "unhammer" and is_sudo(msg) then
    if string.match(matches[2], '^%d+$') then
	  local user_id = matches[2]
	  unhammer_user(user_id)
	  return "User ["..user_id.."] unhammered"
	else
	  local cb_extra = {
	    receiver = get_receiver(msg),
		get_cmd = "unhammer",
		from_id = msg.from.id
      }
	  local username = matches[2]
	  local username = string.gsub(matches[2], "@", "")
	  resolve_username(username, cb_res, cb_extra)
	end
  end
end

return {
  patterns = {
    "^[/!#]([Bb]an)$",
	"^[/!#]([Uu]nban)$",
	"^[/!#]([Bb]lock)$",
	"^[/!#]([Hh]ammer)$",
	"^[/!#]([Bb]an) (.*)$",
	"^[/!#]([Uu]nban) (.*)$",
	"^[/!#]([Bb]lock) (.*)$",
    "^[!/#]([Hh]ammer) (.*)$",
    "^[!/#]([Uu]nhammer) (.*)$",
	"^[!/#]([Ii]d) (.*)$"
  },
  run = run,
  pre_process = pre_process
}

end
