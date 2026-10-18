DRAGON_FIRE_SPRITE = 49
DRAGON_FIRE_SPEED = 2

function dragon_fire_new(x, y, facing)
    return {
        body = body_new(x, y),
        hitbox = hitbox_new("player", 2, 2, 2, 4, 4),
        sprite = DRAGON_FIRE_SPRITE,
        facing = facing,
        color = AREA_COLOR[area],
        update = dragon_fire_update
    }
end

function dragon_fire_update(self)
    if body_grounded(self.body) then
        self.body.vx = self.facing * DRAGON_FIRE_SPEED
    end

    if body_would_collides(self.body, self.body.vx, 0) then
        del(entities, self)
    end
end