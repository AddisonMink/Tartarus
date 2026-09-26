MAGIC_STONE_SPRITE = 52
MAGIC_STONE_SPEED_X = 1
MAGIC_STONE_SPEED_Y = -1
MAGIC_STONE_DURATION = 2

function magic_stone_new(x, y, facing, layer, color)
    local body = body_new(x, y - 1)
    body.vx = facing * MAGIC_STONE_SPEED_X
    body.vy = MAGIC_STONE_SPEED_Y

    return {
        body = body,
        hitbox = hitbox_new(layer, 1, 1, 1, 6, 6),
        sprite = MAGIC_STONE_SPRITE,
        color = color,
        state = "flying",
        timer = 0,
        update = magic_stone_update
    }
end

function magic_stone_update(self)
    local body = self.body

    if self.state == "flying" and body_grounded(body) then
        self.state = "grounded"
        body.vx = 0
        body.vy = 0
        self.hitbox = nil
        self.timer = MAGIC_STONE_DURATION
        rock_body = body
    elseif self.state == "grounded" then
        tick_down(self, "timer")
        if self.timer <= 0 then
            add(entities, poof_new(body.x, body.y))
            del(entities, self)
            rock_body = nil
        end
    end
end