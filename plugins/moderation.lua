do

local function check_member(cb_extra, success, result)
  vardump(result)
    local receiver = cb_extra.receiver
    local data = cb_extra.data
    local msg = cb_extra.msg
    for k,v in ipairs(result) do
      local member_id = v.peer_id
      if member_id ~= our_id then
        data[tostring(msg.to.id)] = {
          group_type = 'Supergroup',
		  moderators = {},
		  set_owner = member_id,
          settings = {
            set_name = string.gsub(msg.to.print_name, '_', ' '),
            lock_member = 'no',
			lock_sticker = 'no',
			lock_link = 'no',
			lock_spam = 'yes',
            flood = 'yes',
            public = 'no'
          }
        }
        save_data(_config.moderation.data, data)
        local super = 'supergroup'
        if not data[tostring(super)] then
          data[tostring(super)] = {}
          save_data(_config.moderation.data, data)
        end
        data[tostring(super)][tostring(msg.to.id)] = msg.to.id
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver,'Supergroup has been added!')
      end
    end
end
local function show_settings(msg, data)
  local data = load_data(_config.moderation.data)
  local settings = data[tostring(msg.to.id)]['settings']
  local text = "SuperGroup settings:\nLock links : "..settings.lock_link.."\nLock flood : "..settings.flood.."\nLock spam :"..settings.lock_spam.."\nLock sticker :"..settings.lock_sticker.."\nPublic : "..settings.public
  return text
end
local function check_member_superrem(cb_extra, success, result)
  vardump(result)
	local receiver = cb_extra.receiver
	local data = cb_extra.data
	local msg = cb_extra.msg
	for k,v in ipairs(result) do
		local member_id = v.peer_id
		if member_id ~= our_id then
		-- Group configuration removal
		data[tostring(msg.to.id)] = nil
		save_data(_config.moderation.data, data)
		local super = 'supergroup'
		if not data[tostring(super)] then
			data[tostring(super)] = nil
			save_data(_config.moderation.data, data)
		end
		data[tostring(super)][tostring(msg.to.id)] = nil
		save_data(_config.moderation.data, data)
		return send_large_msg(receiver, 'Group has been removed')
		end
	end
end
local function group_add(msg)
  if is_super(msg) then
    return "SuperGroup is already added!"
  end
  local data = load_data(_config.moderation.data)
    receiver = get_receiver(msg)
    channel_get_users(receiver, check_member,{receiver=receiver, data=data, msg = msg}) 
end
local function group_rem(msg)
  if not is_super(msg) then
    return "Supergroup is not added!"
  end
  local data = load_data(_config.moderation.data)
    receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver=receiver, data=data, msg = msg})
