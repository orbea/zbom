local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World F5 (Septen Heights) --
---------------------------------------

if game:get_value("i1926")==nil then game:set_value("i1926", 0) end
if game:get_value("i1927")==nil then game:set_value("i1927", 0) end
if game:get_value("i1928")==nil then game:set_value("i1928", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_rito_1)
  random_walk(npc_rito_3)
  if game:is_dungeon_finished(7) then
    bridge_1:set_enabled(true)
    bridge_2:set_enabled(true)
    bridge_3:set_enabled(true)
    bridge_4:set_enabled(true)
  elseif game:get_value("i1926") >= 2 and game:get_value("i1927") >= 2 then
    npc_rito_carpenter:remove()
  end
end

function npc_rito_1:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("rito_1.0.septen")
end

function npc_rito_2:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1928") >= 1 then
    if game:get_value("i1840") < 5 then
      game:start_dialog("rito_2.1.septen")
    else
      game:start_dialog("rito_2.0.septen")
    end
  else
    game:start_dialog("rito_2.0.septen", function()
      game:set_value("i1928", 1)
    end)
  end
end

function npc_rito_3:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1150") then
    game:start_dialog("rito_3.1.septen")
  else
    game:start_dialog("rito_3.0.septen")
  end
end

function npc_rito_carpenter:on_interaction()
  game:set_dialog_style("default")
  if game:is_dungeon_finished(7) then
    game:start_dialog("rito_carpenter.2.septen")
  elseif game:get_value("i1926") >= 1 then
    game:start_dialog("rito_carpenter.1.septen")
    game:set_value("i1927", 2)
  else
    game:start_dialog("rito_carpenter.0.septen")
    game:set_value("i1927", 1)
  end
end

function sign_tower:on_interaction()
  if game:get_value("b1150") then -- Tower under construction until after Snowpeak
    game:set_dialog_style("wood")
    game:start_dialog("sign.tower")
  else
    game:set_dialog_style("wood")
    game:start_dialog("sign.tower_construction")
  end
end