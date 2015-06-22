local enemy = ...

-- A whirlwind shot by another enemy

function enemy:on_created()
  self:set_life(1)
  self:set_damage(4)
  self:create_sprite("enemies/whirlwind")
  self:set_size(48, 64)
  self:set_origin(24, 31)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_optimization_distance(0)
  self:set_minimum_shield_needed(3)  -- Mirror shield protects hero
end

function enemy:on_restarted()
  sol.audio.play_sound("wind")
  -- By default, go to where the hero is now.
  local x, y = self:get_map():get_entity("hero"):get_position()
  x = x + math.random(-32, 32)
  y = y + math.random(-32, 32)
  local m = sol.movement.create("target")
  m:set_speed(144)
  m:set_target(x, y)
  m:set_ignore_obstacles(false)
  m:start(self)
  sol.timer.start(self, 2000, function() self:on_movement_finished() end)
end

function enemy:on_movement_finished(movement)
  sol.timer.start(self, 25000, function() 
    self:remove()
  end)
end

function enemy:go(angle)
  local m = sol.movement.create("straight")
  m:set_speed(192)
  m:set_angle(angle)
  m:set_max_distance(320)
  m:start(self)
end