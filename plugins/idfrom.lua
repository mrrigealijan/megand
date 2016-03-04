do 
local function get_message_callback_id(extra, success, result)
  vardump(result) 
    if result.to.peer_type == 'channel' then
        local chat = 'channel#id'..result.to.peer_id
        send_large_msg(chat, result.from.peer_id)
    else
        return 'Use This in Your Groups'
    end
end

local function get_message_forward(extra, success, result)
  vardump(result)
    if result.to.peer_type == 'channel' then
		local channel = "channel#id"..result.to.peer_id
		send_large_msg(channel, result.fwd_from.peer_id)
	else
		return "User in Groups"
	end
end
local function run(msg, matches)
  if matches[1] == "id" then
    if msg.to.type == "user" then
	  return "👤"..string.gsub(msg.from.print_name, '_', ' ').." @"..(msg.from.username or '[none]').." |"..msg.from.id.."|"
	end
    if type(msg.reply_id) ~= "nil" then
      id = get_message(msg.reply_id, get_message_callback_id, false)
	elseif matches[1] == "id" then
	  return  "👤"..msg.to.title.."\n|"..msg.to.id.."|"
	end
  end
  if matches[1] == "from" then
    if type(msg.reply_id)~= "nil" then
	  id = get_message(msg.reply_id, get_message_forward, false)
	end
  end
end

return {
  patterns = {
    "^[/!#](id)$",
	"^[/!#]id (from)$"
  },
  run = run 
}

end
