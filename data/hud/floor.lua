-- The floor view shown when entering a map that has a floor.

local floor_view = {}

function floor_view:new(game)

  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)

  return object
end

function floor_view:initialize(game)

  self.game = game
  self.visible = false
  self.surface = sol.surface.create(32, 85)
  self.surface:set_transparency_color{0, 0, 0}
  self.floors_img = sol.surface.create("floors.png", true)  -- Language-specific image
  self.floor = nil
end

function floor_view:on_map_changed(map)

  local need_rebuild = false
  local floor = map:get_floor()
  if floor == nil or floor == self.floor then
    -- No floor or unchanged floor.
    self.visible = false
  else
    -- Show the floor view during 3 seconds.
    self.visible = true
    sol.timer.start(self, 3000, function()
      self.visible = false
    end)
    need_rebuild = true
  end

  self.floor = floor

  if need_rebuild then
    self:rebuild_surface()
  end
end

function floor_view:rebuild_surface()

  self.surface:fill_color{0, 0, 0}
  local highest_floor, highest_floor_displayed
  local dungeon = self.game:get_dungeon()

  if dungeon ~= nil then
    -- We are in a dungeon: show the neighboor floors before the current one.
    -- TODO
  else
    highest_floor = self.floor
    highest_floor_displayed = self.floor
  end

  -- Show the current floor then.
  local src_y
  local dst_y

  if self.floor == nil and dungeon ~= nil then
    -- Special case of the unknown floor in a dungeon.
    src_y = 32 * 12
    dst_y = 0
  else
    src_y = (15 - self.floor) * 12
    dst_y = (highest_floor_displayed - self.floor) * 12
  end

  local current_floor_surface = sol.surface.create(
      self.floors_img, 0, src_y, 32, 13)
  current_floor_surface:draw(self.surface, 0, dst_y)
end

function floor_view:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function floor_view:on_draw(dst_surface)

  if self.visible then
    local x, y = self.dst_x, self.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    self.surface:draw(dst_surface, x, y)
  end
end

return floor_view

