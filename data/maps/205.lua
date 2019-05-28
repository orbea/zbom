local map = ...
local game = map:get_game()
local warned = false
local magic_counter = 0
local draw_counter = 0

local shadow = sol.surface.create(1696, 1760)
local lights = sol.surface.create(1696, 1760)
shadow:set_blend_mode("multiply")
lights:set_blend_mode("add")

--------------------------------------
-- Dungeon 4: Mountaintop Mausoleum --
--------------------------------------

if game:get_value("i1029") == nil then game:set_value("i1029", 0) end

function map:on_started(destination)
  if game:get_value("i1029") <= 4 then
    npc_goron_ghost:remove()
  elseif game:get_value("i1029") == 5 then
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(32)
    m:start(npc_goron_ghost)
  elseif game:get_value("i1029") >= 6 then
    dampeh_1:remove()
    dampeh_2:remove()
    npc_goron_ghost:remove()
    if npc_dampeh ~= nil then npc_dampeh:remove() end
  end

  map:set_doors_open("door_miniboss")
  if not game:get_value("b1102") then chest_key_3:set_enabled(false) end
  if not game:get_value("b1103") then chest_key_4:set_enabled(false) end
  if not game:get_value("b1105") then chest_compass:set_enabled(false) end
  if not game:get_value("b1106") then chest_map:set_enabled(false) end
  if not game:get_value("b1107") then miniboss_arrghus:set_enabled(false) end
  if not game:get_value("b1108") then chest_big_key:set_enabled(false) end
  if not game:get_value("b1110") then
    vire:set_enabled(false)
    boss_vire_sorceror:set_enabled(false)
    -- Dodongos appear after the boss is defeated.
    map:set_entities_enabled("dodongo", false)
  else
    if npc_dampeh ~= nil then npc_dampeh:remove() end
  end
  if not game:get_value("b1111") then chest_alchemy:set_enabled(false) end
  if game:get_value("b1113") or game:get_value("b1114") then map:set_doors_open("door_shutter_key2") end
  if not game:get_value("b1117") then chest_book:set_enabled(false) end
  if not game:get_value("b1118") then boss_heart:set_enabled(false) end
  if not game:get_value("b1119") then chest_rupees:set_enabled(false) end
  if game:get_value("b1699") then
    -- End of game: mine is reopened!
    for enemy in map:get_entities_by_type("enemy") do
      enemy:remove()
    end
    map:set_entities_enabled("statue", false)
    map:set_entities_enabled("chest", false)
  else
    npc_dargor:remove()
    map:set_entities_enabled("mine", false)
  end
end

npc_dampeh:register_event("on_interaction", function()
  if game:get_value("i1029") == 5 then
    game:set_dialog_name("Dampeh")
    game:start_dialog("dampeh.1.mausoleum", function()
      game:set_value("i1029", 6)
      npc_dampeh:get_sprite():set_animation("walking")
      local m = sol.movement.create("target")
      m:set_target(232, 1712)
      m:set_speed(24)
      m:start(npc_dampeh, function()
        npc_dampeh:remove(); dampeh_1:remove(); dampeh_2:remove()
        sol.audio.play_sound("ghost"); game:set_dialog_name("Ghost of Osgor")
        game:start_dialog("osgor.2.mausoleum")
      end)
    end)
  else
    game:start_dialog("dampeh.0.mausoleum")
  end
end)

npc_dargor:register_event("on_interaction", function()
  game:start_dialog("dargor.5.mine")
end)

function sensor_miniboss:on_activated()
  if miniboss_arrghus ~= nil then
    map:close_doors("door_miniboss")
    miniboss_arrghus:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if miniboss_arrghus ~= nil then
 function miniboss_arrghus:on_dead()
  map:open_doors("door_miniboss")
  sol.audio.play_sound("boss_killed")
  sol.timer.start(2000, function()
    chest_big_key:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end)
  sol.audio.play_music("temple_mausoleum")
 end
end

