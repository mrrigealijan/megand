do

local function set_join(msg, join, id)
  local hash = nil
  if msg.to.type == "channel" then
    hash = 'setjoin:'
  end
  local name = string.gsub(msg.to.print_name, '_', '')
  if hash then
    redis:hset(hash, join, id)
      return send_large_msg("channel#id"..msg.to.id, "SuperGroup join:\n["..name.."] has been set to:‌\n\n "..join.."\n\nNow people can join in pv by\n!join "..pass.." ", ok_cb, true)
  end
end

local function is_used(join)
  local hash = 'setjoin:'
  local used = redis:hget(hash, join)
  return used or false
end
local function show_add(cb_extra, success, result)
  --vardump(result)
    local receiver = cb_extra.receiver
    local text = "I added you to supergroup "..result.title.."(👤"..result.participants_count..")"
    send_large_msg(receiver, text)
end
local function added(msg, target)
  local receiver = get_receiver(msg)
  channel_info("channel#id"..target, show_add, {receiver=receiver})
end
local function run(msg, matches)
  if matches[1] == "setjoin" and msg.to.type == "channel" and matches[2] then
    local join = string.sub(matches[2], 1, 50)
    local id = msg.to.id
    if is_used(join) then
      return "Sorry,is already taken."
    end
    redis:del("setjoin:", id)
    return set_join(msg, join, id)
  end
  if matches[1] == "join" and matches[2] then
    local hash = 'setjoin:'
    local join = matches[2]
    local id = redis:hget(hash, join)
    local receiver = get_receiver(msg)
    if not id then
      return "i can't find supergroup"
    end
    channel_invite_user("channel#id"..id, "user#id"..msg.from.id, ok_cb, false)
    return channel_info("channel#id"..id, show_add, {receiver=receiver})
  else
	return "I could not added you to"..string.gsub(msg.to.id.print_name, '_', '')
  end
  if matches[1] == "join" then
   local hash = 'setjoin:'
   local channel_id = msg.to.id
   local join = redis:hget(hash, channel_id)
   local receiver = get_receiver(msg)
   send_large_msg(receiver, "join for SuperGroup:["..msg.to.print_name.."]\n\njoin > "..pass)
 end
end

return {
  patterns = {
    "^[/!#](setpass) (.*)$",
    "^[/!#](join)$",
    "^[/!#](join) (.*)$"
  },
  run = run
}

end