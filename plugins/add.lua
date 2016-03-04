do
local function hammercal(extra, success, result)
  vardump(result)
    local receiver = "channel#id"..result.to.peer_id
    local username = result.username or result.peer_id
    local i = 1
    local text = 'hammer list:\n\n . '..username
    send_msg(receiver, text, ok_cb, false)
end
local function hammer_list()
  local hash = 'hammer'
  --local receiver = get_receiver(msg)
  local list = redis:smembers(hash)
  local text = "Hammer list:\n\n"
  for k,v in pairs(list) do
    user_info("user#id"..v, hammercal)
  end
end
local function returninfo(cb_extra, success, result)
  vardump(result)
    local receiver = cb_extra.receiver
    local text = 'Info for supergroup:['..result.title..']'..'\n\nAdmin count: '..result.admins_count..'\nUser count: '..result. participants_count.. '\nKicked user: '..result.kicked_count..'\nID:'..result.peer_id
	if result.username then
	  text = text ..'\nUsername: @'..result.username
	else
	  text = text
	end
	send_large_msg(receiver, text)
end
local function info(msg)
    receiver = get_receiver(msg)
    channel_info(receiver, returninfo,{receiver=receiver})
end
local function userinfocallback(extra, success, result)
  vardump(result)
    local receiver = extra.receiver
    local username = "@"..result.username or 'None'
    local text = "User Info:\n\nID:"..result.peer_id.."\nFirst :"..(result.first_name or 'None').."\nLast :"..(result.last_name or 'None').."\nUsername :"..username
    send_large_msg(receiver, text)
end
local function run(msg, matches)
  if matches[1] == "info" and is_momod(msg) then
	return info(msg)
  end
  if matches[1] == "whois" and is_owner(msg) then
    local receiver = get_receiver(msg)
    user_info("user#id"..matches[2], userinfocallback, {receiver=receiver})
  end
  if matches[1] == "hammers" then
    return hammer_list(msg)
  end
  if matches[1] == "setusername" and is_owner(msg) then
    if string.len(string.gsub(matches[2], "@", "")) < 5 then
	  return "Username Must have at last 5 characters"
	end
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	  return set_username("channel#id"..msg.to.id, username, ok_cb, true)
  end
end

return {
  patterns = {
    "^[/!#](info)$",
    "^[/!#](hammers)$",
	"^[/!#](setusername) (.*)$",
    "^[/!#](whois) (%d+)$"
  },
  run = run
}

end
