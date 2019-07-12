local map = ...
local game = map:get_game()

---------------------------
-- Kakariko City houses  --
---------------------------

if game:get_value("i1026")==nil then game:set_value("i1026", 0) end
if game:get_value("i1651")==nil then game:set_value("i1651", 0) end
if game:get_value("i1806")==nil then game:set_value("i1806", 0) end
if game:get_value("i1830")==nil then game:set_value("i1830", 0) end
if game:get_value("i1918")==nil then game:set_value("i1918", 0) end
if game:get_value("i1919")==nil then game:set_value("i1919", 0) end
if game:get_value("i1920")==nil then game:set_value("i1920", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if not game:has_item("bomb_bag") then
    if item_bomb_1 ~= nil then item_bomb_1:remove() end
    if item_bomb_2 ~= nil then item_bomb_2:remove() end
    if item_bomb_3 ~= nil then item_bomb_3:remove() end
  end
  
  if game:get_time_of_day() == "night" then
    npc_rowin:remove()
    npc_moriss:remove()
    npc_etnaya:remove()
    
    if game:get_value("b1812") then
      quest_bottle:remove() --if bottle already obtained, remove the quest and bottle
      bottle:remove()
      sensor_bottle:remove()
      wall_bottle:remove()
      npc_strap:remove() -- Strap is at the pub
    else
      bottle:remove() --bottle is missing at night, hence the quest
      sensor_bottle:remove()
      wall_bottle:remove()
      np2_strap:remove() -- Strap's NPC at the pub
    end
    
    -- Activate any night-specific dynamic tiles
    for entity in map:get_entities("night_") do
      entity:set_enabled(true)
    end
  else
    quest_bottle:remove() -- Quest only available at night
    np2_strap:remove() -- Strap's NPC at the pub
    if game:get_value("b1812") then
      bottle:remove()
      sensor_bottle:remove()
      wall_bottle:remove()
    end
    random_walk(npc_etnaya)
  end
  
  if destination ~= inn_bed then
    snores:set_enabled(false)
    bed:set_enabled(false)
  end
  
  if game:get_value("i1651") ~= 4 then
    npc_horwin:remove()
  end
  
  -- Replace shop items if they're bought
  if game:get_value("i1820") >= 2 then --shield
    self:create_shop_treasure({
	name = "shop_item_4",
	layer = 0,
	x = 112,
	y = 112,
	price = 40,
	dialog = "_item_description.bow.2",
	treasure_name = "arrow",
	treasure_variant = 3
    })
  end
  if game:get_value("b2017") then --bomb_bag
    self:create_shop_treasure({
	name = "shop_item_5",
	layer = 0,
	x = 160,
	y = 112,
	price = 40,
	dialog = "_item_description.bomb_counter.1",
	treasure_name = "bomb",
	treasure_variant = 3
    })
  end
end

function inn_bed:on_activated()
  game:switch_time_of_day()
  snores:set_enabled(true)
  bed:set_enabled(true)
  bed:get_sprite():set_animation("hero_sleeping")
  bed:get_sprite():set_direction(game:get_value("tunic_equipped") - 1)
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    snores:remove()
    bed:get_sprite():set_animation("hero_waking")
    bed:get_sprite():set_direction(game:get_value("tunic_equipped") - 1)
    sleep_timer = sol.timer.start(1000, function()
      hero:set_visible(true)
      hero:start_jumping(0, 24, true)
      bed:get_sprite():set_animation("empty_open")
      sol.audio.play_sound("hero_lands")
    end)
    sleep_timer:set_with_sound(false)
  end)
end

npc_strap:register_event("on_interaction", function()
  if game:get_time_of_day() == "night" and not game:get_value("b1812") then
    game:start_dialog("strap.0.night", function()
      if quest_bottle ~= nil then quest_bottle:remove() end
      game:set_value("i1612", 1)
    end)
  else
    if math.random(4) == 1 and game:get_item("rupee_bag"):get_variant() < 2 then
      -- Randomly mention the bigger wallet
      game:start_dialog("shopkeep.1")
    else
      game:start_dialog("shopkeep.0")
    end
  end
end)
np2_strap:register_event("on_interaction", function()
  game:start_dialog("strap.0.pub")
end)

npc_warbos:register_event("on_interaction", function()
  if math.random(4) == 1 and game:get_item("rupee_bag"):get_variant() < 2 then
    -- Randomly mention the bigger wallet
    game:start_dialog("shopkeep.1")
  else
    game:start_dialog("shopkeep.0")
  end
end)

npc_etnaya:register_event("on_interaction", function()
  local rand = math.random(4)
  if rand == 1 then
    -- Randomly mention the show
    game:start_dialog("etnaya.0.show")
  else
    game:start_dialog("etnaya.0")
  end
end)

npc_gartan:register_event("on_interaction", function()
  game:start_dialog("gartan.0.pub")
end)

