do
local function scan(extra, success, result)    
  vardump(result)
    local user = result.peer_id
	local username = result.username
	local first_name = string.gsub(result.first_name, "_", " ")
--	local last_name = string.gsub(result.last_name, "_", " ")
	local text = 'User Info:\n\nID: '..result.peer_id..'\nFirst: '..(result.first_name or 'None')..'\nLast: '..(result.last_name or 'None')..'\nUsername: @'..result.username
    send_large_msg(extra.chat, text)
end

local function callbackinfo(extra, success, result)
  vardump(result)
    local text = "Info for Supergroup:["..result.title.."]\n\nAdmin count: "..result.admin_count.."\nUser count:\nKicked user:"..result.kick_count.."\nID:"..result.peer_id
	send_large_msg("channel#id"..msg.to.id, text)
end
local function run(msg, matches)
  if matches[1] == 'whois' and matches[2] then
    local username = string.gsub(matches[2], "_", " ") 
    local chat = get_receiver(msg)
    return user_info('user#id'..username, scan, {chat=chat})
  end
  if matches[1] == "info" and is_sudo(msg) then
    chat = get_receiver(msg)
    channel_info(chat, callbackinfo)
  end
end
return {
  patterns = {
    "^[!/](whois) (%d+)$",
	"^[/!#](info)$"
  },
  run = run
}

end