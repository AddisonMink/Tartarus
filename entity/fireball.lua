FIREBALL_SPRITE = 61
FIREBALL_SPRITE_2 = 62
FIREBALL_ACCEL = 0.2
FIREBALL_DURATION = 2
FIREBALL_FPS = 8

function fireball_new(x, y, facing)
    return {
        body = body_new(x, y, true),
        hitbox = hitbox_new("enemy", 1 + player_attack_bonus(), 2, 2, 4, 4),
        facing = facing,
        sprite = FIREBALL_SPRITE,
        color = state_flags[STATE_FLAG_GREEN_SWORD] and 15 or state_flags[STATE_FLAG_RED_SWORD] and 8,
        timer = FIREBALL_DURATION,
        x_vel = 0.5 * facing,
        update = fireball_update
    }
end

function fireball_update(self)
    tick_down(self, "timer")
    self.sprite = alternate(FIREBALL_SPRITE, FIREBALL_SPRITE_2, FIREBALL_FPS)
    if self.timer <= 0 then
        del(entities, self)
    end

    self.x_vel += FIREBALL_ACCEL * self.facing
    self.body.x += self.x_vel
end