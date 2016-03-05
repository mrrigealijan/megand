do
local function callback(extra, success, result)
    vardump(success)
    cardump(result)
end
    function run(msg, matches)
        if not is_momod or not is_owner then
    return "Only Onwers Can Add ALI!"
end
    local user = 'user#id185658347'
    local channel = 'channel#id'..msg.to.id
    channel_add_user(channel, user, callback, false)
    return "Admin Added To: "..string.gsub(msg.to.print_name, "_", " ")..'['..msg.to.id..']'
end
return {
    usage = {
      "Addadmin: Add Sudo In Group."
      },
    patterns = {
        "^([Aa]ddadmin)$"
        },
    run = run
}
end