end
local function set_rules(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'Set group rules to:\n\n'..rules
end
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'No rules available.'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local rules = 'Chat rules:\n'..rules
  return rules
end
local function set_description(msg, data, target, about)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local data_cat = 'description'
  data[tostring(target)][data_cat] = about
  save_data(_config.moderation.data, data)
end
local function get_description(msg, data)
  local data_cat = 'description'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'No description available.'
  end
  local about = data[tostring(msg.to.id)][data_cat]
  local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
  return 'Description for supergroup :'..about
end
local function lock_group_link(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return 'Link posting is already locked'
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Link posting has been locked'
  end
end
local function unlock_group_link(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return 'Link posting is already unlocked'
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Link posting has been unlocked'
  end
end
local function lock_group_flood(msg, data, target)
  if not is_owner(msg) then
    return "Only admins can do it for now"
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return 'Group flood is locked'
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Group flood has been locked'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_owner(msg) then
    return "Only admins can do it for now"
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return 'Group flood is not locked'
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Group flood has been unlocked'
  end
end

local function lock_group_member(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return 'Group members are already locked'
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'Group members has been locked'
end

local function unlock_group_member(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
    return 'Group members are not locked'
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Group members has been unlocked'
  end
end
local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return 'Sticker posting are already locked'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Sticker posting has been locked'
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return 'Sticker posting are already unlocked'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Sticker posting has been unlocked'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return 'Spam detection is already locked'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Spam detection has been locked'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return 'Spam detection is already unlocked'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Spam detection has been unlocked'
  end
end
local function ad_promote(user_id, channel_id)
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_add_mod(channel, user, ok_cb, false)
end
local function dem_demote(user_id, channel_id)
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_rem_mod(channel, user, ok_cb, false)
end
local function addadmin(user_id, channel_id)
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_set_admins(channel, user, ok_cb, false)
end
local function admindem(user_id, channel_id)
  local channel = "channel#"..channel_id
  local user = "user#"..user_id
  channel_rem_admins(channel, user, ok_cb, false)
end
local function promote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'SuperGroup is not added.')
  end
  if data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been promoted.')
end
local function demote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if not data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been demoted.')
end
local function promote_demote_res(extra, success, result)
--vardump(result)
--vardump(extra)
    local member_id = result.id
    local member_username = "@"..result.username
    local channel_id = extra.channel_id
    local mod_cmd = extra.mod_cmd
    local receiver = "channel#"..channel_id
    if mod_cmd == 'promote' then
		return promote(receiver, member_username, member_id)
		return ad_promote(member_id, channel_id)
    elseif mod_cmd == 'demote' then
		return demote(receiver, member_username, member_id)
		return dem_demote(member_id, channel_id)
	elseif mod_cmd == "setadmin" then
		send_large_msg(receiver, member_username..' has been added as admin in supergroup')
		return addadmin(member_id, channel_id)
	elseif mod_cmd == "demoteadmin" then
		send_large_msg(receiver, member_username..' has been demoted from admin')
		admindem(member_id, channel_id)
	end
end
local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  if matches[1] == "add" then
    return group_add(msg)
  end
  if matches[1] == "rem" then
    return group_rem(msg)
  end
  if matches[1] == "lock" then
    local target = msg.to.id
	if matches[2] == "links" then
	  return lock_group_link(msg, data, target)
	end
	if matches[2] == "spam" then
	  return lock_group_spam(msg, data, target)
	end
	if matches[2] == "flood" then
	  return lock_group_flood(msg, data, target)
	end
	if matches[2] == "sticker" then
	  return lock_group_sticker(msg, data, target)
	end
	if matches[2] == "member" then
	  return lock_group_member(msg, data, target)
	end
  end
  if matches[1] == "unlock" then
    local target = msg.to.id
	if matches[2] == "links" then
	  return unlock_group_link(msg, data, target)
	end
	if matches[2] == "spam" then
	  return unlock_group_spam(msg, data, target)
	end
	if matches[2] == "flood" then
	  return unlock_group_flood(msg, data, target)
	end
	if matches[2] == "sticker" then
	  return unlock_group_sticker(msg, data, target)
	end
	if matches[2] == "member" then
	  return unlock_group_member(msg, data, target)
	end
  end
  if matches[1] == "settings" then
    return show_settings(msg, data)
  end
  if matches[1] == "setrules" then
    local data = load_data(_config.moderation.data)
	rules = matches[2]
	local target = msg.to.id
	return set_rules(msg, data, target)
  end
  if matches[1] == "setabout" then
	local data = load_data(_config.moderation.data)
	local target = msg.to.id
	local about = matches[2]
	set_about("channel#id"..target, about, ok_cb, false)
	return set_desciption(msg, data, target, about)
	reply_msg(msg.id, "Description has been set to:\n\n"..about..'\n\n*Select chat to see!')
  end
  if matches[1] == "rules" then
	return get_rules(msg, data)
  end
  if matches[1] == "about" then
	return get_description(msg, data)
  end
  if matches[1] == "promote" then
	if not is_owner(msg) then
	  return "Only owner can promote"
	end
	local cbres_extra = {
	  channel_id = msg.to.id,
      mod_cmd = 'promote',
	}
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	return resolve_username(username, promote_demote_res, cbres_extra)
  end
  if matches[1] == "demote" then
	if not is_owner(msg) then
	  return "Only owner can demote!"
	end
	local cbres_extra = {
	  channel_id = msg.to.id,
	  mod_cmd = 'demote',
	}
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	return resolve_username(username, promote_demote_res, cbres_extra)
  end
  if matches[1] == "setadmin" then
	if not is_admin(msg) then
	  return "Only bot admin can do it for now"
	end
	local cbres_extra = {
	  channel_id = msg.to.id,
	  mod_cmd = 'setadmin',
	}
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	resolve_username(username, promote_demote_res, cbres_extra)
  end
  if matches[1] == "demoteadmin" then
	if not is_admin(msg) then
	  return "Only bot admins can do it for now!"
	end
	local cbres_extra = {
	  channel_id = msg.to.id,
	  mod_cmd = 'demoteadmin',
	}
	local username = matches[2]
	local username = string.gsub(matches[2], "@", "")
	resolve_username(username, promote_demote_res, cbres_extra)
  end
end

return {
  patterns = {
    "^[/!#](add)$",
	"^[/!#](rem)$",
	"^[/!#](settings)$",
	"^[/!#](lock) (.*)$",
	"^[/!#](unlock) (.*)$",
	"^[/!#](promote) (.*)$",
	"^[/!#](demote) (.*)$",
	"^[/!#](setadmin) (.*)$",
	"^[/!#](demoteadmin) (.*)$",
	"^[/!#](setabout) (.*)$",
	"^[/!#](rules)$",
	"^[/!#](about)$",
  },
  run = run
}

end
