SQUID_SPRITE = 90
SQUID_SPRITE_2 = 92
SQUID_FPS = 2
SQUID_HP = 20
SQUID_SPEED = 0.5

function squid_new(tx, ty, kill_flag)
    if state_flags[kill_flag] then return end

    return {
        body = body_new(tx * 8, ty * 8, true),
        hurtbox = hurtbox_new("enemy", SQUID_HP, -3, -7, 14, 7),
        hitbox = hitbox_new("player", 1, 2, -6, 4, 12),
        facing = 1,
        big_sprite = SQUID_SPRITE,
        update = squid_update,
        die = function(self)
            state_flags[kill_flag] = true
        end
    }
end

function squid_update(self)
    if body_would_collides(self.body, self.facing * SQUID_SPEED, 0) then
        self.facing *= -1
    end

    self.big_sprite = alternate(SQUID_SPRITE, SQUID_SPRITE_2, SQUID_FPS)
    self.body.x += self.facing * SQUID_SPEED
end

function squid_1_new(tx, ty)
    return squid_new(tx, ty, STATE_FLAG_SQUID_1)
end