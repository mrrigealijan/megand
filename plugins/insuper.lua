do
local function callbackres(extra, success, result)
  --vardump(result)
	local user = result.peer_id
	local name = string.gsub(result.print_name, "_", " ")
	local channel = "channel#id"..extra.channelid
	send_large_msg(channel, user..'\n'..name)
end
local function parsed_url(link)
    local parsed_link = URL.parse(link)
    local parsed_path = URL.parse_path(parsed_link.path)
    for k,segment in pairs(parsed_path) do
      if segment == 'joinchat' then
        invite_link = string.gsub(parsed_path[k+1], '[ %c].+$', '')
        break
      end
    end
    return invite_link
  end
local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  if msg.text:match("https://telegram.me/") and data[tostring(msg.to.id)]['settings']['set_link'] == "waiting" and is_owner(msg) then
    local hash = parsed_url(msg.text)
	data[tostring(msg.to.id)]['settings']['set_link'] = hash
	save_data(_config.moderation.data)
	return "Link saved"
  end
  --if parsed_url(msg.text) then
    --data[tostring(msg.to.id)]['settings']['set_link'] = parsed_url(msg.text)
	--save_data(_config.moderation.data, data)
	--return "Link set"
  --end
  if matches[1] == "tosuper" and is_admin(msg) then
    if msg.to.type == 'channel' then
	  return "*Error: Already a supergroup."
	end
    upgrade_chat("chat#id"..msg.to.id, ok_cb, false)
	send_large_msg("chat#id"..msg.to.id, "Group has been upgraded to a super.")
  end
  if matches[1] == "setdesc" and is_sudo(msg) then
    channel = "channel#id"..msg.to.id
    about = matches[2]
	set_about(channel, about, ok_cb, false)
	return reply_msg(msg.id, "Description has been set.\n\nSelect the chat again to see the changes", ok_cb, false)
  end
  if matches[1] == "setname" and is_momod(msg) then
    local new_name = string.gsub(matches[2], '_', ' ')
	local to_rename = "channel#id"..msg.to.id
	rename_channel(to_rename, new_name, ok_cb, false)
  end
  
  if matches[1] == "newlink" and is_momod(msg) then
    local function callback(extra, success, result)
	  local receiver = get_receiver(msg)
	  if success == 0 then
	    return send_large_msg(receiver, "*Error: Invite link failed* \nReason: Not creator.")
	  end
	  send_large_msg(receiver, "Created a new link!")
	  data[tostring(msg.to.id)]['settings']['set_link'] = result
	  save_data(_config.moderation.data, data)
	end
	local receiver = get_receiver(msg)
	if msg.to.type == "channel" then
	  return export_channel_link(receiver, callback, true)
	else
	  return export_chat_link(receiver, callback, true)
	end
  end
  if matches[1] == "link" and is_momod(msg) then
    local link = data[tostring(msg.to.id)]['settings']['set_link']
    if not link then
      return "Create link using  /newlink first !"
    end
    return "Group link:\n\n"..link
  end
  if matches[1] == "setlink" then
    if not is_owner(msg) then
	  return "For owner only"
	end
	data[tostring(msg.to.id)]['settings']['setlink'] = "waiting"
	save_data(_config.moderation.data, data)
	return "Please send me the link now!"
  end
  if matches[1] == "res" and is_owner(msg) then
    local cbres_extra = {
	  channelid = msg.to.id
	}
	local username = matches[2]
	local username = username:gsub("@","")
	return resolve_username(username, callbackres, cbres_extra)
  end
end

return {
  patterns = {
    "^[#/](tosuper)$",
    "^[/!#](link)$",
	"^[#/](setdesc) (.*)$",
	"^[#/](setname) (.*)$",
	"^[#/](res) (.*)$",
	"^[#/](newlink)$",
	"^[/!#](setlink)$",
	"(https://telegram.me/)"
  },
  run = run
}

end