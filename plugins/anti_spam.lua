kicktable = {}

do
function user_print_name(user)
   if user.print_name then
      return user.print_name
   end
   local text = ''
   if user.first_name then
      text = user.last_name..' '
   end
   if user.lastname then
      text = text..user.last_name
   end
   return text
end
local TIME_CHECK = 4
local function pre_process(msg)
  if msg.service then
    return msg
  end
  if msg.from.id == our_id then
    return msg
  end
  --Load json
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['settings']['lock_spam'] == "yes" then
      if msg.from.peer_type == 'user' and msg.text and not is_momod(msg) then
        local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
        if string.len(msg.text) > 2048 or ctrl_chars > 50 then
          local _c, chars = string.gsub(msg.text, '%a', '')
          local _lc, non_chars = string.gsub(msg.text, '%A', '')
          if non_chars > chars then
			delete_msg(msg.id, ok_cb, true)
          end
        end
      end
	end
  end
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['settings']['flood'] == "yes" then
      local user_id = msg.from.id
      local chat_id = msg.to.id
      local receiver = get_receiver(msg)
      local post_count = 'flood:'..user_id..':'..chat_id
      redis:incr(post_count)
      if msg.from.type == 'user' then
        local post_count = 'user:'..user_id..'flood'
        local msgs = tonumber(redis:get(post_count) or 0)
        local data = load_data(_config.moderation.data)
        local NUM_MSG_MAX = 5
        if data[tostring(msg.to.id)] then
          if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
            NUM_MSG_MAX = tonumber(data[tostring(msg.to.id)]['settings']['flood_msg_max'])
          end
        end
        local msg_max = NUM_MSG_MAX
        if msgs > msg_max then 
		  local user = msg.from.id
		--  if kicktable[user] == true then
		   -- return 
		--  end
		   if is_momod(msg) then
		     return 
		   end
          local username = msg.from.username
          local text = 'Flooding is not allowed here\n@'..(username or 'none')..'|'..user_id..'|\nStatus : User kicked'
          send_large_msg(receiver, text, ok_cb, false)
          channel_kick_user("channel#id"..chat_id, "user#id"..msg.from.id, ok_cb, false)
		  local gbanspam = 'hammer:spam'..msg.from.id
		  redis:incr(gbanspam)
		  local gbanredis = redis:get(gbanspam)
		  if gbanredis then
		    if tonumber(gbanredis) ==  4 and not is_onwer(msg) then
			  hammer_user(msg.from.id)
			  local gbanspam = 'hammer:spam'..msg.from.id
			  redis:set(gbanredis, 0)
			  local username = " "
			  if msg.from.username ~= nil then
			    username = msg.from.username
			  end
			  local name = user_print_name(msg.from)
			  send_large_msg(get_receiver(msg), "User [ "..name.." ]"..msg.from.id.." Hammered (spamming)")
			  local log_group = 101755077
			  send_large_msg("chat#id"..log_group, "User [ "..name.." ] ( @"..username.." )"..msg.from.id.." Hammered from ( "..msg.to.print_name.." ) [ "..msg.to.id.."] (spamming)")
			end
		  end
		  kicktable[user] = true
		end
        redis:setex(post_count, TIME_CHECK, msgs+1)
      end
	end
  end
  return msg
end
local function cron()
  --clear that table on the top of the plugins
	kicktable = {}
end

return {
  patterns = {},
  pre_process = pre_process,
  cron = cron
}

end