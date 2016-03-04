do
  local function reload_plugins(msg)
    plugins = {}
    load_plugins()
    return reply_msg(msg.id, "Reloaded!",ok_cb, false)
  end
function run(msg, matches)

if matches[1] == 'reload' then
    if not is_sudo(msg) then
       return "Only sudo"
    end


return reload_plugins(msg)

    end
  
end

return {
  patterns = {
    "^[!/#](reload)$"
  },
  run = run
}
end