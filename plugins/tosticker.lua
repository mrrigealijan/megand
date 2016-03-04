local function callback(extra, success, result)
  if success then
    print('File downloaded to:', result)
    os.rename(result, "media/sticker.webp")
    print('File moved to:', "media/sticker.webp")
  else
    print('Error downloading: '..extra)
  end
end

local function run(msg, matches)
  if msg.media then
    if msg.media.type == 'photo' then
      load_photo(msg.id, callback, msg.id)
    end
  end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end

  return msg

end

return {
  description = "",
  usage = "",
  run = run,
  patterns = {
    '%[(photo)%]',
    "^[!/#]reply$"
  },
  pre_process = pre_process
}