function sensor_boss:on_activated()
  if boss_vire_sorceror ~= nil then
    map:close_doors("door_boss")
    vire:set_enabled(true)
    boss_vire_sorceror:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_vire_sorceror ~= nil then
 function boss_vire_sorceror:on_dead()
  map:open_doors("door_boss")
  sol.audio.play_sound("boss_killed")
  boss_heart:set_enabled(true)
  chest_book:set_enabled(true)
  sol.audio.play_sound("chest_appears")
  sol.audio.play_music("temple_mausoleum")
  sol.timer.start(2000, function()
    game:set_dialog_name("Vire Sorceror")
    game:start_dialog("_mausoleum_outro", function()
      map:set_entities_enabled("dodongo", true)
    end)
  end)
 end
end

function door_key2_1:on_opened()
  map:set_doors_open("door_shutter_key2")
end
function door_key1_1:on_opened()
  map:set_doors_open("door_shutter_key2")
end

for enemy in map:get_entities("tektite_key3") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_key3") and not game:get_value("b1102") then
      chest_key_3:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end
for enemy in map:get_entities("tektite_key4") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_key4") and not game:get_value("b1103") then
      map:move_camera(200, 285, 250, function()
        chest_key_4:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 250, 250)
    end
  end
end
for enemy in map:get_entities("tektite_map") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_map") and not game:get_value("b1106") then
      map:move_camera(1304, 861, 250, function()
        chest_map:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 250, 250)
    end
  end
end
for enemy in map:get_entities("tektite_compass") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_compass") and not game:get_value("b1105") then
      map:move_camera(1304, 1149, 250, function()
        chest_compass:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 250, 250)
    end
  end
end

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("keese_rupees") and not game:get_value("b1119") then
      chest_rupees:set_enabled(true)
      bridge_rupees:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("dodongo") do
  enemy.on_dead = function()
    if not map:has_entities("dodongo_alchemy") and not game:get_value("b1111") then
      map:move_camera(1456, 589, 250, function()
        chest_alchemy:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 250, 250)
    end
  end
end

function map:on_draw(dst_surface)
  local x,y = map:get_camera():get_position()
  local w,h = map:get_camera():get_size()
  if not game:get_value("b1117") then
  -- If dungeon hasn't been defeated then the lights are out! 
  if draw_counter >= 10 then
    lights:clear()
    shadow:fill_color({032,064,128,128})
    for e in map:get_entities("statue_") do
      if e:get_distance(game:get_hero()) <= 300 then
        local xx,yy = e:get_position()
        local sp = sol.sprite.create("entities/torch_light")
        sp:set_blend_mode("blend")
        sp:draw(lights, xx-32, yy-40)
      end
    end
    for e in map:get_entities("lava_") do
      if e:get_distance(game:get_hero()) <= 300 then
        local xx,yy = e:get_position()
        local sp = sol.sprite.create("entities/torch_light_tile")
        sp:set_blend_mode("blend")
        sp:draw(lights, xx-8, yy-8)
      end
    end
    for e in map:get_entities("torch_") do
      if e:get_sprite():get_animation() == "lit" and e:get_distance(game:get_hero()) <= 300 then
        local xx,yy = e:get_position()
        local sp = sol.sprite.create("entities/torch_light")
        sp:set_blend_mode("blend")
        sp:draw(lights, xx-32, yy-40)
      end
    end
    
    -- Lantern more quickly drains magic here so you're forced to find ways to refill magic.
    if magic_counter >= 20 and not game:is_paused() then
      game:remove_magic(1)
      magic_counter = 0
    end
    magic_counter = magic_counter + 1

    if game:has_item("lamp") and game:get_magic() > 0 then
      local xx,yy = map:get_entity("hero"):get_position()
      local sp = sol.sprite.create("entities/torch_light_hero")
      sp:set_blend_mode("blend")
      sp:draw(lights, xx-64, yy-64)
      warned = false
    elseif not warned then
      game:start_dialog("_cannot_see_need_magic")
      warned = true
    end
    draw_counter = 0
  end
  lights:draw_region(x,y,w,h,shadow,x,y)
  shadow:draw_region(x,y,w,h,dst_surface)
  draw_counter = draw_counter + 1
  end
end

function chest_book:on_opened(item, variant, savegame_variable)
  -- Dynamically determine book variant to give, since dungeons can be done in any order.
  local book_variant = game:get_item("book_mudora"):get_variant() + 1
  map:get_hero():start_treasure("book_mudora", book_variant)
  game:set_dungeon_finished(4)
  game:set_value("i1029", 6)
  game:set_value("b1117", true) -- This value varies depending on the dungeon (chest save value)
end