npc_moriss:register_event("on_interaction", function()
  if game:get_value("i1920") > 0 then
    game:start_dialog("moriss.1.pub", game:get_player_name())
  else
    game:start_dialog("moriss.0.pub", function()
      game:set_value("i1919", 1)
    end)
  end
end)

npc_rowin:register_event("on_interaction", function()
  if game:get_value("i1920") >= 2 then
    game:start_dialog("rowin.2.pub")
  else
    game:start_dialog("rowin.0.pub", function()
      game:set_value("i1920", 1)
    end)
  end
end)

npc_architect:register_event("on_interaction", function()
  if game:get_value("i1651") == 4 then
    game:start_dialog("architect.3.house")
    sol.timer.start(game, 180000, function()
      -- After a real-time half hour, the carpenter will return to the bridge.
      game:set_value("i1651", 5)
    end)
  elseif game:get_value("i1651") == 3 then
    game:start_dialog("architect.2.house")
    sol.timer.start(game, 180000, function()
      -- After a real-time half hour, the carpenter will come to the city.
      game:set_value("i1651", 4)
    end)
  elseif game:get_value("i1651") == 2 then
    game:start_dialog("architect.1.house")
    game:set_value("i1651", 3)
    sol.timer.start(game, 180000, function()
      -- After a real-time half hour, the carpenter will come to the city.
      game:set_value("i1651", 4)
    end)
  else
    game:start_dialog("architect.0.house")
    game:set_value("i1651", 1)
  end
end)

npc_horwin:register_event("on_interaction", function()
  game:start_dialog("rito_carpenter.2.kakariko")
  sol.timer.start(game, 360000, function()
    -- After a real-time hour, the carpenter will return to the bridge
    game:set_value("i1651", 5)
  end)
end)

function npc_garroth_sensor:on_interaction()
  game:set_dialog_name("Garroth")
  if game:get_value("i1918") <= 5 then
    if (game:get_value("i1918") >= 0 and game:get_value("i1918") <= 1 and game:get_time_of_day() == "day") or game:get_value("i1918") >= 3 then
      game:start_dialog("garroth."..game:get_value("i1918")..".pub", function()
        game:set_value("i1918", game:get_value("i1918")+1)
      end)
    elseif game:get_value("i1918") <= 5 and game:get_time_of_day() == "night" then
      game:start_dialog("garroth."..game:get_value("i1918")..".pub", function()
        game:set_value("i1918", game:get_value("i1918")+1)
      end)
    else
      game:start_dialog("garroth.0.pub")
    end
  else
    if game:get_value("i1830") >= 75 and game:get_value("i1918") == 8 then
      game:start_dialog("garroth.8.alchemy", game:get_value("i1830"), function()
        hero:start_treasure("heart_piece", 1, "b1726")
        game:set_value("i1918", 9)
        game:set_value("i1653", 4)
      end)
    elseif game:get_value("i1830") >= 50 and game:get_value("i1918") == 7 then
      game:start_dialog("garroth.7.alchemy", game:get_value("i1830"), function()
        hero:start_treasure("rupee", 5)
        game:set_value("i1918", 8)
        game:set_value("i1653", 3)
      end)
    elseif game:get_value("i1830") >= 25 and game:get_value("i1918") == 6 then
      game:start_dialog("garroth.6.alchemy", game:get_value("i1830"), function()
        hero:start_treasure("rupee", 4)
        game:set_value("i1918", 7)
        game:set_value("i1653", 2)
      end)
    else
      game:start_dialog("garroth.5.pub", function() game:set_value("i1653", 1) end)
    end
  end
end

npc_turt:register_event("on_interaction", function()
  game:start_dialog("turt.0.behind_counter")
end)

function npc_turt_sensor:on_interaction()
  game:set_dialog_name("Turt")
  game:start_dialog("turt.0.inn", function(answer)
    if answer == 1 then
      game:remove_money(20)
      hero:teleport("4", "inn_bed", "fade")
      game:set_life(game:get_max_life())
      game:set_stamina(game:get_max_stamina())
      if game:get_value("i1026") < 2 then game:set_max_stamina(game:get_max_stamina()-20) end
      if game:get_value("i1026") > 5 then game:set_max_stamina(game:get_max_stamina()+20) end
      game:set_value("i1026", 0)
    end
  end)
end

function sensor_bottle:on_activated()
  game:start_dialog("strap.0.bottle")
end

function npc_kakariko_1:on_interaction()
  game:start_dialog("hylian_1.0.kakariko")
end

function npc_kakariko_2:on_interaction()
  if math.random(2) == 1 then
    game:start_dialog("hylian_2.1.kakariko")
  else
    game:start_dialog("hylian_2.0.kakariko")
  end
end

function npc_kakariko_3:on_interaction()
  game:start_dialog("hylian_3.0.kakariko")
end