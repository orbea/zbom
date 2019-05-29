local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------
-- Outside World C7 (Desert Expanse) - Kakariko Graveyard and Zuna Astronomer --
--------------------------------------------------------------------------------

local catch = 0
local caught = false
local last_position

-- Possible positions where the thief runs to.
local positions = {
  {x = 848, y = 405},
  {x = 656, y = 405},
  {x = 752, y = 501},
  {x = 944, y = 501},
  {x = 848, y = 597},
  {x = 656, y = 597},
  {x = 752, y = 693},
  {x = 848, y = 693},
  {x = 928, y = 677},
  {x = 616, y = 349},
  {x = 608, y = 813},
  {x = 1024, y = 597},
  {x = 1064, y = 437},
  {x = 1016, y = 309}
}

function map:on_started(destination)
  local entrance_names = { "house" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 3 then
        sol.audio.play_music("gerudo")
      end
    end
  end
  if game:get_value("i1612") == nil or game:get_value("i1612") > 1 then
    thief:remove()  -- If not ready for the thief game, or already have the bottle.
  end
  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function sensor_enter_kakariko:on_activated()
  sol.audio.play_music("town_kakariko")
  sensor_enter_desert:set_enabled(false)
  sol.timer.start(sensor_enter_kakariko,2000,function()
    sensor_enter_desert:set_enabled(true)
  end)
end
function sensor_enter_desert:on_activated()
  sol.audio.play_music("gerudo")
  sensor_enter_kakariko:set_enabled(false)
  sol.timer.start(sensor_enter_desert,2000,function()
    sensor_enter_kakariko:set_enabled(true)
  end)
end

function thief_caught()
  local tx,ty,tl = thief:get_position()
  map:create_pickable({ x=tx, y=ty, layer=0, treasure_name="bottle_3", treasure_savegame_variable="b1812" })
  game:start_dialog("thief.2.bottle")
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(true)
  m:set_smooth(true)
  m:set_target(680,1120)
  m:set_speed(184)
  m:start(thief, function()
    thief:remove()
    game:set_value("i1612", 2)
  end)
end

function thief:on_interaction()
  local position = (positions[math.random(#positions)])
  if position == last_position then
    local position = (positions[math.random(#positions)])
  end
  last_position = position
  local m = sol.movement.create("target")
  m:set_target(position.x, position.y)
  m:set_smooth(true); m:set_speed(184)
  sol.audio.play_sound("hero_seen")
  m:start(thief)
  
  if catch == 0 then
    catch = catch + 1
    game:start_dialog("thief.0.bottle", function()
      sol.timer.start(map, 1000, function() caught = false end)
    end)
  elseif catch >= 10 then
    thief_caught()
  else
    catch = catch + 1
    game:start_dialog("thief.1.bottle", 11-catch, function()
      sol.timer.start(map, 1000, function() caught = false end)
    end)
  end

  thief_timer = sol.timer.start(map, 1000, function()
    if game:get_value("i1612") == 1 then
      if map:get_hero():get_distance(thief) <= 50 and not caught then
        thief:on_interaction()
        caught = true
      end
    end
    return true
  end)
end