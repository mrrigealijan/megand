do

local function run(msg, matches)

  if matches[1] == "test" then
    return post_msg("channel#id"..msg.to.id, "test", ok_cb, true)
  end 
  if matches[1] == "mp" and matches[2] then
    post_msg("channel#id"..matches[2], matches[3], ok_cb, true)
  end
  if matches[1] == "msg.to.id" then
    post_msg("channel#id"..msg.to.id, msg.to.id, ok_cb, true)
  end 
  if matches[1] == "msg.from.id" then
    post_msg("channel#id"..msg.to.id, msg.from.id, ok_cb, true)
  end
  if matches[1] == "inv" and matches[2] and msg.to.type == "channel" then
    local channel = "channel#id"..msg.to.id
	local user = "user#id"..matches[2]
	channel_invite_user(channel, user, ok_cb, false)
  end
  if msg.text:match("msg.to.id") then
    return reply_msg(msg.id, msg.to.id, ok_cb, true)
  elseif msg.text:match("msg.to.peer_id") then
    return reply_msg(msg.id, msg.to.peer_id, ok_cb, false)
  elseif msg.text:match("msg.from.id") then
    return reply_msg(msg.id, msg.from.id, ok_cb, true)
  elseif msg.text:match("msg.from.peer_id") then
    return reply_msg(msg.id, msg.from.peer_id, ok_cb, false)
  end
  if matches[1] == "telecis" then
    local id = "05000000c637523c1f000000000000004194eded9f00bb2e"
    fwd_msg(get_receiver(msg), id, ok_cb, false)
  end
  if matches[1] == "off" and is_sudo(msg) then
    status_offline(ok_cb, true)
    return "Bot offlined"
  end
end

return {
  patterns = {
    "^[/!#](test)$",
	"^[/!#](telecis)$",
    "^[/!#](mp) (.*) (.*)$",
    "(.*)",
	"^[/!#](inv) (.*)$",
	"^[/!#](off)$"
  },
  run = run
}

end