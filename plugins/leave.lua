do

local function run(msg, matches)
  if matches[1] == "leave" and is_admin(msg) then
	  leave("channel#id"..msg.to.id, ok_cb, true)
  end
  if msg.action.type == "chat_add_user" and msg.action.user.id == tonumber(our_id) and not is_sudo(msg) then
	  leave("channel#id"..msg.to.id, ok_cb, false)
	  send_large_msg("channel#id"..msg.to.id, "This is Not my groups")
  end
end

return {
  patterns = {
    "^[/!#](leave)$",
	"^!!tgservice (.+)$"
  },
  run = run
}

end