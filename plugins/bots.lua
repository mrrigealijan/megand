do

local function get_admin(extra, success, result)
  --vardump(result)
    local name = extra.name
    local receiver = extra.receiver
    local text = "Admins for SuperGroup \n"..name..":\n\n"
    local i = 1
    for k,user in ipairs(result) do
        local username = (user.username or '')
        local adname = (user.print_name or '')
        text = text ..i..'- '..adname..' @'..username..' ['..user.peer_id..'] \n\n'
        i = i + 1
    end
    send_large_msg(receiver, text)
end
local function get_bot(extra, success, result)
  vardump(result)
    local name = extra.name
    local receiver = extra.receiver
    local text = "Bots for SuperGroup\n "..name.." :\n\n"
    local i = 1
    for k,user in ipairs(result) do
        local id = user.peer_id
        local botname = user.print_name
		local username = (user.username or 'None')
        if string.sub(username:lower(), -3) == "bot" then
            local username = "@"..user.username
            text = text ..i.."-"..botname..' '..username.." ["..id.."]\n"
            i = i + 1
        end
    end
    send_large_msg(receiver, text)
end
local function returnid(extra, success, result)
 -- vardump(result)
    local receiver = extra.receiver
	local text = 'Members for SuperGroup ID:'..(string.gsub(receiver, "channel#id", ""))..'\n\n\n'
	local i = 1
	for k,user in ipairs(result) do
		local username = (user.username or '')
		local name = (user.print_name or '')
		text = text ..i..'- '..name..' @'..username..' ['..user.peer_id..'] \n\n'
		i = i + 1
	end
		local file = io.open("./data/groups/"..receiver.."memberlist.txt", "w")
		file:write(text)
		file:flush()
		file:close()
		send_document(receiver, "./data/groups/"..receiver.."memberlist.txt", ok_cb, false)
end
local function returnidch(extra, success, result)
  vardump(result)
	local receiver = extra.receiver
	local text = 'Members for Group ['..result.title..'] ID:('..result.peer_id..')\n\n'
	local i = 1
	for k,user in pairs(result.members) do
	  local username = (user.username or '')
	  local name = string.gsub(user.print_name, '_', ' ')
	  text = text ..i..'- '..name..' @'..username..' ['..user.peer_id..'] \n'
	  i = i + 1
	end
	local file = io.open("./data/groups/"..receiver.."memberlist.txt", "w")
	file:write(text)
	file:flush()
	file:close()
	send_document(receiver, "./data/groups/"..receiver.."memberlist.txt", ok_cb, false)
end
local function returnkick(extra, success, result)
  --vardump(result)
    local receiver = extra,receiver
	local id = extra.id
	local text = "Kicked Members for SuperGroup ID:"..id..'\n\n\n'
	local i = 1
	for k,user in ipairs(result) do
		local username = (user.username or '')
		local name = (user.print_name or '')
		text = text ..i..'- '..name..' @'..username..' ['..user.peer_id..'] \n\n'
		i = i + 1
	end
		local file = io.open("./data/groups/"..id.."kicked.txt", "w")
		file:write(text)
		file:flush()
		file:close()
		send_document("channel#id"..id, "./data/groups/"..id.."kicked.txt", ok_cb, false)
end
local function run(msg, matches)
  if matches[1] == "bots" then
    local receiver = get_receiver(msg)
    local name = string.gsub(msg.to.print_name, '_', ' ')
    channel_get_users("channel#id"..msg.to.id, get_bot, {receiver=receiver, name=name})
  end
  if matches[1] == "who" then
    local receiver = get_receiver(msg)
	if msg.to.type == "channel" then
	  channel_get_users("channel#id"..msg.to.id, returnid, {receiver=receiver})
	else
	  chat_info(receiver, returnidch, {receiver=receiver})
	end
  end
  if matches[1] == "kicked" and is_momod(msg) then
    local receiver = "channel#id"..msg.to.id
	local id = msg.to.id
	channel_get_kicked("channel#id"..msg.to.id, returnkick, {receiver=receiver, id=id})
  end
  if matches[1] == "admins" then
    if not is_momod(msg) then
      return "For moderators only"
    end
    local receiver = get_receiver(msg)
    local name = string.gsub(msg.to.print_name, '_', ' ')
    channel_get_admins("channel#id"..msg.to.id, get_admin, {receiver=receiver, name=name})
  end
  if matches[1] == "log" and is_owner(msg) then
    send_document(get_receiver(msg), "./data/groups/"..msg.to.id.."log.txt", ok_cb, true)
  end
end

return {
  patterns = {
    "^[/!#](bots)$",
    "^[/!#](admins)$",
	"^[/!#](who)$",
	"^[/!#](log)$",
	"^[/!#](kicked)$"
  },
  run = run
}
end