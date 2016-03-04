do
local function block_word(receiver, wordblock)
    local chat_id = string.gsub(receiver, '.+#id', '')
    local data = load_data(_config.moderation.data)
    data[tostring(chat_id)]['blocked_words'][(wordblock)] = true
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, wordblock..'has been locked')
end

local function unblock_word(receiver, wordblock)
    local chat_id = string.gsub(receiver, '.+#id', '')
    local data = load_data(_config.moderation.data)
    if data[tostring(chat_id)]['blocked_words'][wordblock] then
        data[tostring(chat_id)]['blocked_words'][(wordblock)] = nil
        save_data(_config.moderation.data, data)
        send_large_msg(receiver, wordblock..' has been unlocked')
    else
        --send_large_msg(receiver, 'Word "'..wordblock..'" isn\'t in lock list.')
    end
end
local function is_word_allowed(chat_id,text)
  local var = true
  local data = load_data(_config.moderation.data)
  if not data[tostring(chat_id)] then
      return true
  end
  local wordlist = ''
  if data[tostring(chat_id)]['blocked_words'] then
    for k,v in pairs(data[tostring(chat_id)]['blocked_words']) do 
        if string.find(string.lower(text), string.lower(k)) then
            return false
        end
    end
  end
  return var
end

local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if matches[1] == "lockword" then 
    if not is_momod(msg) then
      return "For mods only"
    end
    return block_word(receiver, matches[2])
  end
  if matches[1] == "unlockword" then
    if not is_momod(msg) then
      return "For mods only"
    end
    return unblock_word(receiver, matches[2])
  end
  if msg.text then
    if not is_word_allowed(msg.to.id, msg.text) then
      delete_msg(msg.id, ok_cb, true)
    end
  end
  if matches[1] == "locklist" then
    local text = 'Lock word for ['..msg.to.title..']:\n\n'
    local i = 1
    for k,v in pairs(data[tostring(msg.to.id)]['blocked_words']) do
      text = text ..i..'- '..k..'\n'
      i = i + 1
    end 
    return text
  end
end

local function pre_process(msg)
  if is_word_allowed(msg.to.id,msg.text) and is_momod(msg) then
    print("word alowed")
  else
    print('not allowed')
    delete_msg(msg.id, ok_cb, false)
  end
  return msg
end
return {
  patterns = {
    "^[/!#](lockword) (.*)$",
    "^[/!#](unlockword) (.*)$",
    "^[/!#](locklist)$"
  },
  run = run,
  pre_process = pre_process
}
end
