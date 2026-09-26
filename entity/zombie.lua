ZOMBIE_SPRITE = 6
ZOMBIE_SPRITE_WALK = 7
ZOMBIE_FPS = 2
ZOMBIE_SPEED = 0.5
ZOMBIE_HP = 3

function zombie_new(tx, ty)
    return {
        body = body_new(tx * 8, ty * 8),
        hurtbox = hurtbox_new("enemy", ZOMBIE_HP, 1, 1, 6, 6),
        hitbox = hitbox_new("player", 1, 2, 2, 4, 4),
        sprite = ZOMBIE_SPRITE,
        facing = 1,
        update = zombie_update
    }
end

function zombie_update(self)
    local turn = body_would_collides(self.body, self.facing, 0)
            or not body_would_collides(self.body, self.facing * 8, 1)

    self.sprite = alternate(ZOMBIE_SPRITE_WALK, ZOMBIE_SPRITE, ZOMBIE_FPS)

    if turn then
        self.facing = -self.facing
    end

    self.body.vx = self.facing * ZOMBIE_SPEED
end