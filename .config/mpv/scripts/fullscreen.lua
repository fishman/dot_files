function xautolock()
  os.execute("xautolock -disable && xautolock -enable")
end

function on()
    if not is_on then
      timer = mp.add_periodic_timer(10, xautolock)
      is_on = true
    end
end

function off()
    if is_on then
      mp.cancel_timer(timer)
      is_on = false
    end
end

function toggle()
  if is_on then
    off()
  else
    on()
  end
end

is_on = false
function on_pause_change(name, value)
  if value == true then
    mp.set_property("fullscreen", "no")
    off()
  else
    on()
  end
end
-- mp.observe_property("pause", "bool", on_pause_change)
